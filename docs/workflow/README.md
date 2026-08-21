# Workflow

AI-first ticket board and living documentation for {{PROJECT_NAME}}.

## Structure

- `backlog/` — Queued tickets that are real but not yet in active execution.
- `inbox/` — One markdown file per active open task. Tickets stay here while being worked.
- `done/` — Completed and verified tickets. `REJECTED` tickets also live here.
- `schedule/` — Recurring audit prompts (monthly/quarterly health checks).
- `auditResults/` — Dated audit reports produced by running the `schedule/` audits.
- `documentation/` — Living project docs, organized into subfolders by type (see `documentation/README.md`).
- `documentation/archive/` — Point-in-time snapshots (audits, baselines). Never edited.

## Workflow

1. Keep queued work in `backlog/`.
2. Move the next task into `inbox/` when it is ready for active execution.
3. Implement the changes in the codebase.
4. Record verification notes in the ticket file under `## Notes`.
5. If the project versions, bump it before committing: `.\bump-version.ps1 -Ticket {ID}` uses the level recorded in the ticket's `Version` row.
6. Move the ticket file to `done/` only after the change is verified **and committed**, and update `backlog/README.md`.

The agent responsible for the project creates, updates, and moves tickets.
The human uses the board to stay oriented and redirect work when needed.

## Naming

- Ticket files: `{ID}-{kebab-case-title}.md` (e.g., `F1-forgot-password-flow.md`)
- ID prefixes: `S` = Security · `F` = Feature · `T` = Test · `B` = Bug · `R` = Refactor · `A` = Analysis · `D` = Draft (human stub awaiting agent expansion)
- Numbers are sequential within each prefix.

## Documentation

Living docs describe *current state*. Tickets describe *changes*.
See `documentation/README.md` for the full index.

| File | Purpose |
|---|---|
| `documentation/state/CURRENT_STATE.md` | What's implemented now, what's partial, known drift |
| `documentation/state/FEATURES.md` | Complete feature list — current state |
| `documentation/state/ROADMAP.md` | Planned and partial work only (not current-state claims) |
| `documentation/reference/ARCHITECTURE.md` | System architecture, topology, data flow |
| `documentation/reference/CONFIGURATION.md` | All env vars and config keys |
| `documentation/reference/SECURITY.md` | Security posture, gaps, guidance |
| `documentation/reference/VERSIONING.md` | What major/minor/patch mean here, and every file the version is written to |
| `documentation/reference/BUGS.md` | Known bugs and investigations |
| `documentation/runbooks/RUNBOOK.md` | Operations: restarts, log checks, backups |
| `documentation/guides/TESTING.md` | How to run, build, test, code patterns |
| `documentation/guides/FEATURE_CHECKLIST.md` | Manual testing checklist |
| `documentation/features/` | Per-feature changelog — done work, bug fixes, ticket links |

Archive files go in `documentation/archive/` with a date in the filename
(e.g., `SECURITY_AUDIT_2027_BASELINE.md`). Never update them.
