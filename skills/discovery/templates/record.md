---
schema: 1
kind: card
title: "{{kind}}: {{title}}"
order: {{order}}
labels: [{text: {{kind}}, rank: {{rank}}, kind: {type: record, text: Record}}, {text: accepted, rank: 1, kind: {type: status, text: Status}}]
created:  {{stamp}}
modified: {{stamp}}
---
Question: [Q<n>: <title>](lanework://<board>/<card>)

<1 to 3 sentences: context, what was decided, why.>

## Considered options

- <only when the rejected routes are worth remembering>

## Consequences

- <only when a downstream effect is not obvious>

## Related

- <ADR/PDR card on the other side of the same ruling, or the record this supersedes, as a lanework:// link>
