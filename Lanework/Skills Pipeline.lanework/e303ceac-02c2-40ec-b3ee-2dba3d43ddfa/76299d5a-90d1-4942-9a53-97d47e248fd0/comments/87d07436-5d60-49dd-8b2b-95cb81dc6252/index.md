---
schema: 1
kind: comment
created:  {at: 2026-10-06T23:00:43Z, by: {name: reviewer, kind: agent, model: opus}}
modified: {at: 2026-10-06T23:00:43Z, by: {name: reviewer, kind: agent, model: opus}}
---
**REQUEST-CHANGES: two one-line parse bugs in `heal-board.py` corrupt frontmatter the heal doesn't recognise. Everything else holds.**

```
VERDICT: REQUEST-CHANGES
STANCE:  ADVERSARIAL (fixer at opus; blast radius grew by three repair kinds; rewrites persisted board files)
ROUND:   1

CARD:   Active/76299d5a-90d1-4942-9a53-97d47e248fd0 "lanework: a healing script that repairs what agents and hand edits break on a board"
BRANCH: heal-board at 0827c46

BLOCKING: 2
  skills/lanework/scripts/heal-board.py:352 @ 0827c46 "if lines[k].strip() == \"---\"": an indented `  ---` inside a block scalar (`notes: |` / `  line one` / `  ---` / `  more`) closes the frontmatter early. Any repair then inserts `modified:` into the truncated block, so the frontmatter has two `modified` keys and a cut-off `notes`. Reproduced on a $TMPDIR copy: the YAML parsed before the heal and fails after it, and the labels below the `---` went unhealed. The app (FrontmatterDocument.isDelimiter) and the validator (is_delimiter) both use `line.rstrip() == "---"`, column 0. Fix: the same rule here, and at :350 for the opener.
  skills/lanework/scripts/heal-board.py:608 @ 0827c46 "cont = [l.strip() for l in ls[1:] if l.strip()]": a top-level `# comment` line after an unquoted title joins the title's span and is folded into it. Reproduced: `title: Plain title` followed by `# a yaml comment the owner left` was healed to `title: "Plain title # a yaml comment the owner left"`, changing visible title text with no record. Fix: drop lines starting with `#` from `cont`. Better: make Doc's span split put a column-0 comment line in a span of its own.

NOTES: 9
  heal-board.py:633 @ 0827c46 "new, why = rest, \"unquoted\"": `title: Foo # note` reads as `Foo` in YAML and is healed to `"Foo # note"`. That recovers `Fix #12 bug`, but it turns a real comment into title text. Either list it as `skip` or keep YAML's reading.
  heal-board.py:33 @ 0827c46 "or a closed kind's unlisted value": the single-kind reduction (:794) drops an unlisted value too. Reproduced: `Archived` under a single closed `status` [Open, Closed] was dropped. That matches the app's droppedOffsets, so only the docstring is wrong.
  heal-board.py:984 @ 0827c46 "s[\"type\"] not in glob_defs": with --global defining `priority`, the board gains no definition. The docstring (:19) and the app's MigrationDefinitions.addedDefinitions both add the machine's definition instead.
  heal-board.py:817 @ 0827c46 "except (ParseError, UnicodeDecodeError)": an unreadable file (chmod 000) raises PermissionError, and the whole run aborts with a traceback. Nothing was written (checked against a pristine copy), but it should be a `skip`, like the other unreadable cases.
  heal-board.py:941 @ 0827c46 "shutil.move(os.path.join(stage, cid)": across volumes the record is copied into the board non-atomically. stage_and_move covers that case, post_record doesn't. Records also post after every file write, so a failed post leaves a dropped fact recorded only in git.
  heal-board.py:292 @ 0827c46 "str(int(v)) if v.is_integer()": in a rewritten list, an untouched entry `{text: 2.0, kind: {type: release}}` comes back as `text: 2`. The app's emitDouble does the same, so this is a known limitation to add beside the fixer's quoting one.
  Restamp, either way: dropping the restamp (option B) means :835, the docstring at :9, the record text at :930, the writes.md Writes bullet, and two smoke greps (c 8's restamp, and `! grep "^modified: $STAMP$" "$H/index.md"`). That's small. One catch: the `retired-key` repair (:676) drops `modified-by` on the grounds that "the restamp names who modified". Under B it has to fold that name into `modified.by` when `by` is absent, or it drops a fact.
  tests/smoke.sh:149 @ 0827c46 "c() { sed -n '2,/^---$/p'": the smoke reads only frontmatter, so it never checks a repaired file's body. A heal that dropped bodies would still pass. Add a body check on a repaired card.
  Fixer's FAIL-BEFORE comment ran at 3908fde, the pre-rebase base, not b2e31b6. My own run at b2e31b6 agrees, so this is evidence hygiene only.

CHECKED:
  correctness vs done-when: smoke case read line by line. It asserts each repair's exact output, not just a clean validator, so a wrong repair fails it. Nasty $TMPDIR boards: CRLF kept (the body bytes and the new frontmatter lines both stay \r\n); unicode titles; `'it''s'` and `"a #b: c"` keep their values; unknown subkeys on entries and kinds ride along; foreign entries keep their meaning; column-0 and multi-line flow lists parse; a BOM file is skipped, not touched. Root priority → entry, an existing entry wins with a record; a kindless or `default` entry → `text`; bare glyph → icon; title quoting. All match guide v82 and LabelHealing/flattened (open-kind rank dropped, kind replaced whole, as the app does).
  project conduct: stdlib only; telegraphic § Healing in writes.md, one topic there and a pointer from SKILL.md; check-refs passes; the old step 19, "no skill prescribes priority: or component:" (now 25), passes. --name healer/Healer refused (exit 64). Refusal exits 2 with the board's copy present; --ignore-board-copy overrides it.
  both paths: a board without .schema/ and one with its own validator are both in smoke. The app's copy is its own card.
  fail-before: OWN RUN agreed. The branch's smoke.sh in scratch at b2e31b6 died at line 142, heal-board.py missing (exit 127). Scratch restored clean.
  test adequacy: steps 10–15, named like their neighbours; ast.parse added to the syntax step.
  blast radius: 5 files, all within the card's Touches plus README. The three extra repairs are explained on the thread.
  population: Skills Pipeline: 8 repairs over 117 documents. Lanework Pipeline: "1674 repairs in 1264 files" with no total for the board. Smoke at the head: 27 passed, exit 0 (own run).
  adversarial only: written before the reports: CRLF, BOM, block YAML, quoted `#`/`: `, foreign entries, comment lines, dry-run writes, partial writes, records on non-cards, reserved names. Held: block-scalar `---` (blocking), comment folded into title (blocking), unreadable crash (note). Disproved: CRLF, BOM, quoting, foreign entries, dry run (tree checksum unchanged), idempotence (second --apply: 0 repairs, checksum held), atomicity (staged in $TMPDIR, then os.replace).

UNRESOLVED: none. The restamp question is the owner's, already asked.
```
