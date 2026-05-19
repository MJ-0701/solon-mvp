---
id: sfs-policy-context-pollution-guard
summary: Keep durable Solon/SFS context clean by storing conclusions, not prompt or transcript bulk.
load_when: ["context", "token", "capture", "review", "tidy", "release", "prompt"]
---

# Context Pollution Guard

- Core product and adapter context stays thin. `SFS.md`, `CLAUDE.md`,
  `AGENTS.md`, `GEMINI.md`, `kernel.md`, `_INDEX.md`, README/GUIDE, and
  current-product-shape docs hold stable rules, product contracts, and durable
  conclusions.
- Do not copy prompt bodies, raw chat transcripts, review scratch, bridge probe
  stdout/stderr, long command logs, `.sfs-local/tmp/...` paths, or whole
  workbench history into core product docs.
- Natural-language flow belongs in compact `sfs capture` checkpoints. Keep the
  smallest decision/evidence sentence plus exact artifact path when the source
  is bulky.
- Prompt/run scratch belongs in `.sfs-local/tmp/...` while active and in cold
  archives after report/retro. Shared docs should point to evidence paths and
  summarize accepted conclusions, not replay the source text.
- Review must flag context pollution when durable docs contain prompt bodies,
  transcript dumps, bridge/runtime scratch, or old review result blobs that no
  longer change the current contract.
- Tidy/retro should leave visible only files with a one-line reason to remain.
  If the reason is "maybe useful later", archive it and keep a short pointer.
- Release is not clean when product docs or packaged context include prompt or
  transcript residue. Fix the residue before publishing the package.
