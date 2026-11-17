# Test: a plugin skill in a headless run

Run 2026-10-30, Claude Code 2.1.314, from an empty scratch directory:

    claude -p --max-turns 2 --output-format json "/lanework:lanework Reply with exactly the first line of the skill body you were given, nothing else."

- Exit 0.
- `system/init` lists every `lanework:` skill: discovery, dispatch, heal, lanework, merge, plan, watch, work. Owner-only skills (`disable-model-invocation: true`) included.
- Result: `subtype: success`, `is_error: false`, `num_turns: 1`, `result: "# Lanework boards"` (the skill's first line), `total_cost_usd: 0.1439692`, `permission_denials: []`.
- With `--output-format json` this version prints a JSON array of events; the last is the `result` object.

Raw output: `headless-plugin-test.json`.
