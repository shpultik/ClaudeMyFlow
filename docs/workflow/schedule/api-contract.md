# API Contract Audit

<!-- SETUP: delete this file (and its row in README.md) if the project has no client/server split. -->

**Cadence:** Monthly
**Results:** `docs/workflow/auditResults/YYYY-MM-DD-api-contract.md`

## What to check

Verify every call the client makes matches a real server endpoint, and vice versa.

### Flag these issues

| Issue | Description |
|-------|-------------|
| Missing endpoint | Client calls something that doesn't exist on the server (will 404) |
| Dead endpoint | Server defines it, client never calls it |
| Method mismatch | Client uses POST, server expects GET (or vice versa) |
| Missing auth | Client omits the auth header/token on an endpoint that requires it |
| Field mismatch | Client sends `user_id`, server expects `userId` |
| Missing response field | Client reads a field the server doesn't return |

## Files to review

- {{SERVER_ENTRY — server routing/endpoint definitions}} — extract all endpoints: method, path, required params, auth Y/N
- {{CLIENT_HTTP_LAYER — where the client makes HTTP/RPC calls}} — grep for the HTTP client call sites

## Output format

```
# API Contract Audit — YYYY-MM-DD

## Endpoints

### [METHOD] /path
- Server: EXISTS | MISSING
- Client calls it: YES | NEVER
- Issues: [list mismatches, or "None"]

## Orphaned Server Endpoints
- `/path` — defined on server, never called by client

## Summary
- Server endpoints: N
- Client-side calls: N
- Contract violations: N
- Orphaned endpoints: N
- Overall verdict: IN SYNC | MINOR DRIFT | BROKEN CONTRACT
```
