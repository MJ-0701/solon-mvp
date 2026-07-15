---
doc_id: solon-product-methodology-7-step
title: "Methodology — 7-step flow + Gate 1~7 표기"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-07-12
summary: "7-step flow summary applied even to this repo's own development. Gate display labels are 1~7; new CLI examples use --gate 6 style."
load_when: "Read for a quick refresher on the 7-step / Gate label convention. Deeper policy lives in routed context (kernel.md, commands/*.md, policies/*.md)."
---

# Methodology — 7-step flow

본 문서는 0.7.2 이전 CLAUDE.md 의 § 7-step flow 요약 섹션을 떼어내 분리한
maintenance doc 이다. 본 repo 자체 개발에도 동일 7-step 이 적용된다. routed
context 가 SSoT 이고 (`kernel.md`, `commands/*.md`, `policies/*.md`), 본
문서는 빠른 참조용 요약이다.

## 7-step 요약

1. **CEO 요구사항 정리** — Gate 2 (Brainstorm)
2. **CEO plan** — Gate 3 (Plan)
3. **CTO Generator ↔ CPO Evaluator sprint contract**
4. **`/sfs implement` 로 CTO 구현** — Gate 4 (Design/Entry) — 실제 코드 +
   `implement.md` / `log.md` evidence
5. **CPO review** — Gate 6 (Review)
6. **CTO review 확인 + 사용자 최종 통과**
7. **회고 / 문서화**

## 착수 전 (step 1 정렬)

WU 를 위임할 가치가 있는지(다중 입력 / 산출물 / 반복성 / "good" 기준 / 지루한
중간의 5요소), 착수 전 **요구 복창 + 클래리파잉 질문**, 어떤 런타임 tier (quick
chat / assisted session / autonomous code) 로 돌릴지는 routed context
`policies/work-delegation-and-startup.md` 가 SSoT 다 (여기서 재나열하지 않는다 —
포인터만).

plan(Gate 3) 진입 시 **eval-first**: 통과/실패를 가를 ground-truth 케이스 + 채점
차원을 코드보다 먼저 고정한다 ("eval = first commit"). SSoT 는 routed context
`commands/flowcheck.md` 의 Plan-gate self-check 5번 + `policies/skill-promotion-loop.md`
HELD_OUT_SCORING (여기서 재나열하지 않는다 — 포인터만).

같은 plan 진입 시 **unknowns 프리플라이트**: 프롬프트/계획(맵)과 코드베이스
(territory) 의 간극을 4분면(UNKNOWNS_QUADRANT)으로 분해하고, 계약 확정 전
BLIND_SPOT_PASS 한 번으로 에이전트에게 "내가 말하지 않은 것"을 묻는다
(kickoff `blind_spots` 목록, answered/delegated/open 상태). 방향 자체가
말로 표현 안 되면 PROTOTYPE_FORK(2~4 시안 + 비교표 + 선택/탈락 사유 기록),
방향 확정 후엔 SPEC_INTERVIEW_GATE(질문 영향도순 정렬 → 답변 스펙 병합 →
명시적 skip 만 허용), 원하는 동작을 이미 하는 코드가 있으면 REFERENCES_FIELD
(경로/커밋 + 의도 1줄, 구현 전 필독)로 맵을 좁힌다. 구현 중
계획 이탈은 보수적 선택 + `## Deviations` 기록 후 계속(DEVIATIONS_LOG, lessons
SIGNAL 입력원, 완료 주장은 ledger 명시 — entries 또는 `none observed`), 구현 후
explainer/quiz 는 운영자 이해도 게이트다 (COMPREHENSION_GATE, signal-only,
변경 기반 3~5문항). SSoT 는 routed context
`policies/unknowns-and-deviations.md` (여기서 재나열하지 않는다 — 포인터만).

단계 분해는 모델 성능과 무관한 **불변 규율**이다 — 입력 통제·작고 반복
가능한 단계·checked steps 는 모델이 아무리 뛰어나도 유지된다 (외부 검증
by-reference: 최전선 finance-diligence 사례, Claude 블로그 2026-07-13;
vendor/성과 수치 보류). 모델 교체 판단은 같은 도메인 eval head-to-head 로
한다 — SSoT 는 `policies/model-workaround-sunset.md`
MODEL_HEAD_TO_HEAD_ON_UPGRADE (여기서 재나열하지 않는다 — 포인터만).

또 **map-first**: 구현 착수 전 작업 전체를 먼저 매핑(PRD + 티켓 분해)한 뒤 독립
워크플로로 병렬화한다 — 첫 코드 전에 하루 분량의 계획이 나머지를 즉흥 아닌 실행으로
바꾼다. 외부 검증(by-reference): Claude 블로그 build-day 해커톤 글(2026-06-17)
1위 조언 "짓기 전에 프로젝트 전체를 매핑". solon dynamic-workflow / advisor 분배와
정합 (일반화 원칙만 승격, 벤더·인명·모델버전 디테일 보류).

## Gate 표기 규약

- Solon report 에서는 **Gate 1~7 표시**를 쓴다 (Intake / Brainstorm / Plan /
  Design / Handoff / Review / Retro).
- 새 CLI 예시는 **`--gate 6`** 처럼 1~7 숫자를 쓴다.
- 내부 id 는 `G-1 / G0 / G1 / G2 / G3 / G4 / G5` 로 7-display 와 매핑되어
  있다 (`templates/.sfs-local-template/scripts/sfs-common.sh` 의
  `sfs_gate_display_label`).

## Signal vs hard block

Gate 는 all signal-only (ALT-INV-3 never-hard-block). 단 CPO review 자체는
sprint flow 의 필수 단계이며, review executor / tool 은 Codex / Gemini /
Claude / custom 중 선택 가능하다. `/sfs review` 는 artifact acceptance
review 이고, code review 는 자동 또는 명시 `code` lens 일 때만 적용한다.
Production open 을 수반하면 Release Readiness evidence (secret / auth /
data / monitoring / rollback / cost) 를 review 또는 retro-light 에 남긴다.

## 피드백 플라이휠 (record → reflect)

review / bug triage 에서 **두 번 이상** 반복 발견된 문제는 검증 도구(테스트 /
린터 / 게이트 / fixture)에 재반영하는 것이 의무다. 한 번 잡힌 실패는
`.sfs-local/lessons.md` 에 회피 규칙으로 기록(record)하고, 반복되면 검증 도구로
승격(reflect)해 lesson 의 `promoted` 필드에 그 도구를 기재한다. 기록과 도구 반영은
별개 시스템이 아니라 한 루프다 — lesson 이 근거를 보존하고 도구가 강제한다. 도구
출력(에러 / 테스트 / 체크 메시지)은 다음 에이전트의 교육 자료이므로 무엇이 왜
실패했고 어떻게 고치는지 actionable 하게 적는다. 규약 SSoT:
routed context `policies/lessons-accumulation.md`.

## 산출물 provenance + doc colocation

7-step 산출물 / 리포트 중 **독자가 스스로 검증하기 어려운 것**에는 한 줄
provenance footer 를 붙여 신뢰 수준을 노출한다 (비기술 1인 운영자 대상). 또
routed context 를 바꾸면 대응 문서·route 를 같은 변경에서 동반 수정한다 (doc
colocation). 다섯 필드 정의와 colocation/broken-link 규약 SSoT:
routed context `policies/doc-colocation-provenance.md` (여기서 필드를 다시
나열하지 않는다 — 포인터만).

## 6본부 always-on

7-step 과 직교하는 축으로, 6 division (strategy-pm / dev / QA / design /
infra / taxonomy) 이 brainstorm 부터 Gate 6 까지 *항상* 개념적 sub-agent 로
개입한다. `.sfs-local/divisions.yaml` 의 `activation_state` 는 *깊이* 만
제어하지 참여 여부를 제어하지 않는다.

상세 규약: [`policies/six-division-council.md`](policies/six-division-council.md).

## Model-tier quick reference

모델은 역할별로 고른다. Advisor/CPO 판단은 top/high reasoning (Claude Opus,
Codex `gpt-5.5` xhigh, Gemini Pro 계열), plan sequencing 과 질문 진행은
standard facilitator (Claude Sonnet, Codex `gpt-5.4`), 좁은 helper I/O 는
economy tier (Haiku, Codex mini, Gemini lite) 를 쓴다. 구현 slice 는 고정된
AC 안에서 worker tier 로 실행하고, Codex repo-aware helper 는 `gpt-5.3-codex`
까지 허용한다. Spark 류는 판단 없는 mechanical helper 전용이다.

실패 시 knob 에스컬레이션 순서는 컨텍스트/스킬 점검 → effort(철저함) ↑ →
모델 티어 ↑ 이고, 판별 질문은 "몰라서 틀렸나(모델) vs 대충해서 틀렸나
(effort)". 루틴 구간은 작은 티어로 다운시프트한다. SSoT 는 routed context
`policies/token-harness.md` 의 KNOB_DIAGNOSTIC_LADDER (여기서 재나열하지
않는다 — 포인터만).

## Host-agnostic 진입 (0.7.0+)

7-step flow 는 host transport 와 직교한다. 어떤 호스트로 들어와도 같은
flow / 같은 sprint state / 같은 Gate / 같은 SSoT 가 적용된다:

- **CLI** — terminal 의 `sfs <cmd>` 직접 호출. Claude Code / Gemini CLI /
  Codex CLI / Windows PowerShell 모두 이 채널.
- **MCP** — `mcp-server/` 의 stdio MCP server 가 `sfs_*` tool 로 같은
  명령을 노출. Claude Desktop / Claude in Chrome / Cursor / Claude Agent
  SDK 등 MCP host 가 이 채널로 7-step 을 끌어다 쓴다.
- **Agent SDK** — `templates/claude-agent-sdk-zero/` scaffold 가 Claude
  Agent SDK 프로젝트를 `solon-mcp` + `solon-safe-permissions.yaml` 로
  bootstrapping. 자기 agent 안에서 `sfs_*` tool 을 직접 호출.

세 채널 비교 + 호스트별 등록 cheat sheet 는
[`docs/ko/current-product-shape/23-host-channels-and-mcp.md`](../ko/current-product-shape/23-host-channels-and-mcp.md)
([EN](../en/current-product-shape/23-host-channels-and-mcp.md)).

`agent-build` review lens 는 agent / MCP / sub-agent 를 ship 하는 sprint
에서 Gate 6 에 자동 라우팅된다 (0.7.1+). 7개 subsection (tool surface scope
/ permission posture / sub-agent isolation / system prompt drift / SSoT /
evidence / failure modes) 을 CPO 가 점검한다. 자세한 lens 정책은
`sfs context cat policies/agent-build-review-lens`.

## Routed context SSoT

본 문서는 빠른 참조이고, 실제 SSoT 는 routed context 다:

- `sfs context cat kernel`
- `sfs context cat index`
- `sfs context cat commands/<name>`
- `sfs context cat policies/<name>`
- `sfs context list` (0.7.1+) — slug 색인 출력
