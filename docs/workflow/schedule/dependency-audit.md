# Dependency Audit

**Cadence:** Monthly
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-dependency-audit.md`

## What to check

1. All dependencies declared in {{DEPENDENCY_MANIFEST — e.g. the .csproj, package.json, requirements.txt, go.mod}}
2. For each package: latest stable version, any CVEs or security advisories, deprecation notices

## Key packages to watch

<!-- SETUP: fill with this project's dependencies, riskiest first.
     HIGH = auth/crypto/deserialization surfaces or rapid release cycles;
     MEDIUM = data access, UI frameworks; LOW = stable pure-logic libs. -->

| Package | Risk level | Why |
|---------|-----------|-----|
| {{PACKAGE_1}} | HIGH | {{WHY}} |
| {{PACKAGE_2}} | MEDIUM | {{WHY}} |

## Output format

```
# Dependency Audit — YYYY-MM-DD

## Packages

| Package | Current | Latest | Status | Notes |
|---------|---------|--------|--------|-------|
| PackageName | 1.0.0 | 1.2.0 | OUTDATED | minor gap |
| PackageName | 2.0.0 | 2.0.0 | OK | — |

## Security Findings
- **[CVE-XXXX-XXXXX]** PackageName vX.X — description, affected versions, fix version

## Deprecated Packages
- PackageName — reason, recommended replacement

## Summary
- Packages reviewed: N
- Up to date: N
- Outdated: N (major: N, minor: N, patch: N)
- CVEs found: N
- Deprecated: N
- Overall verdict: HEALTHY | NEEDS UPDATES | URGENT (CVE present)
```
