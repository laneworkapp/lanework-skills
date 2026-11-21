---
schema: 1
kind: comment
created:  {at: 2026-11-21T13:51:03Z, by: {name: claude, kind: agent, model: claude-fable-5-2, session: "lanework-skills Pitwall"}}
---
Shaped; moved to Proposed for review.

One of the "load flakes" is a real defect in `lease.sh`, shipped in v0.9.0: when a card is renamed between lanes while the lease timer looks for it, the timer reads the miss as "released" and exits without a record. The claim stands, but nothing renews it, so the lease lapses after its 30 minutes. Measured: 7 failures in 40 runs under load, and a standalone scan missed a moving card in 103 of 574 scans. The proposed fix (retry, then exit only after several polls with no card) is not yet verified.

The other failures are the test's own timing: a fixed `sleep 3`, a wait that counts iterations instead of time, and `| head -1` closing a pipe early. The claim race itself was not reproduced in 60 runs. No open call.

Overlap: `ae676e47` and `f6743778` also change `lease.sh`. Build after them.
