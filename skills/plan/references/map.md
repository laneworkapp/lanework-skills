# Map

One card, Map lane, order 1024: `templates/map-card.md`. The whole plan at low resolution, read once per session.

## Index, not store

- A decision lives only in its ticket's Resolution. The map gists + links, never restates.
- Live tickets aren't listed: they are the Frontier, Blocked and Working lanes (`scripts/frontier.sh`).
- Rewritten whole after every resolved ticket, plus a thread comment naming the ticket.

## Sections

| section | holds |
|---|---|
| Destination (above the first `##`) | the spec, decision or change; 1–2 lines; every session orients to it |
| Notes | domain, skills every session consults, standing preferences, any override of plan, don't do |
| Decisions so far | one line per Resolved ticket: link + gist. Moot tickets too |
| Not yet specified | fog |
| Out of scope | one line each: gist + why, linking a ruled-out ticket |

## Refer by name

Every ticket named as a link: `[T3: <title>](lanework://<board>/<card>)`, in the map, chat, comments and resolutions. Never a bare `T3`, short id or uuid.

## Fog or ticket?

Test: can you state the question precisely now? Not: can you answer it.

- Sharp, even if blocked → ticket.
- Not yet → Not yet specified. Coarse; don't pre-slice. One patch may graduate into several tickets, or none.
- Graduating = file the ticket, delete the patch: it lives only as the ticket.
- Not yet specified excludes: decided (Decisions so far), live tickets, out of scope.

## Out of scope

- Scope, not sharpness: past the destination. Never fog.
- Never graduates. Returns only if the destination is redrawn, as a fresh plan, not a resumption.
- A scoping act, not a step on the route: stays out of Decisions so far.
- A ticket already filed → `tickets.md` § Out of scope.
