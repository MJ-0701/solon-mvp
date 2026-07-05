---
doc_id: sfs-current-product-shape-ko-29
title: "기능 총람 (Feature Overview)"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-07-03
parent: docs/ko/current-product-shape.md
summary: "Solon/SFS 전체 기능을 축별 한 장으로 정리한 총람 — 명령 표면과 상세 문서 라우팅."
load_when: "Read when you need the whole feature surface at a glance, before routing into a detailed section."
---
## 기능 총람 (Feature Overview)

Solon(SFS)의 전체 기능을 한 장으로 봅니다. 각 행은 상세 문서로 라우팅되는
입구이고, 본문 규약의 SSoT 는 routed context (`sfs context cat ...`) 입니다.

### 1. 7-step 작업 레일 (결정론적 코어)

흐름은 결정론 rail 이 소유하고, LLM 은 각 게이트 안의 지정 지점에서 호출됩니다.

| 기능 | 표면 | 상세 |
|---|---|---|
| sprint 시작/상태 | `sfs start "<goal>"` / `sfs status` | [시작](./02-start.md) |
| 의도 정리 (Gate 2) | `sfs brainstorm [--simple\|--hard]` | [brainstorm](./05-brainstorm-3.md), [hard mode](./06-hard-mode.md) |
| 계약 작성 (Gate 3, eval-first) | `sfs plan` | [plan](./07-plan-transcript.md) |
| 구현 slice (Gate 4) | `sfs implement [slice\|--stdin]` | [implement](./09-implement.md) |
| 산출물 수용 리뷰 (Gate 6) | `sfs review [--lens ...]` | [review](./10-review-artifact-acceptance-review.md), [렌즈](./14-review-lens.md) |
| 회고/종결 (Gate 7) | `sfs retro [--draft]` | [retro](./15-retro-sprint-close.md) |
| 흐름 정합 점검 | `sfs flowcheck` / `sfs healthcheck` | routed context `commands/flowcheck.md` |

### 2. Evidence·기록 프리미티브

| 기능 | 표면 | 상세 |
|---|---|---|
| 최소 사실 기록 | `sfs capture [--kind ...]` / `sfs note` | [capture](./08-capture-evidence-primitive.md) |
| 결정 기록 | `sfs decision` / `sfs event` | routed context `commands/*` |
| 보고/버그 | `sfs report` / `sfs report-bug` | bug-report lifecycle 정책 |
| 과거 회수 | `sfs recall` | routed context `commands/recall.md` |
| 공유 산출물 | `docs/solon/<domain>/.../report.md`·`retro.md` | [design.md](./13-design-md-ai.md) |

### 3. 하네스 엔지니어링 (진단·지표·설계도)

| 기능 | 표면 | 상세 |
|---|---|---|
| 하네스 준비도 점검 | `sfs harness doctor` | [harness map](./22-project-harness-map.md) |
| AI-readiness(Sanity) 4축 채점 | doctor "AI Readiness" 섹션, `.sfs-local/readiness-waiver` | 정책 `policies/harness-readiness.md` |
| AI-friendly 표면 4축 (저장소 표준 4요소) | 같은 섹션 `ai-surface` 축 그룹 — 안내서/가드레일/커맨드·스킬/AI 리뷰어 | 정책 `policies/harness-readiness.md` |
| AI 성숙도 셀프 진단 (5단계 사다리) | doctor "AI Maturity" 섹션 — delegated-wu/review-loop/parallel-capsule/rework 신호 | 정책 `policies/harness-maturity.md` |
| 세션 비용 신호 (3 런타임) | doctor "Cost Signals" 섹션 — Claude Code / Codex / Gemini 어댑터, `SFS_COST_RUNTIME` 핀 | [token harness](./17-token-harness-hygiene.md) |
| 하네스 설계도 + 진화 원장 | `sfs harness map --write` | [harness map](./22-project-harness-map.md) |
| 시간/비용 대시보드 | `sfs measure [--json]` / `measure --alive` | `bin/sfs` usage |

Sanity→Cartography 순서 규율과 모든 지표의 signal-only(차단 없음) 계약이
함께 적용됩니다.

### 4. 컨텍스트 라우팅·토큰 위생

| 기능 | 표면 | 상세 |
|---|---|---|
| routed context 조회 | `sfs context path\|cat\|list` | [토큰 다이어트](./03-token-diet-compact-i-o.md) |
| 얇은 어댑터 유지 | `sfs agent doctor --fix` / `sfs doctor --fix` | [토큰·하네스 위생](./17-token-harness-hygiene.md) |
| 캐시 프리픽스 규율 | 정책 `policies/token-harness.md` (세션 고정 prefix, 새 세션 재시작) | 같은 문서 |
| 워커 위임 캡슐 | 정책 `sub-agent-capsule-contract.md` (goal/AC/scope/budget + optional exemplar) | [위임 레퍼토리](./26-delegation-repertoire.md) |

### 5. 팀·오케스트레이션

| 기능 | 표면 | 상세 |
|---|---|---|
| 팀 preset 활성화 | `sfs team use <solo\|pair\|trio>` / `team refresh` / `team show` | [인간-에이전트 팀](./27-human-agent-teams.md) |
| 6본부 council (always-on) | `sfs division` + `.sfs-local/divisions.yaml` | [리뷰 렌즈](./14-review-lens.md) |
| 작업 라우팅/오케스트레이터 | `sfs route` / `sfs orchestrator` / `sfs dispatch` | [작업 인입 라우팅](./20-ai-work-intake-routing.md) |
| 반복 루프 | `sfs loop` + loop-taxonomy 정책 (4유형 결정 렌즈) | routed context `policies/loop-taxonomy.md` |
| 에이전트 신원/권한 구획 | 정책 `agent-identity`·compartment 계열 | [신원과 구획](./28-agent-identity-and-compartments.md) |

### 6. 기억·위키 (장기 메모리)

| 기능 | 표면 | 상세 |
|---|---|---|
| LLM 탐색 위키 | `llm-wiki/` (opt-in, waiver 가능) | [wiki 연속성](./19-obsidian-llm-wiki-continuity.md), [온보딩](./25-wiki-onboarding-guide.md) |
| Raw source intake | `sfs ingest --source-type --purpose` | [인입 라우팅](./20-ai-work-intake-routing.md) |
| 승격 파이프라인 | `sfs tidy --all --wiki-promote [--apply]` | [도메인 지식 자산](./21-domain-knowledge-assets.md) |
| 반복 실수 원장 | `.sfs-local/lessons.md` (record→reflect 플라이휠) | routed context `policies/lessons-accumulation.md` |

### 7. 호스트 채널·플랫폼

| 기능 | 표면 | 상세 |
|---|---|---|
| CLI | `sfs <cmd>` (Claude Code / Codex / Gemini CLI 공용) | [호스트 채널](./23-host-channels-and-mcp.md) |
| MCP | `mcp-server/` stdio `solon-mcp` (`sfs_*` tool 1:1) | 같은 문서 |
| Agent SDK | `templates/claude-agent-sdk-zero/` scaffold | 같은 문서 |
| Windows | `install.ps1`/`sfs.ps1` → Git Bash bash SSoT 브리지 | [Windows](./04-windows.md) |

### 8. 설치·업그레이드·릴리스 운영

| 기능 | 표면 | 상세 |
|---|---|---|
| 설치/초기화 | `install.sh` → `sfs init --layout thin --yes` / `sfs bootstrap` | README [설치](../../../README/04-section.md) |
| 최신화 | `sfs upgrade` / `sfs update` / `sfs version --check` | README [명령](../../../README/07-section.md) |
| 커밋 레일 | `sfs commit plan` → `commit apply --group` | [시작](./02-start.md) |
| 배포 채널 | Homebrew tap / Scoop bucket (릴리스마다 sha 고정) | CHANGELOG |
| 인계 검증 | `sfs handoff verify` / session-transfer 정책 | [학습 가이드](./24-topdown-learning-guide.md) |

### 9. 안전 계약 (전 기능 공통)

- 게이트·지표·advisory 는 **전부 signal-only** — 어떤 판정도 명령을 차단하지
  않습니다 (차단 가능한 것은 상태 전이 순서 설계뿐, 그것도 waiver 로 전이).
- 쓰기 작업은 consent-gated: `--yes`/`--apply`/dry-run 프리뷰가 기본.
- 외부 오케스트레이터·지식 그래프·위키는 opt-in — 제거해도 전 기능 동일
  동작 (standalone 보증).
- 비용/readiness 어댑터는 토큰 집계와 도구 이름만 읽고 메시지 본문은 읽지
  않습니다.
