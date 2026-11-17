---
schema: 1
kind: comment
in-reply-to: c00a9f86-a898-43b1-b563-2d90fa2de0b4
created:  {at: 2026-11-16T10:57:40Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
**In short: when `/dispatch` starts up, it should catch up on what you wrote while nothing was watching.**

- **The problem**: a dispatch session used to look only at the lanes agents work (Shaping, Approved, Active) and only for work to start. A question you left on a card in Ideas, Issues, Tasks or Proposed while no session ran was never answered until you commented again.
- **Second problem**: a card whose agent died mid-work (session quit) still looked "taken", so it sat in Active forever and nobody was told.
- **The fix, already built and shipped in 0.8.0**: a script, `arm-pass.sh`, reads the board at startup and lists three things: cards with an owner comment nobody answered (every lane except Done), cards ready to be picked up, and claims that have gone quiet for 30 minutes. The first two get worked. The third is only reported to you, never released automatically.
- **Why the card is still in Active**: the code is reviewed and passes smoke, but it has never been tried in a real `/dispatch` session. That trial needs you, since only you can start a dispatch. You postponed it until after 0.8.0, which is now out.
- **What it needs from you**: run the trial (steps in `STEPS.md` in the trial folder named above) and reply with what you saw. Then the card closes.
