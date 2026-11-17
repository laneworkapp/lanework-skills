---
schema: 1
kind: comment
in-reply-to: 2e887173-26e5-418e-b523-e94b131f4ecd
created:  {at: 2026-11-17T11:35:45Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In plain terms: one sentence on every pipeline board describes the Active lane, and it will soon describe something agents no longer do.**

- **Today** the sentence says an agent takes a card by "claiming it with a comment naming the session and branch". That comment is the START comment.
- **Once the lease cards are built**, an agent takes a card by writing a lease on it: a `claimed` key naming who holds the card and until when, renewed while it works. The START comment stops being the claim.
- **So the sentence needs new words.** It appears in the Active lane of every new pipeline board, and the heal skill offers it to older boards.
- **Option A** names the lease: "holds it with a lease while it works". A reader of the lane learns that the card is held and by what. It also puts the word "lease" in front of anyone opening the board, before they know what one is.
- **Option B** says nothing about how a card is held: "moves a card in as it starts and moves it to Done". It never goes stale again if the mechanism changes. A reader does not learn that only one agent holds a card at a time.
- **Nothing else rides on the choice.** The files, the tests and the build order are the same either way.
- **Timing**: neither sentence should ship before the lease cards do, since A would describe something that does not exist yet.
