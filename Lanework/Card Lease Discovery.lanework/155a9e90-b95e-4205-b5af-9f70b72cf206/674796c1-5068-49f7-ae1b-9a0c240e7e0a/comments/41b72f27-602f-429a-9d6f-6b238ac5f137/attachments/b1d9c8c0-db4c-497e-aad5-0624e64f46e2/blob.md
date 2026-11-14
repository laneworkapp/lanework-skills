# Guide v117, § Frontmatter, lines 724-726

```
Unknown keys are preserved verbatim by the app and invisible in its UI —
custom metadata (`project:`, `tags:`, `claimed-by:` …) is safe to add and
survives every app rewrite. Reserved for future use — preserved but
```

# .schema/card.json

```
94:  "additionalProperties" : true
```

# grep -n -i claim CLAUDE.md

```
17:- **Stamp every file you write** with `by`. A missing `by` claims the owner wrote it (Stamping your work).
725:custom metadata (`project:`, `tags:`, `claimed-by:` …) is safe to add and
765:the board's owner** — that is a claim about who wrote the file, not a blank:
```
