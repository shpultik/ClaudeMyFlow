---
name: backlog-readme-update
description: Always update docs/workflow/backlog/README.md when creating a ticket, finishing a task, or moving a ticket to done
metadata:
  type: feedback
---

After creating a ticket, completing a task, or moving a ticket from `backlog/`/`inbox/` to `done/`, always update `docs/workflow/backlog/README.md`:
- New ticket → add a row to the active backlog table
- Completed → remove the row from the active table; add it to the "Done" section with a correct `../done/<file>.md` link and a one-line note

**Why:** The README is the board index — leaving done items in the active table creates stale and broken references, and the human relies on this table to see project state at a glance.

**How to apply:** Treat the README update as part of the "Close" step in the board workflow, same as moving the ticket file itself. Related: [[ticket-done-requires-commit]].
