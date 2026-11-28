#!/usr/bin/env python3
# sign-board.py: leave this plugin's signature in a board, for the Lanework app to read. Python 3, standard library only.
"""sign-board.py: write <board>/.plugin.lanework-signature, which tells the sandboxed app which plugin version works the board.

    sign-board.py <board>

Called by every board-writing script after its write has landed (lib.sh sign_board; the two heal scripts by path).
Frontmatter only: schema, kind, name, version and written always; installed, updated, commit, scope and agent when found.
- Only on a board with the app's seeded .gitignore (a line `.*.lanework-*`, trailing blanks allowed, which keeps the file out
  of git). A board the app has never opened has none: nothing written.
- name, version: the .claude-plugin/plugin.json found walking up from this file's real path (a symlinked skill folder reads
  what it points at). None found: nothing written.
- installed, updated, commit (7 hex), scope: Claude Code's install record (LANEWORK_PLUGINS_FILE, else
  ${CLAUDE_CONFIG_DIR:-~/.claude}/plugins/installed_plugins.json), the `<name>@...` entry whose installPath is this plugin's root.
- agent: claude-code when CLAUDECODE=1.
- Every value passes an allow-list (a plain word, a version, a UTC timestamp, hex) or its key is left out: never a path,
  a user name or a host name. A value that fails its check, or raises, leaves out that key alone.
- Only regular files are read: the .gitignore, plugin.json and the install record may be symlinks to one, the signature
  never is (a symlink there is replaced, never read through). Anything else at the signature's path (a FIFO, a socket, a
  device) is left as it is, unsigned; anything else as the .gitignore: unsigned; as the record: no install facts.
- Rewritten when a key other than `written` changed, or `written` is missing or not a UTC stamp, through a temp file in the
  board (it fits `.*.lanework-*` too) and os.replace; the temp file is removed on any failure.
Exit 0 always given one board, nothing on stdout or stderr: a signature never fails or blocks the write it follows.
LANEWORK_SIGNATURE_DEBUG=1: the reason it wrote nothing, on stderr. exit 2 usage: no argument or more than one, the usage line on
stderr (every caller ignores the status: lib.sh sign_board ends `|| true`, the heal scripts swallow it)."""
import datetime, json, os, re, stat, sys

NAME = ".plugin.lanework-signature"
PATTERN = ".*.lanework-*"
ORDER = ("name", "version", "installed", "updated", "commit", "scope", "agent")
WORD = re.compile(r"[a-z][a-z0-9-]{0,63}")
VERSION = re.compile(r"[0-9][0-9A-Za-z.+-]{0,63}")
SCOPE = re.compile(r"[a-z]{1,32}")
SHA = re.compile(r"[0-9a-fA-F]{7,64}")
STAMP = re.compile(r"(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)(\.\d+)?(Z|[+-]\d\d:\d\d)", re.ASCII)
WRITTEN = re.compile(r"written: \d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ", re.ASCII)


def note(msg):
    if os.environ.get("LANEWORK_SIGNATURE_DEBUG") == "1":
        sys.stderr.write("sign-board.py: %s\n" % msg)


def read_regular(path, follow=True):
    """The text of path when it is a regular file (follow: through a symlink), else None. Never opens anything else, so a
    FIFO or a device never blocks; O_NONBLOCK and the fstat cover a file swapped in after the stat."""
    try:
        if not stat.S_ISREG((os.stat if follow else os.lstat)(path).st_mode):
            return None
        fd = os.open(path, os.O_RDONLY | os.O_NONBLOCK | (0 if follow else os.O_NOFOLLOW))
    except (OSError, ValueError):
        return None
    with os.fdopen(fd, "rb") as f:
        if not stat.S_ISREG(os.fstat(f.fileno()).st_mode):
            return None
        return f.read().decode("utf-8")


def match(rx, v):
    return v if isinstance(v, str) and rx.fullmatch(v) else None


def utc(v):
    """An install record's time as whole-second UTC with Z, or None: an offset beyond +-14:00, minutes over 59, or a time
    that overflows on conversion included."""
    m = STAMP.fullmatch(v) if isinstance(v, str) else None
    if not m:
        return None
    z = m.group(8)
    oh, om = (0, 0) if z == "Z" else (int(z[1:3]), int(z[4:6]))
    if om > 59 or oh * 60 + om > 14 * 60:
        return None
    try:
        t = datetime.datetime(*(int(m.group(i)) for i in range(1, 7)), tzinfo=datetime.timezone.utc)
        off = datetime.timedelta(hours=oh, minutes=om)
        if z[0] == "+":
            t -= off
        elif z[0] == "-":
            t += off
    except (ValueError, OverflowError):
        return None
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
        text = read_regular(path)
        plugins = json.loads(text).get("plugins") if text is not None else None
    except (ValueError, AttributeError) as e:
        note("no install record: %s" % type(e).__name__)
        return {}
    if not isinstance(plugins, dict):
        return {}
    for key, entries in plugins.items():
        if not isinstance(key, str) or key.split("@", 1)[0] != name or not isinstance(entries, list):
            continue
        for e in entries:
            p = e.get("installPath") if isinstance(e, dict) else None
            try:
                mine = isinstance(p, str) and p != "" and os.path.realpath(p) == root
            except (ValueError, OSError):   # a NUL in the path: not this plugin's entry
                mine = False
            if not mine:
                continue
            out = {}
            for k, get in (("installed", lambda: utc(e.get("installedAt"))), ("updated", lambda: utc(e.get("lastUpdated"))),
                           ("commit", lambda: (match(SHA, e.get("gitCommitSha")) or "")[:7].lower() or None),
                           ("scope", lambda: match(SCOPE, e.get("scope")))):
                try:
                    out[k] = get()
                except Exception as err:   # one bad value leaves out its own key, never the file
                    note("%s left out: %s" % (k, type(err).__name__))
            return out
    return {}


def render(found, written):
    lines = ["---", "schema: 1", "kind: plugin-signature"]
    for k in ORDER:
        if found.get(k):
            lines.append('%s: "%s"' % (k, found[k]) if k == "version" else "%s: %s" % (k, found[k]))
    return "\n".join(lines + ["written: " + written, "---", ""])


def current(old, new):
    """True when old is new apart from a well-formed `written` line: exactly one, a whole-second UTC stamp."""
    lines = old.split("\n")
    w = [i for i, l in enumerate(lines) if l.startswith("written:")]
    if len(w) != 1 or not WRITTEN.fullmatch(lines[w[0]]):
        return False
    del lines[w[0]]
    return "\n".join(lines) == re.sub(r"(?m)^written: .*\n", "", new)


def main(argv):
    board = argv[0]
    if not os.path.isfile(os.path.join(board, "index.md")):
        return note("not a board")
    try:
        gi = read_regular(os.path.join(board, ".gitignore"))
    except ValueError:
        gi = None
    if gi is None or PATTERN not in (line.rstrip() for line in gi.split("\n")):
        return note("no seeded .gitignore listing %s" % PATTERN)
    root = plugin_root()
    if root is None:
        return note("no .claude-plugin/plugin.json above this script")
    text = read_regular(os.path.join(root, ".claude-plugin", "plugin.json"))
    manifest = json.loads(text) if text is not None else {}
    found = {"name": match(WORD, manifest.get("name")), "version": match(VERSION, manifest.get("version"))}
    if not found["name"] or not found["version"]:
        return note("plugin.json gives no usable name or version")
    found.update(install_facts(root, found["name"]))
    if os.environ.get("CLAUDECODE") == "1":
        found["agent"] = "claude-code"
    new = render(found, datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    target = os.path.join(board, NAME)
    try:
        mode = os.lstat(target).st_mode
    except OSError:
        mode = None
    if mode is not None and not (stat.S_ISREG(mode) or stat.S_ISLNK(mode) or stat.S_ISDIR(mode)):
        return note("a FIFO, socket or device sits at the signature's path: left as it is")
    try:
        old = read_regular(target, follow=False)   # a symlink is never read through: it is replaced
    except ValueError:
        old = None
    if old is not None and current(old, new):
        return None
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
    if len(sys.argv) != 2:
        sys.stderr.write("usage: sign-board.py <board>\n")
        sys.exit(2)
    try:
        main(sys.argv[1:])
    except Exception as e:   # a signature never fails the write it follows
        note("%s: %s" % (type(e).__name__, e))
    sys.exit(0)
