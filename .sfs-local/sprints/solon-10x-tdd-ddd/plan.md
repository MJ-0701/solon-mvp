---
phase: plan
gate_id: G1
sprint_id: "solon-10x-tdd-ddd"
goal: "Solon 10x value planning: non-developer productivity + TDD/DDD AI coding workflow"
created_at: "2026-04-30T23:07:33+09:00"
last_touched_at: 2026-04-30T23:08:47+09:00
---

# Plan — Solon 10x Value + TDD/DDD Coding Workflow

> Sprint **G1 — Plan Gate** 산출물. 본 문서의 목적은 **요구사항·AC 의 측정 가능성 확보**.
> 변경 이력은 `.sfs-local/events.jsonl` 의 `phase_change` / `gate_review` event 로 추적.
> SSoT: `05-gate-framework.md §5.1` (Gate 매트릭스).
> 입력 기준: 같은 sprint 의 `brainstorm.md` (G0) 를 먼저 읽고 작성한다.

---

## §1. 요구사항 (Requirements)

본 sprint 가 풀어야 할 문제 / 사용자 니즈 / 비즈니스 입력. 1줄 요약 + 배경 컨텍스트.

- [x] R1: Solon 의 10x 가치를 "더 많은 AI code generation" 이 아니라 "AI-ready work/code operating system" 으로 설명한다.
- [x] R2: 비개발자 productivity loop 를 정의한다: fuzzy idea -> shared design concept -> domain language -> acceptance criteria -> work units.
- [x] R3: 개발자 coding loop 를 정의한다: codebase analysis -> DDD-lite glossary -> TDD contract -> small implementation slice -> review gate.
- [x] R4: 영상 요약의 4 failure pattern 을 Solon product promise 로 흡수한다.
- [x] R5: 이번 sprint 안에서 최소 1개 product-facing artifact 를 구현한다.
- [x] R6: onboarding guide 와 설치 후 SFS 운영 지침에도 AI-safe DDD/TDD coding contract 를 반영한다.

## §2. Acceptance Criteria (AC, 측정 가능)

각 요구사항에 대해 **측정 가능한 통과 조건** 정의. "되면 안 되는 것" (anti-AC) 도 명시.

- [x] AC1: 10x value 를 한 문장, 한 paragraph, 실행 루프로 각각 표현한다 — verify by `10X-VALUE.md` sections.
- [x] AC2: 비개발자와 개발자 workflow 가 별도 section 으로 구분된다 — verify by headings.
- [x] AC3: DDD/TDD 가 optional best practice 가 아니라 AI entropy 방지 장치로 설명된다 — verify by "Why DDD/TDD are defaults" section.
- [x] AC4: Spec-to-code entropy, missing design concept, missing domain language, weak feedback loop, irregular codebase failure 가 모두 언급된다 — verify by checklist.
- [x] AC5: 각 구현 slice 는 1~2 product files 로 닫힌다 — verify by changed files per log entry.
- [x] AC6: GUIDE/SFS template 에 AI-safe first slice, DDD-lite, TDD-lite, review criteria 가 들어간다 — verify by keyword checklist.

Anti-AC:
- [x] AA1: `/sfs code` 신규 명령 전체 구현은 이번 sprint 에 넣지 않는다.
- [x] AA2: Soongsil consumer plan/review 작업은 건드리지 않는다.
- [x] AA3: TDD/DDD 를 긴 교재처럼 설명하지 않는다. 제품 약속과 workflow 중심으로 쓴다.

## §3. 범위 (Scope)

- **In scope**:
  - `solon-mvp-dist/10X-VALUE.md` 신설.
  - `solon-mvp-dist/README.md` 에 10x value 문서 링크와 핵심 문장 추가.
  - `solon-mvp-dist/GUIDE.md` 에 첫 sprint AI-safe 구현 흐름 추가.
  - `solon-mvp-dist/templates/SFS.md.template` 에 설치 후 기본 AI coding contract 추가.
  - Sprint G0/G1 산출물 정리.
- **Out of scope**:
  - `/sfs code` / `/sfs implement` 신규 command.
  - Codebase scanner 자동화.
  - TDD test generator 구현.
  - Soongsil consumer 작업.
  - release cut / stable sync.
- **Dependencies**:
  - 영상 원본 transcript 는 직접 접근 불가. 사용자가 제공한 요약을 raw evidence 로 사용한다.
  - 다음 sprint 에서 product template (`SFS.md.template`, `GUIDE.md`) 반영 여부 결정 가능.

## §4. G1 Gate 자기 점검

- [x] R/AC 가 측정 가능 (정량 또는 binary)
- [x] 범위가 sprint 1개 안에서 닫힘
- [x] 의존성 / 결정 대기 항목이 명시됨

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. verdict (pass / partial / fail) 는 `review.md` 에 기록.

## §5. Sprint Contract (Generator ↔ Evaluator)

`brainstorm.md` 의 G0 맥락을 기반으로 이번 sprint 의 실행 계약을 명시한다.
역할 흐름은 **CEO → CTO Generator ↔ CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro** 이다.

- **CEO 요구사항/plan 결정**:
  - 문제 정의: AI coding 은 좋은 codebase 에서만 생산성을 높이고, 나쁜 codebase 에서는 entropy 를 가속한다. Solon 은 이 위험을 제품 가치로 직접 다뤄야 한다.
  - 최종 목표: 비개발자와 개발자가 모두 이해할 수 있는 "Solon 10x value" product artifact 를 만들고 README 에 연결한다.
  - 이번 sprint 에서 버릴 것: command 구현, scanner 자동화, release cut, Soongsil 작업.
- **CTO Generator 가 만들 것**:
  - persona: `.sfs-local/personas/cto-generator.md`
  - preferred executor: codex
  - 산출물:
    - `10X-VALUE.md`: Solon 10x product value doc.
    - README link/copy patch.
    - GUIDE AI-safe first implementation section.
    - SFS template AI coding contract section.
  - 변경 파일/모듈:
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/10X-VALUE.md`
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/README.md`
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/GUIDE.md`
    - `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/SFS.md.template`
  - 구현하지 않을 것:
    - bash adapter 변경.
    - 설치 스크립트 변경.
    - version/changelog bump.
- **CPO Evaluator 가 검증할 것**:
  - persona: `.sfs-local/personas/cpo-evaluator.md`
  - preferred executor: claude or gemini in a later review; current runtime may do mechanical checks only.
  - self-validation 방지: 구현한 agent/tool 과 다른 evaluator instance/tool 사용 권장
  - AC 검증 방법: file existence, heading/content checklist, README link validation, `git diff --check`.
  - 회귀/위험 체크: README flow 가 너무 길어지지 않는지, product promise 가 `/sfs` current behavior 와 충돌하지 않는지, TDD/DDD 가 과장되지 않는지.
  - 통과/부분통과/실패 기준:
    - pass: AC1~AC6 전부 충족, README link 정상, 각 implementation slice 가 작게 닫힘.
    - partial: 가치 문서는 있으나 workflow/DDD/TDD 중 하나가 약함.
    - fail: marketing slogan 만 있고 Solon workflow 로 내려가지 않음.
- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입
  - CPO `partial`: 지정된 항목만 CTO 재구현 후 재리뷰
  - CPO `fail`: plan/scope 재검토 또는 구현 재작업
- **사용자 최종 결정이 필요한 지점**:
  - 다음 sprint 에서 이 내용을 `GUIDE.md` 와 `SFS.md.template` 까지 확장할지 여부.
  - `/sfs code` 신규 command 를 만들지, 기존 `/sfs plan`/`loop` 의 coding guidance 로 흡수할지 여부.

## §6. Phase 1 구현 Backlog Seed

1. `10X-VALUE.md` 신설 ✅
   - 한 문장 promise
   - failure patterns
   - non-developer 10x loop
   - TDD/DDD coding loop
   - "What Solon does not promise"
2. `README.md` 연결 ✅
   - Why Solon 근처에 10x value link 추가
   - How It Works 에 design concept/domain language/test contract 문장 추가
3. `GUIDE.md` AI-safe first slice section 추가 ✅
   - codebase rules -> DDD-lite -> TDD-lite -> small slice -> review
4. `templates/SFS.md.template` AI coding contract 추가 ✅
   - 설치 후 프로젝트 기본 운영 지침에 DDD/TDD safety rail 반영
5. 검증
   - `rg` checklist
   - `git diff --check`
   - changed files 확인
