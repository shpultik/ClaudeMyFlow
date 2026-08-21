# Runbook — {{PROJECT_NAME}}

> Updated: {{DATE}}

Operational procedures: exact commands, expected output, and what to do when they fail. Anything requiring production credentials is marked **Human**.

<!-- SETUP: fill from CI/CD files and deploy scripts if discoverable; otherwise leave
     explicit TBDs. Add a new section every time an operational task is performed
     for the first time — future sessions should never re-derive a procedure. -->

## Deploy

{{DEPLOY — how a change reaches production/users, step by step; or "TBD — fill in when known"}}

## Health checks

{{HEALTH — how to tell the system is healthy: URLs, log locations, commands; or TBD}}

## Backup / restore

{{BACKUP — what gets backed up, where, and the restore drill; or TBD}}

## Incident basics

{{INCIDENT — first three things to check when something is down; or TBD}}
