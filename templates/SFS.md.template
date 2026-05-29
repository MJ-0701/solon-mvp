---
doc_id: sfs-project-router
title: "SFS.md — `<PROJECT-NAME>` Solon SFS router"
doc_type: solon-router
router_doc: true
managed_by: sfs
detail_sources:
  - packaged-sfs-runtime-context
  - .sfs-local/context/
  - .sfs-local/presets/solon-safe-permissions.yaml
  - mcp-server/README.md
maintenance:
  bloat_check: "sfs doctor"
  bloat_fix: "sfs doctor --fix"
---

# SFS.md — `<PROJECT-NAME>` Solon SFS router

This file is the small shared entry for Claude, Codex, Gemini, and the
terminal-facing `sfs` command. Keep detailed policy in routed context, not here.

## 프로젝트 개요

- **이름**: `<PROJECT-NAME>`
- **유형**: `<PROJECT-TYPE>`
- **단계**: `<PROJECT-STAGE>`
- **환경**: `<PROJECT-ENVIRONMENT>`
- **핵심 산출물**: `<PROJECT-OUTPUT>`
- **공유/운영 방식**: `<PROJECT-DELIVERY>`

## Read Order

1. `sfs context cat kernel`
2. `sfs context cat index`
3. Only the matching routed module, such as
   `sfs context cat commands/<name>.md` or
   `sfs context cat policies/<name>.md`

In thin layout, managed context lives in the packaged global `sfs` runtime.
`.sfs-local/context/` is optional project-local override space.

## Default Entry

- `sfs status`
- current sprint `report.md` when one exists
- `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` for shared adoption
  or handoff summaries when product domain labels are known
- `docs/solon/<english-workspace>/<yyyyMMdd>/` as the legacy flat fallback
- private workbench/log expansion only when routed context needs evidence

## Project Overview Refresh

`sfs profile` updates only this file's `## 프로젝트 개요` section.

## Harness Check

Use `sfs harness doctor` before long autonomous work. Use
`sfs harness map --write` when project structure, agent roles, evidence loops,
or parallel-worker plans need an inspectable harness map.

## Output Contract

Never paraphrase bash adapter output. Bash-first commands may add one compact
Next action after verbatim output. Compact output is quality-preserving only:
never compress evidence, risk warnings, decisions, source links/paths, or
raw-source traceability. If compactness would weaken quality, use full clarity.

## Maintenance

`SFS.md` is a router, not a policy archive. If detailed command tables, gate
rules, model routing, review policy, monitor policy, or long agent instructions
accumulate here, run `sfs doctor --fix`; it archives the old file and restores
this thin router while preserving `## 프로젝트 개요`.
