# Test Quality Audit

**Cadence:** Monthly
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-test-audit.md`

## What to check

1. **Trivially passing tests** — empty bodies, `assert true`, only checking not-null
2. **No meaningful assertions** — test runs but asserts nothing about behavior
3. **Would pass if feature were broken** — everything mocked so the actual logic is never exercised
4. **Implementation-coupled** — tests private internals, breaks on refactors that don't change behavior
5. **Coverage gaps** — critical paths with zero tests:
   - {{CRITICAL_PATH_1 — SETUP: list this project's 4–6 most critical behaviors (the ones whose silent breakage hurts users most)}}
   - {{CRITICAL_PATH_2}}
   - {{CRITICAL_PATH_3}}

## Files to review

- All test files in {{TEST_DIR}}

## Output format

```
# Test Audit — YYYY-MM-DD

## Findings

### [TestFileName]
- **[trivial|no-assertions|implementation-coupled|would-pass-if-broken]** `File:LINE` — explanation

## Coverage Gaps
- [Feature area] — no tests exist for this critical path

## Summary
- Test files reviewed: N
- Tests reviewed: N
- Issues found: N (critical: N, moderate: N, minor: N)
- Coverage gaps: N
- Overall verdict: PASS | NEEDS ATTENTION | URGENT
```
