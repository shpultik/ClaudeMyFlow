# Audit Schedule

Periodic health checks for {{PROJECT_NAME}}. To run any audit, tell the agent: "run the [name] audit" or "run all monthly audits". Results are saved to `docs/workflow/auditResults/YYYY-MM-DD-{audit-name}.md` — and every actionable finding gets a backlog ticket.

## Monthly (run on 1st of each month)

| Audit | File | What it checks |
|-------|------|----------------|
| Test Quality | [test-audit.md](test-audit.md) | Test meaningfulness, coverage gaps |
| Security | [security-review.md](security-review.md) | Auth, data at rest, injection surfaces, leakage |
| Docs Drift | [docs-drift.md](docs-drift.md) | Living docs vs actual code |
| Dependency | [dependency-audit.md](dependency-audit.md) | Package versions, CVEs, deprecations |
| API Contract | [api-contract.md](api-contract.md) | Client calls vs server endpoints <!-- SETUP: delete this row if no client/server split --> |

## Quarterly (run Jan/Apr/Jul/Oct 1st)

| Audit | File | What it checks |
|-------|------|----------------|
| Code Complexity | [code-complexity.md](code-complexity.md) | Long methods, dead code, overloaded classes |
| Performance | [performance-check.md](performance-check.md) | Known-costly patterns in the project's hot paths |

## Results

All audit reports are saved to `docs/workflow/auditResults/YYYY-MM-DD-{audit-name}.md` and never edited afterwards.
