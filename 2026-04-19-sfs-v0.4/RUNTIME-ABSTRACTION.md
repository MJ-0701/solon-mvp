---
doc_id: sfs-v0.4-runtime-abstraction
title: "Runtime Abstraction — Claude / Codex / Gemini-CLI multi-agent runtime 지원 설계"
version: 0.2-mvp-correction
status: draft
last_updated: 2026-04-24
author: "Claude (direct 지시 by 채명정) — WU-11 A"
role: reference
scope_declaration: "이 문서는 MVP. SFS core 는 runtime-agnostic 으로 정의하고, Claude/Codex/Gemini CLI 는 경량 adapter 문서로 연결한다. 상세 SDK 어댑터와 CI 매트릭스는 후속."
depends_on:
  - sfs-v0.4-s02-design-principles
  - sfs-v0.4-s03-c-level-matrix
  - sfs-v0.4-s07-plugin-distribution
  - sfs-v0.4-s10-phase1-implementation
defines:
  - concept/runtime-abstraction-layers                     # 🆕 v0.4-r3
  - concept/execution-contract                             # 🆕 v0.4-r3
  - concept/runtime-adapter                                # 🆕 v0.4-r3
  - rule/mvp-runtime-neutral-core                          # 🆕 v0.4-r3 corrected 2026-04-24
  - rule/do-not-touch-brand-decoupled-assets               # 🆕 v0.4-r3
references:
  - principle/cli-gui-shared-backend (defined in: s02)
  - principle/phase1-phase2-separation (defined in: s02)
  - concept/sfs-plugin (defined in: s07)
  - concept/cli-cowork-shared-fs (defined in: s07)
  - rule/model-allocation-concrete (defined in: s03)
affects:
  - sfs-v0.4-s07-plugin-distribution (runtime별 packaging 은 후속, 경량 문서 adapter 는 MVP 포함)
  - sfs-v0.4-s10-phase1-implementation (MVP scope = L0/L1 core + Claude/Codex/Gemini 문서 adapter)
triggered_by_user_directive: |
  "sfs를 claude 뿐만 아니라 codex랑 gemini-cli에서도 사용하고 싶거든??
  그래서 추상화 하는게 중요할듯?!"
  — 채명정, 2026-04-20 심야 (WU-8 진행 중)
---

# Runtime Abstraction — Solon 을 Claude 외 runtime 에서도 돌릴 수 있게 만드는 설계 골격

> **이 문서는 MVP 다.** 목적은 다음주(2026-04-27~) 부터 Phase 1 구현을 시작할 때 **"지금 내가 만드는 이 파일/모듈이 runtime-agnostic 인지 runtime-specific 인지"** 를 즉시 판정할 수 있는 기준선 제공. MVP 배포판은 최소한 `SFS.md` core + `CLAUDE.md`/`AGENTS.md`/`GEMINI.md` adapter 를 포함해야 한다. 상세 SDK 어댑터 API / CI 매트릭스는 후속 단계에서 추가한다.
>
> 🚨 **MVP 범위 정정 (rule/mvp-runtime-neutral-core)**: SFS core 가 Claude 에 lock-in 되면 안 된다. MVP 생성 시점부터 공통 core(`SFS.md`)와 runtime adapter(`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`)가 분리되어야 한다. 단, Claude slash command(`/sfs`) 같은 네이티브 UX는 runtime-specific adapter 로 취급한다.

---

## TOC

- §1 왜 이 문서가 필요한가 (문제 정의)
- §2 4-Layer 추상화 모델 (L0 ~ L3)
- §3 현 docset 의 각 자산을 어느 레이어에 매핑하는가 (Lock-in Map)
- §4 이미 brand-decoupled 되어 있는 것들 (DO NOT TOUCH)
- §5 L1 Execution Contract — 개략 카테고리만 (v0.2 에서 정식화)
- §6 Runtime Adapter 슬롯 — MVP 문서 adapter / 후속 SDK adapter 구분
- §7 후속 SDK 어댑터 착수 판정 기준
- §8 문서 유지 보수 약속 (원칙/컨벤션)

---

## §1. 왜 이 문서가 필요한가

### §1.1 문제 정의

현재 Solon v0.4-r3 docset 은 **Claude Code 에 암묵적으로 lock-in** 되어 있다. 사용자가 multi-agent runtime (Codex, Gemini-CLI) 에서도 사용을 원한다는 의도를 표명했고, **지금 Phase 1 구현을 시작하기 전에** 어느 조각이 Claude 전용이고 어느 조각이 agnostic 인지 정리해 두지 않으면 다음과 같은 사고가 난다:

1. Phase 1 구현 후반에 "이거 runtime-agnostic 버전 만드려면 절반을 다시 짜야 하는데?" 가 발견됨 (경제학적으로 = Phase 2 전체 rework).
2. 반대로 과도한 선제 추상화 → Phase 1 에서 1인이 16~20주 안에 끝낼 수 없는 복잡도 유발 (YAGNI 위반, 원칙 7).
3. 둘 다 피하려면 MVP 에서는 **runtime-neutral core + 얇은 문서 adapter** 까지만 구현하고, SDK/플러그인 수준의 깊은 어댑터는 후속으로 미루는 것이 정답.

### §1.2 이 문서의 포지셔닝

이 문서는 v0.4-r3 docset 에 **비파괴적으로 추가되는 reference** 다:

- 기존 본문 (00~10, appendix/*) **수정 없음** (WU-11 A scope).
- Phase 1 구현이 시작되면, 이 문서가 "내가 만드는 파일이 어디 속하는지" 를 판정하는 rubric 역할.
- v0.2 (= WU-11 B scope 해당) 에서는 Claude-specific 파일들에 "이 레이어는 L2/L3 이며 runtime-agnostic 버전은 L1 contract 에 정의됨" 주석을 주입한다.
- v0.3 이후에는 Codex / Gemini-CLI 의 SDK/플러그인 실물 어댑터 초안 파일이 `appendix/runtime-adapters/` 하위에 생긴다.

---

## §2. 4-Layer 추상화 모델

Solon 을 "어느 agent runtime 위에서 돌릴 것인가" 의 관점에서 4 개 레이어로 분리한다.

```
┌────────────────────────────────────────────────────────────────────────┐
│ L3  Install / Package                     (per-runtime, 배포 단위)       │
│     e.g. plugin.json (Claude), agents.toml (Codex?), .gemini/ (Gemini)  │
│     — 실행 환경에 "여기 Solon 이 있다" 고 알리는 레지스트리              │
├────────────────────────────────────────────────────────────────────────┤
│ L2  Runtime Adapter                        (per-runtime, 어댑터 코드)    │
│     Claude adapter: Task tool, sub-agents (agents/*.md), MCP 호출       │
│     Codex adapter:  OpenAI Agents SDK invoke, tool-use, function-call   │
│     Gemini adapter: Gemini-CLI agent primitive, google tool-use         │
│     — L1 contract 을 구체 runtime API 로 변환                            │
├────────────────────────────────────────────────────────────────────────┤
│ L1  Execution Contract                     (agnostic, 🆕 신설)           │
│     "agent 1명에게 프롬프트 주고 응답 받기"                              │
│     "sub-agent spawn / L1 log write / 파일 읽고 쓰기 / tool 호출"        │
│     — 어떤 runtime 도 반드시 구현해야 할 최소 인터페이스 카테고리       │
├────────────────────────────────────────────────────────────────────────┤
│ L0  Domain Core                            (agnostic, 이미 존재)         │
│     PDCA / Gate / Division / 원칙 13개 / 본부 6개 / Evaluator 24개       │
│     dialogs (Socratic 5-phase) / engines (alternative-suggestion)       │
│     schemas (divisions / dialog-state / gate-report / l1-log-event)     │
│     — Solon 이 "무엇인가" 에 대한 답. runtime 과 무관.                   │
└────────────────────────────────────────────────────────────────────────┘
```

### §2.1 레이어별 속성

| Layer | Agnostic? | Phase 1 존재? | 구현 물리적 형태 | 변경 빈도 |
|:-:|:-:|:-:|------|:-:|
| **L3** | ❌ per-runtime | 경량 install.sh + Claude command | `install.sh`, `.claude/commands/sfs.md` | 낮음 |
| **L2** | ❌ per-runtime | 문서 adapter 3종 | `CLAUDE.md`, `AGENTS.md`, `GEMINI.md` | 중간 |
| **L1** | ✅ | ✅ | `SFS.md` + `.sfs-local/` contract | 중간 |
| **L0** | ✅ | ✅ | docset Markdown/YAML (이미 존재) | 낮음 |

### §2.2 핵심 invariant

- **L0 → L1 → L2 → L3** 방향으로 의존. 역방향 의존은 금지.
  - 즉 `02-design-principles.md` 안에서 `plugin.json` 을 직접 언급하면 violation (L0 → L3 역류).
  - 현재 docset 에 이 violation 이 얼마나 있는지는 WU-11 B 에서 스캔 예정. MVP 에서는 검출만 예약.
- **L0 과 L1 은 하나의 runtime 에만 묶이지 않는다**. 여기에 Claude-specific 개념 (Opus/Sonnet/Haiku, Task tool, MCP) 이 들어가면 설계 자체가 오염된 것.

---

## §3. 현 docset 자산의 레이어 매핑 (Lock-in Map)

> 이 표는 "v0.4-r3 에 지금 존재하는 파일/개념" 을 4 레이어 중 어디로 배정할지 MVP 판정. 분류가 애매한 것은 "⚠ 재판정 필요" 로 표기. WU-11 B 에서 각 파일 frontmatter 에 `layer:` 필드를 추가할 때 최종 확정.

### §3.1 L0 Domain Core (agnostic — 이미 완성)

| 자산 | 위치 | 근거 |
|------|------|------|
| PDCA 3-layer (Initiative ⊃ Sprint ⊃ PDCA) | `04-pdca-redef.md` | runtime 무관한 개념 |
| Gate Framework (G-1 + G1~G5) | `05-gate-framework.md` | 품질 게이트는 agent 가 누구든 동일 |
| 6 본부 + 3 C-Level × Division matrix | `03-c-level-matrix.md` | 조직 설계, runtime 무관 |
| 13대 원칙 | `02-design-principles.md` | 철학. 단, §2.2 model allocation (Opus/Sonnet/Haiku) 은 L2 쪽으로 끌어내려야 할 가능성 → **⚠ v0.2 재판정** |
| Socratic 5-phase dialog 스펙 | `appendix/dialogs/*.yaml` | dialog 구조는 agnostic. 다만 "어떤 LLM 이 해석하는가" 는 L2 |
| Alternative Suggestion Engine 스펙 | `appendix/engines/alternative-suggestion-engine.md` | 엔진 policy 자체는 agnostic |
| 6 branch dialog 본부 | `appendix/dialogs/branches/*.yaml` | 본부 지식, agnostic |
| divisions.schema / dialog-state.schema / gate-report / escalation / l1-log-event schemas | `appendix/schemas/*.yaml` | 데이터 포맷, agnostic |
| L3 backend driver contract (notion/none/obsidian/logseq/confluence/custom) | `08-observability.md` + `appendix/drivers/*.manifest.yaml` | 이미 contract 추상화됨 (v0.4-r2) |
| 14 `/sfs *` command spec | `appendix/commands/*.md` | 명령어 시그니처는 CLI 레이어라 L0. 실행 내부가 L2 |

### §3.2 L1 Execution Contract (🆕 신설 — 현재 미존재)

| 카테고리 | 설명 | 현 상태 |
|---------|------|---------|
| Agent invocation | "agent A 에게 프롬프트 P 주고 응답 받기" | 🆕 v0.2 에서 spec |
| Sub-agent spawn | "Lead agent 가 worker agent 를 spawn" | 🆕 v0.2 |
| File I/O | "repo 내 파일 read/write/edit" | 🆕 v0.2 |
| Tool invocation | "CLI / API / MCP 도구 호출" (§10.11 4-tier policy 와 직결) | 🆕 v0.2 |
| L1 log emission | "structured event 를 L1 채널 (S3) 에 기록" | 🆕 v0.2, schema 는 L0 에 이미 존재 |
| Long-running task | "backgrounded job + monitor + resume" | 🆕 v0.2, Claude 의 `run_in_background` 에 준함 |

### §3.3 L2 Runtime Adapter — Claude (Phase 1)

| 자산 | 위치 | Claude 의존 |
|------|------|-------------|
| `agents/` 디렉터리 (15 prompt 원자재) | repo root | Claude Code sub-agent 포맷 (.md + frontmatter) |
| `skills/` 디렉터리 | repo root | Claude Code skill 포맷 |
| `claude-shared-config/` | repo root | Claude Code 전역 설정 |
| Task tool 사용 가정 | `10-phase1-implementation.md` 본문 전반 | Claude Code 전용 |
| Opus / Sonnet / Haiku tier 할당 | `03-c-level-matrix.md §3.6`, `07 §7.2`, plugin.json | Anthropic 모델명. 추상화 시 "Tier L1/L2/L3" 같은 runtime-agnostic 층위로 돌려야 함 → **⚠ v0.2 재판정** |
| MCP 호출 | `10-phase1-implementation.md §10.11.4` | MCP 는 Anthropic 발 스펙이나 일부 타 runtime 도 지원. 현재로선 Claude-biased |
| `appendix/hooks/observability-sync.sample.ts` | appendix | Claude Code hooks 포맷 가정 |

### §3.4 L3 Install / Package — Claude (Phase 1)

| 자산 | 위치 |
|------|------|
| `plugin.json` (Claude Code plugin manifest) | `07-plugin-distribution.md §7.2` |
| `install.sh` | `07 §7.4` |
| Claude Code CLI registration + Claude Desktop Cowork symlink | `07 §7.4 / §7.5` |
| Cowork shared FS 메커니즘 | `07 §7.5` (Claude Desktop 전용 기능) |

### §3.5 ⚠ 레이어 재판정 필요 목록 (v0.2 작업)

1. `02-design-principles.md §2.2` 근처의 model allocation 언급 — L0 에 머무를 것인가 L2 로 내려갈 것인가.
2. MCP 사용 언급 전반 (§10.11.4) — "tool protocol" 을 L1 에서 agnostic 화할 수 있는가.
3. `principle/cli-gui-shared-backend` 의 "GUI" = 현재는 Claude Desktop Cowork 만 가리킴. Codex Desktop / Gemini Desktop 이 생기면 재정의 필요.
4. `agents/*.md` frontmatter 의 `model:` 필드 — runtime-agnostic 하게 쓰려면 모델 tier 추상화 필요.

---

## §4. 이미 brand-decoupled 되어 있는 것들 (🚨 DO NOT TOUCH)

> 사용자 지시 verbatim: "건드리지 마: `/sfs` CLI prefix (brand-decoupled), `sfs-*` structural IDs, `.sfs-local/`, 역사 참조 3곳, 원칙 ID 3종"

이 자산들은 runtime 이 바뀌어도 동일하게 유지된다. Runtime Abstraction 작업 중 이 목록을 건드리면 abstraction 이 아니라 rename 이 되어 버린다.

| 자산 | 이유 | 변경 시 영향 |
|------|------|-------------|
| `/sfs` CLI prefix | 이미 brand (Solon) 와 분리된 구조적 prefix. runtime 마다 slash command 방식이 달라도 prefix 는 동일 유지 | breaking change (사용자 머슬 메모리 + doc_id 체계) |
| `sfs-*` structural IDs (`sfs-plan`, `sfs-gates`, `sfs-doc-validate` 등) | 문서/스키마의 fixed identifier | cross-ref 전체 깨짐 |
| `.sfs-local/` 디렉터리 | 런타임 무관한 local state scratch | 기존 사용자 state 유실 |
| 역사 참조 3곳 (`07-plugin-distribution.md:917, 1050`, `02-design-principles.md:527`) | v0.3 시절 "SFS/bkit" 언급. 역사 증거물 | 과거 decision log 단절 |
| 원칙 ID 3종 (`sprint-superset-pdca`, `cli-gui-shared-backend`, `phase1-phase2-separation`) | 원칙 ID 는 cross-reference 의 뿌리 | 모든 references: 링크 깨짐 |

L2/L3 어댑터가 추가되어도 이 목록은 불변.

---

## §5. L1 Execution Contract — 개략 카테고리 (MVP)

> **v0.2 에서 정식화**. 본 MVP 는 "어떤 카테고리가 반드시 필요한지" 만 선언.

L1 은 "agent runtime 이 Solon 을 돌리기 위해 반드시 제공해야 할 기본 operation 집합" 이다. Claude Code / Codex / Gemini-CLI 는 각자 다른 이름/시그니처로 이 operation 들을 제공한다.

### §5.1 필수 operation 카테고리 (6개)

1. **`invoke_agent(agent_id, prompt, context) -> response`**
   - Claude: Task tool + sub-agent
   - Codex: OpenAI Agents SDK `Runner.run`
   - Gemini-CLI: Gemini agent primitive
2. **`spawn_worker(lead_agent, worker_spec, task) -> handle`**
   - Lead agent 가 worker 를 만들고 task 를 위임
3. **`read_file(path) / write_file(path, content) / edit_file(path, diff)`**
   - 모든 runtime 이 FS 접근 제공. 차이는 sandbox 경계.
4. **`invoke_tool(tool_kind, spec, args) -> output`**
   - `tool_kind ∈ {cli, api, mcp, runtime-native}` (§10.11 CLI-First 4-tier 와 직결)
5. **`emit_l1_event(event_type, payload)`**
   - L1 log 채널에 schema-검증된 event 기록. Schema 는 L0 (`appendix/schemas/l1-log-event.schema.yaml`).
6. **`run_in_background(cmd) -> handle` + `monitor(handle)`**
   - 장시간 작업 비동기 실행 + 완료 알림. 세 runtime 모두 유사 primitive 제공.

### §5.2 L1 이 포함하지 **않는** 것 (의도적 exclusion)

- **모델 선택**: "Opus vs Sonnet vs Haiku" 같은 runtime-specific 모델명은 L2 의 책임. L1 은 "tier L1 / L2 / L3" 같은 추상 등급만 노출.
- **사용자 UI**: CLI vs Desktop GUI 차이는 L3 의 책임.
- **인증/계정**: 각 runtime 의 API key 관리는 L3.

### §5.3 L1 스펙 파일 (v0.2 예정)

```
appendix/contracts/
  execution-contract.v1.yaml          # 🆕 v0.2 — L1 spec 본체
  execution-contract.examples.yaml    # 🆕 v0.2 — 각 runtime 별 "이 operation 이 어떻게 mapping 되는가" 예시
```

---

## §6. Runtime Adapter 슬롯

### §6.1 Claude Adapter (MVP active)

- **Status**: MVP 포함.
- **Distribution files**: `CLAUDE.md`, `.claude/commands/sfs.md`
- **Maps SFS core to**: Claude Code project memory + project slash command (`/sfs`)
- **Deferred**: 정식 `claude plugin install solon` packaging.

### §6.2 Codex Adapter (MVP active, document adapter)

- **Status**: MVP 포함.
- **Distribution files**: `AGENTS.md`
- **Maps SFS core to**: Codex repo instructions. `/sfs ...` 는 native slash command 가 아니라 natural-language alias 로 처리.
- **Deferred SDK questions**:
  - Codex 의 sub-agent spawn 모델이 Claude Task tool 과 얼마나 호환되는가?
  - MCP / native tool-use / function-call 을 어떤 레이어에서 추상화할 것인가?

### §6.3 Gemini-CLI Adapter (MVP active, document adapter)

- **Status**: MVP 포함.
- **Distribution files**: `GEMINI.md`
- **Maps SFS core to**: Gemini CLI project instruction context. `/sfs ...` 는 native slash command 가 아니라 natural-language alias 로 처리.
- **Deferred SDK questions**:
  - Gemini-CLI 가 long-running background 작업을 네이티브 지원하는가?
  - Context window 제약 차이 (Gemini 의 2M token 장점이 Solon Evaluator polling pattern 에 어떻게 영향?)

### §6.4 어댑터 공통 테스트 매트릭스

| 시나리오 | Claude | Codex | Gemini-CLI |
|---------|:-:|:-:|:-:|
| 공통 core 파일 인식 (`SFS.md`) | ✅ | ✅ | ✅ |
| runtime adapter 파일 인식 | ✅ `CLAUDE.md` | ✅ `AGENTS.md` | ✅ `GEMINI.md` |
| 상태 확인 flow | ✅ `/sfs status` | ✅ `sfs status` alias | ✅ `sfs status` alias |
| native slash command | ✅ | 후속 | 후속 |
| SDK-level worker orchestration | 후속 | 후속 | 후속 |

✅ = MVP 검증 대상. 후속 = MVP 이후 정식 SDK/plugin adapter 대상.

---

## §7. 후속 SDK 어댑터 착수 판정 기준

> 언제 Codex / Gemini-CLI 의 SDK/plugin 수준 어댑터를 만들 것인가의 판정 룰.

**모든 조건을 만족** 해야 후속 SDK 어댑터 착수:

1. `SFS.md` + adapter docs 로 최소 1개 실제 프로젝트 cycle 운용 성공.
2. Claude/Codex/Gemini 중 최소 2개 runtime 에서 같은 `.sfs-local/` 산출물을 읽고 이어받는 흐름 확인.
3. native slash command / SDK orchestration 이 실제 병목이라는 증거 확보.
4. 사용자 (채명정) 가 후속 상품화 go 결정.

조건 미충족 시 SDK adapter 는 만들지 않는다. MVP adapter docs 로 운용한다.

---

## §8. 문서 유지 보수 약속

이 문서는 **작게 성장하는 reference** 다. 비대화 방지를 위해 다음 규칙을 둔다:

1. **WU-11 A (v0.1-mvp)**: 본 문서 신설 + 4-layer 골격 + lock-in map 작성.
2. **2026-04-24 correction (v0.2-mvp-correction)**: runtime abstraction 은 root SFS 설계의 MVP 범위임을 명시. `solon-mvp` 생성 시 `SFS.md` + `CLAUDE.md`/`AGENTS.md`/`GEMINI.md` adapter 가 포함돼야 함.
3. **후속**: SDK/plugin 수준 `appendix/runtime-adapters/{codex,gemini-cli}/` 는 실제 병목 확인 후 작성.

이 문서 자체의 크기는 **A4 6~8장 상한**. 그보다 커지면 별도 파일 (예: `RUNTIME-ABSTRACTION-contract.md`) 로 분리.

---

## §9. 관련 원칙 / 결정

- **원칙 `phase1-phase2-separation`** (02 §2.x): Phase 1 = 채명정 dogfooding, Phase 2 = 상품화. 본 문서는 이 원칙을 runtime 축으로 재확인.
- **원칙 `cli-gui-shared-backend`** (02 §2.x): 동일 backend 를 CLI / GUI 가 공유. Claude Code (CLI) + Claude Desktop Cowork (GUI) 에만 묶이지 않도록, 본 문서 §3.5 항목 3 에서 재정의 예약.
- **§10.11 CLI-First Tool Selection Policy**: CLI > API > MCP > Claude-native 4-tier preference. 본 문서 §5.1 operation 4 (`invoke_tool`) 의 `tool_kind` 에 직접 반영.
- **원칙 13 `progressive-activation-non-prescriptive-guidance`**: abstraction 도 마찬가지 — Phase 1 에는 abstract 상태로 두고, 실제 필요 시 active 화. Codex / Gemini-CLI 어댑터는 현재 **abstract state** 로 선언된 것과 동치.

---

## Changelog

- **v0.1-mvp** (2026-04-20, WU-11 A): 초안 작성. 4-layer 모델 + lock-in map + Phase 1/2 슬롯 선언만 포함. 본문 수정 없음.
