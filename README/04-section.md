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

개발, 터미널, CLI 환경이 낯설다면 먼저 [BEGINNER-GUIDE.md](../BEGINNER-GUIDE.md)를 보시면 됩니다.

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

### MCP host 채널 (0.7.0+)

CLI 외에 Claude Desktop / Claude in Chrome / Cursor / Claude Agent SDK 같은
MCP host 에서도 같은 7-step flow 를 끌어다 쓸 수 있습니다. `mcp-server/`
디렉토리의 stdio MCP server (`solon-mcp`) 가 `sfs_*` tool 12개로 같은
명령을 노출하고, bash adapter stdout 을 verbatim forward 합니다 (SSoT 보존).

호스트별 등록 스니펫은 [`mcp-server/README.md`](./mcp-server/README.md), 채널
일람 + invariant 비교는
[`docs/ko/current-product-shape/23-host-channels-and-mcp.md`](../docs/ko/current-product-shape/23-host-channels-and-mcp.md).

---

