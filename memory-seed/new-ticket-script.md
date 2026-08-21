---
name: new-ticket-script
description: File tickets with .\new-ticket.ps1 — never hand-scan the board for the next number, and never add a file that stores the last-used numbers
metadata:
  type: feedback
---

Create every board ticket with `.\new-ticket.ps1 <Prefix> "<title>"` (repo root). It derives the next free number from the existing filenames, generates the file from `_TEMPLATE.md`, and prints the path. Never list the board to work out the next number by hand, and never introduce a counter file that stores the last-used number per prefix.

**Why:** Both alternatives were measured on a real 182-ticket board.

- *Hand-scanning* costs ~4,600 tokens per ticket (215 filenames listed to recover one integer) against ~90 for the script. At 14–16 new tickets/week that is the difference between ~3.6M and ~70k tokens a year.
- *A counter file* measured 1,068 tokens per ticket against 1,045 for deriving from filenames — a 2% saving, inside the measurement error — while adding state that drifts from the filenames and that two agents can both read before either writes. Filenames are the source of truth and cannot drift.
- Most of the residual cost is not the number lookup at all: it is the `_TEMPLATE.md` round-trip (read it, then re-emit its boilerplate when writing). Only *generating* the file removes that, which is why the script beats any lookup-only approach by ~12×.

**The race is real, not theoretical.** On a board with parallel agents, one scan returned "next B = 68" and, minutes later, another agent had created both B68 and B69. An older collision left two different `S1-` tickets in `done/`.

**How to apply:**
- `.\new-ticket.ps1 B "trip stops recording after a restart"` → prints `docs/workflow/backlog/B12-trip-stops-recording-after-a-restart.md`
- `-Dest inbox` to start in the inbox · `-Scope` / `-Severity` / `-Assignee` / `-Bump` to prefill the metadata table · `-DryRun` to preview
- The `Version` row (`major`/`minor`/`patch`/`none`) is the release decision, taken while the change is fresh; the script guesses from the prefix (`F` minor, `B`/`S` patch, rest none) and `-Bump` overrides it. `.\bump-version.ps1 -Ticket <id>` reads it back later ([[version-bump-end-of-work]])
- Anything needing credentials, production access, or secrets → `-Assignee Human` ([[no-credentials-in-repo]])
- Then fill in Problem, Required Changes, and Acceptance Criteria, and add the row to `backlog/README.md` ([[backlog-readme-update]])
- If the script aborts complaining about `_TEMPLATE.md`, the template's header or metadata rows were edited — fix the script to match rather than bypassing it by hand
- A leftover `B12.md` (no title in the name) in `backlog/` is an abandoned reservation from a killed run — delete it and the number frees up

**If you ever need to change how numbers are claimed:** locking the final `{Prefix}{N}-{slug}.md` filename does *not* prevent collisions, because two runs with different titles are different filenames — 5 of 6 parallel runs took the same id that way. The reservation name must depend on nothing but the number, and the "is this number taken" check must happen *after* the reservation is held, since renaming it to the slug name releases it. ([[parallel-agents-commit-scope]])
