# Docs Drift Audit

**Cadence:** Monthly
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-docs-drift.md`

## What to check

Compare each living doc against actual code. Flag stale claims, missing features, and undocumented changes.

| Doc | What to verify |
|-----|----------------|
| `CURRENT_STATE.md` | "Implemented" features exist in code; "partial" items still partial |
| `ARCHITECTURE.md` | Listed components, endpoints, data models match actual files |
| `FEATURES.md` | "Done" features shipped; known issues still present |
| `ROADMAP.md` | "In progress" items still being worked; completed items moved |
| `TESTING.md` | Described test structure matches actual test files |
| `BUGS.md` | Listed bugs still reproducible; fixed ones removed |

## Files to review

- `docs/workflow/documentation/state/CURRENT_STATE.md`
- `docs/workflow/documentation/reference/ARCHITECTURE.md`
- `docs/workflow/documentation/state/FEATURES.md`
- `docs/workflow/documentation/state/ROADMAP.md`
- `docs/workflow/documentation/guides/TESTING.md`
- `docs/workflow/documentation/reference/BUGS.md`
- Cross-reference against {{SRC_DIR — the main source directory}}

## Output format

```
# Docs Drift Audit — YYYY-MM-DD

## CURRENT_STATE.md
- **[stale-claim|missing-feature|undocumented-change]** — Doc says: "X" / Code shows: "Y"

## ARCHITECTURE.md
...

## FEATURES.md
...

## ROADMAP.md
...

## TESTING.md
...

## BUGS.md
...

## Summary
- Docs reviewed: N
- Drift items found: N (stale claims: N, undocumented changes: N, missing features: N)
- Most out-of-date doc: [name]
- Overall verdict: IN SYNC | MINOR DRIFT | SIGNIFICANT DRIFT
```
