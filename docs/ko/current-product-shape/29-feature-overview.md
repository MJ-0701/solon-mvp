---
doc_id: sfs-current-product-shape-ko-29
title: "기능 총람 (Feature Overview)"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-08-27
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
| unknowns 루프 (정찰·시안 fork·인터뷰 게이트·blind_spots·references·deviation ledger·이해 퀴즈) | plan/implement/review 레일 + 스프린트 템플릿 섹션 (signal-only) | [Unknowns 루프](./30-unknowns-loop.md) |
| unknowns 런타임 신호 (deviation-ledger / plan-readiness advisory) | `sfs healthcheck` WARN (exit 불변) | [Unknowns 루프](./30-unknowns-loop.md) |
| 자기 반증 패스 (구현 착수 전 1회) | 리서치 결론을 스스로 공격 — 반증 시도와 살아남은 것을 plan 에 기록, 흔적 없으면 리뷰 finding (signal-only) | routed context `policies/source-pointer-citation.md` (ANTAGONISTIC_RESEARCH_PASS) |

### 2. Evidence·기록 프리미티브

| 기능 | 표면 | 상세 |
|---|---|---|
| 최소 사실 기록 | `sfs capture [--kind ...]` / `sfs note` | [capture](./08-capture-evidence-primitive.md) |
| 결정 기록 | `sfs decision` / `sfs event` | routed context `commands/*` |
| 보고/버그 | `sfs report` / `sfs report-bug` | bug-report lifecycle 정책 |
| 과거 회수 | `sfs recall` | routed context `commands/recall.md` |
| 공유 산출물 | `docs/solon/<domain>/.../report.md`·`retro.md` | [design.md](./13-design-md-ai.md) |
| 추론 로그 = 감사 산출물 (고위험 티어 한정) | 파괴적·장시간 무인 작업에 한해 판단 경로를 산출물로 계약 — 사전 invariant 선언의 사후 짝, 일상 작업엔 미적용 | routed context `policies/flow-conformance-postflight.md` (REASONING_LOG_AS_AUDIT_ARTIFACT) |

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
| 무문서 코드베이스 역추적 (L0 스캔·ERD·L1 그래프·fact card·확증 상태) | `sfs dig scan|graph|capsule|card|status` | routed context `commands/dig.md` |
| 정적 보안 감사 (OWASP 계열, secret redact, 방어 범위) | `sfs audit scan|report|status` | routed context `commands/audit.md` |
| held-out evals scaffold (eval-first·wrong-premise fixture 축) | `.sfs-local/evals/README.md` + doctor "Held-Out Evals" 섹션 (케이스 수만, 내용 미열람) | [Unknowns 루프](./30-unknowns-loop.md) |
| 모델 교체 규율 (head-to-head 벤치 + 새 모델의 셋업 감사) | 정책 `model-workaround-sunset.md` (MODEL_HEAD_TO_HEAD_ON_UPGRADE / MODEL_UPGRADE_SETUP_AUDIT, tidy 레일) | routed context `policies/model-workaround-sunset.md` |
| 과제약·중복 지시 감지 (rightsize) | doctor "Context Conflict Gate" 섹션 — 2개 이상 표면에 재기술된 상시 지시 + 서술형 always/never 카운트 (info-only) | routed context `policies/context-conflict-gate.md` (RIGHTSIZE_CONTEXT_PASS) |
| 런 중(in-flight) intent 재검증 | 장시간·무인 WU 의 스텝 경계마다 가정 변화 + 원 AC 대조를 산출물에 남김 (침묵 직진 = drift finding, advisory) | routed context `policies/flow-conformance-postflight.md` (MID_RUN_INTENT_RECHECK) |
| 게이트 활동 계측 | doctor "Verification Loop" 섹션 — deviation ledger·lessons 를 읽어 게이트가 실제로 무언가를 잡았는지 표시. 활동 0 = 안전 입증이 아니라 미검증 (info-only, exit 불변) | `scripts/sfs-harness.sh` `gate_activity_check` |

Sanity→Cartography 순서 규율과 모든 지표의 signal-only(차단 없음) 계약이
함께 적용됩니다.

### 4. 컨텍스트 라우팅·토큰 위생

| 기능 | 표면 | 상세 |
|---|---|---|
| routed context 조회 | `sfs context path\|cat\|list` | [토큰 다이어트](./03-token-diet-compact-i-o.md) |
| 얇은 어댑터 유지 | `sfs agent doctor --fix` / `sfs doctor --fix` | [토큰·하네스 위생](./17-token-harness-hygiene.md) |
| 캐시 프리픽스 규율 | 정책 `policies/token-harness.md` (세션 고정 prefix, 새 세션 재시작) | 같은 문서 |
| 워커 위임 캡슐 | 정책 `sub-agent-capsule-contract.md` (goal/AC/scope/budget + optional exemplar; verb 단위 least-agency, done=디스크 산출물, 공유표면 충돌 스캔) | [위임 레퍼토리](./26-delegation-repertoire.md) |
| 대규모 배치 루프 규율 (룰 상류 수정·judge 음성대조·비싼 연산 직렬화) | 정책 `harness-autonomy.md` / `token-harness.md` (FIX_THE_LOOP / JUDGE_NEGATIVE_CONTROL / SERIALIZE_EXPENSIVE_OPS) | routed context `policies/harness-autonomy.md` |
| 지시 배치 판별 (비우회 게이트 vs 서술 advisory) | 한 번의 위반이 치명적이면 집행 표면으로, 아니면 trim 후보 — 라벨링이지 삭제가 아님 | routed context `policies/steering-surface-taxonomy.md` (RULE_VS_GUARDRAIL) |
| 결과당 비용 프레임 | 토큰이 아니라 결과 하나당 비용으로 진입 — "에이전트 없이 했다면 얼마였나(안 했을 일 포함)", "어려운 일인가 그냥 양이 많은 일인가" | routed context `policies/token-harness.md` (KNOB_DIAGNOSTIC_LADDER) |
| 코어 고정 · 확장은 버전 표면 | 신규 기능이 코어 변경인지 버전 붙은 확장인지 먼저 판별 — 확장 경로가 없으면 압력이 코어를 오염시킴 | routed context `policies/skill-catalog-discipline.md` (VERSIONED_EXTENSION_SURFACE) |
| 검증 체크 배치 사다리 | standalone → embedded → chained → 매 변경; 수동 반복 호출 = 승격 신호, 습관→계약 체이닝은 트레이드오프 동반 | routed context `policies/loop-taxonomy.md` (CHECK_PLACEMENT_LADDER) |
| 스펙=아티팩트 / 제어로직=데이터 | 검증 대상과 실행 대상 사이 번역층 금지, 루틴·전이·게이트는 읽고 고칠 수 있는 데이터 표면 | routed context `policies/harness-autonomy.md` (SPEC_IS_THE_ARTIFACT / CONTROL_LOGIC_AS_DATA) |

### 5. 팀·오케스트레이션

| 기능 | 표면 | 상세 |
|---|---|---|
| 팀 preset 활성화 | `sfs team use <solo\|pair\|trio>` / `team refresh` / `team show` | [인간-에이전트 팀](./27-human-agent-teams.md) |
| 5개 조직 본부 + cross-cutting taxonomy lens의 6개 필수 council role (always-on) | `sfs division` + `.sfs-local/divisions.yaml` | [리뷰 렌즈](./14-review-lens.md) |
| 작업 라우팅/오케스트레이터 | `sfs route` / `sfs orchestrator` / `sfs dispatch` | [작업 인입 라우팅](./20-ai-work-intake-routing.md) |
| 반복 루프 | `sfs loop` + loop-taxonomy 정책 (4유형 결정 렌즈) | routed context `policies/loop-taxonomy.md` |
| 에이전트 신원/권한 구획 | 정책 `agent-identity`·compartment 계열 | [신원과 구획](./28-agent-identity-and-compartments.md) |
| advisor 선택 코칭 바인딩 | 빠른 worker + 필요 시에만 advisor — 호출 조건(막힘/검증 게이트 · 출하 직전 검증이 대표 지점/저신뢰)이 `agent_runtime_bindings` 옆 데이터 표면 | routed context `policies/external-orchestrator-entry.md` (ADVISOR_STRATEGY_BINDING) |
| 단계별 effort 사전 배분 | capsule 발행 시점에 배분 — 라우팅·추출·요약은 저 effort, 최종 판단·리뷰는 고 effort. 실패 후 에스컬레이션과 별개(상한 아님) | routed context `policies/sub-agent-capsule-contract.md` (SUBAGENT_TIER_DEFAULT) |
| 무인 위임 판별 신호 | 에이전트가 스스로 올라탈 측정 신호가 없으면 위험이 낮아도 `decision` 단위로 못 올라감 — "밤새 돌릴 수 있는 일인가" | routed context `policies/work-delegation-and-startup.md` (DELEGATION_UNIT_LADDER) |
| 위임 단위 사다리 | chunk → task → decision, 검증 신뢰로 올라가고 대상 표면의 위험 티어로 상한 | routed context `policies/work-delegation-and-startup.md` (DELEGATION_UNIT_LADDER) |

### 6. 기억·위키 (장기 메모리)

| 기능 | 표면 | 상세 |
|---|---|---|
| LLM 탐색 위키 | `llm-wiki/` (opt-in, waiver 가능) | [wiki 연속성](./19-obsidian-llm-wiki-continuity.md), [온보딩](./25-wiki-onboarding-guide.md) |
| Raw source intake | `sfs ingest --source-type --purpose` | [인입 라우팅](./20-ai-work-intake-routing.md) |
| 승격 파이프라인 | `sfs tidy --all --wiki-promote [--apply]` | [도메인 지식 자산](./21-domain-knowledge-assets.md) |
| 반복 실수 원장 | `.sfs-local/lessons.md` (record→reflect 플라이휠) | routed context `policies/lessons-accumulation.md` |
| 보안 finding 클래스 폐루프 | waiver·수정으로 끝내지 않고 재발 클래스는 routed 룰·skill·회귀잠금으로 승격 | routed context `commands/audit.md` (VULNERABILITY_CLASS_CLOSED_LOOP) |
| 수동 리뷰 → eval 승격 | 자동화 전 손으로 한 번 수행해 "good" 고정 후, 구조화한 리뷰를 held-out 케이스로 승격 (judge 에이전트 채점) | routed context `policies/self-improvement-loop.md` (BE_THE_AGENT_FIRST / REFLECTION_TO_EVAL_PIPELINE) |
| 파생 문서 주석 보존 | 코드에서 파생한 문서를 재생성할 때 사람이 항목에 단 why/correction/constraint 주석을 덮어쓰지 않고 보존 (충돌은 gap 으로) | routed context `policies/doc-colocation-provenance.md` (DERIVED_DOC_ANNOTATION) |

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
- 새 커넥터/MCP/외부 도구 연결 전 **4질문 리스크 프리플라이트** (untrusted
  ingest / 액션·신원 / blast radius / 관측성 — suggest-only, `policies/credential-hygiene.md`);
  capsule 도구는 verb 단위 최소화 — 비가역 verb 는 목록 제거 = by-construction 차단.
- 경계는 오늘 모델 한계가 아니라 **운영자 허용 기준**으로 설계 —
  모델 업그레이드 후 경계 안 emergent 행동은 관측성이 잡습니다
  (`policies/harness-autonomy.md` BOUNDS_OUTLIVE_MODEL_LIMITS).
- 매번 지켜야 할 것은 프롬프트가 아니라 **harness** 에 둡니다 — 장기 런에서
  프롬프트 문장은 결국 무시되므로, 상시 규칙은 레일·게이트·회귀잠금으로
  내려갑니다 (`policies/harness-autonomy.md` PROMPTS_ARE_SUGGESTIONS).
- 신뢰불가 입력에 닿는 **접점마다** 인젝션 채점 체크포인트를 두고, 하이재킹은
  막는 게 아니라 도달 범위를 미리 좁혀 봉쇄합니다
  (`policies/credential-hygiene.md` INGRESS_TRUST_CHECKPOINT).
- 매 스텝 사람 승인은 **안전 근거가 아닙니다** — 승인 검출력은 세션이 길수록
  떨어지므로, 상시 규칙은 harness 층에 두고 희소한 승인은 재량 불가 클래스에만
  씁니다 (`policies/harness-autonomy.md` APPROVAL_FATIGUE_DECAY).
- **재량에 넘기지 않는 클래스**가 따로 있습니다 — 자격증명·소스 외부 송출,
  그리고 사람에게 나가는 메시지(메일·메신저·티켓 코멘트). 설정 데이터 표면에
  선언되고 사용자 요청으로 열리지 않으며, 런 시작 전 선언 변경만 가능합니다
  (`policies/credential-hygiene.md` NEVER_APPROVE_CLASS). 게이트를 통째로
  우회시키는 광역 waiver 는 예외가 아니라 게이트 폐지로 분류됩니다.
- 쓰기 작업은 consent-gated: `--yes`/`--apply`/dry-run 프리뷰가 기본.
- 외부 오케스트레이터·지식 그래프·위키는 opt-in — 제거해도 전 기능 동일
  동작 (standalone 보증).
- 비용/readiness 어댑터는 토큰 집계와 도구 이름만 읽고 메시지 본문은 읽지
  않습니다.
