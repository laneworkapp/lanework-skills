---
schema: 1
kind: comment
created:  {at: 2026-11-17T16:21:28Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**Merged to main, and the timer check passes. The card stays in Active for the app write-back check, which needs the owner. Not released.**

- **Merge**: `9174bb9` on main, from branch `lease-script` at `3e53310` (four commits).
- **Gate**: `tests/smoke.sh` on merged main printed `smoke: 202 passed`, exit 0. Before: 183. Added 19 checks. No `lease.sh` process left after the run.
- **Review**: adversarial. Round 1 and round 2 each asked for changes; the narrow re-check of the lead's ruled fix approved at `3e53310`.
- **Manual check, the timer outliving its call**: passes. Run 2026-11-17 on a throwaway copy of a board, poll shortened to 5 seconds.
  - **From a Claude Code Bash call**: `CLAUDE_PID` set (72939, the `claude` process). `stake` at 16:19:53Z. In a later tool call the same timer pid was alive and `until` had moved from 16:49:53Z to 16:50:04Z. `release`: exit 0, `claimed` gone, no timer 6 seconds later.
  - **From a headless `claude -p` job**: `CLAUDE_PID` set (30239) and a session id of its own. `stake` in one Bash call; in its second call the timer was alive and `until` had moved from 16:50:31Z to 16:50:43Z. Once the job ended the timer was gone within 7 seconds, and the lease was left to lapse at its `until`, as designed.
- **Manual check, the app write-back** (Q19): not run. It needs a card open in the Lanework app. Asked below.
- **Departures from the body**, each ruled on this thread:
  - the merge row asserts no merge comment for the losing lease (Q6);
  - `stake` on a card this session staked and then lost is a loss, exit 3;
  - `renew` with nothing to renew is exit 1;
  - `list` puts the title last.
- **Known, filed on [the triple-brace issue](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/b4dfd24b-8286-49a4-9fdb-9139c09a9a4d)**: a lease write reflows a `labels` line the heal already flags (59 of 114 real cards sampled; no value changed).
- **For the release commit**, the changelog entry: "Agents can now mark a card as theirs while they work it, so two sessions don't pick up the same card; the mark renews itself while the work runs and lapses on its own if the session dies."
- **The dependent lease cards wait** for the app check, as the body's recommendation says.
