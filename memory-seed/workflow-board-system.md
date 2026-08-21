---
name: workflow-board-system
description: This project uses the ClaudeMyFlow board at docs/workflow/ — backlog/inbox/done tickets, living documentation, scheduled audits; orient via CURRENT_STATE.md at session start
metadata:
  type: project
---

This project runs on a ticket board at `docs/workflow/`: `backlog/` (queued), `inbox/` (active — resume first at session start), `done/` (completed, verified, committed). Living docs live in `docs/workflow/documentation/` (start orientation at `state/CURRENT_STATE.md`). Recurring audit prompts are in `docs/workflow/schedule/`, results in `docs/workflow/auditResults/`.

**Why:** The board is the shared source of truth between the human and agents across sessions — work not on the board effectively doesn't exist.

**How to apply:** Session start: read `CURRENT_STATE.md`, check `inbox/`, resume or pick from `backlog/`. During work: [[backlog-ticket-on-discovery]], [[always-keep-docs-current]]. Closing: [[ticket-done-requires-commit]], [[backlog-readme-update]].
