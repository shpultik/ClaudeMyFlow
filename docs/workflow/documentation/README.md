# Documentation

Living project docs for {{PROJECT_NAME}}. Organized into subfolders by type.

## Subfolders

| Folder | Contents |
|--------|----------|
| [`state/`](state/) | Project snapshot: current implementation, feature list, roadmap |
| [`reference/`](reference/) | Technical reference: architecture, config, security, known bugs |
| [`runbooks/`](runbooks/) | Operations: deployment, CI/CD, monitoring, runbooks |
| [`guides/`](guides/) | How-to guides: testing, manual checklist |
| [`features/`](features/) | Per-feature changelog — done work, bug fixes, ticket links |
| [`archive/`](archive/) | Point-in-time snapshots — never edited |

## Quick links

| What you need | File |
|---------------|------|
| What's working now | [state/CURRENT_STATE.md](state/CURRENT_STATE.md) |
| Full feature list | [state/FEATURES.md](state/FEATURES.md) |
| What's next | [state/ROADMAP.md](state/ROADMAP.md) |
| System architecture | [reference/ARCHITECTURE.md](reference/ARCHITECTURE.md) |
| Known bugs | [reference/BUGS.md](reference/BUGS.md) |
| Operations runbook | [runbooks/RUNBOOK.md](runbooks/RUNBOOK.md) |
| How to run tests | [guides/TESTING.md](guides/TESTING.md) |
| Feature history | [features/README.md](features/README.md) |

## Rules

- **state/** and **reference/** are updated whenever the code changes — keep them in sync.
- **runbooks/** and **guides/** change only when processes change.
- **features/** gets a new entry every time a ticket moves to `done/`.
- **archive/** is never edited after a file is placed there.
