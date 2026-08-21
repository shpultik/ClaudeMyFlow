---
name: parallel-agents-commit-scope
description: When committing, only include changes made by this agent — parallel agents or the user may have uncommitted changes; don't accidentally bundle them
metadata:
  type: feedback
---

Before running `git commit`, always check `git status` and `git diff --stat` carefully. The working tree may contain changes from parallel agents or the user. If it contains files you didn't touch, those belong to someone else's task — do not stage or commit them.

Safe pattern:
1. Identify ONLY the files this agent actually changed during the current session
2. `git add <exactly those files>` — even named files can be wrong if someone else also touched the same file
3. `git diff --cached` — verify staged content before committing; if anything unexpected appears, unstage it
4. Never commit on behalf of someone else's work

**Why:** This has failed twice in a prior project — first with a broad `git add -A`, then again with explicit `git add file1 file2 ...` that named files already modified by a parallel agent. Running `git diff HEAD -- <file>` before staging catches this.

**How to apply:** Before staging any file, confirm: "Did I edit this file in this session?" If unsure, run `git diff HEAD -- <file>` and check whether the change matches what this agent did.

**Amend/reset hazard:** A parallel agent can commit on top of yours between your `git commit` and any follow-up git operation. Then a no-arg `git commit --amend` rewrites *their* commit, and `git reset --soft HEAD~1` drops *their* commit. Guards: before `--amend`/`reset`, run `git log --oneline -3` and confirm HEAD is actually your commit. If you do clobber a parallel commit, recover it faithfully with `git cherry-pick <sha-from-reflog>` rather than re-creating their changes yourself.
