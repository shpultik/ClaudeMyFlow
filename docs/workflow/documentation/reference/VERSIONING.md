# Versioning — {{PROJECT_NAME}}

The version is `x.y.z`. One file owns the real number; every other place that shows it is a copy kept in sync by `bump-version.ps1`. Nothing is edited by hand.

## What each part means

| Level | Bump when | Examples | Not this |
|---|---|---|---|
| `major` (x) | Something that worked stops working without intervention | Removed or renamed a public API, endpoint, or CLI flag; schema change with no migration path; config key renamed with no fallback; dropped support for a platform or format | Internal rename nobody outside can see |
| `minor` (y) | New capability, nothing existing broken | New screen, endpoint, command, or export format; new optional config key; a limit raised; a feature flag turned on by default | A fix that restores intended behaviour |
| `patch` (z) | Wrong behaviour becomes right, or something invisible improves | Bug fix; crash fix; performance work; dependency bump with no API change; corrected copy or validation message | Anything a user could newly *do* |
| `none` | Nothing shippable changed | Tests, pure refactors, doc edits, analysis tickets, board housekeeping, CI config | A refactor that changes observable behaviour — that is at least `patch` |

**Tie-breakers.** A change that both fixes and adds takes the higher level. Unsure between `minor` and `patch`: *could a user or caller now do something they could not do before?* Yes → `minor`. Unsure between `major` and `minor`: *does anything that worked yesterday need a human to fix it?* Yes → `major`.

**Shipping several tickets at once:** bump once, at the highest level among them.

<!-- SETUP: If this project is pre-1.0 and treats 0.x as "anything may break",
     say so here explicitly and state what a 0.x major/minor means in practice.
     Delete this comment either way. -->

## Deciding the level

The call is made **when the ticket is filed**, not at release time — the change is freshest then, and a diff weeks later is the worst evidence to decide from. Every ticket carries the decision in its metadata:

```
| Version  | `minor` |
```

`new-ticket.ps1` prefills it from the ticket prefix, and `-Bump` overrides when that guess is wrong:

| Prefix | Default | Override when |
|---|---|---|
| `F` Feature | `minor` | The feature replaces something existing → `-Bump major` |
| `B` Bug · `S` Security | `patch` | The fix changes a contract → `-Bump major`; internal-only → `-Bump none` |
| `R` Refactor · `T` Test · `A` Analysis · `D` Draft | `none` | The refactor drops a public path → `-Bump major`; observable change → `-Bump patch` |

```powershell
.\new-ticket.ps1 F "offline map download"                    # minor, by default
.\new-ticket.ps1 R "drop the v1 sync endpoint" -Bump major   # default was wrong
```

The row is not frozen — if the work turns out bigger than the ticket assumed, edit it before bumping.

## Where the version is written

`bump-version.config.json` (repo root) lists every place, and `bump-version.ps1` updates all of them in one run:

| Role | Config key | Typical file | Pattern shape |
|---|---|---|---|
| **Source of truth** — the one file that owns the number | `versionSource` | `src/App/App.csproj`, `package.json`, or a plain `VERSION` | `<Version>(?<ver>\d+\.\d+\.\d+)</Version>` |
| **Copies** — docs that restate the version in a header | `targets[]` | `state/CURRENT_STATE.md`, `state/FEATURES.md`, `reference/ARCHITECTURE.md` | `> Version: (?<ver>\d+\.\d+\.\d+)` |
| **Build counter** — separate monotonic integer, if the project has one | `buildNumber` | `src/App/App.csproj` | `<ApplicationVersion>(?<num>\d+)</ApplicationVersion>` |

Every pattern must match its file **exactly once**. That is the drift check: if a pattern matches zero times or twice, the script aborts *before writing anything*, because a file that no longer looks the way the config expects is a file whose version can silently go stale.

**Do not add as targets:** changelogs and release notes (they list many versions, so the pattern matches more than once), lock files, generated or build-output files, and anything vendored. A `> Version:` line in a doc header is a target; a version *mentioned in prose* is not.

## Applying it

```powershell
.\bump-version.ps1 -Ticket F12   # use the level recorded on ticket F12
.\bump-version.ps1               # patch  1.2.3 -> 1.2.4
.\bump-version.ps1 -Minor        #        1.2.3 -> 1.3.0
.\bump-version.ps1 -Major        #        1.2.3 -> 2.0.0
.\bump-version.ps1 1.4.0         # set an exact version
.\bump-version.ps1 -DryRun       # print the plan, write nothing
```

`-Ticket` accepts an id (`F12`, searched for across every board folder) or a path to a ticket file. A ticket marked `none` writes nothing and says so. `-Ticket` cannot be combined with `-Minor`, `-Major`, or an explicit version.

## Rules

- **Never edit a version field by hand.** The script's abort-on-drift is the only early warning that a doc header has fallen behind; hand edits are exactly how that happens.
- **Bump at the end of the work, before the commit** — not when starting, not in a separate commit afterwards.
- **Check `git diff` first.** If the version is already changed in the working tree and uncommitted, someone else already bumped it — leave it. Double-bumping wastes numbers and confuses history.
- **A drift abort is a finding, not an obstacle.** Fix the file or the config; never loosen a pattern to make the error go away.

## Setting this up in another repository

Two files carry the mechanism, plus a third if that repo runs a ticket board:

1. `bump-version.ps1` and `bump-version.config.json` → repo root.
2. In `bump-version.config.json`, set `versionSource.file` and its pattern to whichever file owns the version there. List the doc headers that repeat it under `targets`, and delete the rows for docs that repo does not have. Leave `buildNumber` as `null` unless there is a separate build counter.
3. If that repo has a ticket board, add a `| Version |` row to its ticket template and copy `new-ticket.ps1` too; without a board, `-Ticket` is simply unused and the `-Minor`/`-Major` flags carry the whole job.
4. Verify with `.\bump-version.ps1 -DryRun` — it prints the current version and every file it would touch. The script refuses to run while the config still holds unfilled setup placeholders.
