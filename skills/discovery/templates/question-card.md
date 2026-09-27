---
schema: 1
kind: card
title: "Q{{n}}: {{title}}"
order: {{order}}
labels: [{text: "Round {{round}}", kind: {type: round, text: Round}}]
waiting: {for: {{handle}}, since: {{since}}, comment: {{ask_id}}}
created:  {{stamp}}
modified: {{stamp}}
---
<The question, one paragraph, above the first ##.>

## Options

- A: <one line>
- B: <one line>

## Recommended

<Letter>. <One sentence why.>

## Depends on

- [Q<n>](lanework://<board>/<card>): <what it settled>
- [Fact: <title>](lanework://<board>/<card>)
