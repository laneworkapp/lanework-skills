# Ruling shapes

## Ruling section, appended to the question body

```markdown
## Ruling

**<YYYY-MM-DD>**: C, as recommended. "<owner's words>"
ADR: [ADR1](lanework://<board>/<card>)
PDR: [PDR1](lanework://<board>/<card>)
Glossary: **Tracker**, **Remote** in CONTEXT.md
```

Record lines only when written. Parked: `**<YYYY-MM-DD>**: Parked. "<owner's reason>"`

## Chat record comment, in reply to the ask

Shape and rule: `work/references/writing.md` § The owner's exception. `settle-question.sh --record` refuses a file with no `>` line or no `**Given**` line.

```markdown
**Owner ruled off the board.**

> <owner's words, verbatim>

**Given**: chat, <YYYY-MM-DD>
```
