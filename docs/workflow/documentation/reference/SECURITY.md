# Security — {{PROJECT_NAME}}

> Updated: {{DATE}}

Security posture, gaps, and guidance. Findings from monthly security reviews (`../../schedule/security-review.md`) that change the posture get reflected here; the dated reports themselves live in `../../auditResults/`.

<!-- SETUP: write a brief honest assessment from the repo scan. Unknowns are findings too. -->

## Posture summary

{{POSTURE — 3–6 sentences: auth model, where secrets live, what's encrypted, biggest known risk}}

## Secret handling

- {{SECRETS — how credentials/tokens/keys are stored and injected; what must never be committed}}

## Attack surface

| Surface | Mechanism | Notes |
|---|---|---|
| {{SURFACE — e.g. public API, local storage, file import}} | {{how it's protected}} | {{gaps}} |

## Known gaps / accepted risks

- {{GAP — with the ticket tracking it, or "accepted because ..."}}
