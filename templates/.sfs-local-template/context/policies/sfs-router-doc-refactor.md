---
id: sfs-policy-router-doc-refactor
summary: Keep SFS.md as a thin project router, not a policy archive.
load_when: ["SFS.md", "router", "docs bloat", "doctor", "upgrade"]
---

# SFS Router Doc Refactor

`SFS.md` is the project entry router. It may hold frontmatter, the
`## 프로젝트 개요` section, read order, default entry points, and the compact
output contract. Detailed policies live in `kernel.md`, routed command modules,
or routed policy modules.

## Contract

- Keep `SFS.md` short enough to scan during agent bootstrap.
- Preserve the `## 프로젝트 개요` section because `sfs profile` owns it.
- Do not inline command tables, gate rules, model routing, review policy,
  monitor policy, division packs, wiki policy, release policy, prompt bodies,
  or transcripts.
- If an SFS policy needs durability, add or update routed context and route it
  from `_INDEX.md`.
- Root agent docs point to `SFS.md`; `SFS.md` points to routed context.

## Command Surface

- `sfs doctor` audits `SFS.md` and root agent docs from the current project.
- `sfs doctor --fix` archives a recognized bloated `SFS.md` under
  `.sfs-local/archives/sfs-router-doc-refactor/<timestamp>/`, rewrites it from
  the thin router template, and preserves `## 프로젝트 개요`.
- `sfs upgrade` performs the same `SFS.md` refactor by default. Set
  `SFS_ROUTER_DOC_REFACTOR=0` to audit without rewriting.
- `sfs agent doctor --fix` remains the narrow command for root LLM agent docs.

## Review Questions

- Is `SFS.md` still a router instead of a policy archive?
- Are detailed rules reachable through `sfs context cat kernel/index/...`?
- Was the old `SFS.md` archived before rewrite?
- Did the project overview survive the rewrite unchanged?
