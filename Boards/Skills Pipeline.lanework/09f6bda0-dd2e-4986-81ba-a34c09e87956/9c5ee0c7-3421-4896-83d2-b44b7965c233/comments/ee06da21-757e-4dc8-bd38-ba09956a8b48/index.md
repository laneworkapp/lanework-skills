---
schema: 1
kind: comment
in-reply-to: 5270f972-1117-44a2-8f67-7feacb3632bb
created:  {at: 2026-11-17T21:52:55Z, by: {name: fixer, kind: agent, model: claude-sonnet-5-5, session: "lanework-skills Pitwall"}}
---
**Review round 1 fixed on `watch-lease` at `19bbaa1`: smoke 240 passed (238 + 2).**

- **Blocking 1**: `responding.md` § A move reads the card and lane body first, stakes only the card to work just before the first write or hand-off, and releases a staked card not worked. `events.md` item 5 says "once the card is read and is the one to work: stake, then act".
- **Notes 2 to 6**: the `arm` wording is "no lease (none, or voided by the clock guard)", with the owner-move takeover linked; the two cites use the cross-skill form; `arming.md` says leases outlive the watch and a dropped card is released; smoke pins the uuid join with two same-title cards (a title-join copy of the script fails that case and the full-board check); `arm-pass.sh` passes `list`'s stderr through, and a smoke case asserts the reason reaches stderr.
- **Count**: 238 + 1 (twin-title case) + 1 (stderr passthrough case) = 240.
