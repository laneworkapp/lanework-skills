#!/usr/bin/env python3
"""obsidian-kanban-to-lanework-csv.py: turn an Obsidian Kanban plugin board into a Lanework CSV folder.

usage: obsidian-kanban-to-lanework-csv.py <board.md> --out <new folder> [--vault <folder>]
                                           [--include-archive] [--max-asset-bytes N]
Writes <out>/board.csv, and <out>/assets/ when --vault copied embedded files.
Exit 0 ok, 2 bad input or usage (a bad file, or an --out folder that holds anything), 1 failure.
No arguments: prints usage, exit 2. Never prompts. Python 3 standard library only, no network.
With --vault, every path is resolved with realpath and must stay inside the vault: nothing outside is read.
"""
import argparse
import csv
import datetime
import io
import os
import re
import sys
import textwrap

COLUMNS = ["kind", "uuid", "parent", "title", "body", "labels", "due", "file", "extension"]
DEFAULT_MAX_BYTES = 25 * 1024 * 1024
NOTE_CAP = 2 * 1024 * 1024

ITEM = re.compile(r"^[-*] (?:\[([ xX])\] ?)?(.*)$")
EMBED = re.compile(r"!\[\[([^\]\|]+?)(?:\|[^\]]*)?\]\]")
TAG = re.compile(r"(?<![\w/&#\[(])#([A-Za-z][\w/-]*)")
DATE = re.compile(r"@\{(\d{4})-(\d\d)-(\d\d)\}")
TIME = re.compile(r"@@\{[^}]*\}")
LINK_ONLY = re.compile(r"^\[\[([^\]\|]+?)(?:\|([^\]]*))?\]\]$")


class UsageError(Exception):
    pass


def one_line(s):
    return re.sub(r"\s+", " ", s or "").strip()


def strip_frontmatter(lines):
    if lines and lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return lines[i + 1:]
    return lines


# ---- reading the board -----------------------------------------------------------------------------

def parse_board(text):
    """Returns (lanes, has_settings): lanes = [{title, archived, cards: [{checked, first, rest}]}]."""
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    lines = strip_frontmatter(lines)
    has_settings = False
    for i, ln in enumerate(lines):
        if ln.startswith("%% kanban:settings"):
            lines, has_settings = lines[:i], True
            break
    lanes, lane, card, archived, blanks = [], None, None, False, 0
    orphans = 0

    def close():
        if card is not None:
            card["rest"] = textwrap.dedent("\n".join(card["rest"])).strip("\n")

    for ln in lines:
        if ln.startswith("## "):
            close(); card = None; blanks = 0
            lane = {"title": ln[3:].strip(), "archived": archived, "cards": []}
            lanes.append(lane)
            continue
        if ln.strip() == "***" and not ln.startswith((" ", "\t")):
            close(); card = None; blanks = 0
            archived = True
            continue
        m = ITEM.match(ln)
        if m:
            close()
            if lane is None:
                orphans += 1; card = None
                continue
            card = {"checked": (m.group(1) or "").lower() == "x", "first": m.group(2), "rest": []}
            lane["cards"].append(card)
            blanks = 0
            continue
        if card is not None and ln.startswith((" ", "\t")) and ln.strip():
            card["rest"].extend([""] * blanks)
            card["rest"].append(ln)
            blanks = 0
        elif ln.strip() == "":
            blanks += 1
        else:
            close(); card = None; blanks = 0
    close()
    return lanes, has_settings, orphans


# ---- the vault -----------------------------------------------------------------------------------

class Vault(object):
    def __init__(self, root, board_real):
        self.root = os.path.realpath(root)
        self.files = []  # (posix relative path, absolute path as walked)
        for d, dirs, names in os.walk(self.root):
            dirs[:] = sorted(x for x in dirs if not x.startswith("."))
            for n in sorted(names):
                if n.startswith("."):
                    continue
                ap = os.path.join(d, n)
                if os.path.realpath(ap) == board_real:
                    continue
                self.files.append((os.path.relpath(ap, self.root).replace(os.sep, "/"), ap))

    def inside(self, real):
        return real == self.root or real.startswith(self.root + os.sep)

    def find(self, target, want_note):
        """(status, abspath): status ok | missing | ambiguous | refused."""
        t = target.split("#", 1)[0].split("^", 1)[0].strip().replace("\\", "/")
        if not t or t.startswith("/") or ".." in t.split("/"):
            return ("refused" if t else "missing"), None
        if want_note and not t.lower().endswith(".md"):
            t += ".md"
        for fold in (False, True):
            tt = t.lower() if fold else t
            hits = []
            for rel, ap in self.files:
                r = rel.lower() if fold else rel
                if r == tt or r.endswith("/" + tt):
                    hits.append(ap)
            if len(hits) > 1:
                return "ambiguous", None
            if hits:
                real = os.path.realpath(hits[0])
                if not self.inside(real) or not os.path.isfile(real):
                    return "refused", None
                return "ok", real
        return "missing", None


def read_note(real):
    if os.path.getsize(real) > NOTE_CAP:
        return None
    with open(real, "r", encoding="utf-8", errors="replace") as f:
        text = f.read().replace("\r\n", "\n")
    return "\n".join(strip_frontmatter(text.split("\n"))).strip()


# ---- conversion ----------------------------------------------------------------------------------

def convert(text, title, vault=None, include_archive=False, max_bytes=DEFAULT_MAX_BYTES):
    lanes, has_settings, orphans = parse_board(text)
    if not lanes:
        raise UsageError("no lanes found: a Kanban plugin board has one '## ' heading per lane")
    st = {"carried": {}, "left": {}}

    def carry(k, n=1):
        st["carried"][k] = st["carried"].get(k, 0) + n

    def left(k, n=1):
        if n:
            st["left"][k] = st["left"].get(k, 0) + n

    rows = [{"kind": "board", "uuid": "b1", "parent": "", "title": title}]
    carry("board")
    files, assets_by_src, used = {}, {}, set()
    nl = nc = na = 0
    for lane in lanes:
        if lane["archived"] and not include_archive:
            left("cards in the Archive section", len(lane["cards"]))
            continue
        nl += 1
        lid = "l%d" % nl
        rows.append({"kind": "lane", "uuid": lid, "parent": "b1", "title": one_line(lane["title"]) or "(untitled)"})
        carry("lanes")
        for card in lane["cards"]:
            nc += 1
            cid = "c%d" % nc
            first, rest = card["first"], card["rest"]
            labels, seen = [], set()
            for m in TAG.finditer(first + "\n" + rest):
                if m.group(1) not in seen:
                    seen.add(m.group(1)); labels.append(m.group(1))
            due = ""
            dm = DATE.search(first + "\n" + rest)
            if dm:
                try:
                    datetime.date(*[int(g) for g in dm.groups()])
                    due = "%s-%s-%s" % dm.groups()
                except ValueError:
                    left("dates that are not real dates (kept as text)")
            embeds = []
            if vault is not None:
                for blob in (first, rest):
                    embeds.extend(EMBED.findall(blob))
                first, rest = EMBED.sub("", first), EMBED.sub("", rest)
            else:
                n = len(EMBED.findall(first)) + len(EMBED.findall(rest))
                left("picture embeds kept as text (no --vault)", n)
            clean = DATE.sub("", TIME.sub("", TAG.sub("", first)))
            clean = one_line(clean)
            body = rest.strip()
            lm = LINK_ONLY.match(clean)
            if lm:
                if vault is None:
                    left("note links kept as text (no --vault)")
                else:
                    status, real = vault.find(lm.group(1), True)
                    note = read_note(real) if status == "ok" else None
                    if status == "ok" and note is not None:
                        carry("notes taken as card bodies")
                        body = (note + ("\n\n" + body if body else "")).strip()
                        clean = one_line(lm.group(2) or os.path.splitext(os.path.basename(lm.group(1).split("#", 1)[0]))[0])
                    elif status == "ok":
                        left("note links kept as text (note over the size cap)")
                    elif status == "refused":
                        left("note links refused (path leaves the vault)")
                    else:
                        left("note links kept as text (%s)" % ("matches several notes" if status == "ambiguous" else "no such note"))
            card_atts = []
            for target in embeds:
                status, real = vault.find(target, False)
                if status == "ok" and target.lower().endswith(".md"):
                    status = "skip"
                if status == "skip":
                    left("note embeds dropped from the text")
                elif status == "ok":
                    if real not in assets_by_src:
                        if os.path.getsize(real) > max_bytes:
                            left("embedded files over the size cap")
                            continue
                        name = os.path.basename(real)
                        name = re.sub(r"[^A-Za-z0-9._ -]", "_", name).strip(" .") or "file"
                        stem, ext = os.path.splitext(name)
                        cand, k = name, 1
                        while cand.lower() in used:
                            k += 1; cand = "%s-%d%s" % (stem, k, ext)
                        used.add(cand.lower())
                        with open(real, "rb") as f:
                            files["assets/" + cand] = f.read()
                        assets_by_src[real] = cand
                    cand = assets_by_src[real]
                    stem, ext = os.path.splitext(cand)
                    na += 1
                    card_atts.append({"kind": "attachment", "uuid": "a%d" % na, "parent": cid, "title": stem,
                                      "extension": ext.lstrip("."), "file": "assets/" + cand})
                    carry("attachments")
                elif status == "refused":
                    left("embeds refused (path leaves the vault)")
                else:
                    left("embeds with no file in the vault, or several")
            if not clean:
                clean = os.path.splitext(card_atts[0]["title"])[0] if card_atts else "(untitled)"
            rows.append({"kind": "card", "uuid": cid, "parent": lid, "title": clean, "body": body,
                         "labels": "; ".join(labels), "due": due})
            rows.extend(card_atts)
            carry("cards")
            if labels:
                carry("cards with tags")
            if due:
                carry("cards with a due date")
            if card["checked"]:
                carry("checked cards (kept in place; the checked state is not carried)")
    left("items before the first lane", orphans)
    if has_settings:
        left("the plugin's settings block (ignored)")
    return rows, files, st


def to_csv(rows):
    used = [c for c in COLUMNS if c in ("kind", "uuid", "parent") or any(r.get(c) for r in rows)]
    buf = io.StringIO(newline="")
    w = csv.writer(buf, lineterminator="\n")
    w.writerow(used)
    for r in rows:
        w.writerow([r.get(c, "") for c in used])
    return buf.getvalue()


def write_output(out, csv_text, files):
    """Write into a new or empty folder; remove what was written when a write fails."""
    if os.path.lexists(out) and (not os.path.isdir(out) or os.listdir(out)):
        raise UsageError("%s exists and is not an empty folder; give --out a new folder" % out)
    made_dir = not os.path.exists(out)
    written = []
    try:
        os.makedirs(out, exist_ok=True)
        if files:
            os.makedirs(os.path.join(out, "assets"), exist_ok=True)
        for rel, data in files.items():
            p = os.path.join(out, rel)
            with open(p, "wb") as f:
                written.append(p)
                f.write(data)
        p = os.path.join(out, "board.csv")
        with open(p, "w", encoding="utf-8", newline="") as f:
            written.append(p)
            f.write(csv_text)
    except Exception:
        for p in written:
            try:
                os.remove(p)
            except OSError:
                pass
        for d in (os.path.join(out, "assets"), out if made_dir else None):
            try:
                if d:
                    os.rmdir(d)
            except OSError:
                pass
        raise


def summary(out, st, title):
    lines = ['Obsidian Kanban board "%s" -> %s' % (title, os.path.join(out, "board.csv")), "carried:"]
    for k, n in st["carried"].items():
        lines.append("  %d %s" % (n, k))
    if st["left"]:
        lines.append("left out:")
        for k, n in st["left"].items():
            lines.append("  %d %s" % (n, k))
    lines.append("always left out: frontmatter, other plugins' syntax (kept as written in card text), links between notes that are not cards")
    return "\n".join(lines)


def build_parser():
    p = argparse.ArgumentParser(prog="obsidian-kanban-to-lanework-csv.py",
                                description="Turn an Obsidian Kanban plugin Markdown board into a Lanework CSV folder (board.csv, assets/).")
    p.add_argument("board", help="the Kanban plugin's Markdown file")
    p.add_argument("--out", required=True, help="a new (or empty) folder to write board.csv into")
    p.add_argument("--vault", help="the vault folder: linked notes become card bodies, embedded files become attachments")
    p.add_argument("--include-archive", action="store_true", help="carry the Archive section too")
    p.add_argument("--max-asset-bytes", type=int, default=DEFAULT_MAX_BYTES, help="size cap per embedded file (default 25 MiB)")
    return p


def main(argv=None):
    args = build_parser().parse_args(argv)  # a usage error exits 2
    try:
        if args.max_asset_bytes < 1:
            raise UsageError("--max-asset-bytes must be positive")
        try:
            with open(args.board, "r", encoding="utf-8-sig") as f:
                text = f.read()
        except (OSError, ValueError) as e:
            raise UsageError("cannot read %s as text: %s" % (args.board, e))
        vault = None
        if args.vault is not None:
            if not os.path.isdir(args.vault):
                raise UsageError("--vault %s is not a folder" % args.vault)
            vault = Vault(args.vault, os.path.realpath(args.board))
        if os.path.lexists(args.out) and (not os.path.isdir(args.out) or os.listdir(args.out)):
            raise UsageError("%s exists and is not an empty folder; give --out a new folder" % args.out)
        title = os.path.splitext(os.path.basename(args.board))[0]
        rows, files, st = convert(text, title, vault, args.include_archive, args.max_asset_bytes)
        write_output(args.out, to_csv(rows), files)
        print(summary(args.out, st, title))
        return 0
    except UsageError as e:
        print("obsidian-kanban-to-lanework-csv: %s" % e, file=sys.stderr)
        return 2
    except Exception as e:
        print("obsidian-kanban-to-lanework-csv: failed: %s: %s" % (type(e).__name__, e), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
