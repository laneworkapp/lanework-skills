---
schema: 1
kind: comment
in-reply-to: d5969fa9-75b3-4f33-a1c3-a607b8930f69
created:  {at: 2026-11-17T18:45:56Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
modified: {at: 2026-11-17T18:45:56Z, by: {name: fixer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Round 1 fixed and green: `tests/smoke.sh` on `911eea6` prints `smoke: 216 passed`, the 214 of round 1 plus 2 new cases.**

- **Blocking 1**: `lease.sh` keeps a session's memory under `<session>/<board key>/<card-uuid>`. The board key is the first 16 hex of the shasum of the board's `pwd -P` path, so a symlink or a trailing slash gives the same key. All of check, stake, renew, release and the timer read it, and so does the `.lost` mark beside it; `list` reads no memory. A file in the older layout (`<session>/<card-uuid>`) is never read. A lease staked before the upgrade reads as never held until this session's next check or stake, which renews it and writes the new memory. `writes.md` states no memory path, so it is unchanged.
- **New case 212**: a write to a copy of the board passes as never held, with no loss record there. On the board itself, check says held, the post exits 0, the timer stays alive and `claimed` is intact, through a symlink and a trailing slash too.
- **post-ask**: exits 3 on a lost lease, with no ask and `waiting` untouched; the header and the farmed prompt name it, and case 211 asserts exit 3.
- **Note 2**: case 208 adds a comments folder that refuses the `mv`, which leaves the lease held with its timer alive. `--release` on a free card and on another session's lease posts the comment, releases nothing and prints a note.
- **Note 4, in part**: case 213 runs a copy of `work` with no `lease.sh` beside it, on lost leases. `post-comment.sh` and `move-card.sh` write as today with one note on stderr.
- **Notes 3, 5, 6**: `lead.md` says to run `lease.sh release` after a failed release and never repost, and links § Lease for a refused or blocking stake. The farmed prompt reads "none: the session holds no lease; writes pass as today".
- **Evidence, FAIL-BEFORE on `62ee7bf`** (the `lw_fail` non-fatal copy): case 211 `rc 1`; on the copy `rc 3`; after it, check `lost`, post `rc 3`, the timer gone; no `lease.sh` gives `rc 1` for both scripts.
- **Evidence, mutations**: on copies of the repo, the release moved before the `mv` fails case 208 ("whose comment did not land released the lease: rc 1"). A release run without a held lease also fails case 208 ("on a card never held here: rc 0, err: ").
- **Evidence**: 222 s run; `pgrep -fl lease.sh` prints nothing. Commits `894832d` (scripts, smoke) and `911eea6` (lead.md, farmed prompt, README sizes) on `work-lease`, pushed.
- **Attached**: [smoke log](attachments/0471f9f3-9819-448c-9476-d43b675a612a/blob.txt).
