---
name: solo-dev-commit-to-master
description: For routine work the user is the only developer; commit & push directly to the default branch. Only create a branch + PR for big or critical changes.
metadata:
  type: feedback
---

For routine work — bug fixes, small features, refactors, doc updates, operational changes — commit straight to the default branch and push. The user is the sole developer and doesn't need PR review for everything.

**Why:** The user has stated they work solo and reflexive branching for small changes only adds ceremony.

**How to apply:**
- **Default:** work on the default branch, commit, push. No branch.
- **Never** add `Co-Authored-By: Claude ...` lines to commit messages — the user explicitly doesn't want them.
- **Make a branch + PR only when:** the change is large (touches many subsystems, hard to review as one diff), risky/critical (could break production — non-backwards-compatible migrations, breaking API changes, auth/payment changes), or the user explicitly asks.
- When unsure between "small enough for the default branch" and "warrants a branch", ask once. Don't reflexively branch.
- Respect [[parallel-agents-commit-scope]] on every commit.
