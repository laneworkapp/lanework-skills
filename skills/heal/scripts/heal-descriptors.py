#!/usr/bin/env python3
# heal-descriptors.py: bring a board's lane bodies and pipeline sheet up to the current templates. Python 3, standard library only.
"""heal-descriptors.py: check that a board's lane bodies name who acts on each lane and what starts it.

    heal-descriptors.py <board>... [--apply --model M [--name N] [--session S]]

Dry run by default: one line per change, `<where>: <code> <what>`, nothing written.
`--apply` writes each changed file (staged outside the board, then moved in) and restamps that
file's `modified` whole with the running agent: `--model` is required (exit 2 without it,
nothing written); `--name` defaults to `claude`, `--session` is optional. Idempotent: a
second run finds nothing.

The source is the template tables, read at run time, never a copy: `lanework/templates/pipeline-lanes.md`,
`design-loop-lanes.md`, `datapoint-lanes.md` and `discovery/templates/lanes.md`, plus the permission
line of `lanework/templates/pipeline-index.md`. A board's lane titles pick the lane set (at
least 75% of a set's titles present, and one set clearly best); no set, no descriptor changes.
The second sentence of a template body is its actor/trigger sentence (`lanework/references/board-kinds.md`).

Per lane of the matched set:
  fill-body          the body is empty: the current template body
  replace-body       the body is the current template's predecessor, word for word (OLD_BODIES): the current body
  insert-actor       a customised body that does not yet say it: the actor/trigger sentence goes after
                     its first sentence. Nothing else is touched, never a replacement
  (nothing)          the body is the current template's, or already carries the sentence word for word
Pipeline boards also get, on the board sheet (`index.md` body):
  insert-permission  the `Agent lanes` bullet, after the `Two human gates` bullet

Never touched: `.trash/`, cards, comments, the guide, `.schema/`, `collapsed`, `order`, `width`, and any lane
whose title is not in the matched set. `skip` lines name what was left for the owner.
"""

import os
import re
import shutil
import sys
import tempfile
from datetime import datetime, timezone

HERE = os.path.dirname(os.path.abspath(__file__))
SKILLS = os.path.normpath(os.path.join(HERE, "..", ".."))        # siblings by relative path: users symlink each skill folder
TEMPLATES = {
    "pipeline": os.path.join(SKILLS, "lanework", "templates", "pipeline-lanes.md"),
    "design-loop": os.path.join(SKILLS, "lanework", "templates", "design-loop-lanes.md"),
    "datapoint": os.path.join(SKILLS, "lanework", "templates", "datapoint-lanes.md"),
    "discovery": os.path.join(SKILLS, "discovery", "templates", "lanes.md"),
}
PIPELINE_INDEX = os.path.join(SKILLS, "lanework", "templates", "pipeline-index.md")
PERMISSION_MARK = "- **Agent lanes**"
ANCHOR_MARK = "- **Two human gates**"
RESERVED_NAMES = {"healer", "shortcuts", "tracker"}
MATCH = 0.75

# Bodies earlier templates shipped, per lane set and lane title. A board founded before a template changed
# carries one of these word for word. Source: `git log -p` of the four lanes tables
# (lanework/templates/{pipeline,design-loop,datapoint}-lanes.md, discovery/templates/lanes.md, and their
# earlier paths under lanework-boards/), every distinct body per lane up to 35ba2ce. When a template body
# changes, add the body it replaces here, in the same commit.
OLD_BODIES = {
    "pipeline": {
        "Ideas": [
            "The inbox and the triage queue. Zero bar to entry, a one-line card is fine. Triage moves each card on to Shaping, or out.",
        ],
        "Issues": [
            "The side entrance for something broken in the running system. An issue skips triage and is shaped or fixed on its own merit.",
        ],
        "Shaping": [
            "The agent work lane. A raw idea is developed here into a proposal with scope, constraints, risks and a recommendation in the body.",
            "The agent work lane. A raw idea is developed here into a proposal with scope, constraints, risks and a recommendation in the body. Once the proposal is finished and its open questions are answered, the agent moves it to Proposed.",
        ],
        "Proposed": [
            "The human review gate. The proposal is finished and waiting on the owner. Agents never move a card out of this lane.",
            "The human review gate. The agent moves a finished proposal in, and it waits here on the owner. Agents never move a card out of this lane.",
        ],
        "Approved": [
            "The ready-to-build queue, ranked in build order, top is next. The spec is frozen, so a scope change bounces the card back to Shaping.",
            "The ready-to-build queue, ranked in build order, top is next. Approving a card is the go-ahead: an agent takes the top card into Active without waiting to be asked. The spec is frozen, so a scope change bounces the card back to Shaping.",
        ],
        "Active": [
            "The build lane. One session holds a card at a time, claiming it with a comment naming the session and the branch.",
        ],
        "Done": [
            "Shipped work. A card arrives when its done-when is met, with a closing comment carrying the evidence.",
        ],
        "Tasks": [
            "The owner's side entrance for small, clear chores. A card the owner files here is already approved, so it is built straight through Active. Agents file the chores they find in Ideas, never here.",
        ],
    },
    "design-loop": {
        "Brief": [
            "The standing reference: the inventory, the constraints, the evidence, and the calls still open.",
        ],
        "Alternatives": [
            "One candidate direction per card, as a paragraph and its reasoning. Agents move cards on to Mockups when there is something to draw.",
        ],
        "Mockups": [
            "Drawn directions. Renders are attached to the card, light and dark, for every variant it lists. A card that shows no picture is not in Mockups.",
        ],
        "Sittings": [
            "The owner has walked the card. Rulings are recorded on it in the owner's words, and a card can loop back to Mockups. Only happens with the owner present.",
        ],
        "Chosen": [
            "The direction that won. Only the owner chooses. It leaves as build cards on a pipeline board, linked both ways.",
        ],
        "Dead ends": [
            "Directions that died, one line each saying why. Collapsed because it is read least and regretted most when lost.",
        ],
    },
    "datapoint": {
        "Brief": [
            "The map: what the record is, where the values are pushed, and what the limits are.",
        ],
        "Ideas": [
            "What is not a card yet. An idea about an existing value is a comment on its card, never a new card.",
        ],
        "Drafting": [
            "The body is ahead of the file: the value is still being written. A card drops back here the moment its body changes.",
        ],
        "Filed": [
            "The body matches the file in the repository, and the live system does not have it yet. Filed in the same commit that writes the file.",
        ],
        "Pushed": [
            "The live system holds exactly what the body says, verified by reading it back. Pushing is the owner's.",
        ],
    },
    "discovery": {
        "Brief": [
            "The two standing references. The Topic card states the scope and what a shared understanding must cover. The Discovery map card is the outline of every decision, grouped by corner of the space, rewritten by the agent at the close of each round, and is the first thing a resuming session reads.",
        ],
        "Facts": [
            "One card per fact the agent established: from the code, the docs, the filesystem, a tool, or the web. The body is the fact and its source; the raw report is an attachment. A fact found wrong gets a dated correction comment, never an edit that hides the first reading.",
        ],
        "Asked": [
            "One card per open question, filed by the agent, waiting on the owner. The body is the question, the options and the recommendation. Answer by commenting on the card or by replying in chat. Only the agent moves a card out, and only once the ruling is written into the body.",
        ],
        "Settled": [
            "Answered questions. The body ends with a dated ruling in the owner's words. This lane is the design record: read it in order to see what was decided and why. A settled question is never edited; a change of mind is a new question in a later round that links this one.",
        ],
        "Parked": [
            "Questions the owner deferred or declined, with the reason as the ruling. Collapsed because it is read least; reopen one by asking it again as a new card that links this one.",
        ],
        "Decisions": [
            "One card per ADR or PDR, filed by the agent straight into this lane from a ruling in Settled. The title starts `ADR:` or `PDR:`, the `Record` and `Status` labels say which and whether it still stands, and line 1 of the body links the question it came from. Cards never leave this lane. A decision overturned keeps its card: it gets the `superseded` status and a dated comment linking its replacement, and the new card links it under Related.",
            "One card per ADR or PDR, filed by the agent straight into this lane from a question's ruling, before the question settles. The title starts `ADR:` or `PDR:`, the `Record` and `Status` labels say which and whether it still stands, and line 1 of the body links the question it came from. Cards never leave this lane. A decision overturned keeps its card: it gets the `superseded` status and a dated comment linking its replacement, and the new card links it under Related.",
        ],
    },
}


UUID = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")
BOUNDARY = re.compile(r"[.!?][\"')\]*`]*\s+(?=[A-Z`\"*(\[])")


def norm(text):
    return re.sub(r"\s+", " ", text).strip().lower()


def read_templates():
    """{set name: [(title, body)]} from the template tables, in file order. A missing file drops its set."""
    sets = {}
    for name, path in TEMPLATES.items():
        try:
            with open(path, encoding="utf-8") as f:
                lines = f.read().split("\n")
        except OSError:
            continue
        rows = []
        for line in lines:
            if re.match(r"\|\s*\d+\s*\|", line):
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if len(cells) >= 4:
                    rows.append((cells[1], "|".join(cells[3:]).strip()))
        if rows:
            sets[name] = rows
    return sets


def actor_sentence(body):
    """The template body's second sentence: who acts on the lane and what starts it."""
    para = body.split("\n\n", 1)[0]
    m = BOUNDARY.search(para)
    if not m:
        return None
    rest = para[m.end():]
    n = BOUNDARY.search(rest)
    return (rest[:n.start() + 1] if n else rest).strip()


def permission_line():
    try:
        with open(PIPELINE_INDEX, encoding="utf-8") as f:
            for line in f.read().split("\n"):
                if line.startswith(PERMISSION_MARK):
                    return line.rstrip()
    except OSError:
        pass
    return None


def says(body, sentence):
    """Does the body already carry the sentence, word for word. A paraphrase doesn't count: the owner's prose
    can't be told from a missing trigger by word overlap (a Tasks body saying "built straight through Active" lacks it)."""
    return norm(sentence) in norm(body)


def insert_after_first_sentence(body, sentence):
    lead = body[:len(body) - len(body.lstrip())]
    content = body.lstrip()
    cut = content.find("\n\n")
    para, tail = (content[:cut], content[cut:]) if cut >= 0 else (content.rstrip(), "")
    if cut < 0:
        tail = content[len(content.rstrip()):]
    m = BOUNDARY.search(para)
    if m:       # the match keeps a closing quote or bracket with the sentence it ends
        new = para[:m.end()].rstrip() + " " + sentence + " " + para[m.end():]
    else:
        new = para + ("" if re.search(r"[.!?]$", para) else ".") + " " + sentence
    return lead + new + tail


class Document:
    """A board file: frontmatter lines, a body, the file's own line ending."""

    def __init__(self, path):
        self.path = path
        with open(path, "rb") as f:
            self.raw = f.read()
        text = self.raw.decode("utf-8")
        self.nl = "\r\n" if "\r\n" in text.split("\n", 1)[0] + "\n" else "\n"
        lines = text.split(self.nl)
        if not lines or lines[0].rstrip() != "---":
            raise ValueError("no frontmatter")
        end = next((k for k in range(1, len(lines)) if lines[k].rstrip() == "---"), None)
        if end is None:
            raise ValueError("frontmatter never closes")
        self.fm = lines[1:end]
        self.body = self.nl.join(lines[end + 1:]).replace("\r\n", "\n")

    def title(self):
        for line in self.fm:
            m = re.match(r"title:\s*(.*)$", line)
            if m:
                v = m.group(1).strip()
                if v[:1] == '"' and v.endswith('"') and len(v) > 1:
                    return v[1:-1].replace('\\"', '"').replace("\\\\", "\\")
                if v[:1] == "'" and v.endswith("'") and len(v) > 1:
                    return v[1:-1].replace("''", "'")
                return v
        return None

    def order(self):
        for line in self.fm:
            m = re.match(r"order:\s*(-?[0-9.]+)\s*$", line)
            if m:
                return float(m.group(1))
        return float("inf")

    def kind(self):
        for line in self.fm:
            m = re.match(r"kind:\s*(\S+)", line)
            if m:
                return m.group(1).strip("\"'")
        return None

    def render(self, body, stamp_line):
        fm, out, skipping = self.fm, [], False
        replaced = False
        for line in fm:
            if line.startswith("modified:"):
                out.append(stamp_line); replaced = True; skipping = True; continue
            if skipping and line[:1] in (" ", "\t"):
                continue                      # a block-style modified: its continuation lines go with it
            skipping = False
            out.append(line)
        if not replaced:
            out.append(stamp_line)
        text = self.nl.join(["---"] + out + ["---"])
        body = body.replace("\n", self.nl)
        return text + self.nl + body


def scalar(v):
    return v if re.fullmatch(r"[A-Za-z0-9._-]+", v) else '"' + v.replace("\\", "\\\\").replace('"', '\\"') + '"'


def stamp_line(at, name, model, session):
    by = "{name: %s, kind: agent, model: %s" % (scalar(name), scalar(model))
    if session:
        by += ', session: "%s"' % session.replace("\\", "\\\\").replace('"', '\\"')
    return "modified: {at: %s, by: %s}}" % (at, by)


def match_set(titles, sets):
    have = {t.lower() for t in titles}
    scored = []
    for name, rows in sets.items():
        hit = sum(1 for t, _ in rows if t.lower() in have)
        scored.append((hit / len(rows), hit, name))
    scored.sort(reverse=True)
    if not scored or scored[0][0] < MATCH:
        return None
    if len(scored) > 1 and scored[1][0] == scored[0][0]:
        return None
    return scored[0][2]


def move_in(src, dst, board):
    try:
        os.replace(src, dst)
    except OSError:
        near = tempfile.mkdtemp(prefix=".lanework-heal-", dir=os.path.dirname(os.path.abspath(board)))
        try:
            shutil.move(src, os.path.join(near, "x"))
            os.replace(os.path.join(near, "x"), dst)
        finally:
            shutil.rmtree(near, ignore_errors=True)


def lane_docs(board):
    out = []
    for n in sorted(os.listdir(board)):
        p = os.path.join(board, n, "index.md")
        if UUID.fullmatch(n) and os.path.isfile(p):
            out.append(p)
    return out


def check_board(board, sets, perm):
    """(info lines, changes [(path, where, code, detail, new body)], skips)"""
    info, changes, skips = [], [], []
    lanes, titles = [], []
    for p in lane_docs(board):
        try:
            d = Document(p)
        except (OSError, UnicodeDecodeError, ValueError) as e:
            skips.append(("lane %s" % os.path.relpath(p, board), "can't read it (%s)" % e)); continue
        if d.kind() != "lane" or not d.title():
            continue
        lanes.append(d); titles.append(d.title())
    lanes.sort(key=lambda d: (d.order(), d.title()))
    kind = match_set(titles, sets)
    if kind is None:
        info.append("no known lane set (lanes: %s): no descriptor changes" % (", ".join(titles) or "none"))
        return info, changes, skips
    rows = {t.lower(): b for t, b in sets[kind]}
    info.append("lane set: %s" % kind)
    olds = {t.lower(): {norm(b) for b in bs} for t, bs in OLD_BODIES.get(kind, {}).items()}
    for d in lanes:
        title = d.title()
        cur = rows.get(title.lower())
        if cur is None:
            continue
        body = d.body.strip()
        sentence = actor_sentence(cur)
        where = "lane %s" % title
        if not body:
            changes.append((d, where, "fill-body", "empty: the current template body", cur + "\n"))
        elif norm(body) == norm(cur):
            continue
        elif norm(body) in olds.get(title.lower(), ()):
            changes.append((d, where, "replace-body", "an older template's body: the current one", cur + "\n"))
        elif sentence and not says(body, sentence):
            changes.append((d, where, "insert-actor", "customised: add \"%s\" after its first sentence" % sentence,
                            insert_after_first_sentence(d.body, sentence).rstrip("\n") + "\n"))
    if kind == "pipeline":
        try:
            idx = Document(os.path.join(board, "index.md"))
        except (OSError, UnicodeDecodeError, ValueError) as e:
            skips.append(("board sheet", "can't read it (%s)" % e)); return info, changes, skips
        lines = idx.body.split("\n")
        if not perm:
            skips.append(("board sheet", "the pipeline-index template has no Agent lanes line"))
        elif any(l.startswith(PERMISSION_MARK) or says(l, perm) for l in lines if l.startswith("-")):
            pass
        elif not any(l.startswith("## ") for l in lines):
            skips.append(("board sheet", "no instruction sheet (no ## heading): add the Agent lanes line by hand"))
        else:
            at = next((k for k, l in enumerate(lines) if l.startswith(ANCHOR_MARK)), None)
            if at is None:       # no Two human gates bullet: after the first bullet list under the first ## heading
                start = next(k for k, l in enumerate(lines) if l.startswith("## "))
                at = next((k for k in range(start + 1, len(lines)) if lines[k].startswith("- ")), None)
                if at is not None:
                    while at + 1 < len(lines) and lines[at + 1].startswith(("- ", "  ")):
                        at += 1
            if at is None:
                skips.append(("board sheet", "no bullet list under its first ## heading: add the Agent lanes line by hand"))
            else:
                new = lines[:at + 1] + [perm] + lines[at + 1:]
                changes.append((idx, "board sheet", "insert-permission", "the Agent lanes line: agents' lanes are acted on unasked", "\n".join(new)))
    return info, changes, skips


def main(argv):
    boards, apply_, name, model, session = [], False, "claude", None, None
    it = iter(argv)
    for a in it:
        if a == "--apply":
            apply_ = True
        elif a in ("--name", "--model", "--session"):
            v = next(it, None)
            if a == "--name": name = v
            elif a == "--model": model = v
            else: session = v
        elif a in ("-h", "--help"):
            print(__doc__); return 0
        elif not a.startswith("-"):
            boards.append(a)
        else:
            print("heal-descriptors: unknown argument %s" % a, file=sys.stderr); return 64
    if not boards:
        print("usage: heal-descriptors.py <board>... [--apply --model M [--name N] [--session S]]", file=sys.stderr); return 64
    if apply_ and not model:
        print("heal-descriptors: --apply needs --model (the restamp names who healed); nothing written", file=sys.stderr); return 2
    if apply_ and (not name or name.lower() in RESERVED_NAMES):
        print("heal-descriptors: %s is reserved for the app; sign as yourself" % name, file=sys.stderr); return 64
    for b in boards:
        if not os.path.isfile(os.path.join(b, "index.md")):
            print("heal-descriptors: %s is not a board (no index.md)" % b, file=sys.stderr); return 64
    sets, perm = read_templates(), permission_line()
    if not sets:
        print("heal-descriptors: no lane templates found beside this script (install the skills side by side)", file=sys.stderr); return 64
    at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    stamp = stamp_line(at, name, model or "dry-run", session)
    for b in boards:
        board = os.path.abspath(b)
        if len(boards) > 1:
            print("== %s" % os.path.basename(board))
        info, changes, skips = check_board(board, sets, perm)
        for line in info:
            print(line)
        for _, where, code, detail, _ in changes:
            print("%s: %s %s" % (where, code, detail))
        for where, why in skips:
            print("skip %s: %s" % (where, why))
        if apply_ and changes:
            stage = tempfile.mkdtemp(prefix="lanework-heal-")
            try:
                for n, (d, where, code, detail, body) in enumerate(changes):
                    with open(d.path, "rb") as f:
                        if f.read() != d.raw:
                            print("skip %s: changed while healing, run again" % where); continue
                    tmp = os.path.join(stage, str(n))
                    with open(tmp, "w", encoding="utf-8", newline="") as f:
                        f.write(d.render(body, stamp))
                    move_in(tmp, d.path, board)
            finally:
                shutil.rmtree(stage, ignore_errors=True)
        print("%d changes in %d files%s" % (len(changes), len({d.path for d, *_ in changes}),
              "" if apply_ or not changes else " (dry run: --apply to write)"))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
