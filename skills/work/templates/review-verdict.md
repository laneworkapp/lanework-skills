# Reviewer verdict

Rules: `references/reviewer.md` § Verdict, `references/team.md` § Bounding review.

Post everything below the line as the comment body: plain Markdown, no code fence, no hard line breaks inside a paragraph or list item, a blank line after every list. Anchors, symbols, shas and paths in inline code; every card and comment a `lanework://` link.

- `**Blocking**: none.` on one line when clean.
- **Questions for the lead** sits above Notes and Checked; leave it out when none.
- **Notes**: only what a person could act on, or a result someone will cite. A clean check goes under Checked.
- **Checked**: the whole walk, one bullet per checklist item (`references/reviewer.md` § Checklist); nested bullets where an item has several facts.
- **Hypotheses**: adversarial reviews only; leave it out otherwise.

---

**Verdict: APPROVE.** <one sentence: why, and the note count>

(or **Verdict: REQUEST-CHANGES.** and one sentence naming the blocking count)

- **Stance**: <standard | adversarial, and the trigger>
- **Round**: <1 | 2 | lead-ruled re-check>
- **Card**: [<title>](lanework://<board>/<card>)
- **Branch**: `<branch>` at `<head sha read off the branch>`

**Blocking**

1. `file:line @ sha` "<quoted fragment>": <failure scenario: input or state -> wrong result>. Fix: <direction>.

**Questions for the lead**

1. <owner-only or scope question>

**Notes**

1. <anchor>: <never blocks; the lead may file it as a card>

**Checked**

- **Correctness vs done-when**: <what was compared against the card's observation>
- **Project conduct**: <repo CLAUDE.md bars checked; any "assume Y" shapes>
- **Both paths**: <second path handled, flagged, or why only one applies>
- **Fail-before**: <FIXER RUN checked | OWN RUN agreed | REASONED, and why>
  - <nested bullet per extra fact>
- **Test adequacy**: <named and located like its neighbours>
- **Blast radius**: <Phase-2 actual vs Phase-1 expected; unexplained churn>
- **Population**: <every delta arrived with its denominator, or didn't>

**Hypotheses**, written before reading <the reports, as links>. <N of M held.>

1. <hypothesis, and what refuted or confirmed it>
