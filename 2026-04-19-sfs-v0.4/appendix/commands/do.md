---
command_id: "sfs-do"
command_name: "/sfs do"
version: "1.0.0"
phase: "do"
mode: "common"
operator: "division-worker"    # Sonnet tier worker agents
triggers:
  - "do"
  - "implement"
  - "구현"
  - "개발 시작"
  - "build"
  - "code"
requires_gate_before:
  - "G2"
produces:
  - "docs/03-implementation/PDCA-{id}.{division}.work-log.md"
  - "src/** (actual code)"
  - "tests/** (optional)"
  - "docs/03-implementation/PDCA-{id}.dod.yaml"
calls_evaluators: []   # Do phase 자체는 evaluator 없음 (G3 handoff에서 호출)
model_allocation:
  worker_default: "claude-sonnet-4-6"
  helper: "claude-haiku-4-5-20251001"   # 로그 정리, 파일 이동 등
  opus_allowed: false                    # worker tier는 Opus 금지
cost_budget_usd: 2.00                    # 실제 구현은 비용 변동성 큼
timeout_ms: 1800000                       # 30분 (긴 구현 허용)
tool_restrictions:
  allowed: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Task", "NotebookEdit"]
  forbidden: []
audit_fields: ["called_by", "called_at", "pdca_id", "sprint_id", "division", "commit_sha"]
references:
  - "04-pdca-redef.md §4.4.3 Do phase"
  - "05-gate-framework.md §5.5 G3 Pre-Handoff Gate"
  - "02-design-principles.md §2.3 Evidence-first"
  - "10-phase1-implementation.md §10.3 재활용 항목"
---

# /sfs do

## 의도 (Intent)

PDCA 의 **Do 단계** 를 실행한다. G2를 통과한 Design 산출물을 입력으로 받아, **해당 본부의 worker** 가 실제 구현 작업을 수행한다. Do 단계는 **코드/테스트/문서** 등 실물 산출물을 생성하는 단계이며, 이후 G3 Pre-Handoff Gate 에서 품질 검증을 받는다.

본 command는 각 본부 worker (Sonnet tier) 가 실행한다. 본부장(Lead)은 Do 단계에 직접 개입하지 않고 **호출 전 위임 / 호출 후 G3 래퍼** 역할만 수행 (§2 원칙 3 본부장=Gate Operator + 원칙 2 자기검증 금지의 일환).

## 입력 (Input)

### 필수
- `--feature <id>`: PDCA 식별자
- `--division <name>`: 실행 본부

### 선택
- `--resume`: 이전 `/sfs do` 중단 지점에서 재개 (`.solon/do-state.yaml` 참조)
- `--checkpoint-every <n>`: N개 파일 수정마다 commit 자동 생성 (기본값: 10)
- `--dod-check`: 구현 종료 시 Definition-of-Done 자동 체크 (기본 on)

## 절차 (Procedure)

1. **G2 PASS 확인** (Haiku, <3s)
   - `docs/02-design/PDCA-{id}.{division}.gate-g2.yaml` 에서 result=pass 확인
   - 본부별로 참조할 design 산출물 존재 확인
2. **Do-state 초기화** (Haiku)
   - `.solon/do-state.yaml` 에 PDCA id, division, start_at, checkpoints 배열 초기화
   - 이미 존재 시 `--resume` flag 요구
3. **Worker 구현 실행** (Sonnet)
   - Design spec + AC를 입력으로 코드 작성
   - bkit 재활용: dev 본부는 bkit의 `code-analyzer` / `gap-detector` 참조 가능 (G3에서 호출됨)
   - 테스트 코드 작성 (qa 본부 산출물 참조)
   - 주기적 checkpoint commit (`--checkpoint-every`)
4. **Work log 기록**
   - `docs/03-implementation/PDCA-{id}.{division}.work-log.md` 에 각 커밋 시점의 변경 요약, 의사결정, 블록된 지점 기록
   - L2 git-submodule 자동 동기화 (post-commit hook)
5. **DoD 자동 체크** (`--dod-check`)
   - `docs/03-implementation/PDCA-{id}.dod.yaml` 에 항목별 check (코드 작성 / 테스트 통과 / 문서 업데이트 / lint pass 등)
   - 일부 미충족 시 사용자에게 경고 (block하지 않음 — G3에서 재검증)
6. **L1 이벤트 발행**
   - `l1.do.progress` (각 checkpoint 마다)
   - `l1.do.complete` (최종, commit_sha 기록)

## 산출물 (Output)

- `docs/03-implementation/PDCA-{id}.{division}.work-log.md` — 구현 로그
- `docs/03-implementation/PDCA-{id}.dod.yaml` — Definition-of-Done 체크리스트
- `src/**` — 실제 코드 변경사항 (git commit 이력에서 추적)
- `tests/**` — 테스트 코드 (선택)
- `.solon/do-state.yaml` — Do 상태 (resume용)

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
|-------|------|------|
| `E_G2_NOT_PASSED` | G2 Design Gate 미통과 | `/sfs design --feature ... --division ...` 선행 |
| `E_DO_ALREADY_IN_PROGRESS` | 동일 PDCA do-state 존재 | `--resume` flag 필수 |
| `E_CHECKPOINT_COMMIT_FAILED` | git commit hook 실패 | pre-commit hook 수동 확인, retry |
| `E_DOD_INCOMPLETE` | DoD 필수 항목 미체크 | 경고만, G3에서 재검증 |
| `E_TIMEOUT` | 30분 초과 | checkpoint까지 save 후 TIMEOUT, `--resume`으로 재개 |

## 예시 (Examples)

### 예시 1: Dev 본부 구현 실행

```bash
$ /sfs do --feature new-pricing --division dev
[do] G2 PASS 확인 ✓
[do] do-state 초기화 ✓
[do] Design spec 로드: docs/02-design/PDCA-new-pricing.design.design.md
[do] 구현 시작 (Sonnet worker)...
[do] checkpoint 1/? — commit a1b2c3d (5 files changed)
[do] checkpoint 2/? — commit d4e5f6g (3 files changed)
[do] DoD 체크 ✓ (8/8 항목)
[do] 완료. 다음: /sfs handoff --feature new-pricing --division dev
```

### 예시 2: 재개 (resume)

```bash
$ /sfs do --feature new-pricing --division dev --resume
[do] 이전 do-state 발견 (checkpoint 2/?, 2026-04-20T14:23:11Z)
[do] 재개 중...
[do] checkpoint 3/? — commit h7i8j9k
```

### 예시 3: QA 본부 테스트 구현

```bash
$ /sfs do --feature new-pricing --division qa
[do] G2 PASS 확인 ✓ (qa test-strategy spec)
[do] 테스트 코드 작성 중...
[do] checkpoint 1 — pytest 27 tests added
[do] DoD: 커버리지 82% (target 80%)
[do] 완료.
```

## 관련 docs

- `04-pdca-redef.md §4.4.3` — Do phase 정의
- `05-gate-framework.md §5.5` — G3 Pre-Handoff Gate (다음 단계 검증)
- `10-phase1-implementation.md §10.3.2` — bkit 재활용 (code-analyzer, gap-detector)
- `appendix/commands/handoff.md` — Do 종료 후 G3 호출
- `appendix/commands/check.md` — G4 Check phase
