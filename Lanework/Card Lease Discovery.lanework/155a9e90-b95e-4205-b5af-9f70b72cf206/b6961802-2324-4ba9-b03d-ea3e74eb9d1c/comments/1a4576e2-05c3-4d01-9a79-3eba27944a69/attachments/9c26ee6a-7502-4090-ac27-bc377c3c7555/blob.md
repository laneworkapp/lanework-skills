# skills/work/references/companions.md

```
5:- **A START / plan comment is a claim.** That card is theirs. Don't double-dispatch, even if an earlier owner comment called for the work. Post your own START before working a card.
```

# skills/dispatch/scripts/arm-pass.sh, lines 14-19

```
#   arm      an unclaimed card in an agent lane (Approved: its top card only, by `order`). Author and paths `-`.
#   stale    a claim, and nothing newer on the card for STALE_MINUTES (default 30). Author `-`, paths =
#            the minutes of silence, `<n>m`. Report-only: the router never routes it, nothing is released.
# Claim = the card's last comment opening `START` (bold or plain) with no later closing comment. A closing
# comment opens `Merged`, `Closed`, `Shipped`, `Done`, `Confirmed done`, `Released`, `Landed` or `Abandoned`
# (bold or plain); a closing comment in any other shape reads as still claimed.
```

# skills/dispatch/references/routing.md

```
23:   - `stale`: a START with nothing newer on the card for 30 minutes (`STALE_MINUTES`). Never routed, never released: step 5 reports each with its lane, title and minutes of silence.
25:5. **Tell the user**: `watch/references/arming.md` § Tell the user, with `/dispatch` for `/watch`, then the `stale` lines: claims whose handler may have died with its session (a quit or a resume; a `/clear` kills none), for the owner to free or leave.
```
