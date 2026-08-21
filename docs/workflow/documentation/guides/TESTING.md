# Testing — {{PROJECT_NAME}}

> Updated: {{DATE}} · Tests: {{TEST_COUNT — total (skipped), or "0 — no tests yet"}}

## Running tests

```bash
{{TEST_CMD}}
```

<!-- SETUP: note any isolation requirements (parallel agents, output directories),
     required env vars, or platform constraints. -->

## Structure

{{TEST_STRUCTURE — test project location, framework, how tests are grouped}}

## Writing new tests

- Deterministic — no timing dependence, no external services
- One behavior per test; the test name states the expected behavior
- {{TEST_CONVENTIONS — assertion library, mocking approach, fixtures/builders in use}}

## Known flaky tests

| Test | Ticket | Notes |
|---|---|---|
| _(none known)_ | | |
