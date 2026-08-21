# ClaudeMyFlow — Setup

A project-agnostic AI-agent workflow template: ticket board (backlog → inbox → done), living documentation, scheduled audits, and working rules distilled from months of real agent-driven development.

## How to use (human)

1. Copy **everything in this folder except `README.md`** into the root of your solution/repo. (That README describes the template itself; your project keeps its own.)
2. Open Claude Code (or another agent) in that solution.
3. Say: **"Read SETUP.md and run setup."**
4. Review the generated `CLAUDE.md` and the agent's summary; correct anything that reads wrong.

That's it. The agent fills in all project specifics by scanning your repo, then removes the template scaffolding (this file, `CLAUDE.template.md`, `memory-seed/`).

After setup, the daily loop is:

- You (or the agent) file tickets in `docs/workflow/backlog/` — `.\new-ticket.ps1 B "short title"` creates one with the next free number, ready to fill in.
- The agent works them through `inbox/` → `done/`, one at a time.
- Living docs in `docs/workflow/documentation/` stay in sync with the code.
- Once a month / quarter, say "run the monthly audits" — prompts live in `docs/workflow/schedule/`, results land in `docs/workflow/auditResults/`.

---

## Setup procedure (agent)

You are setting up the ClaudeMyFlow workflow in this repository. Work through every step in order and do not skip the verification at the end. Do **not** start feature work during setup — if you find problems, file tickets for them (Step 7).

### Step 0 — Preconditions

- If `docs/workflow/` existed in this repo **before** this template was copied in (check git history, or ask), stop and ask the user how to merge.
- If the repo is not a git repository, ask the user whether to `git init` first.

### Step 1 — Inventory the repo

Scan the repository and establish:

- Language(s), framework(s), target platform(s)
- Build system and the exact build command; test framework and the exact test command; run/launch command; lint command if any — **verify each command actually works by running it**
- Entry point(s) / composition root (main, DI registration, app bootstrap)
- Data layer (database, ORM, where the schema lives) — or none
- Client/server split (app + API backend) — or a single component
- CI/CD (workflow files), deployment mechanism
- Versioning scheme (where the version number lives, how it gets bumped) — or none
- Existing docs (README, an existing CLAUDE.md, docs folders)

### Step 2 — Create CLAUDE.md

- Open `CLAUDE.template.md`. Fill every `{{PLACEHOLDER}}` from your Step 1 inventory and act on then delete every `<!-- SETUP: ... -->` comment.
- Sections that genuinely don't apply (e.g. no backend, no versioning): **delete them cleanly** rather than leaving "N/A" noise.
- If the repo already has a `CLAUDE.md`: merge. Keep the existing file's project-specific facts (commands, gotchas, rules the user already wrote); adopt the template's **Documentation, Board Operations, Workflow, Working Rules, and Coding Rules** sections.
- Save the result as `CLAUDE.md` in the repo root. Delete `CLAUDE.template.md`.

### Step 3 — Fill the documentation stubs

In `docs/workflow/documentation/`, fill each stub from your inventory. Resolve every `{{...}}` and `<!-- SETUP: ... -->`:

| File | Fill with |
|---|---|
| `state/CURRENT_STATE.md` | Honest snapshot of what exists and works **today** |
| `state/FEATURES.md` | Implemented / planned / known-issue lists |
| `state/ROADMAP.md` | Upcoming work — ask the user; if unknown, write `TBD` explicitly |
| `reference/ARCHITECTURE.md` | Components, data flow, key files, patterns |
| `reference/CONFIGURATION.md` | Every env var / config key you can find: default, meaning |
| `reference/SECURITY.md` | Brief posture assessment: secrets handling, auth, attack surface |
| `reference/BUGS.md` | Leave the empty table; add rows only for bugs you actually found |
| `guides/TESTING.md` | How to run tests, test structure, how to write new ones |
| `guides/FEATURE_CHECKLIST.md` | Manual pre-release checks, if derivable; else `TBD` |
| `runbooks/RUNBOOK.md` | Deploy/ops procedures if discoverable; else `TBD` |

Where something is truly unknowable from the repo, write `TBD — fill in when known`. **Never guess.**

### Step 4 — Set up versioning

`bump-version.ps1` ships with this template and is driven entirely by `bump-version.config.json`. Fill that config from your Step 1 inventory:

- `versionSource` — the single file that owns the version number, plus a regex containing a `(?<ver>...)` group. The placeholder text lists examples for a csproj, a `package.json`, and a plain `VERSION` file.
- `targets` — every other file that repeats the version, typically the doc headers already listed there. Delete rows for docs that don't carry a version; add rows for any that do.
- `buildNumber` — leave `null` unless the project has a separate monotonic build counter; `_buildNumberExample` shows the shape.

Every pattern must match its file **exactly once**. The script aborts before writing anything if one matches zero or several times — that check is the whole point, so don't loosen a pattern to make it match.

Verify with `.\bump-version.ps1 -DryRun`: it prints the current version and each file it would touch. The script refuses to run while any `{{placeholder}}` remains in the config.

**Version impact per ticket.** Tickets carry a `Version` row (`major` / `minor` / `patch` / `none`) that `new-ticket.ps1` fills from the prefix — `F` → minor, `B`/`S` → patch, everything else → none — and `.\bump-version.ps1 -Ticket <id>` reads back at release time. Nothing to configure, but if this project's prefixes mean something different, edit `$bumpDefaults` in `new-ticket.ps1`.

**If the project has no version number**, delete `bump-version.ps1` and `bump-version.config.json`, delete the version-bump step from `CLAUDE.md`'s Workflow section, and delete the `| Version |` row from `docs/workflow/backlog/_TEMPLATE.md` along with the rule describing it in `backlog/README.md` and the bump step in `docs/workflow/README.md`. `new-ticket.ps1` handles the missing row on purpose — it just stops filling it.

### Step 5 — Adapt the audit schedule

In `docs/workflow/schedule/`, tailor each audit's project-specific parts (marked with `SETUP` comments): critical paths in `test-audit.md`, attack surfaces and search terms in `security-review.md`, the dependency manifest in `dependency-audit.md`, hot areas in `performance-check.md`, composition root in `code-complexity.md`.

If the project has **no client/server split**, delete `api-contract.md` and remove its row from `schedule/README.md`.

### Step 6 — Seed memory (if available)

If your system prompt gives you a persistent memory directory:

1. Copy each file from `memory-seed/` (except its README) into that memory directory. Skip any file whose name already exists there.
2. Add one index line per copied memory to your `MEMORY.md`, per your memory system's format.
3. `solo-dev-commit-to-master.md` encodes a solo-developer git workflow — confirm with the user that this project is also solo before seeding it; skip it for team projects.

If you have no memory system, skip this — the same rules are baked into CLAUDE.md.

**Either way, delete the `memory-seed/` folder from the repo afterwards.**

### Step 7 — Board

- Put the project name into `docs/workflow/backlog/README.md` and `docs/workflow/README.md`.
- Adjust the ticket template's `Scope` values in `docs/workflow/backlog/_TEMPLATE.md` to this project's components.
- If Step 1 turned up real problems (failing build, zero tests, obvious security smells), file backlog tickets for them with `.\new-ticket.ps1 <Prefix> "<title>"` — **file them, don't fix them now.** The script picks the next free number and generates the ticket from `_TEMPLATE.md`; adjust the `Scope` values (bullet above) first so it can fill that row via `-Scope`.

### Step 8 — Verify and finish

- Delete `SETUP.md`.
- Verification checklist — all must pass:
  - [ ] `CLAUDE.md` exists at repo root; `CLAUDE.template.md`, `SETUP.md`, and `memory-seed/` are gone
  - [ ] Searching `CLAUDE.md`, `docs/workflow/`, **and `bump-version.config.json`** for `{{` returns **zero** hits — the config sits at the repo root, outside the folders above, so it is the one that gets missed
  - [ ] Searching `CLAUDE.md` and `docs/workflow/` for `SETUP:` returns **zero** hits
  - [ ] The build command written in CLAUDE.md was actually run and works
  - [ ] The test command written in CLAUDE.md was actually run and works (or CLAUDE.md honestly says there are no tests yet)
  - [ ] `.\new-ticket.ps1 B "setup smoke test" -DryRun` prints a path (proves the script can read `_TEMPLATE.md`; it aborts loudly if the template's header or metadata rows were changed)
  - [ ] `.\bump-version.ps1 -DryRun` prints the current version and its target files — or `bump-version.ps1` and `bump-version.config.json` were deleted because the project doesn't version (Step 4)
- Commit the workflow files (message: `chore: set up ClaudeMyFlow workflow`), following the project's git workflow. Stage only the files this setup created or edited.
- Report to the user: what you filled in, what's `TBD`, which tickets you created, and anything that surprised you.
