# Code Complexity Audit

**Cadence:** Quarterly (Jan 1 / Apr 1 / Jul 1 / Oct 1)
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-code-complexity.md`

## What to check

1. **Long methods** — any method/function body longer than 50 lines (excluding blank lines and braces)
2. **Overloaded classes/modules** — more than one clear responsibility (God objects, service classes doing 5+ unrelated things)
3. **Dead code** — unreferenced modules, unused public methods/properties, commented-out code blocks
4. **Unused registrations** — components registered in {{COMPOSITION_ROOT — DI container / plugin registry; delete if N/A}} but never used anywhere
5. **Deeply nested logic** — nesting depth > 4 (if inside if inside loop inside try...)
6. **Duplicate logic** — near-identical code blocks in 3+ places that should be extracted

## Files to review

- All source files in {{SRC_DIR}}
- {{COMPOSITION_ROOT}} for registrations vs actual usages

## Output format

```
# Code Complexity Audit — YYYY-MM-DD

## Long Methods (>50 lines)
- **[HIGH|MEDIUM]** `File:LINE` MethodName — N lines, suggested split

## Overloaded Classes
- **[HIGH|MEDIUM]** `File` ClassName — responsibilities: X, Y, Z

## Dead Code
- **[confirmed|suspected]** `File:LINE` — description

## Unused Registrations
- ComponentName — registered, never used

## Duplicate Logic
- `File1:LINE` and `File2:LINE` — description of duplication

## Summary
- Files reviewed: N
- Long methods: N
- Overloaded classes: N
- Dead code items: N
- Duplicate logic clusters: N
- Overall verdict: CLEAN | NEEDS ATTENTION | REFACTOR NEEDED
```
