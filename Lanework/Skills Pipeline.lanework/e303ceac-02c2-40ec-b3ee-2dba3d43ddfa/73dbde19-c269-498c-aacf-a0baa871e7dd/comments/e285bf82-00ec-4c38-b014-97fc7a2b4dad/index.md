---
schema: 1
kind: comment
created:  {at: 2026-11-12T01:42:49Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
---
**Landed on main as 8f33812 (branch head 8f21986, reviewer APPROVE round 2 a983b8a8). The card stays in Active until the owner has looked at a rewrite.**

- **Change**: `skills/work/templates/review-verdict.md` has no fence around the verdict, in the body's order; `skills/work/references/reviewer.md` § Verdict matches. An empty Notes section is written "**Notes**: none.".
- **Gate**: `bash tests/smoke.sh` at 8f21986, exit 0, "smoke: 129 passed". The two skill files are byte-identical to the approved 0085b6d; only README § Sizes moved in the rebase. On main after the merge: check-sizes 62 rows, 0 wrong; check-refs 249 references, 0 missing.
- **Rewrites**: four, on a throwaway board, none with a code fence or a hard line break: two adversarial APPROVEs, one REQUEST-CHANGES, one standard APPROVE. The standard one is posted above as c4295243.
- **Remaining done-when**: the owner's view in the app, asked in 39bf5655.
- **Known mismatch**: the older sample dbada9ba still ends with an "Unresolved" line. The landed template has none; c4295243 is the current form.
