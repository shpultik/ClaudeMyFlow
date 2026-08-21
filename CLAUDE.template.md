<!-- SETUP: This file becomes the project's CLAUDE.md.
     Fill every {{PLACEHOLDER}}, act on and remove every SETUP comment,
     save the result as CLAUDE.md in the repo root, then delete this template.
     Full procedure: SETUP.md Step 2. -->

# CLAUDE.md

## Project Overview

{{PROJECT_DESCRIPTION — 1–3 sentences: what the product is, who it's for, key qualities (e.g. "offline-first", "real-time"). Include the app/package/module id if relevant.}}

**Stack:** {{TECH_STACK — languages, frameworks, target platforms}}

## Commands

```bash
{{BUILD_CMD}}    # Build
{{TEST_CMD}}     # Run tests
{{RUN_CMD}}      # Run locally
{{LINT_CMD}}     # Lint / static analysis
```

<!-- SETUP: Delete command lines that don't apply. Verify each remaining command by running it. -->

<!-- SETUP: If multiple agents may work in this repo in parallel, add a short
     "Parallel agents" paragraph here describing how test/build runs stay isolated
     (e.g. per-run output directories) so agents don't lock each other's files.
     Delete this comment if single-agent. -->

## Architecture

- **Entry point:** {{ENTRY_POINT — main file / composition root / DI registration}}
- **Core logic:** {{CORE_LOGIC — services/domain layer location}}
- **Data:** {{DATA_LAYER — database, ORM, schema location; delete if none}}
- **UI:** {{UI_LAYER — views/pages location; delete if none}}
- **Backend / API:** {{BACKEND — location, protocol, auth mechanism; delete if none}}
- **Tests:** {{TESTS — framework and location}}

Full details: `docs/workflow/documentation/reference/ARCHITECTURE.md`.

## Documentation

Docs live under `docs/workflow/`. See `docs/workflow/README.md` for the full workflow (backlog → inbox → done).

**Living docs** (`docs/workflow/documentation/`):

- `state/` — project snapshot (start here): `CURRENT_STATE.md` (what's implemented now, known drift), `FEATURES.md` (done / planned / known issues), `ROADMAP.md` (upcoming work)
- `reference/` — technical reference: `ARCHITECTURE.md`, `CONFIGURATION.md` (all env vars and config keys), `SECURITY.md`, `BUGS.md`
- `runbooks/` — operations: `RUNBOOK.md`, deployment docs
- `guides/` — how-to: `TESTING.md`, `FEATURE_CHECKLIST.md` (manual testing checklist)
- `features/` — per-feature changelog (done work only)
- `archive/` — point-in-time snapshots (audits, baselines), never edited

**Audits** (`docs/workflow/schedule/`) — monthly/quarterly health-check prompts; results are saved to `docs/workflow/auditResults/`.

## Board Operations

The ticket board lives at `docs/workflow/`. At the start of each session:

1. **Orient** — read `docs/workflow/documentation/state/CURRENT_STATE.md`. Check `inbox/` — if a ticket is there, resume it.
2. **Pick** — if inbox is empty, choose the next ticket from `backlog/` and move it to `inbox/`.
3. **Implement** — do the work. Build and run tests before declaring done.
4. **Record** — add a `## Notes` block to the ticket with what you changed and how you verified it.
5. **Close** — move the ticket file from `inbox/` to `done/` (only after the changes are committed — see Working Rules) and update `backlog/README.md`.
6. **Update docs** — if behaviour changed, update the relevant file in `documentation/`, and update `documentation/state/CURRENT_STATE.md`.

**Creating new tickets:** run `.\new-ticket.ps1 <Prefix> "<title>"` (repo root) — it picks the next free number, generates the file from `docs/workflow/backlog/_TEMPLATE.md`, and prints the path. Then fill in the sections.
Prefix guide: `F` Feature · `B` Bug · `S` Security · `T` Test · `R` Refactor · `A` Analysis · `D` Draft (human stub awaiting agent expansion). Numbers are sequential within each prefix.
**Don't scan the board to find the next number by hand.** Listing every ticket to recover one integer costs ~50× what the script does, and it races: two agents that scan seconds apart pick the same number. The script claims the number atomically, so parallel runs can't collide. For the same reason, don't add a file that stores the last-used number — it drifts from the filenames, which are the real source of truth.
Options: `-Dest inbox` to start in the inbox, `-Scope`/`-Severity`/`-Assignee` to prefill the metadata table, `-DryRun` to preview the path. Anything requiring credentials, production access, or secrets → `-Assignee Human`.
Design sections are kept for `F` tickets and dropped for the rest, per the note in `_TEMPLATE.md`. `-Scope` is left for you to fill when omitted.

## Workflow (CRITICAL)

After ANY code change:

1. Build → fix compile errors
2. Run tests → fix failures
3. **Never stop while build or tests are failing**
4. Update relevant `docs/workflow/documentation/` files if behaviour changed
5. **After adding a feature:** bump the version with `.\bump-version.ps1` (repo root) — one command updates the version source and every doc header listed in `bump-version.config.json`. No args = patch bump; `-Minor` / `-Major` for larger steps; an explicit `x.y.z` to set one; `-DryRun` to preview. **Never edit version fields by hand** — the script aborts loudly when a pattern no longer matches exactly once, and that abort is the only thing that catches drift early.

<!-- SETUP: The step above assumes the shipped bump-version.ps1, configured in SETUP.md Step 4. If this project versions some other way, replace the step with the real procedure. If it doesn't version at all, delete the step entirely — and delete bump-version.ps1 and bump-version.config.json from the repo. -->


## Working Rules

These apply to every session, alongside the board workflow:

- **Docs stay current.** After any change that affects behaviour, update `documentation/state/CURRENT_STATE.md` first, then any other affected living doc. CURRENT_STATE.md is the first thing read next session — it must be accurate.
- **Ticket on discovery.** Any bug, security concern, code smell, or feature idea noticed during other work → create a backlog ticket from `_TEMPLATE.md` before moving on. Observations not written down are lost.
- **Board index maintenance.** Moving a ticket always includes updating `backlog/README.md` — remove it from the active table, add it to the done section with a link and a one-liner.
- **Done requires commit.** Only move a ticket to `done/` after the implementing changes are committed. Work finished but not yet committed → set ticket status to `ready to commit`.
- **Commit scope discipline.** The working tree may contain changes that are not yours (parallel agents, the user's edits). Stage only files you actually edited this session — never `git add -A`. Before staging a file, confirm the diff is yours (`git diff HEAD -- <file>`). Before `--amend` or `reset`, confirm HEAD is actually your commit (`git log --oneline -3`).
- **Security first.** For every feature ask: who can call this? What data is exposed? Can it be abused? Consider injection, auth bypass, data leakage, enumeration, and rate limiting during design — not after.
- **No credentials in the repo.** Never write real secret values (passwords, tokens, keys) into any committed file — docs, tickets, examples, and comments included. Placeholders only. This applies to private repos too.
- **Git workflow:** {{GIT_WORKFLOW — e.g. "solo dev: commit straight to master and push; branch + PR only for large or risky changes" — ask the user if unclear. Also note whether Co-Authored-By lines are wanted in commit messages.}}

## Gotchas

<!-- SETUP: Seed this list with pitfalls discovered while scanning the repo
     (framework quirks, build traps, naming confusions, files that look dead but aren't).
     This list must keep growing: whenever a mistake costs more than ~15 minutes,
     record it here (project-wide) or in memory (cross-session). -->

- {{GOTCHA — or delete the bullet and leave the section empty}}

## Coding Rules

- **Architecture flow:** {{ARCHITECTURE_FLOW — the layering rule, e.g. "Views → ViewModels → Services → Repositories"}}
- **No business logic in the UI layer**, no direct data access from UI
- **Async/await properly**, keep the UI/main thread responsive
- **Tests:** deterministic, no external dependencies; add tests for new logic; fix bugs with minimal changes + a regression test
- **Naming:** follow the project's existing conventions; descriptive names
- Minimal changes — don't rewrite unless asked; follow existing patterns, reuse existing services
- **Surgical changes:** when editing existing code, don't improve adjacent code, comments, or formatting — touch only what the task requires. If your changes create unused imports/variables, remove them; don't remove pre-existing dead code unless asked.
- **Goal-driven execution:** before implementing, convert the task to a verifiable criterion (e.g. "fix bug" → "write a test that reproduces it, then make it pass"). For multi-step tasks, state a brief plan with a verify step for each.
- **Read before edit:** read any file before editing it; grep for all callers before modifying a function. Research before you edit.
- Ask if unclear — don't guess
- **Prefer:** Correctness > Simplicity > Speed
- **Avoid:** overengineering, unnecessary dependencies, silent breaking changes
