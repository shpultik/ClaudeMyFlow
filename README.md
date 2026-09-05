# ClaudeMyFlow

A project-agnostic workflow template for AI-agent-driven development: a filesystem ticket board, living documentation, recurring audits, and a set of working rules distilled from months of real agent-driven work.

Drop it into an existing repo, tell your agent to run the setup, and it fills in every project-specific detail by scanning your code — build commands, architecture, config keys, security posture — then deletes its own scaffolding. What's left is a workflow your agent follows in every session.

Built and battle-tested with [Claude Code](https://claude.com/claude-code) (hence the name), but the workflow itself is plain Markdown and works with any agent that reads an instructions file — see [Using it with other agents](#using-it-with-other-agents).

## Why

Coding agents start every session cold. Left to itself, an agent re-derives what the project is, forgets what it decided last time, and loses the bug it noticed but didn't stop to fix. ClaudeMyFlow gives it somewhere to put those things that it reads back automatically:

- **`CURRENT_STATE.md`** — read first, every session. The agent orients from an accurate snapshot instead of guessing from the code.
- **The board** (`backlog/ → inbox/ → done/`) — plain Markdown files, versioned with the code, so a ticket filed on Monday is still there on Friday. No external tracker, no tool call to read it.
- **Living docs** — describe *current state*; tickets describe *changes*. Split so the agent knows where to look and where to write.
- **Working rules** — the mistakes that cost time once ("committed a secret", "bundled a parallel agent's changes", "let the version drift") encoded so they don't recur.

## Quick start

1. Copy everything in this repo **except this `README.md`** into the root of your project.
2. Open your coding agent in that project.
3. Say: **"Read SETUP.md and run setup."**
4. Review the generated `AGENTS.md` and the agent's summary; correct anything that reads wrong.

The agent works through [SETUP.md](SETUP.md): it inventories the repo, verifies the build and test commands by actually running them, fills the doc stubs, configures versioning, files tickets for problems it found (without fixing them), then removes `SETUP.md`, `AGENTS.template.md`, and `memory-seed/`.

- **Already have an `AGENTS.md` or `CLAUDE.md`?** Setup merges into it — your existing commands and rules are kept.
- **Want to undo it?** It's all one commit; `git revert` removes it cleanly.

## What setup produces

Everything lands under `docs/workflow/`, plus an instructions file and the helper scripts at the repo root:

```
your-repo/
├── AGENTS.md                     # agent instructions: commands, architecture, rules
├── CLAUDE.md                     # one line, pointing Claude Code at AGENTS.md
├── new-ticket.ps1
├── bump-version.ps1
├── bump-version.config.json
└── docs/workflow/
    ├── backlog/  inbox/  done/   # the board — one Markdown file per ticket
    ├── documentation/
    │   ├── state/                # CURRENT_STATE, FEATURES, ROADMAP
    │   ├── reference/            # ARCHITECTURE, CONFIGURATION, SECURITY, VERSIONING, BUGS
    │   ├── guides/               # TESTING, FEATURE_CHECKLIST
    │   ├── runbooks/             # RUNBOOK
    │   └── features/             # per-feature changelog
    ├── schedule/                 # recurring audit prompts
    └── auditResults/             # dated audit reports
```

## The daily loop

After setup, work moves in one direction: `backlog/ → inbox/ → done/`. You mostly talk to the agent; the agent runs the scripts.

- **File** *(you or the agent)* — `.\new-ticket.ps1 B "invite link does not open the app"` creates the next-numbered ticket from the board template. It also records how shipping the ticket moves the version (`major` / `minor` / `patch` / `none`), guessed from the prefix and overridable with `-Bump`.
- **Pick** *(agent)* — moves the next ticket from `backlog/` to `inbox/` and works it, one at a time.
- **Implement** *(agent)* — makes the change, builds, runs tests; never stops on a red build.
- **Bump** *(agent)* — `.\bump-version.ps1 -Ticket B12` applies the level that ticket recorded, across the version source and every doc header that repeats it.
- **Close** *(agent)* — moves the ticket to `done/` only after the change is verified *and committed*, and updates `backlog/README.md`.
- **Record** *(agent)* — updates the living docs under `docs/workflow/documentation/` in the same session, so the next session starts from an accurate `CURRENT_STATE.md`.
- **Audit** *(you trigger, agent runs)* — once a month or quarter, say "run the monthly audits". Prompts live in `docs/workflow/schedule/`, results land in `docs/workflow/auditResults/`, and every finding becomes a backlog ticket.

## Example ticket

```markdown
# B12 — invite link does not open the app

## Metadata
| Field    | Value |
|----------|-------|
| Status   | `inbox` |
| Assignee | `Agent` |
| Scope    | `APP` |
| Severity | `HIGH` |
| Version  | `patch` |

## Problem
Opening an invite link launches a browser tab instead of the app. The link
handler is never registered for the `https` scheme, so the OS has nothing
to route the URL to.

## Required Changes
- Register the `https` deep-link handler for the invite host
- Route a matched link to the invite screen

## Acceptance Criteria
- [ ] An invite link opens the app directly, on the invite screen
- [ ] A regression test covers the link parsing
```

Features additionally keep Design / Open questions / Phasing sections; see [`_TEMPLATE.md`](docs/workflow/backlog/_TEMPLATE.md).

## What's in the box

| Path | What it is |
|---|---|
| [SETUP.md](SETUP.md) | The one-time setup procedure the agent executes. Deleted when it's done. |
| [AGENTS.template.md](AGENTS.template.md) | Becomes your project's `AGENTS.md`: commands, architecture, board operations, working rules, coding rules. |
| [new-ticket.ps1](new-ticket.ps1) | Creates a ticket with the next free number, generated from the board template. |
| [bump-version.ps1](bump-version.ps1) | Bumps the version in the source file and every doc header that repeats it. |
| [bump-version.config.json](bump-version.config.json) | Declares where the version lives and which files mirror it. |
| [docs/workflow/](docs/workflow/) | The board (`backlog`, `inbox`, `done`), living docs, audit prompts, audit results. |
| [memory-seed/](memory-seed/) | Pre-written agent memories for Claude Code — seeded into its memory directory, then deleted. Skipped for agents without a memory system. |

### Living documentation

Tickets describe *changes*; the docs under `docs/workflow/documentation/` describe *current state*. They're split so an agent knows where to look and where to write:

| Folder | Contents |
|---|---|
| `state/` | `CURRENT_STATE.md` (read first, every session), `FEATURES.md`, `ROADMAP.md` |
| `reference/` | `ARCHITECTURE.md`, `CONFIGURATION.md`, `SECURITY.md`, `VERSIONING.md`, `BUGS.md` |
| `guides/` | `TESTING.md`, `FEATURE_CHECKLIST.md` |
| `runbooks/` | `RUNBOOK.md` — deploy and ops procedures |
| `features/` | Per-feature changelog, appended when a ticket closes |
| `archive/` | Point-in-time snapshots. Never edited. |

### Audits

Seven recurring health checks, tailored to your project during setup:

**Monthly** — test quality, security review, docs drift, dependency audit, API contract (client calls vs. server endpoints).
**Quarterly** — code complexity, performance check.

## Using it with other agents

The workflow is plain Markdown; only the entry point differs by tool.

- **Claude Code** — reads `CLAUDE.md`, which points at `AGENTS.md`; nothing to do. `memory-seed/` is copied into its memory directory during setup.
- **Codex, Amp, Zed, Cursor, and others that read `AGENTS.md`** — nothing to do; the generated `AGENTS.md` is the file they already look for.
- **Agents that read a different file** (`.cursorrules`, `GEMINI.md`, `.windsurfrules`, …) — tell the agent during setup and it will add a one-line pointer to `AGENTS.md` from that file.
- **Any agent with no persistent memory** — the `memory-seed/` step is skipped automatically; the same rules live in `AGENTS.md`'s Working Rules section.

Whatever the tool, the session-start instruction is the same: *read `docs/workflow/documentation/state/CURRENT_STATE.md`, check `inbox/`, then pick from `backlog/`.*

## Why the scripts exist

Both scripts replace something an agent would otherwise do by hand, badly:

**`new-ticket.ps1`** — filenames are the source of truth for ticket numbers; there is no counter file to drift. Scanning a real 182-ticket board by hand to find the next number costs roughly 4,600 tokens and races: two agents that scan seconds apart pick the same number. The script costs about 90 tokens and claims the number atomically, so parallel agents can't collide.

**`bump-version.ps1`** — every version pattern must match its file exactly once. If one matches zero times or several, the script aborts *before writing anything*. That abort is the point: it's what catches a version number that has quietly drifted out of a doc header. It also reads the bump level off the ticket's `Version` row, so "was that a feature or a fix?" is answered once, while the change is fresh, rather than re-derived from a diff at release time.

## Working rules

The rules that end up in your `AGENTS.md` — and, for Claude Code, its persistent memory:

- **Docs stay current.** Behaviour changed → `CURRENT_STATE.md` is updated in the same session.
- **Ticket on discovery.** A bug, smell, or idea noticed during other work gets a backlog ticket before moving on. Observations not written down are lost.
- **Done requires commit.** A ticket reaches `done/` only after its changes are committed.
- **Commit scope discipline.** Stage only files you edited this session — never `git add -A`. The working tree may hold changes from parallel agents or the user.
- **Security first.** Who can call this? What data is exposed? Can it be abused? Asked during design, not after.
- **No credentials in the repo.** Placeholders only — in docs, tickets, examples, and comments. Private repos included.
- **Never stop while the build or tests are failing.**

## Requirements

- **A coding agent that reads an instructions file** (`AGENTS.md`, `CLAUDE.md`, or equivalent). Built for [Claude Code](https://claude.com/claude-code); works with any equivalent — see [Using it with other agents](#using-it-with-other-agents).
- **Git** — the workflow assumes commits gate ticket completion.
- **PowerShell** (Windows PowerShell 5.1 or PowerShell 7+, which also runs on macOS and Linux) — *only* for the two helper scripts. Everything else is Markdown; skip or port the scripts and nothing else depends on them.

## License

MIT — see [LICENSE](LICENSE).
