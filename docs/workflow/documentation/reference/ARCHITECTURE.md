# Architecture — {{PROJECT_NAME}}

> Version: {{VERSION — or "unversioned"}} · Updated: {{DATE}}

<!-- SETUP: fill from the repo scan. Keep it navigational — enough for an agent to find
     the right file fast, not a prose essay. Update whenever components, data flows,
     or dependencies change. -->

## Overview

{{OVERVIEW — 3–6 sentences: the components, how they talk, where state lives}}

## Components

| Component | Location | Responsibility |
|---|---|---|
| {{COMPONENT}} | `{{path}}` | {{what it does}} |

## Data layer

{{DATA_LAYER — database/storage, schema location, access rules (e.g. "all DB access goes through X only"); delete if none}}

## External services / APIs

{{EXTERNAL — third-party services, endpoints consumed or exposed, auth mechanisms; delete if none}}

## Patterns and conventions

- {{PATTERN — e.g. layering rule, error-handling convention, serialization library choice}}
