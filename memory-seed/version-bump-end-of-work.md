---
name: version-bump-end-of-work
description: If the project versions — bump the version at the end of feature work; but if the version was already changed and not yet committed, leave it alone
metadata:
  type: feedback
---

If this project has a version number: after completing feature work, bump the version as part of finishing (per the project's versioning scheme in CLAUDE.md). But first check `git diff` — if the version was already changed in the working tree and not yet committed (e.g. by the user or a parallel agent), leave it as is rather than bumping again.

**Why:** Double-bumping wastes version numbers and creates confusing history; forgetting to bump makes releases and bug reports ambiguous. In a prior project the version and test counts drifted 5 releases behind when updated by hand — if the project has a bump script, always use it instead of editing version fields manually.

**How to apply:** End of feature work → check whether the version is already dirty in `git status`/`git diff`; if clean, bump with `.\bump-version.ps1` (no args = patch, `-Minor`/`-Major` for larger steps, `-DryRun` to preview); if dirty, leave it. The script also updates every doc header listed in `bump-version.config.json`, so don't touch those by hand ([[always-keep-docs-current]]). If it aborts saying a pattern matched 0 or 2+ times, a file drifted — fix the file or the config, never loosen the pattern to make the error go away.
