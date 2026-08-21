# Performance Check

**Cadence:** Quarterly (Jan 1 / Apr 1 / Jul 1 / Oct 1)
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-performance-check.md`

## What to check

Code analysis only (unless benchmarks exist). Look for patterns known to cause perf issues in this stack.

<!-- SETUP: replace the sections below with this project's 3–5 hot areas
     (the code paths that run most often or handle the most data), each with
     concrete anti-patterns to grep for. Keep the "General" section. -->

### 1. {{HOT_AREA_1 — e.g. "request handling pipeline"}}
- Work done on the UI/main thread that should be off it?
- Synchronous I/O inside frequently-called callbacks?
- Unbounded in-memory growth (lists/caches that only ever grow)?
- Repeated expensive computation inside tight loops?

### 2. {{HOT_AREA_2 — e.g. "database access"}}
- N+1 patterns — a query inside a loop
- Missing indexes on columns used in WHERE clauses
- Fetching full rows when only a few columns are needed
- Row-by-row writes where a batch would do

### 3. {{HOT_AREA_3 — e.g. "rendering / network layer"}}
- Full rebuilds/redraws triggered more often than needed?
- Objects recreated on every update instead of updated in place?
- Large payloads parsed synchronously on a hot thread?
- Retry logic without backoff (tight retry loops)?

### General
- Fire-and-forget async that swallows exceptions and can't be awaited
- Blocking waits on async results (`.Result`, `.Wait()`, sync-over-async)
- Expensive iteration over large in-memory collections inside hot paths

## Files to review

- {{PERF_REVIEW_FILES — the files implementing the hot areas above}}

## Output format

```
# Performance Check — YYYY-MM-DD

## [Hot Area]
- **[HIGH|MEDIUM|LOW]** `File:LINE` — issue description, estimated impact

## General
- **[HIGH|MEDIUM|LOW]** `File:LINE` — issue description, estimated impact

## Summary
- Areas reviewed: N
- Issues found: N (HIGH: N, MEDIUM: N, LOW: N)
- Most impactful: [description]
- Overall verdict: PERFORMANT | WATCH LIST | ACTION NEEDED
```
