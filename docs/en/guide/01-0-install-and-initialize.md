---
doc_id: sfs-product-guide-en-1
title: "0. Install And Initialize"
visibility: oss-public
doc_type: user-guide
language: en
updated: 2026-05-22
parent: docs/en/guide.md
summary: "0. Install And Initialize"
load_when: "Read when docs/en/guide.md routes to this section."
---
## 0. Install And Initialize

> One `brew install` / `scoop install` lets Claude Code
> (`/sfs`), Gemini CLI (`sfs`), and Codex CLI (`$sfs`) find Solon automatically.
> Your project keeps the files you read and the records you create.

Mac:

```bash
brew install MJ-0701/solon-product/sfs
sfs doctor              # ✅ Claude / Gemini / Codex — three green lines

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

Windows PowerShell/cmd:

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
sfs.cmd doctor          # same three-line check on Windows

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

If any line in `sfs doctor` shows `⚠️`, the next line on screen prints the
single-shot recovery command. The `sfs` binary itself is unaffected.

For multi-sprint projects or existing projects with meaningful docs, the AI may
recommend an Obsidian `llm-wiki/` map. It is optional and does not copy source
docs; it gives future sprints a faster navigation layer over the source files.
