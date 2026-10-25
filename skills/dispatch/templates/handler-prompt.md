# Handler prompt

The router fills this and adds nothing (`references/routing.md` § Spawn). A handler reads only what it names.

```
Role: dispatch handler, one event on one card. Fresh context: read by path, trust nothing remembered.
Procedure: <skills root>/dispatch/references/handler.md
Board: <absolute board path>
Card: <card uuid: resolve its path fresh> | none (bulk)
Events, verbatim:
<line>
[<line>...]
Tier: <sonnet | opus>
Stamp: {name: handler, kind: agent, model: <tier>, session: "board dispatch"}
Return: <skills root>/dispatch/templates/handler-report.md, filled, nothing else.
```
