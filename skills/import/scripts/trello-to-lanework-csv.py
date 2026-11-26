#!/usr/bin/env python3
"""trello-to-lanework-csv.py: turn a Trello board JSON export into a Lanework CSV folder.

usage: trello-to-lanework-csv.py <export.json> --out <new folder> [--include-archived]
                                 [--attachments] [--max-attachment-bytes N]
Writes <out>/board.csv, and <out>/assets/ when --attachments fetched files.
Exit 0 ok, 2 bad input or usage (a bad file, or an --out folder that holds anything), 1 failure.
No arguments: prints usage, exit 2. Never prompts.
Python 3 standard library only. The only network call is --attachments: one HTTPS GET, no
credentials, per uploaded attachment URL already in the export. Nothing else leaves the machine.
"""
import argparse
import csv
import datetime
import io
import json
import os
import re
import sys
import urllib.error
import urllib.request

COLUMNS = ["kind", "uuid", "parent", "title", "body", "labels", "due", "start", "created", "file", "extension"]
DEFAULT_MAX_BYTES = 25 * 1024 * 1024
TIMEOUT = 20


class UsageError(Exception):
    pass


class FetchError(Exception):
    pass


# ---- values -------------------------------------------------------------------------------------

def one_line(s):
    return re.sub(r"\s+", " ", s or "").strip()


def norm_ts(s):
    """A Trello timestamp as YYYY-MM-DDTHH:MM:SSZ, a bare date as is; None when not a real date."""
    if not isinstance(s, str):
        return None
    m = re.match(r"^(\d{4})-(\d\d)-(\d\d)(?:T(\d\d):(\d\d):(\d\d)(?:\.\d+)?Z)?$", s.strip())
    if not m:
        return None
    try:
        parts = [int(g) for g in m.groups() if g is not None]
        if len(parts) == 3:
            datetime.date(*parts)
            return "%04d-%02d-%02d" % tuple(parts)
        datetime.datetime(*parts)
        return "%04d-%02d-%02dT%02d:%02d:%02dZ" % tuple(parts)
    except ValueError:
        return None


def label_text(lab):
    name = one_line(lab.get("name"))
    value = name or one_line(lab.get("color"))
    # the short form reads "Kind: Value"; a colon or semicolon inside a name would be read as one
    value = re.sub(r"\s*:\s*", " - ", value.replace(";", ","))
    return value.strip()


def pos_key(o):
    p = o.get("pos")
    return p if isinstance(p, (int, float)) else float("inf")


def safe_name(name, used):
    """A file name that is one path segment: no separators, no leading dot, unique among used."""
    base = os.path.basename((name or "").replace("\\", "/"))
    base = re.sub(r"[^A-Za-z0-9._ -]", "_", base).strip(" .")
    if not base:
        base = "attachment"
    stem, ext = os.path.splitext(base)
    cand, n = base, 1
    while cand.lower() in used:
        n += 1
        cand = "%s-%d%s" % (stem, n, ext)
    used.add(cand.lower())
    return cand


# ---- fetching (the one network call; tests pass a fake) -------------------------------------------

class _HttpsOnly(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        if not newurl.lower().startswith("https://"):
            raise FetchError("redirect to a non-https address")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def default_fetch(url, max_bytes, timeout=TIMEOUT):
    """GET url with no credentials; https only, redirects stay https; at most max_bytes. Returns bytes."""
    if not url.lower().startswith("https://"):
        raise FetchError("not an https address")
    opener = urllib.request.build_opener(_HttpsOnly())
    req = urllib.request.Request(url, headers={"User-Agent": "lanework-import"}, method="GET")
    try:
        with opener.open(req, timeout=timeout) as r:
            n = r.headers.get("Content-Length")
            if n and n.isdigit() and int(n) > max_bytes:
                raise FetchError("larger than the size cap")
            data = r.read(max_bytes + 1)
    except urllib.error.HTTPError as e:
        raise FetchError("HTTP %d (needs a login?)" % e.code)
    except FetchError:
        raise
    except Exception as e:
        raise FetchError(type(e).__name__)
    if len(data) > max_bytes:
        raise FetchError("larger than the size cap")
    return data


# ---- conversion ---------------------------------------------------------------------------------

def convert(export, include_archived=False, attachments=False, max_bytes=DEFAULT_MAX_BYTES, fetch=default_fetch):
    """Returns (rows, files, stats). rows: list of dicts; files: {assets/<name>: bytes}."""
    if not isinstance(export, dict) or not isinstance(export.get("lists"), list) or not isinstance(export.get("cards"), list):
        raise UsageError("not a Trello board export: no lists and cards")
    st = {"carried": {}, "left": {}, "notes": [], "failed": []}

    def carry(k, n=1):
        if n:
            st["carried"][k] = st["carried"].get(k, 0) + n

    def left(k, n=1):
        if n:
            st["left"][k] = st["left"].get(k, 0) + n

    board_id = str(export.get("id") or "board")
    rows = [{"kind": "board", "uuid": board_id, "parent": "", "title": one_line(export.get("name")) or "Trello board"}]
    carry("board")
    files = {}
    used_names = set()

    labels_by_id = {l.get("id"): l for l in export.get("labels") or [] if isinstance(l, dict)}
    checklists = {c.get("id"): c for c in export.get("checklists") or [] if isinstance(c, dict)}
    comments = {}
    other_actions = 0
    for a in export.get("actions") or []:
        if not isinstance(a, dict):
            continue
        if a.get("type") == "commentCard":
            cid = ((a.get("data") or {}).get("card") or {}).get("id")
            if cid:
                comments.setdefault(cid, []).append(a)
        else:
            other_actions += 1

    lists = sorted([l for l in export["lists"] if isinstance(l, dict)], key=pos_key)
    cards_by_list = {}
    for c in export["cards"]:
        if isinstance(c, dict):
            cards_by_list.setdefault(c.get("idList"), []).append(c)

    members = votes = stickers = covers = fields = plugins = 0
    for lst in lists:
        lid = str(lst.get("id"))
        if lst.get("closed") and not include_archived:
            left("archived lists")
            left("cards in archived lists", len(cards_by_list.get(lst.get("id"), [])))
            continue
        rows.append({"kind": "lane", "uuid": lid, "parent": board_id, "title": one_line(lst.get("name")) or "(untitled)"})
        carry("lanes")
        for card in sorted(cards_by_list.get(lst.get("id"), []), key=pos_key):
            if card.get("closed") and not include_archived:
                left("archived cards")
                continue
            cid = str(card.get("id"))
            members += 1 if card.get("idMembers") else 0
            votes += 1 if (card.get("badges") or {}).get("votes") else 0
            stickers += 1 if card.get("stickers") else 0
            covers += 1 if (card.get("cover") or {}).get("idAttachment") or (card.get("cover") or {}).get("color") else 0
            fields += 1 if card.get("customFieldItems") else 0
            plugins += 1 if card.get("pluginData") else 0

            labs, seen = [], set()
            for lab in card.get("labels") or [labels_by_id.get(i) for i in card.get("idLabels") or []]:
                if isinstance(lab, dict):
                    t = label_text(lab)
                    if t and t not in seen:
                        seen.add(t)
                        labs.append(t)
            due = norm_ts(card.get("due"))
            start = norm_ts(card.get("start"))
            if card.get("due") and not due:
                left("unreadable due dates")
            if card.get("start") and not start:
                left("unreadable start dates")

            parts = []
            items = 0
            desc = (card.get("desc") or "").strip()
            if desc:
                parts.append(desc)
            for clid in card.get("idChecklists") or []:
                cl = checklists.get(clid)
                if not cl:
                    continue
                lines = []
                nm = one_line(cl.get("name"))
                if nm:
                    lines.append("**%s**" % nm)
                    lines.append("")
                for it in sorted([i for i in cl.get("checkItems") or [] if isinstance(i, dict)], key=pos_key):
                    done = "x" if it.get("state") == "complete" else " "
                    lines.append("- [%s] %s" % (done, one_line(it.get("name"))))
                    items += 1
                parts.append("\n".join(lines))

            att_rows = []
            link_lines = []
            for at in card.get("attachments") or []:
                if not isinstance(at, dict) or not at.get("url"):
                    continue
                label = one_line(at.get("name")) or at["url"]
                if not at.get("isUpload"):
                    link_lines.append("- [%s](%s)" % (label.replace("]", ")").replace("[", "("), at["url"]))
                    carry("links kept in the body")
                    continue
                got = None
                if attachments:
                    try:
                        got = fetch(at["url"], max_bytes)
                    except Exception as e:
                        st["failed"].append("%s (%s): %s" % (label, cid, one_line(str(e)) or type(e).__name__))
                if got is None:
                    left("uploaded attachments not fetched")
                    link_lines.append("- [%s](%s)" % (label.replace("]", ")").replace("[", "("), at["url"]))
                    continue
                name = safe_name(at.get("fileName") or at.get("name"), used_names)
                stem, ext = os.path.splitext(name)
                files["assets/" + name] = got
                att_rows.append({"kind": "attachment", "uuid": str(at.get("id") or name), "parent": cid, "title": stem,
                                 "extension": ext.lstrip("."), "file": "assets/" + name})
                carry("attachments")
            if link_lines:
                parts.append("**Links**\n\n" + "\n".join(link_lines))

            rows.append({"kind": "card", "uuid": cid, "parent": lid, "title": one_line(card.get("name")) or "(untitled)",
                         "body": "\n\n".join(parts), "labels": "; ".join(labs), "due": due or "", "start": start or ""})
            carry("cards")
            carry("checklist items", items)
            for c in sorted(comments.get(card.get("id"), []), key=lambda a: a.get("date") or ""):
                text = ((c.get("data") or {}).get("text") or "").strip()
                who = c.get("memberCreator") or {}
                name = one_line(who.get("fullName")) or one_line(who.get("username")) or "Unknown"
                row = {"kind": "comment", "uuid": str(c.get("id") or "%s-comment-%d" % (cid, len(rows))), "parent": cid,
                       "body": "**%s**\n\n%s" % (name, text) if text else "**%s**" % name}
                ts = norm_ts(c.get("date"))
                if ts:
                    row["created"] = ts
                rows.append(row)
                carry("comments")
            rows.extend(att_rows)

    left("cards with members", members)
    left("cards with votes", votes)
    left("cards with stickers", stickers)
    left("cards with covers", covers)
    left("cards with custom fields", fields)
    left("cards with Power-Up data", plugins)
    left("activity entries other than comments", other_actions)
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


def summary(out, st, board_title):
    lines = ['Trello board "%s" -> %s' % (board_title, os.path.join(out, "board.csv")), "carried:"]
    for k, n in st["carried"].items():
        lines.append("  %d %s" % (n, k))
    if st["left"]:
        lines.append("left out:")
        for k, n in st["left"].items():
            lines.append("  %d %s" % (n, k))
    lines.append("always left out: members, votes, stickers, covers, custom fields, Power-Up data, activity other than comments")
    if st["failed"]:
        lines.append("attachments that could not be fetched (kept as links in the card body):")
        for f in st["failed"]:
            lines.append("  " + f)
    return "\n".join(lines)


def build_parser():
    p = argparse.ArgumentParser(prog="trello-to-lanework-csv.py",
                                description="Turn a Trello board JSON export into a Lanework CSV folder (board.csv, assets/).")
    p.add_argument("export", help="the JSON file from Trello's Export as JSON")
    p.add_argument("--out", required=True, help="a new (or empty) folder to write board.csv into")
    p.add_argument("--include-archived", action="store_true", help="carry archived lists and cards too")
    p.add_argument("--attachments", action="store_true",
                   help="download uploaded attachments that need no login into assets/ (one HTTPS GET each, no credentials)")
    p.add_argument("--max-attachment-bytes", type=int, default=DEFAULT_MAX_BYTES, help="size cap per attachment (default 25 MiB)")
    return p


def main(argv=None, fetch=default_fetch):
    args = build_parser().parse_args(argv)  # a usage error exits 2
    try:
        if args.max_attachment_bytes < 1:
            raise UsageError("--max-attachment-bytes must be positive")
        try:
            with open(args.export, "r", encoding="utf-8-sig") as f:
                export = json.load(f)
        except (OSError, ValueError) as e:
            raise UsageError("cannot read %s as JSON: %s" % (args.export, e))
        if os.path.lexists(args.out) and (not os.path.isdir(args.out) or os.listdir(args.out)):
            raise UsageError("%s exists and is not an empty folder; give --out a new folder" % args.out)
        rows, files, st = convert(export, args.include_archived, args.attachments, args.max_attachment_bytes, fetch)
        write_output(args.out, to_csv(rows), files)
        print(summary(args.out, st, rows[0]["title"]))
        return 0
    except UsageError as e:
        print("trello-to-lanework-csv: %s" % e, file=sys.stderr)
        return 2
    except Exception as e:
        print("trello-to-lanework-csv: failed: %s: %s" % (type(e).__name__, e), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
