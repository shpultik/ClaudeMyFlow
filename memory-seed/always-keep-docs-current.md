---
name: always-keep-docs-current
description: After any change — always update state/CURRENT_STATE.md first, then any other affected living doc
metadata:
  type: feedback
---

After completing any meaningful change, update docs before finishing. Highest priority: `docs/workflow/documentation/state/CURRENT_STATE.md` — update version, what's implemented, known bugs, partial work. Then as applicable: new feature → `FEATURES.md` (Planned → Implemented); bug fixed → `FEATURES.md` Known Issues; structure changed → `reference/ARCHITECTURE.md`; new config key → `reference/CONFIGURATION.md`.

**Why:** The user explicitly wants docs to always reflect current state. CURRENT_STATE.md is the first thing read when orienting at the start of a session — if it's stale, every following decision starts from wrong premises.

**How to apply:** At the end of any task that changes features, version, or architecture — update CURRENT_STATE.md first, then check which other living docs are affected. Treat the doc update as part of the task, not optional follow-up.
