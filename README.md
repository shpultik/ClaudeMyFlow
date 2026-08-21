# ClaudeMyFlow

A project-agnostic workflow template for AI-agent-driven development: a ticket board, living documentation, recurring audits, and a set of working rules distilled from months of real agent-driven work.

You drop it into an existing repo, tell the agent to run the setup, and it fills in every project-specific detail by scanning your code — build commands, architecture, config keys, security posture — then deletes its own scaffolding. What's left is a workflow your agent follows in every session.

> The scripts are PowerShell (`.ps1`), so they run as-is on Windows and on PowerShell 7 elsewhere. Everything else is plain Markdown and works with any coding agent.

## Quick start

1. Copy everything in this repo **except this `README.md`** into the root of your project.
2. Open your coding agent (Claude Code or equivalent) in that project.
3. Say: **"Read SETUP.md and run setup."**
4. Review the generated `CLAUDE.md` and the agent's summary; correct anything that reads wrong.

The agent works through [SETUP.md](SETUP.md): it inventories the repo, verifies the build and test commands by actually running them, fills the doc stubs, configures versioning, files tickets for problems it found (without fixing them), and then removes `SETUP.md`, `CLAUDE.template.md`, and `memory-seed/`.

## The daily loop

After setup, work moves in one direction:

```
backlog/  →  inbox/  →  done/
```

- **File** a ticket: `.\new-ticket.ps1 B "invite link does not open the app"`
- **Pick** — the agent moves the next ticket from `backlog/` to `inbox/` and works it, one at a time.
- **Close** — the ticket moves to `done/` only after the change is verified *and committed*, and `backlog/README.md` is updated.
- **Record** — living docs under `docs/workflow/documentation/` are updated in the same session, so the next session starts from an accurate `CURRENT_STATE.md`.
- **Audit** — once a month or quarter, say "run the monthly audits". Prompts live in `docs/workflow/schedule/`, results land in `docs/workflow/auditResults/`, and every finding becomes a backlog ticket.

## What's in the box

| Path | What it is |
|---|---|
| [SETUP.md](SETUP.md) | The one-time setup procedure the agent executes. Deleted when it's done. |
| [CLAUDE.template.md](CLAUDE.template.md) | Becomes your project's `CLAUDE.md`: commands, architecture, board operations, working rules, coding rules. |
| [new-ticket.ps1](new-ticket.ps1) | Creates a ticket with the next free number, generated from the board template. |
| [bump-version.ps1](bump-version.ps1) | Bumps the version in the source file and every doc header that repeats it. |
| [bump-version.config.json](bump-version.config.json) | Declares where the version lives and which files mirror it. |
| [docs/workflow/](docs/workflow/) | The board (`backlog`, `inbox`, `done`), living docs, audit prompts, audit results. |
| [memory-seed/](memory-seed/) | Pre-written agent memories — seeded into the agent's memory directory, then deleted. |

### Living documentation

Tickets describe *changes*; the docs under `docs/workflow/documentation/` describe *current state*. They're split so an agent knows where to look and where to write:

| Folder | Contents |
|---|---|
| `state/` | `CURRENT_STATE.md` (read first, every session), `FEATURES.md`, `ROADMAP.md` |
| `reference/` | `ARCHITECTURE.md`, `CONFIGURATION.md`, `SECURITY.md`, `BUGS.md` |
| `guides/` | `TESTING.md`, `FEATURE_CHECKLIST.md` |
| `runbooks/` | `RUNBOOK.md` — deploy and ops procedures |
| `features/` | Per-feature changelog, appended when a ticket closes |
| `archive/` | Point-in-time snapshots. Never edited. |

### Audits

Seven recurring health checks, tailored to your project during setup:

**Monthly** — test quality, security review, docs drift, dependency audit, API contract (client calls vs. server endpoints).
**Quarterly** — code complexity, performance check.

## Why the scripts exist

Both scripts replace something an agent would otherwise do by hand, badly:

**`new-ticket.ps1`** — filenames are the source of truth for ticket numbers; there is no counter file to drift. Scanning a real 182-ticket board by hand to find the next number costs roughly 4,600 tokens and races: two agents that scan seconds apart pick the same number. The script costs about 90 tokens and claims the number atomically, so parallel agents can't collide.

**`bump-version.ps1`** — every version pattern must match its file exactly once. If one matches zero times or several, the script aborts *before writing anything*. That abort is the point: it's what catches a version number that has quietly drifted out of a doc header.

## Working rules

The rules that end up in your `CLAUDE.md` — and, if your agent has one, its persistent memory:

- **Docs stay current.** Behaviour changed → `CURRENT_STATE.md` is updated in the same session.
- **Ticket on discovery.** A bug, smell, or idea noticed during other work gets a backlog ticket before moving on. Observations not written down are lost.
- **Done requires commit.** A ticket reaches `done/` only after its changes are committed.
- **Commit scope discipline.** Stage only files you edited this session — never `git add -A`. The working tree may hold changes from parallel agents or the user.
- **Security first.** Who can call this? What data is exposed? Can it be abused? Asked during design, not after.
- **No credentials in the repo.** Placeholders only — in docs, tickets, examples, and comments. Private repos included.
- **Never stop while the build or tests are failing.**

## Requirements

- A coding agent that reads a `CLAUDE.md`-style instruction file — built for [Claude Code](https://claude.com/claude-code), works with any equivalent.
- PowerShell (Windows PowerShell 5.1 or PowerShell 7+) for the two scripts. Skip or port them if you'd rather not; nothing else depends on them.
- Git — the workflow assumes commits gate ticket completion.

## License

MIT — see [LICENSE](LICENSE).
