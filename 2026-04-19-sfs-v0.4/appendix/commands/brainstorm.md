---
command_id: "sfs-brainstorm"
command_name: "/sfs brainstorm"
version: "1.0.0"
phase: "g0"
mode: "common"
operator: "strategy/ceo"
triggers:
  - "brainstorm"
  - "브레인스토밍"
  - "새 아이디어"
  - "new initiative"
  - "G0"
  - "ideation"
requires_gate_before: []     # G0 자체가 Initiative 첫 Gate
produces:
  - "docs/00-governance/Initiative-{id}/brainstorm-report.md"
  - "docs/00-governance/Initiative-{id}/gate-g0.yaml"
calls_evaluators:
  - "prd-lock"               # brainstorm 결론의 잠금
model_allocation:
  default: "claude-opus-4-6"   # CEO 전략 판단은 Opus 필수
  opus_allowed: true
cost_budget_usd: 1.50
timeout_ms: 600000
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Task", "WebSearch"]
  forbidden: []
audit_fields: ["called_by", "called_at", "initiative_id", "mode_at_install"]
references:
  - "04-pdca-redef.md §4.2 G0 Brainstorm Gate"
  - "02-design-principles.md §2.9 brainstorm-before-plan"
  - "02-design-principles.md §2.12 brownfield-no-retro-brainstorm"
  - "05-gate-framework.md §5.11.6 G-1 vs G0 관계"
---

# /sfs brainstorm

## 의도 (Intent)

Initiative (큰 기능 뭉치) 진입 전의 **Brainstorm Gate (G0)** 를 실행한다. CEO (사용자 자기 자신) 가 새 Initiative의 방향을 탐색하고, 대안을 비교하며, 선택 근거를 기록한다.

본 command는 **greenfield 모드에서 Initiative 당 1회** 호출된다. brownfield에서는 원칙 12 (`brownfield-no-retro-brainstorm`) 에 의해 **기존 제품 방향을 재brainstorm하지 않음**. 단, brownfield 환경에서도 **"새 Sprint에 신기능 추가"** 또는 **"pivot (전면 재설계)"** 상황에서는 G0 재호출 허용.

## G-1 vs G0 관계 (§5.11.6 요약)

| 상황 | G-1 | G0 |
|------|-----|-----|
| 최초 greenfield install | — | ✓ |
| 최초 brownfield install | ✓ | — (원칙 12) |
| brownfield에서 신기능 Sprint | — | ✓ |
| 전면 pivot | — | ✓ |
| 리팩토링 Sprint | — | — |

## 입력 (Input)

### 필수
- `--initiative <id>`: 새 Initiative 식별자

### 선택
- `--pivot`: 기존 제품을 전면 재설계한다는 의사 표시 (brownfield 환경에서 G0 허용 조건)
- `--new-feature-from-brownfield`: brownfield 설치 후 새 기능 추가 의사 표시 (G0 허용)
- `--from-inspiration <path>`: 참조 문서 (user research / competitor analysis)
- `--timebox-min <n>`: brainstorm 최대 시간 (기본 30분)

## 절차 (Procedure)

1. **모드 검증** (Haiku, <3s)
   - `.solon/config.yaml` 에서 install mode 확인
   - brownfield 모드인데 `--pivot` / `--new-feature-from-brownfield` 둘 다 없으면 FAIL-HARD (원칙 12 위반)
2. **Context 수집**
   - 현재 `divisions.yaml`, 최신 `learnings-v1.md`, 기존 Initiative 리스트
   - `--from-inspiration` 있으면 로드
3. **Divergent thinking** (Opus, CEO role)
   - 최소 3개 대안 생성 (Option A/B/C)
   - 각 대안의 User-Outcome / Value-Fit / Soundness / Future-Proof 예비 점수
4. **Convergent thinking** (Opus, CEO role)
   - 대안 비교 표 작성
   - 1 안 선정 + 선정 근거 기록
   - 나머지 안은 "Parked alternatives" 로 brainstorm-report에 보존
5. **YAGNI 리뷰**
   - 선정 안에서 "지금 당장 필요한 최소" 와 "미래에 고려할 것" 분리
6. **G0 Gate 실행**
   - brainstorm-report.md 완결성 체크
   - 3+ 대안 + 비교표 + 선정 근거 모두 존재 시 PASS
7. **Initiative 등록**
   - `docs/00-governance/Initiative-{id}/` 디렉토리 생성
   - brainstorm-report.md + gate-g0.yaml 저장
8. **L1 이벤트 발행**
   - `l1.gate.g0.complete` (alternatives_count, selected, pivot_flag)

## 산출물 (Output)

- `docs/00-governance/Initiative-{id}/brainstorm-report.md` — brainstorm 본문
  - 필수 섹션: Problem Space / Alternatives (≥3) / Comparison / Selected + Rationale / Parked / YAGNI
- `docs/00-governance/Initiative-{id}/gate-g0.yaml` — G0 gate report

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_BROWNFIELD_WITHOUT_JUSTIFICATION` | brownfield 모드인데 --pivot/--new-feature-from-brownfield 없음 | FAIL-HARD, 원칙 12 레퍼런스 |
| `E_INSUFFICIENT_ALTERNATIVES` | Options < 3 | FAIL-FIXABLE |
| `E_NO_RATIONALE` | 선정 근거 미기록 | FAIL-FIXABLE |
| `E_INITIATIVE_ID_COLLISION` | 동일 id Initiative 존재 | `--force` 또는 다른 id 요구 |

## 예시 (Examples)

### 예시 1: Greenfield Initiative 시작

```bash
$ /sfs brainstorm --initiative pricing-v2
[brainstorm] greenfield 모드 확인 ✓
[brainstorm] Context 수집...
[brainstorm] 3 대안 생성 (Opus)...
   A) Flat monthly tiers   B) Usage-based   C) Hybrid
[brainstorm] 비교표 작성 ✓
[brainstorm] Selected: C (Hybrid), 근거: ...
[brainstorm] YAGNI 리뷰 ✓
[brainstorm] G0 PASS
[brainstorm] Initiative-pricing-v2 등록 ✓
```

### 예시 2: Brownfield에서 원칙 12 위반 시도

```bash
$ /sfs brainstorm --initiative redesign-everything
[brainstorm] brownfield 모드 감지
[brainstorm] --pivot / --new-feature-from-brownfield flag 없음
[brainstorm] FAIL-HARD: 원칙 12 위반. 기존 제품 방향을 재brainstorm하지 않음.
[brainstorm] 해결책:
   - 새 기능 추가라면: --new-feature-from-brownfield
   - 전면 재설계라면: --pivot (팀 결정 필요)
   - 단순 개선이라면: /sfs plan 로 바로 진행
```

### 예시 3: Brownfield 신기능

```bash
$ /sfs brainstorm --initiative add-ai-search --new-feature-from-brownfield
[brainstorm] brownfield + new-feature flag ✓
[brainstorm] 기존 제품 방향 유지 전제로 진행
...
[brainstorm] G0 PASS
```

## 관련 docs

- `04-pdca-redef.md §4.2` — G0 Brainstorm Gate 정의
- `02-design-principles.md §2.9` — 원칙 9 brainstorm-before-plan
- `02-design-principles.md §2.12` — 원칙 12 brownfield-no-retro-brainstorm
- `05-gate-framework.md §5.11.6` — G-1 vs G0 관계 테이블
- `appendix/templates/brainstorm.md` — Brainstorm 템플릿
- `appendix/commands/plan.md` — 다음 단계 (PDCA Plan)
