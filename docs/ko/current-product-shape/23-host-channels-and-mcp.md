---
doc_id: sfs-current-product-shape-ko-23
title: "Host channels — CLI / MCP / Agent SDK"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-08-27
parent: docs/ko/current-product-shape.md
summary: "Solon 7-step 은 transport 에 독립적이다. CLI / MCP / Agent SDK 어떤 host 로 들어와도 같은 bash adapter, 같은 sprint state, 같은 review gate 를 만난다."
load_when: "Read when deciding how to drive Solon from a host other than the terminal, or when reviewing the 0.7.0+ host-agnostic surface."
---
## Host channels — CLI / MCP / Agent SDK

Solon 7-step flow 는 transport 에 독립적입니다. 0.7.0 이후 세 가지 host
채널이 동등하게 같은 `sfs` bash adapter 위에서 동작합니다:

- **CLI** — 가장 오래된 진입. 터미널에서 `sfs status`, `sfs start`,
  `sfs plan`, `sfs review` 를 직접 호출. Claude Code (`/sfs ...`), Gemini
  CLI (`sfs ...`), Codex CLI (`$sfs ...`), Windows PowerShell/cmd
  (`sfs.cmd ...`) 가 같은 진입을 다른 trigger 로 노출.
- **MCP** — `mcp-server/` 의 stdio MCP server 가 12개 `sfs_*` tool 로
  같은 명령을 노출. Claude Desktop, Claude in Chrome, Cursor, 그 외
  MCP-capable host 가 이 채널로 7-step 을 끌어다 씁니다. bash adapter
  stdout 을 verbatim forward 하므로 SSoT 룰 (kernel.md) 위배 없음.
- **Agent SDK** — `templates/claude-agent-sdk-zero/` scaffold 가 Claude
  Agent SDK 프로젝트를 `solon-mcp` + `solon-safe-permissions.yaml` 와 함께
  bootstrapping. 자기 agent 안에서 `sfs_*` tool 을 직접 호출 가능.

### 어떤 호스트로 들어와도 같은 것

세 채널 모두 같은 invariant 을 만납니다:

- 같은 `.sfs-local/sprints/` 상태
- 같은 `divisions.yaml` 활성화 상태
- 같은 routed context (`sfs context cat kernel` / `index` / `commands/*` /
  `policies/*`)
- 같은 Gate 6 review 룰 (6개 필수 role의 Council Participation Ledger가 비어 있으면 partial)
- 같은 `kernel.md` SSoT 원칙 (output verbatim)
- 같은 review lens (agent-build 자동 라우팅 포함)

### 호스트별 등록 한 줄 요약

| host | 등록 위치 | 비고 |
| --- | --- | --- |
| Claude Code | `.claude/commands/sfs.md` (sfs agent install all 로 자동) | CLI 트리거 `/sfs ...` |
| Gemini CLI | `.gemini/commands/sfs.toml` | CLI 트리거 `sfs ...` |
| Codex CLI | `.agents/skills/sfs/SKILL.md` | CLI 트리거 `$sfs ...` |
| Claude Desktop | `~/Library/Application Support/Claude/claude_desktop_config.json` → mcpServers | MCP 채널 |
| Claude in Chrome | 확장 MCP config | MCP 채널 |
| Cursor | `~/.cursor/mcp.json` → mcpServers | MCP 채널 |
| Claude Agent SDK | `AgentOptions(mcp_servers={...})` | Agent SDK 채널 |

상세 등록 스니펫: [`mcp-server/README.md`](../../../mcp-server/README.md).

### 권한 baseline

세 채널 모두에 적용되는 권한 baseline 은
`templates/.sfs-local-template/presets/solon-safe-permissions.yaml` 입니다.
auto-push / destructive bash / hard reset 은 기본 denied, mutating `sfs_*`
tool 은 ask-approval, read-only tool 은 pre-approved. consumer 는 자기
runtime 의 permission config 형식에 맞춰 이 preset 을 import 하면 됩니다.

### agent-build review lens 자동 적용

Solon 자체로 새 agent 를 만들 때 (예: agent SDK / MCP server / sub-agent
harness) Gate 6 review 가 `agent-build` lens 로 자동 라우팅됩니다 (0.7.1+).
tool surface scope / permission posture / sub-agent isolation / system
prompt drift / SSoT / evidence / failure modes 7개 subsection 을 CPO 가
점검합니다. 자세한 lens 정책은
[`policies/agent-build-review-lens.md`](../../../templates/.sfs-local-template/context/policies/agent-build-review-lens.md).
