---
schema: 1
title: "Write reviewer verdicts as Markdown, not a code fence"
order: 6144
created: {at: 2026-11-07T02:58:36Z}
waiting: {for: rzen, since: 2026-11-12T01:37:59Z, comment: 39bf5655-5b28-401e-8c57-eacc19b03f85}
modified: {at: 2026-11-12T01:37:59Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "board watch"}}
kind: card
labels: [{text: work, kind: {type: skill, text: Skill}}]
---
Reviewer verdicts become plain Markdown comments that keep the whole check walk, laid out to read in a card-width column instead of as one code fence.

## Problem

A verdict is the longest thing on a card and the hardest to read. The median runs 889 words, and over half of those are a CHECKED walk that later readers almost never cite. The template is one code fence, so nothing renders in it, links can't click, and its hard line breaks wrap again in a card-width column. Numbers and method are in the thread.

## Proposal

Replace the fence in `work/templates/review-verdict.md` with this order, in plain Markdown with no hard line breaks:

1. **Result**: `**Verdict: APPROVE.**` or `**Verdict: REQUEST-CHANGES.**` and one sentence, then short labelled bullets for stance with its trigger, round, the card as a link and the head on its branch.
2. **Blocking**: one numbered item each: anchor, failure scenario, fix direction. `**Blocking**: none.` when clean.
3. **Questions for the lead**: moved up from the bottom, so they can't be missed under the walk. Left out when there are none.
4. **Notes**: numbered. Only something a person could act on, or a result someone will cite. A check that came up clean belongs under Checked.
5. **Checked**: the whole walk, one bullet per checklist item with its label in bold, and nested bullets where an item has several facts.
6. **Hypotheses**: adversarial reviews only, numbered, under a line saying they were written before the reports and how many held.

Throughout: anchors, symbols, shas and paths in inline code, every card and comment named as a link, a blank line after every list. Nothing is cut for length.

The worked example is [the sample comment](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/73dbde19-c269-498c-aacf-a0baa871e7dd/dbada9ba-c8b5-4bf4-8e5a-45bb646b87b9), the screenshot's verdict with every line kept.

## Scope

- **In**: reviewer verdicts on card threads, and the copy sent to the lead.
- **Out**: the review checklist and read order, the review stance rules, verdicts already posted.
- ~~**Open call, the check walk**: A (recommended) attach it as a file on adversarial reviews, B a separate comment, C stop writing it.~~ ~~**ruled 2026-11-07: attach it to the verdict as a file, on adversarial reviews only.**~~ **re-ruled 2026-11-07: keep the walk in the verdict, no attachment.**
- ~~**Open call, the fixer's phase reports**: A (recommended) leave them out, B give them the same shape.~~ **ruled 2026-11-07: reviewer verdicts only.**

## Files

- `skills/work/templates/review-verdict.md`: the new shape.
- `skills/work/references/reviewer.md` § Verdict: the Markdown shape, what counts as a note, and questions above the walk.
- `README.md` § Sizes: the word counts.

## Risks

- Verdicts stay as long as they are now, so the thread reads no faster for an agent. The gain is for a person reading the card.
- Smoke is red today on the guide gate until [2c29a34f](lanework://04b8692e-adef-4b77-959d-ca3e08eb7776/2c29a34f-fde2-4a44-8a3b-94157a320609) lands.

## Verification

- `tests/smoke.sh`, with `check-refs.sh` and `check-sizes.sh` inside it. A prose change, so no new smoke case.
- Read the changed files through against the target guide's § Use the thread, and `work/references/writing.md` § The record.
- Rewrite three real verdicts in the new shape, one clean APPROVE, one REQUEST-CHANGES and one adversarial, as comments on a throwaway board. Validate them with its `lanework-validate.py`, then have the owner view one in the app at card width.

## Done when

- `review-verdict.md` has no fence around the verdict, and its order is the one above.
- Each of the three rewrites keeps every line of its original, with no code fence and no hard line breaks inside a paragraph or list item.
- `tests/smoke.sh` passes, or fails only on the guide gate, named as such in the closing comment.
- The owner has looked at a rewrite in the app and the thread records it.
