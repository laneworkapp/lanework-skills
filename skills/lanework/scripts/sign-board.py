#!/usr/bin/env python3
# sign-board.py: leave this plugin's signature in a board, for the Lanework app to read. Python 3, standard library only.
"""sign-board.py: write <board>/.plugin.lanework-signature, which tells the sandboxed app which plugin version works the board.

    sign-board.py <board>

Called by every board-writing script after its write has landed (lib.sh sign_board; the two heal scripts by path).
Frontmatter only: schema, kind, name, version and written always; installed, updated, commit, scope and agent when found.
- Only on a board with the app's seeded .gitignore (a line `.*.lanework-*`, which keeps the file out of git). A board the
  app has never opened has none: nothing written.
- name, version: the .claude-plugin/plugin.json found walking up from this file's real path (a symlinked skill folder reads
  what it points at). None found: nothing written.
- installed, updated, commit (7 hex), scope: Claude Code's install record (LANEWORK_PLUGINS_FILE, else
  ${CLAUDE_CONFIG_DIR:-~/.claude}/plugins/installed_plugins.json), the `<name>@...` entry whose installPath is this plugin's root.
- agent: claude-code when CLAUDECODE=1.
- Every value passes an allow-list (a plain word, a version, a UTC timestamp, hex) or its key is left out: never a path,
  a user name or a host name.
- Rewritten only when a key other than `written` changed, through a temp file in the board (it fits `.*.lanework-*` too)
  and os.replace; the temp file is removed on any failure.
Exit 0 always, nothing on stdout or stderr: a signature never fails the write it follows. LANEWORK_SIGNATURE_DEBUG=1: the
reason it wrote nothing, on stderr."""
import datetime, json, os, re, sys

NAME = ".plugin.lanework-signature"
PATTERN = ".*.lanework-*"
ORDER = ("name", "version", "installed", "updated", "commit", "scope", "agent")
WORD = re.compile(r"[a-z][a-z0-9-]{0,63}")
VERSION = re.compile(r"[0-9][0-9A-Za-z.+-]{0,63}")
SCOPE = re.compile(r"[a-z]{1,32}")
SHA = re.compile(r"[0-9a-fA-F]{7,64}")
STAMP = re.compile(r"(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)(\.\d+)?(Z|[+-]\d\d:\d\d)")


def note(msg):
    if os.environ.get("LANEWORK_SIGNATURE_DEBUG") == "1":
        sys.stderr.write("sign-board.py: %s\n" % msg)


def match(rx, v):
    return v if isinstance(v, str) and rx.fullmatch(v) else None


def utc(v):
    """An install record's time as whole-second UTC with Z, or None."""
    m = STAMP.fullmatch(v) if isinstance(v, str) else None
    if not m:
        return None
    try:
        t = datetime.datetime(*(int(m.group(i)) for i in range(1, 7)), tzinfo=datetime.timezone.utc)
    except ValueError:
        return None
    z = m.group(8)
    if z != "Z":
        off = datetime.timedelta(hours=int(z[1:3]), minutes=int(z[4:6]))
        t = t - off if z[0] == "+" else t + off
    return t.strftime("%Y-%m-%dT%H:%M:%SZ")


def plugin_root():
    d = os.path.dirname(os.path.realpath(__file__))
    while True:
        if os.path.isfile(os.path.join(d, ".claude-plugin", "plugin.json")):
            return d
        up = os.path.dirname(d)
        if up == d:
            return None
        d = up


def install_facts(root, name):
    path = os.environ.get("LANEWORK_PLUGINS_FILE") or os.path.join(
        os.environ.get("CLAUDE_CONFIG_DIR") or os.path.join(os.path.expanduser("~"), ".claude"), "plugins", "installed_plugins.json")
    try:
        with open(path, encoding="utf-8") as f:
            plugins = json.load(f).get("plugins")
    except (OSError, ValueError, AttributeError) as e:
        note("no install record: %s" % type(e).__name__)
        return {}
    if not isinstance(plugins, dict):
        return {}
    for key, entries in plugins.items():
        if not isinstance(key, str) or key.split("@", 1)[0] != name or not isinstance(entries, list):
            continue
        for e in entries:
            p = e.get("installPath") if isinstance(e, dict) else None
            if isinstance(p, str) and p and os.path.realpath(p) == root:
                sha = match(SHA, e.get("gitCommitSha"))
                return {"installed": utc(e.get("installedAt")), "updated": utc(e.get("lastUpdated")),
                        "commit": sha[:7].lower() if sha else None, "scope": match(SCOPE, e.get("scope"))}
    return {}


def render(found, written):
    lines = ["---", "schema: 1", "kind: plugin-signature"]
    for k in ORDER:
        if found.get(k):
            lines.append('%s: "%s"' % (k, found[k]) if k == "version" else "%s: %s" % (k, found[k]))
    return "\n".join(lines + ["written: " + written, "---", ""])


def unwritten(text):
    return re.sub(r"(?m)^written: .*\n", "", text)


def main(argv):
    if len(argv) != 1:
        return note("usage: sign-board.py <board>")
    board = argv[0]
    if not os.path.isfile(os.path.join(board, "index.md")):
        return note("not a board")
    try:
        with open(os.path.join(board, ".gitignore"), encoding="utf-8") as f:
            seeded = PATTERN in (line.strip() for line in f)
    except (OSError, ValueError):
        seeded = False
    if not seeded:
        return note("no seeded .gitignore listing %s" % PATTERN)
    root = plugin_root()
    if root is None:
        return note("no .claude-plugin/plugin.json above this script")
    with open(os.path.join(root, ".claude-plugin", "plugin.json"), encoding="utf-8") as f:
        manifest = json.load(f)
    found = {"name": match(WORD, manifest.get("name")), "version": match(VERSION, manifest.get("version"))}
    if not found["name"] or not found["version"]:
        return note("plugin.json gives no usable name or version")
    found.update(install_facts(root, found["name"]))
    if os.environ.get("CLAUDECODE") == "1":
        found["agent"] = "claude-code"
    new = render(found, datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    target = os.path.join(board, NAME)
    try:
        with open(target, encoding="utf-8") as f:
            if unwritten(f.read()) == unwritten(new):
                return None
    except (OSError, ValueError):
        pass
    tmp = "%s.%d.tmp" % (target, os.getpid())   # still fits .*.lanework-*
    try:
        fd = os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(new)
        os.replace(tmp, target)
    finally:
        if os.path.lexists(tmp):
            os.unlink(tmp)


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except Exception as e:   # a signature never fails the write it follows
        note("%s: %s" % (type(e).__name__, e))
    sys.exit(0)
