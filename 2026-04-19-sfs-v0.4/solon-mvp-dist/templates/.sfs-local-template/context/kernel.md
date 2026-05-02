---
id: sfs-kernel
summary: Minimal rules every Solon agent reads before acting.
load_when: ["always", "sfs", "entry"]
---

# SFS Kernel

- Run `sfs <command>` first; bash adapter output is SSoT and must be verbatim.
- Start from `sfs status` and current sprint `report.md`; avoid old logs unless needed.
- Stop on mutex conflicts and report owner/domain.
- Ask only 1-3 blocking questions.
- After adapter output, read only the context module routed by `_INDEX.md`.
