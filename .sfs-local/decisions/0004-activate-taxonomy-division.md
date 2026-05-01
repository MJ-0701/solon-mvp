---
decision_id: "0004"
title: "Activate taxonomy division"
created_at: "2026-05-01T15:42:59Z"
status: accepted
division: "taxonomy"
action: "activate"
---

# Activate taxonomy division

## Context

The `taxonomy` division needed a concrete runtime state instead of staying only as an abstract concept.

## Decision

- action: `activate`
- division: `taxonomy`
- activation_scope: `full`
- reason: Abstract-only divisions blocked runtime activation; promote core guardrails to executable scope.

## Implementation Contract

Owns canonical domain terms, entities, states, naming rules, and drift detection.

Required outputs:
- canonical terms + forbidden aliases
- entity/state naming map
- drift notes across code/docs/UI

## Consequences

SFS commands may now treat `taxonomy` as executable division scope and should record evidence in sprint workbench/report artifacts.
