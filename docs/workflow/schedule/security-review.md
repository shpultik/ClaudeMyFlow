# Security Review

**Cadence:** Monthly
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-security-review.md`

## Attack surfaces to review

<!-- SETUP: tailor this list to the project. Keep the categories; make each bullet
     name the project's concrete mechanism (token type, storage location, framework). -->

1. **Auth / secret handling** — how are tokens/credentials stored? Plaintext vs secure storage? Logged anywhere? Sent over plain HTTP?
2. **Data at rest** — local database/files accessible to other apps or users? Sensitive data unencrypted?
3. **Input validation** — every piece of external input (API responses, incoming messages, user input, files) validated before use?
4. **Injection** — SQL injection (parameterized queries?), command injection, path traversal, missing auth checks, endpoints unauthenticated that shouldn't be
5. **Data leakage** — PII/sensitive data in logs, crash reports, or analytics? Over-sharing in API responses?
6. **New endpoints / entry points** — any added since last review without obvious auth checks?
7. **Platform permissions** — declared permissions ({{PERMISSIONS_FILE — e.g. AndroidManifest.xml, entitlements; delete if N/A}}) appropriate and minimal?

## Files to review

- {{SECURITY_REVIEW_FILES — SETUP: list the auth code, data layer, network layer, backend entry points}}

## Key search terms

- {{SEARCH_TERMS — SETUP: list stack-appropriate greps, e.g. token names, `password`, logging calls, raw query construction, `eval`, `exec`}}

## Output format

```
# Security Review — YYYY-MM-DD

## Findings

### [Surface Area]
- **[CRITICAL|HIGH|MEDIUM|LOW|INFO]** `file:line` — description and potential impact

## New Since Last Review
- Any new endpoints, services, or data flows

## Summary
- Surface areas reviewed: N
- Findings: N (CRITICAL: N, HIGH: N, MEDIUM: N, LOW: N, INFO: N)
- Overall verdict: SECURE | NEEDS ATTENTION | URGENT ACTION REQUIRED
```
