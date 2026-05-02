---
id: sfs-command-profile
summary: Profile refresh is a narrow hybrid command for only SFS.md project overview.
load_when: ["sfs profile", "profile", "project overview", "프로젝트 개요"]
---

# Profile Command Context

`sfs profile` detects a narrow project profile for `SFS.md`.

Rules:
- Run the adapter first and show stdout/stderr verbatim.
- Read only files listed in adapter `allowed_read` that exist.
- Write only `SFS.md` from `## 프로젝트 개요` until the next `## ` heading.
- Keep unknown fields as placeholders.
- Do not read sprint files, source files, git history, or unrelated docs.
- `sfs profile --apply` is shell-only quick apply; after it succeeds, do not
  perform additional AI refinement unless the user asks.
