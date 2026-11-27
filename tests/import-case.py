#!/usr/bin/env python3
"""import-case.py: the import skill's smoke case. Exit non-zero on the first failed assertion.

usage: tests/import-case.py <scratch dir> [--update]
  --update rewrites tests/fixtures/import/expected/ from the scripts' current output (review the diff).
No test touches the network: sockets are blocked for the whole run and attachment fetching is a fake.
Contains its own small checker of Lanework CSV (not shipped): the contract in the docs' reference/csv page.
"""
import csv
import importlib.util
import io
import json
import os
import py_compile
import re
import shutil
import socket
import subprocess
import sys

sys.dont_write_bytecode = True  # importing the scripts must leave no __pycache__ in the repo
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPTS = os.path.join(ROOT, "skills", "import", "scripts")
FIX = os.path.join(ROOT, "tests", "fixtures", "import")
EXPECTED = os.path.join(FIX, "expected")


def die(msg):
    print("import-case: " + msg)
    sys.exit(1)


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), os.path.join(SCRIPTS, name + ".py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# ---- the checker -------------------------------------------------------------------------------

KINDS = {
    "board": ["title", "icon", "config", "template"],
    "lane": ["title", "icon", "order", "width", "collapsed", "presentation", "group", "filter", "card-defaults", "locked"],
    "card": ["title", "icon", "order", "background", "labels", "due", "hero", "waiting", "start", "end", "cite-as"],
    "comment": ["reactions", "in-reply-to", "moved"],
    "attachment": ["title", "extension"],
    "relation": ["rel", "to", "suspect"],
}
PARENT = {"board": None, "lane": ["board"], "card": ["lane"], "comment": ["card"], "attachment": ["card", "comment"], "relation": ["card"]}
BODY_KINDS = ["lane", "card", "comment", "relation"]
ONE_LINE = ["title", "labels", "due", "start", "end", "created", "modified", "order", "extension", "file"]


def real_date(s):
    import datetime
    import re
    m = re.match(r"^(\d{4})-(\d\d)-(\d\d)(?:T(\d\d):(\d\d):(\d\d)Z)?$", s)
    if not m:
        return False
    try:
        p = [int(g) for g in m.groups() if g is not None]
        datetime.date(*p[:3])
        if len(p) > 3:
            datetime.datetime(*p)
        return True
    except ValueError:
        return False


def check_csv(folder):
    """Return a list of problems with <folder>/board.csv."""
    bad = []
    path = os.path.join(folder, "board.csv")
    raw = open(path, "rb").read()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        return ["not UTF-8"]
    rows = list(csv.reader(io.StringIO(text, newline="")))
    if not rows:
        return ["no header"]
    head = rows[0]
    for c in ("kind", "uuid", "parent"):
        if c not in head:
            bad.append("missing column " + c)
    if len(set(head)) != len(head):
        bad.append("repeated column")
    if bad:
        return bad
    recs = []
    for n, r in enumerate(rows[1:], 2):
        if len(r) > len(head):
            bad.append("row %d: more cells than the header" % n)
            continue
        recs.append((n, dict(zip(head, r + [""] * (len(head) - len(r))))))
    by_id = {}
    for n, r in recs:
        if r["kind"] not in KINDS:
            bad.append("row %d: unknown kind %r" % (n, r["kind"]))
        elif not r["uuid"]:
            bad.append("row %d: no uuid" % n)
        elif r["uuid"] in by_id:
            bad.append("row %d: repeated uuid %s" % (n, r["uuid"]))
        else:
            by_id[r["uuid"]] = r
    if sum(1 for _, r in recs if r["kind"] == "board") != 1:
        bad.append("want exactly one board row")
    for n, r in recs:
        k = r["kind"]
        if k not in KINDS:
            continue
        if PARENT[k] is None:
            if r["parent"]:
                bad.append("row %d: board has a parent" % n)
        elif r["parent"] not in by_id or by_id[r["parent"]]["kind"] not in PARENT[k]:
            bad.append("row %d: %s parent %r is missing or of the wrong kind" % (n, k, r["parent"]))
        allowed = set(["kind", "uuid", "parent", "created", "modified"] + KINDS[k])
        if k in BODY_KINDS:
            allowed.add("body")
        if k == "attachment":
            allowed.add("file")
        for c in head:
            if r[c] and c not in allowed:
                bad.append("row %d: %s filled on a %s" % (n, c, k))
            if r[c] and c in ONE_LINE and "\n" in r[c]:
                bad.append("row %d: %s spans lines" % (n, c))
        for c in ("due", "start", "end"):
            if r.get(c) and not real_date(r[c]):
                bad.append("row %d: %s %r is not a real date" % (n, c, r[c]))
        for c in ("created", "modified"):
            if r.get(c) and not zoned_stamp(r[c]):
                bad.append("row %d: %s %r is not a map with a zoned at" % (n, c, r[c]))
        if r.get("order"):
            try:
                float(r["order"])
            except ValueError:
                bad.append("row %d: order is not a number" % n)
        if r.get("labels") and not label_list(r["labels"]):
            bad.append("row %d: labels %r is not a list of {text, kind}" % (n, r["labels"]))
        if k == "attachment":
            f = r.get("file", "")
            root = os.path.realpath(folder)
            if not f or os.path.isabs(f) or ".." in f.split("/"):
                bad.append("row %d: file %r is empty or leaves the folder" % (n, f))
            else:
                p = os.path.join(folder, f)
                if not os.path.isfile(p):
                    bad.append("row %d: file %r missing" % (n, f))
                parts, cur = f.split("/"), folder
                for seg in parts:
                    cur = os.path.join(cur, seg)
                    if os.path.islink(cur):
                        bad.append("row %d: a symbolic link in %r" % (n, f))
                if not os.path.realpath(p).startswith(root + os.sep):
                    bad.append("row %d: file %r leaves the folder" % (n, f))
    return bad


def zoned_stamp(cell):
    """A stamp cell: a JSON map whose `at` is a timestamp with a time and a zone."""
    try:
        v = json.loads(cell)
    except ValueError:
        return False
    return isinstance(v, dict) and isinstance(v.get("at"), str) and bool(
        re.match(r"^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(\.\d+)?(Z|[-+]\d\d(:?\d\d)?)$", v["at"])) and real_date(v["at"][:10])


def label_list(cell):
    """A labels cell: a JSON list of maps, each with a text and a kind that names its type."""
    try:
        v = json.loads(cell)
    except ValueError:
        return False
    return isinstance(v, list) and bool(v) and all(
        isinstance(e, dict) and isinstance(e.get("text"), str) and e["text"].strip()
        and isinstance(e.get("kind"), dict) and isinstance(e["kind"].get("type"), str) for e in v)


def must_be_valid(folder, what):
    bad = check_csv(folder)
    if bad:
        die("%s: board.csv fails the contract check:\n  %s" % (what, "\n  ".join(bad)))
    print("ok - %s: board.csv passes the contract check" % what)


def checker_self_test():
    t = os.path.join(SCRATCH, "checker")
    cases = {
        "bad-parent": "kind,uuid,parent\nboard,b,\ncard,c,b\n",
        "two-boards": "kind,uuid,parent\nboard,b,\nboard,b2,\n",
        "due-on-lane": "kind,uuid,parent,due\nboard,b,,\nlane,l,b,2026-01-01\n",
        "title-on-comment": "kind,uuid,parent,title\nboard,b,,B\nlane,l,b,L\ncard,c,l,C\ncomment,m,c,x\n",
        "fake-date": "kind,uuid,parent,due\nboard,b,,\nlane,l,b,\ncard,c,l,2026-02-30\n",
        "no-uuid-col": "kind,parent\nboard,\n",
        "label-short-form": "kind,uuid,parent,labels\nboard,b,,\nlane,l,b,\ncard,c,l,Priority: High\n",
        "bare-stamp": "kind,uuid,parent,created\nboard,b,,\nlane,l,b,\ncard,c,l,2026-11-09T10:00:00Z\n",
        "stamp-no-zone": "kind,uuid,parent,created\nboard,b,,\nlane,l,b,\ncard,c,l,\"{\"\"at\"\": \"\"2026-11-09T10:00:00\"\"}\"\n",
    }
    for name, body in cases.items():
        d = os.path.join(t, name)
        os.makedirs(d)
        open(os.path.join(d, "board.csv"), "w").write(body)
        if not check_csv(d):
            die("checker self-test: %s was not caught" % name)
    d = os.path.join(t, "good")
    os.makedirs(d)
    open(os.path.join(d, "board.csv"), "w").write(
        "kind,uuid,parent,title,body,labels,due\nboard,b1,,R,,,\nlane,l1,b1,T,,,\ncard,c1,l1,F,\"B, md\",\"[{\"\"text\"\": \"\"High\"\", \"\"kind\"\": {\"\"type\"\": \"\"priority\"\"}}, {\"\"text\"\": \"\"urgent\"\", \"\"kind\"\": {\"\"type\"\": \"\"text\"\"}}]\",2026-12-01\ncomment,m1,c1,,Ok,,\n")
    if check_csv(d):
        die("checker self-test: the docs example was refused: %s" % check_csv(d))
    print("ok - checker: refuses 7 broken files, accepts the docs example")


# ---- helpers -----------------------------------------------------------------------------------

def run_main(mod, argv, fetch=None):
    out, err = io.StringIO(), io.StringIO()
    so, se = sys.stdout, sys.stderr
    sys.stdout, sys.stderr = out, err
    try:
        try:
            rc = mod.main(argv) if fetch is None else mod.main(argv, fetch=fetch)
        except SystemExit as e:
            rc = e.code
    finally:
        sys.stdout, sys.stderr = so, se
    return rc, out.getvalue(), err.getvalue()


def compare(folder, name, update):
    got = open(os.path.join(folder, "board.csv"), "rb").read()
    path = os.path.join(EXPECTED, name)
    if update:
        os.makedirs(EXPECTED, exist_ok=True)
        open(path, "wb").write(got)
        print("updated " + path)
        return
    want = open(path, "rb").read()
    if got != want:
        sys.stdout.write("--- got ---\n" + got.decode("utf-8") + "--- want ---\n" + want.decode("utf-8"))
        die("board.csv differs from expected/%s" % name)
    print("ok - board.csv equals expected/%s byte for byte" % name)


def need(cond, msg):
    if not cond:
        die(msg)


def tree(folder):
    out = []
    for d, _, names in os.walk(folder):
        for n in names:
            out.append(os.path.relpath(os.path.join(d, n), folder))
    return sorted(out)


# ---- the run -----------------------------------------------------------------------------------

def main():
    global SCRATCH
    args = [a for a in sys.argv[1:] if a != "--update"]
    update = "--update" in sys.argv[1:]
    if len(args) != 1:
        print(__doc__)
        sys.exit(2)
    SCRATCH = os.path.abspath(args[0])
    shutil.rmtree(SCRATCH, ignore_errors=True)
    os.makedirs(SCRATCH)

    # nothing here reaches the network: any socket connection fails the run
    def no_net(*a, **k):
        raise AssertionError("a test reached the network")
    socket.socket.connect = no_net
    socket.create_connection = no_net
    socket.getaddrinfo = no_net

    checker_self_test()

    trello = load("trello-to-lanework-csv")
    obs = load("obsidian-kanban-to-lanework-csv")
    tj = os.path.join(FIX, "trello.json")
    vault = os.path.join(FIX, "vault")
    board = os.path.join(vault, "Project Board.md")

    # compile both, with the cache redirected so nothing lands in the repo
    cache = os.path.join(SCRATCH, "pycache")
    for s in ("trello-to-lanework-csv.py", "obsidian-kanban-to-lanework-csv.py"):
        r = subprocess.run([sys.executable, "-m", "py_compile", os.path.join(SCRIPTS, s)],
                           env=dict(os.environ, PYTHONPYCACHEPREFIX=cache), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        need(r.returncode == 0, "py_compile %s: %s" % (s, r.stdout.decode()))
        r = subprocess.run([sys.executable, os.path.join(SCRIPTS, s), "--help"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        need(r.returncode == 0 and b"usage:" in r.stdout, "%s --help" % s)
        r = subprocess.run([sys.executable, os.path.join(SCRIPTS, s)], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        need(r.returncode == 2 and b"Traceback" not in r.stderr, "%s with no arguments exits 2, got %d" % (s, r.returncode))
    print("ok - both scripts compile, answer --help, and exit 2 with no arguments")

    # Trello, default: no fetch may happen
    def forbidden(url, max_bytes):
        raise AssertionError("fetch called without --attachments: " + url)
    o = os.path.join(SCRATCH, "t1")
    rc, out, err = run_main(trello, [tj, "--out", o], fetch=forbidden)
    need(rc == 0, "trello default run failed: rc %s %s" % (rc, err))
    need(tree(o) == ["board.csv"], "trello default run wrote more than board.csv: %s" % tree(o))
    need("1 archived lists" in out and "1 archived cards" in out and "1 cards in archived lists" in out, "trello summary lacks the archive counts:\n" + out)
    need("1 uploaded attachments not fetched" in out and "always left out: members" in out, "trello summary lacks the left-out lines:\n" + out)
    compare(o, "trello.csv", update)
    must_be_valid(o, "trello default")

    # Trello, with --include-archived
    o = os.path.join(SCRATCH, "t2")
    rc, out, err = run_main(trello, [tj, "--out", o, "--include-archived"], fetch=forbidden)
    need(rc == 0 and "3 lanes" in out and "5 cards" in out, "include-archived counts:\n" + out)
    must_be_valid(o, "trello --include-archived")

    # Trello, --attachments with a fake fetcher: only the uploaded one is asked for, one https GET, nothing else
    calls = []

    def fake(url, max_bytes):
        calls.append((url, max_bytes))
        return b"\x89PNG fake bytes"
    o = os.path.join(SCRATCH, "t3")
    rc, out, err = run_main(trello, [tj, "--out", o, "--attachments", "--max-attachment-bytes", "1000"], fetch=fake)
    need(rc == 0, "trello --attachments failed: %s" % err)
    need(calls == [("https://trello.com/1/cards/cd1/attachments/at1/download/Mockup.png", 1000)], "fetch calls were %s" % calls)
    need(tree(o) == ["assets/Mockup.png", "board.csv"], "trello --attachments tree: %s" % tree(o))
    need(open(os.path.join(o, "assets", "Mockup.png"), "rb").read() == b"\x89PNG fake bytes", "asset bytes")
    need("1 attachments" in out, "summary lacks the attachment count:\n" + out)
    compare(o, "trello-attachments.csv", update)
    must_be_valid(o, "trello --attachments")

    # a fetch that fails: listed in the summary, the link stays in the body, no asset
    def failing(url, max_bytes):
        raise trello.FetchError("HTTP 401 (needs a login?)")
    o = os.path.join(SCRATCH, "t4")
    rc, out, err = run_main(trello, [tj, "--out", o, "--attachments"], fetch=failing)
    need(rc == 0 and "could not be fetched" in out and "HTTP 401" in out and tree(o) == ["board.csv"], "failed fetch handling:\n" + out)
    must_be_valid(o, "trello failed fetch")

    # the real fetcher refuses anything but https before any network use, and a redirect off https
    for u in ("http://example.com/a.png", "file:///etc/passwd", "ftp://example.com/a"):
        try:
            trello.default_fetch(u, 100)
            die("default_fetch accepted " + u)
        except trello.FetchError:
            pass
    h = trello._HttpsOnly()
    for u in ("file:///etc/passwd", "http://example.com/x", "ftp://example.com/x"):
        try:
            h.redirect_request(None, None, 302, "Found", {}, u)
            die("a redirect to %s was followed" % u)
        except trello.FetchError:
            pass
    print("ok - the real fetcher takes https only and refuses a redirect to another scheme")

    # file names from a remote: no separators, no dots first, unique
    used = set()
    names = [trello.safe_name(n, used) for n in ("../../etc/passwd", "a/b\\c.png", ".hidden", "x.png", "x.png", "")]
    need(names == ["passwd", "c.png", "hidden", "x.png", "x-2.png", "attachment"], "safe_name gave %s" % names)
    print("ok - remote file names are one safe path segment")

    # Obsidian, with the vault
    o = os.path.join(SCRATCH, "o1")
    rc, out, err = run_main(obs, [board, "--vault", vault, "--out", o])
    need(rc == 0, "obsidian run failed: %s" % err)
    need(tree(o) == ["assets/shot.png", "board.csv"], "obsidian tree: %s" % tree(o))
    need(open(os.path.join(o, "assets", "shot.png"), "rb").read() == open(os.path.join(vault, "media", "shot.png"), "rb").read(), "copied picture differs")
    for want in ("1 notes taken as card bodies", "1 attachments", "matches several notes", "no such note", "path leaves the vault", "1 cards in the Archive section", "settings block"):
        need(want in out, "obsidian summary lacks %r:\n%s" % (want, out))
    compare(o, "obsidian.csv", update)
    must_be_valid(o, "obsidian with vault")

    # without the vault: links and embeds stay text
    o = os.path.join(SCRATCH, "o2")
    rc, out, err = run_main(obs, [board, "--out", o])
    need(rc == 0 and tree(o) == ["board.csv"] and "(no --vault)" in out, "obsidian without vault:\n" + out + err)
    compare(o, "obsidian-novault.csv", update)
    must_be_valid(o, "obsidian without vault")

    # the archive
    o = os.path.join(SCRATCH, "o3")
    rc, out, err = run_main(obs, [board, "--vault", vault, "--out", o, "--include-archive"])
    need(rc == 0 and "Archive section" not in out and "3 lanes" in out, "include-archive:\n" + out)
    need(b"Old card" in open(os.path.join(o, "board.csv"), "rb").read(), "the archived card is missing with --include-archive")
    must_be_valid(o, "obsidian --include-archive")

    # confinement: symlinks inside a vault that point out are never read
    ev = os.path.join(SCRATCH, "evil")
    os.makedirs(os.path.join(ev, "vault"))
    secret = os.path.join(ev, "secret.md")
    open(secret, "w").write("TOP SECRET NOTE\n")
    open(os.path.join(ev, "secret.png"), "wb").write(b"SECRET PICTURE")
    os.symlink(secret, os.path.join(ev, "vault", "leak.md"))
    os.symlink(os.path.join(ev, "secret.png"), os.path.join(ev, "vault", "leak.png"))
    os.symlink(ev, os.path.join(ev, "vault", "dirlink"))
    open(os.path.join(ev, "vault", "inside.md"), "w").write("inside text\n")
    os.symlink(os.path.join(ev, "vault", "inside.md"), os.path.join(ev, "vault", "alias.md"))
    kb = os.path.join(ev, "vault", "Evil.md")
    open(kb, "w").write("## Lane\n\n- [ ] [[leak]]\n- [ ] Pic ![[leak.png]]\n- [ ] Deep ![[dirlink/secret.png]]\n- [ ] [[alias]]\n- [ ] [[../secret]]\n")
    o = os.path.join(SCRATCH, "o4")
    rc, out, err = run_main(obs, [kb, "--vault", os.path.join(ev, "vault"), "--out", o])
    need(rc == 0, "confinement run failed: %s" % err)
    blob = b"".join(open(os.path.join(o, p), "rb").read() for p in tree(o))
    need(b"SECRET" not in blob, "a file outside the vault was read")
    need(tree(o) == ["board.csv"], "confinement: assets written: %s" % tree(o))
    need("refused (path leaves the vault)" in out, "confinement summary:\n" + out)
    need("note links refused" in out and "embeds refused" in out, "refusals not counted:\n" + out)
    need(b"inside text" in open(os.path.join(o, "board.csv"), "rb").read(), "a symlink that stays inside the vault should still resolve")
    must_be_valid(o, "obsidian confinement")
    print("ok - symlinks that leave the vault, '..' paths and symlinked folders are refused and counted; nothing outside is read")

    # refuse a folder that holds anything; an empty one is fine; the folder is left untouched
    for mod, argv in ((trello, [tj]), (obs, [board])):
        d = os.path.join(SCRATCH, "taken-" + mod.__name__)
        os.makedirs(d)
        open(os.path.join(d, "mine.txt"), "w").write("keep")
        rc, out, err = run_main(mod, argv + ["--out", d])
        need(rc == 2 and "not an empty folder" in err and tree(d) == ["mine.txt"], "%s into a non-empty folder: rc %s %s" % (mod.__name__, rc, err))
        f = os.path.join(SCRATCH, "afile-" + mod.__name__)
        open(f, "w").write("x")
        rc, out, err = run_main(mod, argv + ["--out", f])
        need(rc == 2, "%s into a file: rc %s" % (mod.__name__, rc))
        e = os.path.join(SCRATCH, "empty-" + mod.__name__)
        os.makedirs(e)
        rc, out, err = run_main(mod, argv + ["--out", e])
        need(rc == 0 and "board.csv" in tree(e), "%s into an empty folder: rc %s %s" % (mod.__name__, rc, err))
    print("ok - a folder holding anything is refused (exit 2) and left as it was; an empty one is used")

    # bad input exits 2
    bad = os.path.join(SCRATCH, "bad.json")
    open(bad, "w").write("{not json")
    for mod, argv in ((trello, [bad]), (trello, [os.path.join(SCRATCH, "nope.json")]), (obs, [os.path.join(SCRATCH, "nope.md")])):
        rc, out, err = run_main(mod, argv + ["--out", os.path.join(SCRATCH, "never")])
        need(rc == 2 and not os.path.exists(os.path.join(SCRATCH, "never")) and "Traceback" not in err, "bad input: rc %s %s" % (rc, err))
    plain = os.path.join(SCRATCH, "plain.md")
    open(plain, "w").write("just text\n")
    rc, out, err = run_main(obs, [plain, "--out", os.path.join(SCRATCH, "never")])
    need(rc == 2, "a file with no lanes exits 2, got %s" % rc)
    print("ok - unreadable or foreign input exits 2 and writes nothing")
    print("import-case: all passed")


if __name__ == "__main__":
    main()
