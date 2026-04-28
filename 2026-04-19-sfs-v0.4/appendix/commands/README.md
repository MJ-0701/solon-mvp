---
doc_id: sfs-v0.4-appendix-commands-index
title: "Solon Command Spec Index (/sfs *)"
version: 0.4-r4
status: draft
last_updated: 2026-04-28
audience: [implementers, plugin-developers]

defines:
  - concept/sfs-command
  - schema/command-spec-v1

references:
  - principle/human-final-filter (defined in: s02)
  - principle/brownfield-first-pass (defined in: s02)
  - phase/p-1-discovery (defined in: s04)
  - concept/g-1-intake-gate (defined in: s05)
  - concept/release-readiness-gate (defined in: s05)
  - plugin/solon (defined in: s07)
---

# Solon `/sfs *` Command Spec Index

> Solon 플러그인이 Claude Code에 노출하는 **Slash Command 13종**의 단일 레지스트리.
> 각 command는 `commands/<name>.md` 파일로 별도 정의. 본 README는 목록·호출 관계·스키마만 기술한다.

---

## 0. 네이밍 규약

- 모든 command는 `/sfs <subcommand>` 형태 (plugin namespace = `sfs`, Solon 제품명과 별개)
- 파일 이름: `<subcommand>.md` (hyphen-lowercase)
- `defines` 필드에 `skill/<subcommand>` 추가 — Solon의 skill slot과 1:1 매핑

> **Solon vs /sfs 프리픽스**: 제품명은 Solon, 플러그인 namespace는 `sfs` (historical, v0.4 이전부터 사용). v0.5에서 `/solon` alias 추가 검토. 현재는 `/sfs`만 공식.

## 1. 13개 Command 전체 목록

| # | Command | Phase | Mode | 오퍼레이터 | 주요 trigger |
|:-:|---------|:-----:|:----:|-----------|-------------|
| 0 | `/sfs install` | setup | 공통 | user (CLI) | 최초 설치 |
| 1 | `/sfs discover` 🆕 | **P-1** | brownfield only | `strategy/ceo` | `install --mode brownfield` 직후 자동 호출 |
| 2 | `/sfs brainstorm` | G0 | 공통 | `strategy/ceo` | 새 Initiative 시작 시 |
| 3 | `/sfs plan` | Plan | 공통 | `strategy-pm/lead` | 새 PDCA Plan 작성 |
| 4 | `/sfs design` | Design | 공통 | 각 본부장 | Plan G1 통과 후 |
| 5 | `/sfs do` | Do | 공통 | 각 본부 worker | Design G2 통과 후 |
| 6 | `/sfs handoff` | Do→Check | 공통 | 각 본부장 | G3 호출 래퍼 |
| 7 | `/sfs check` | Check | 공통 | `qa/lead` + `strategy/cpo` | Do 완료 후 G4 호출 |
| 8 | `/sfs act` | Act | 공통 | `strategy-pm/lead` | G4 통과 후 learnings 기록 |
| 9 | `/sfs retro` | Sprint Retro | 공통 | `strategy/ceo` + `strategy-pm/lead` | Sprint 종료 시 G5 |
| 10 | `/sfs status` | any | 공통 | any | 현재 PDCA/Gate 상태 조회 |
| 11 | `/sfs escalate` | any | 공통 | 각 본부장 | 수동 escalate 트리거 |
| 12 | `/sfs division` | division admin | 공통 | user only | 본부 activation_state 조회/변경 |

총 13개 — 기존 11개(#0, #2~#11)에 brownfield 지원을 위해 `#1 /sfs discover`를 v0.4-r2에서 추가했고, v0.4-r3에서 `#12 /sfs division`을 추가.

> **Release Readiness note (2026-04-28)**: `gate_id: RELEASE` 는 §5.12와 schema에 먼저 추가됐지만, slash command 는 아직 미확정이다. 후보는 `/sfs check --release-readiness` 로 흡수하거나 `/sfs release` 를 신설하는 두 가지다. 결정 전까지 command 목록에는 추가하지 않는다.

## 2. Command 간 호출 관계 (DAG)

```
install (greenfield)
    └─> brainstorm ─> plan ─> design ─> do ─> handoff ─> check ─> act ─> (Sprint 끝) ─> retro

install --mode brownfield
    └─> discover ─> [G-1 intake] ─> plan ─> design ─> do ─> handoff ─> check ─> act ─> retro
                    └─(optionally)─> brainstorm (새 Sprint 신기능 시, §2.12.3)

status/escalate: 어느 phase에서도 호출 가능
division: 사용자 호출 시에만 activation_state 조회/변경
release readiness: command 미확정, G4 이후 production 전 checklist 로 운영
```

## 3. Command Spec 표준 스키마 (schema/command-spec-v1)

각 `<subcommand>.md` 파일은 다음 필드 구성:

```yaml
---
command_id: "sfs-<subcommand>"
command_name: "/sfs <subcommand>"
version: "1.0.0"               # semver
phase: "plan"                  # setup | p-1 | g0 | plan | design | do | check | act | retro | any
mode: "common"                 # common | greenfield | brownfield
operator: "strategy-pm/lead"   # 오퍼레이터 role
triggers:                      # 자연어 trigger 키워드
  - "plan"
  - "계획"
requires_gate_before:           # 이 command 호출 전 PASS되어야 할 gate
  - "G-1"                      # (brownfield-only 경우)
produces:                       # 산출물 (L2 SSoT 경로)
  - "docs/01-plan/PDCA-{id}.plan.md"
calls_evaluators:               # 내부적으로 호출하는 evaluator
  - "plan-validator"
model_allocation:
  default: "claude-sonnet-4-6"
  opus_allowed: false          # Opus 사용 허용 여부
cost_budget_usd: 0.50          # 1회 호출 최대 비용
timeout_ms: 120000
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id"]
---

# /sfs <subcommand>

## 의도 (Intent)
...

## 입력 (Input)
...

## 절차 (Procedure)
...

## 산출물 (Output)
...

## 오류 처리 (Error Handling)
...

## 예시 (Examples)
...

## 관련 docs
...
```

## 4. Model Allocation 요약 표

| Command | Default | Opus 허용 | 근거 |
|---------|---------|:---:|------|
| install | Haiku | ❌ | 설정 파일 쓰기 |
| discover | Sonnet + Haiku | ❌ | 원칙 11 비용 cap |
| brainstorm | Opus | ✅ | CEO 전략 판단 |
| plan | Sonnet + Opus (plan-validator만) | ✅ | G1에서 Opus |
| design | Sonnet | ⚠️ lead만 | worker=Sonnet, lead=Opus |
| do | Sonnet + Haiku | ❌ | worker tier |
| handoff | Sonnet | ❌ | G3 binary |
| check | Sonnet + Opus (CPO 5-axis) | ✅ | G4에서 Opus |
| act | Sonnet | ❌ | 학습 기록만 |
| retro | Opus | ✅ | sprint-retro-analyzer |
| status | Haiku | ❌ | 조회만 |
| escalate | Sonnet + Opus | ✅ | §6 5-option |
| division | Haiku + Sonnet | ⚠️ dialog only | 원칙 13 user-only activation |

## 5. Phase 1 구현 우선순위

**P0 (must-ship)**:
- `install`, `discover`, `plan`, `design`, `do`, `check`, `act`, `status`

**P1 (should-ship)**:
- `brainstorm`, `handoff`, `retro`, `division`

**P2 (nice-to-have)**:
- `escalate` (Phase 1에서는 수동 §6 참조로 우회)
- Release Readiness command surface (`/sfs check --release-readiness` vs `/sfs release`) — §5.12 open decision

## 6. 다음 읽을 문서

- `appendix/commands/install.md` — Solon 설치
- `appendix/commands/discover.md` — 🆕 brownfield 전용 Discovery
- `appendix/commands/plan.md` ~ `retro.md` — 나머지 PDCA spec
- `appendix/commands/division.md` — 본부 activation_state 조회/변경

---

*(끝)*
