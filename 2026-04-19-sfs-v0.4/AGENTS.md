---
doc_id: sfs-v0.4-agents-redirect
title: "Solon docset AGENTS.md — Codex/Cowork entry redirect"
scope: "Codex/Cowork auto-load compatibility shim. The operational SSoT remains CLAUDE.md."
version: 1.0
created: 2026-04-28
visibility: raw-internal
---

# Solon Docset AGENTS.md — Redirect

> This file exists because the repo-root `AGENTS.md` points Codex/Cowork sessions here.
> It must stay tiny. Do not duplicate the full operating rules in this file.

## Required Entry Order

1. Read [`CLAUDE.md`](CLAUDE.md) first. It is the actual SSoT for rules, terminology, mutex, commit policy, and project operation.
2. Read [`PROGRESS.md`](PROGRESS.md) next. Check `resume_hint`, `current_wu_owner`, and `domain_locks`.
3. If `current_wu_owner` is non-null and still within TTL, stop and ask the user before taking over.
4. If the user asks for structural review or design cleanup rather than resume work, do not auto-run `resume_hint.default_action`; inspect and fix the requested structural area instead.

## Why This File Exists

The root `AGENTS.md` is an auto-load bootstrap and references `2026-04-19-sfs-v0.4/AGENTS.md`. Before this shim existed, the bootstrap target was missing, so Codex/Cowork sessions could fail the documented entry sequence and fall back to ad hoc behavior.

## Non-Goals

- Do not copy `CLAUDE.md` §1 rules here.
- Do not make this file a second SSoT.
- Do not update this file for normal project progress; update `CLAUDE.md` or `PROGRESS.md` instead.
