---
name: ticket-done-requires-commit
description: Tickets may only be moved to done/ after the changes are committed — use "ready to commit" status otherwise
metadata:
  type: feedback
---

Only move a ticket to `done/` once the implementing changes have been committed to git. If the work is complete but not yet committed, set the ticket status to `ready to commit` instead.

**Why:** The done/ folder represents shipped/committed work. Moving a ticket there before committing creates a misleading board state — the ticket says done but the code isn't in history yet.

**How to apply:** After finishing a fix or feature, check `git status` before moving the ticket. If uncommitted: update status in the ticket file to `ready to commit`. Move to done/ only after the commit is made. Related: [[backlog-readme-update]].
