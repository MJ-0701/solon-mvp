---
doc_id: sfs-product-readme-4
title: "설치"
visibility: oss-public
doc_type: product-intro
language: ko
updated: 2026-05-22
parent: README.md
summary: "설치"
load_when: "Read when README.md routes to this section."
---
## 설치

개발, 터미널, CLI 환경이 낯설다면 먼저 [BEGINNER-GUIDE.md](./BEGINNER-GUIDE.md)를 보시면 됩니다.

### Mac

```bash
brew install MJ-0701/solon-product/sfs

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

### Windows

```powershell
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

### AI 도구 연결 확인

```bash
sfs doctor
```

Claude Code, Gemini CLI, Codex CLI 가 모두 연결되면 각 도구에서 같은 Solon 흐름을 사용할 수 있습니다.

| Runtime | 진입 명령 |
|---|---|
| Claude Code | `/sfs status` |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Windows PowerShell/cmd | `sfs.cmd status` |

---

