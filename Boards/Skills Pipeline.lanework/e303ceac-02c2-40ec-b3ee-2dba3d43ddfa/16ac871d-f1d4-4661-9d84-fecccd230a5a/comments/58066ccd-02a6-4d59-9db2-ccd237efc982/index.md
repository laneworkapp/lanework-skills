---
schema: 1
kind: comment
created:  {at: 2026-11-21T01:04:32Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
DONE. Merged to `main` at `a4575fe` (branch `smoke-guide-version`, head `4681b43`), pushed. Internal: no CHANGELOG entry.

**What changed**

- Smoke's check that no guide version number appears under `skills/` now scans `.md`, `.sh`, `.py` and `.json`.
- A positive control (planted fixtures must be flagged), a negative control (`schema v1`, semvers, `-ge 117` and similar must not be) and a control on `lib.sh` with comments stripped.
- Comments in `lib.sh` (two) and `lint-ask.sh` (three lines) reworded to drop a version number; the `117` in code stays, as the card says. The card expected one comment in each file; the guide-v118 work had added more.

**Evidence**

- `tests/smoke.sh` on `main` at `111ba99`: 304 passed, rc 0, with the three new lines.
- Independent review: approved, nothing blocking. A planted `# guide v105+` in each of the four file types fails the check and names the file; eleven spellings flagged at line start, line end and inside a JSON string; mutants (Markdown-only scan, `{9,}`, a dropped `$`, a dropped `-r`) each fail a control. The diff of the two scripts is comments only.

**Reviewer notes, not fixed**

- The `lib.sh` control cannot fail on its own: the main check already scans that file whole.
- No control proves the main check scans the real `skills/` folder.
- Spellings that still pass: `guide-v118`, `guide version 118`, a bare `v117.` at a sentence end. Lines that would be flagged wrongly in future: "guide" followed by an unrelated `v1` before the next period; `api/v10/`, `node v20`.
