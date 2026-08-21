---
name: backlog-ticket-on-discovery
description: Always create a backlog ticket when noticing a bug, potential issue, or feature idea — even if not acting on it immediately
metadata:
  type: feedback
---

Whenever a bug, problem, or feature idea is noticed — during investigation, code review, or planning — file a ticket with `.\new-ticket.ps1 <Prefix> "<title>"` before moving on ([[new-ticket-script]]).

**Why:** Observations get lost if not written down. The backlog is the single source of truth for what was found, why it matters, and what the fix or design should look like. Creating the ticket is how the thinking is preserved.

**How to apply:**
- Spotted a bug during unrelated work → create a `B{N}` ticket before continuing
- Discussing a new feature idea → create an `F{N}` ticket to capture the design thinking
- Found a security concern → create an `S{N}` ticket
- Noticed a code smell or structural issue → create an `R{N}` or `A{N}` ticket
- Fill in Problem, Required Changes, and Acceptance Criteria at minimum
- Remember to update `backlog/README.md` with the new entry ([[backlog-readme-update]])
