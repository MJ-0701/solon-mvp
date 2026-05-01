---
decision_id: "0003"
title: "Activate infra division"
created_at: "2026-05-01T15:42:59Z"
status: accepted
division: "infra"
action: "activate"
---

# Activate infra division

## Context

The `infra` division needed a concrete runtime state instead of staying only as an abstract concept.

## Decision

- action: `activate`
- division: `infra`
- activation_scope: `full`
- reason: Abstract-only divisions blocked runtime activation; promote core guardrails to executable scope.

## Implementation Contract

Owns secrets, deploy path, observability, rollback, cost, and production readiness.

Required outputs:
- secret/auth/data risk checklist
- deploy/rollback notes
- monitoring/cost notes

## Consequences

SFS commands may now treat `infra` as executable division scope and should record evidence in sprint workbench/report artifacts.
