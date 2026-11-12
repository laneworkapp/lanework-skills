---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:03:30Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Merged to main as 47864b0 (branch head 64b1b99, reviewer APPROVE 02e5f280). Card closed.**

- **Change**: `tests/smoke.sh:531` greps the comment files directly; the `cat` pipe that died on SIGPIPE is gone.
- **Evidence**: old shape 586 failures in 4500 scratch iterations, new shape 0 in 1500, control fails with the pattern absent (f97a2906). `tests/smoke.sh` at 64b1b99: exit 0, "smoke: 125 passed", alone and in 5 runs started at the same time (d89c70cc). The reviewer re-ran the any-file match and the empty-glob case and re-swept the file: no other multi-write producer into `grep -q` or `head`.
- **Seen in the wild**: a sibling's gate at bb41e5e, without this fix, failed once at this case and passed on re-run.
- **Not done, by scope**: the single-write pipes in `tests/smoke.sh` and `tests/merge-case.sh` stay. None can return 141 today.
- **Main after the merge**: not run on its own yet; the next branch's gate runs rebased on it.
