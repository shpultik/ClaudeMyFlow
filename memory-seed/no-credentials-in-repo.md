---
name: no-credentials-in-repo
description: Never write actual credential values in any committed file — docs, tickets, examples, comments — only placeholders
metadata:
  type: feedback
---

Never write actual credential values (passwords, tokens, keys, fingerprints that act as secrets) in any file that goes into the repository — including docs, backlog tickets, example files, code comments, or migration notes. Use placeholders only: `"..."`, `<your-password>`, `YOUR_SECRET_HERE`.

**Why:** In a prior project the actual keystore password was written into a backlog ticket that was committed to git — exactly the mistake that ticket had been created to prevent. The password had to be rotated and history rewritten.

**How to apply:** Before committing any file that mentions credentials, scan it for real values. If illustrating a config or command that involves a secret, use a placeholder. This applies even to private repos and internal docs. Related: [[security-first]].
