---
decision_id: "0001"
title: "Activate qa division"
created_at: "2026-05-01T15:42:59Z"
status: accepted
division: "qa"
action: "activate"
---

# Activate qa division

## Context

The `qa` division needed a concrete runtime state instead of staying only as an abstract concept.

## Decision

- action: `activate`
- division: `qa`
- activation_scope: `full`
- reason: Abstract-only divisions blocked runtime activation; promote core guardrails to executable scope.

## Implementation Contract

Owns test strategy, smoke/regression coverage, defect triage, and release confidence.

Required outputs:
- test matrix
- smoke/regression result
- release confidence notes

## Consequences

SFS commands may now treat `qa` as executable division scope and should record evidence in sprint workbench/report artifacts.
