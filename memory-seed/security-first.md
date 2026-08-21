---
name: security-first
description: Security is a first-class concern in every design decision — always think about attack surface, data exposure, and safe defaults before implementing
metadata:
  type: feedback
---

Always think about safety and security before and during implementation — not as an afterthought. The user wants a well-optimized, secure product; security review happens at design time, not after shipping.

**Why:** Security gaps introduced during feature work are far cheaper to prevent than to remediate — and the user has explicitly asked for this posture.

**How to apply:** For every feature, consider: who can call this? What data is exposed? Can it be abused? Rate limits? Input validation? Always review: injection, auth bypass, data leakage, enumeration, abuse potential. Related: [[no-credentials-in-repo]].
