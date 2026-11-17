---
schema: 1
kind: comment
created:  {at: 2026-11-17T12:30:47Z, by: {name: reviewer, kind: agent, model: claude-opus-5-5, session: "lanework-skills Pitwall"}}
---
**Verdict: REQUEST-CHANGES.** Blocking 1 is half fixed: the new clause arms a card only after a fresh answer, so a card whose `comment` line is a false alarm is still never armed. One note.

- **Stance**: adversarial (unchanged from round 1)
- **Round**: 2
- **Card**: [ee07c8d2](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/ee07c8d2-6fa8-41ac-b06a-ceb5f3045fd0)
- **Branch**: `retire-dispatch` at `fb56a57b3ac6c5571f89e2583dd2c2e6a417d4d1`, diff reviewed since `1696614`

**Blocking**

1. `skills/watch/references/arming.md:25 @ fb56a57` "Already answered (...) → no reply, one report line. Else answer it as a new owner comment (`responding.md`), then carry on as `arm`": the clause is attached to the Else branch only. Read as written, an already-answered card gets one report line and nothing more. Failure: an unclaimed card at the top of Approved whose old ruling was folded without `in-reply-to` (the false alarm this card's Risks names; [d42328d4](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/d42328d4-c343-4249-ad76-ce64e4e808c7) and [714177b9](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/714177b9-948b-4e11-a895-41b60250ecc3) sit in Approved today, one ship away from the top). The script prints `comment` in place of `arm`, the watch finds it answered, reports, and the card is never armed. Fix: make the arm step follow both branches, e.g. "Either way, carry on as `arm` when …" after the Else sentence, and let the smoke grep pin that wording.

**Notes**

1. `README.md:84 @ fb56a57` "| `references/arming.md` |      647 |": the cell is padded with spaces, unlike every other row. `check-sizes` reads it fine (57 rows, 0 wrong); cosmetic.

**Checked**

- **Correctness vs done-when**: "Approved: its top card" reads correctly against the script: in Approved, only when this card is the lane's first by `order`, as `arm` already means. Notes 1 and 2 from round 1 are fixed: "passing every agent lane title … (titles passed replace those rows, not add to them)", and `stale` goes "in the arming message to the user (§ Tell the user)" with a matching bullet there. Note 3 is fixed: entry 1 is one sentence (semicolon), entries 2 and 3 say `/lanework:watch`.
- **Project conduct**: one commit since `1696614`, four files (`CHANGELOG.md`, `README.md`, `arming.md`, `smoke.sh`), no board writes, plugin version untouched.
- **Both paths**: the `comment` row has two branches (answered now, already answered), and the arm step covers one. That is Blocking 1.
- **Fail-before**: FIXER RUN checked (record `99101209`: the extended case fails at `1696614`). OWN RUN on a copy of the branch's `skills/`: the extended case passes, and with the "then carry on as `arm` …" clause cut out it fails. It pins the words, not which branch they follow.
- **Test adequacy**: the extended case is the existing watch-arming case, grown by three greps; same place, same style.
- **Blast radius**: matches the fixer's record. `wc -w arming.md` = 647, total 1,600; `check-sizes` 0 wrong over 57 rows; `check-refs` 216 references, 0 missing.
- **Population**: smoke not re-run by me this round; the fixer's record quotes `smoke: 152 passed`, the same count as round 1 (no case added or removed, one extended).
