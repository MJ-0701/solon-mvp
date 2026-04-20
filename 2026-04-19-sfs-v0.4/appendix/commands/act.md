---
command_id: "sfs-act"
command_name: "/sfs act"
version: "1.0.0"
phase: "act"
mode: "common"
operator: "strategy/pm/lead"
triggers:
  - "act"
  - "learnings"
  - "학습 기록"
  - "finalize"
  - "close pdca"
  - "마무리"
requires_gate_before:
  - "G4"
produces:
  - "docs/09-learnings/PDCA-{id}.learnings.md"
  - "docs/01-plan/PDCA-{id}.act-decisions.yaml"
calls_evaluators: []       # Act는 평가 없음, 학습 기록만
model_allocation:
  default: "claude-sonnet-4-6"
  opus_allowed: false
cost_budget_usd: 0.30
timeout_ms: 180000
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep"]
  forbidden: ["Bash(destructive)"]
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "learning_count"]
references:
  - "04-pdca-redef.md §4.4.5 Act phase"
  - "06-escalate-plan.md §6.7 H6 Self-Learning"
  - "10-phase1-implementation.md §10.8 Seed Patterns"
---

# /sfs act

## 의도 (Intent)

PDCA 의 **Act 단계** 를 실행한다. G4 PASS 이후, 해당 PDCA에서 얻은 **학습 (learnings)** 을 정리하고 H6 Self-Learning 루프에 적재한다. Act 단계는 다음 PDCA (또는 다음 Sprint) 의 개선 입력이 된다.

본 command는 **strategy/pm/lead** 가 오퍼레이터. PM 본부장은 각 본부의 work-log / check-report / gate report를 통합해 **learnings-v1.md 형식** 으로 요약한다. 개별 본부의 깊은 학습은 본부별 PDCA directory에 남고, cross-division 학습만 H6 DB에 누적.

Act는 다음 PDCA의 Plan 단계에서 자동 참조됨 (§6.7.2 H6 Loop).

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자

### 선택
- `--link-to <pdca-id>`: 다음 PDCA와 연결 (H6 loop)
- `--pattern-detect`: seed pattern 중 매칭되는 것 자동 감지 (기본 on)
- `--promote-to-seed`: 본 learning을 신규 seed pattern으로 승격 제안 (검토 후 merge)

## 절차 (Procedure)

1. **G4 PASS 확인** (Haiku, <3s)
   - `docs/04-qa/PDCA-{id}.gate-g4.yaml` result=pass + human_approved=true 확인
2. **PDCA 산출물 집계** (Sonnet)
   - `docs/01-plan/PDCA-{id}.plan.md`
   - `docs/02-design/PDCA-{id}.*.design.md` (본부별)
   - `docs/03-implementation/PDCA-{id}.*.work-log.md`
   - `docs/04-qa/PDCA-{id}.check-report.md` + gate-g4.yaml + 5-axis.yaml
   - escalation 있었으면 `docs/05-escalation/PDCA-{id}.escalate.md`
3. **Learnings 추출** (Sonnet)
   - "What worked" / "What didn't" / "What surprised us" 구조
   - Cross-division insights (예: "design spec 변경이 dev work-log에 영향")
   - 7 Failure Mode 발생 빈도 & 해결 시간
4. **Seed Pattern Matching** (`--pattern-detect`)
   - `.solon/memory/h6-seed-patterns.yaml` 의 5 seed와 매칭
   - 매칭 시 seed의 occurrence_count++ 기록
   - 매칭 안 되는 새 패턴 발견 시 `--promote-to-seed` 제안
5. **의사결정 기록**
   - `docs/01-plan/PDCA-{id}.act-decisions.yaml` 에 follow-up action item 기록
   - 각 item: id, description, owner_division, target_sprint
6. **H6 DB 적재**
   - `.solon/memory/h6-live-patterns.yaml` 에 patterns 추가
   - next PDCA의 Plan phase에서 plan-validator 입력으로 사용
7. **L1 이벤트 발행**
   - `l1.act.complete` (learning_count, seed_matches, promoted_patterns)

## 산출물 (Output)

- `docs/09-learnings/PDCA-{id}.learnings.md` — 학습 내용 본문
  - 필수 섹션: Summary / What Worked / What Didn't / Cross-Division / Patterns (seed match 포함) / Follow-Up Actions
- `docs/01-plan/PDCA-{id}.act-decisions.yaml` — follow-up action item YAML

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_G4_NOT_PASSED` | G4 미통과 또는 human_approved=false | `/sfs check` 재확인 |
| `E_NO_ARTIFACTS` | PDCA 산출물 누락 | 본부별 파일 존재 확인 후 재시도 |
| `E_H6_DB_CORRUPTED` | h6-live-patterns.yaml schema 위반 | 수동 복구 후 retry |
| `E_SEED_PROMOTE_CONFLICT` | 제안된 신규 seed가 기존 seed와 의미 중복 | 수동 merge 검토 |

## 예시 (Examples)

### 예시 1: 정상 Act

```bash
$ /sfs act --feature new-pricing
[act] G4 PASS + human_approved 확인 ✓
[act] PDCA 산출물 집계 중...
[act] Learnings 추출 (Sonnet)... 8개 insight 추출
[act] Seed Pattern Matching:
   - seed-001 (AC ambiguity): 0 매치
   - seed-003 (design-dev handoff gap): 1 매치! (work-log 라인 42)
[act] H6 DB 적재 ✓
[act] Follow-up: 2개 액션 (next sprint target)
[act] 완료. 다음: 다음 PDCA는 /sfs plan --feature ...
```

### 예시 2: 신규 seed 승격 제안

```bash
$ /sfs act --feature notifications --promote-to-seed
...
[act] 신규 패턴 감지: "푸시 토큰 갱신 실패 시 silent fail"
[act] 기존 seed와 의미 중복 없음
[act] 제안: seed-006-push-token-silent-fail 로 승격?
> [y/n]: y
[act] `.solon/memory/h6-seed-patterns.yaml` 에 seed-006 추가 ✓
```

## 관련 docs

- `04-pdca-redef.md §4.4.5` — Act phase 정의
- `06-escalate-plan.md §6.7` — H6 Self-Learning loop
- `10-phase1-implementation.md §10.8` — Seed Patterns 5개
- `appendix/templates/analysis.md` — 분석 템플릿
- `appendix/commands/plan.md` — 다음 PDCA 시작
- `appendix/commands/retro.md` — Sprint 종료 시 G5
