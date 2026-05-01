---
phase: plan
gate_id: G1
sprint_id: "sfs-doc-tidy-release-notes"
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: 2026-05-01T18:28:09+09:00
---

# Plan — SFS doc tidy command + update awareness + release notes policy

> Sprint **G1 — Plan Gate** 산출물. 본 문서의 목적은 **요구사항·AC 의 측정 가능성 확보**.
> 변경 이력은 `.sfs-local/events.jsonl` 의 `phase_change` / `gate_review` event 로 추적.
> SSoT: `05-gate-framework.md §5.1` (Gate 매트릭스).
> 입력 기준: 같은 sprint 의 `brainstorm.md` (G0) 를 먼저 읽고 작성한다.
> 생명주기: 본 문서는 진행 중 sprint contract 이다. Close 후 최종 scope/AC/결과만
> `report.md` 에 남고, 본 파일은 compact stub 로 줄어든다.

---

## §1. 요구사항 (Requirements)

SFS 문서 생명주기 하네스를 실제 명령과 릴리즈 운영 규칙으로 만든다.
작업 중 문서는 노트패드처럼 쌓여도 되지만, 완료 후에는 보고서 중심으로 압축되어야 한다.

- [x] R1: 기존 SFS workbench 문서를 삭제 없이 정리하는 명령이 필요하다.
- [x] R2: 완료된 sprint 는 `report.md` 중심으로 읽히고, brainstorm/plan/implement/log/review 는 핵심 안내 stub 로 줄어야 한다.
- [x] R3: 사용자가 새 버전 존재 여부를 확인하는 공식 경로가 문서와 CLI 에 명확해야 한다.
- [x] R4: 버전업 때 Added/Changed/Fixed 같은 release note 가 누락되지 않도록 릴리즈 규칙이 필요하다.
- [x] R5: SFS 약자 정의는 Solo Founder System 으로 고정하고, Sprint Flow 는 내부 workflow 로 설명한다.

## §2. Acceptance Criteria (AC, 측정 가능)

각 요구사항에 대해 **측정 가능한 통과 조건** 정의. "되면 안 되는 것" (anti-AC) 도 명시.

- [ ] AC1: `sfs tidy` 는 기본 실행 시 dry-run 으로 동작하고 파일을 수정하지 않는다 — verify by `git diff --exit-code` after dry-run.
- [ ] AC2: `sfs tidy --apply` 는 대상 sprint 의 원문 workbench 문서를 삭제하지 않고 archive/snapshot 위치에 보존한다 — verify by archived files exist and original content is recoverable.
- [ ] AC3: `sfs tidy --apply` 는 `brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md` 를 `report.md` 중심 redirect stub 로 압축한다 — verify by stub text links to `report.md` and archive path.
- [ ] AC4: `sfs tidy` 는 `--sprint <id>` 와 현재 sprint 기본값을 지원하고, 완료/미완료 sprint 에 대한 안전 메시지를 낸다 — verify by smoke on active and named sprint.
- [ ] AC5: README/GUIDE/skill/command docs 에 `sfs upgrade`, `sfs version --check`, SFS = Solo Founder System, release note 확인 경로가 명시된다 — verify by `rg`.
- [ ] AC6: `scripts/cut-release.sh` 는 대상 버전의 CHANGELOG 또는 release note entry 가 없을 때 preflight 에서 실패한다 — verify by sandbox release dry-run with missing entry.
- [ ] AC7: CHANGELOG 규칙은 최소 `Added`, `Changed`, `Fixed` 를 포함하고, 필요 시 `Deprecated`, `Removed`, `Security` 를 허용한다 — verify by documented template and release script pattern.
- [ ] Anti-AC: 어떤 경로에서도 사용자 동의 없는 삭제, `rm` 기반 청소, report 없이 workbench 압축을 하지 않는다.

## §3. 범위 (Scope)

- **In scope**:
  - `sfs tidy` CLI dispatch + bash adapter.
  - 기존 compact/report helper 재사용 또는 최소 보강.
  - archive-first 보존 정책과 redirect stub 포맷.
  - README/GUIDE/SFS template/skill/agent command docs 갱신.
  - CHANGELOG release note policy 와 cut-release preflight.
  - sandbox smoke: dry-run 무변경, apply 보존/압축, release note missing fail.
- **Out of scope**:
  - 과거 전체 sprint 문서의 실제 일괄 정리 적용.
  - GUI, web dashboard, search index, archive restore UI.
  - 백그라운드 auto-update notifier.
  - 사용자 동의 없는 자동 compact.
- **Dependencies**:
  - 기존 `report --compact` / `retro --close` compact helper 확인.
  - 0.5.45 에 추가된 `sfs version --check`, `sfs upgrade`, Homebrew/Scoop upgrade 흐름.
  - release cut 은 dev-first/stable sync-back 규칙을 유지한다.

## §4. G1 Gate 자기 점검

- [x] R/AC 가 측정 가능 (정량 또는 binary)
- [x] 범위가 sprint 1개 안에서 닫힘
- [x] 의존성 / 결정 대기 항목이 명시됨

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. verdict (pass / partial / fail) 는 `review.md` 에 기록.

## §5. Sprint Contract (Generator ↔ Evaluator)

`brainstorm.md` 의 G0 맥락을 기반으로 이번 sprint 의 실행 계약을 명시한다.
역할 흐름은 **CEO → CTO Generator ↔ CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro** 이다.

- **CEO 요구사항/plan 결정**:
  - 문제 정의: SFS 는 작업 중 사고 기록을 허용하지만, 완료 후에도 그 기록이 최종 산출물처럼 남아 문서 부피가 커진다.
  - 최종 목표: 삭제 없는 `sfs tidy` 와 release note/update awareness 규칙으로 문서 생명주기 하네스를 실행 가능하게 만든다.
  - 이번 sprint 에서 버릴 것: 대규모 과거 문서 수동 정리, 자동 삭제, background notifier, GUI.
- **CTO Generator 가 만들 것**:
  - persona: `.sfs-local/personas/cto-generator.md`
  - reasoning_tier: `strategic_high` for architecture/contract; worker 실행은 `execution_standard`
  - model profile source: `.sfs-local/model-profiles.yaml`
  - selected runtime / policy: Codex local implementation, bash adapter SSoT.
  - fallback when unset: current runtime model
  - preferred executor: codex first; release smoke 는 local shell.
  - implementation worker persona: `.sfs-local/personas/implementation-worker.md`
  - 산출물: `sfs tidy` adapter, CLI dispatch/docs, release note policy, cut-release preflight, smoke evidence.
  - 변경 파일/모듈: `solon-mvp-dist/bin/sfs`, `.sfs-local-template/scripts/*`, docs/templates/skills, `scripts/cut-release.sh`, `CHANGELOG.md`.
  - 구현하지 않을 것: 실제 사용자의 오래된 sprint 산출물 일괄 compact 적용.
- **CPO Evaluator 가 검증할 것**:
  - persona: `.sfs-local/personas/cpo-evaluator.md`
  - reasoning_tier: `review_high`
  - preferred executor: codex/gemini external review where available; local smoke evidence required.
  - self-validation 방지: 구현한 agent/tool 과 다른 evaluator instance/tool 사용 권장
  - AC 검증 방법: dry-run diff 없음, apply archive/stub 생성, docs `rg`, release preflight fail/pass, version docs 확인.
  - 회귀/위험 체크: `report --compact` / `retro --close` 기존 동작, `sfs upgrade/update/version` dispatch, Homebrew/Scoop package smoke.
  - 통과/부분통과/실패 기준: AC1~AC7 모두 통과 시 pass; docs 만 남으면 partial; 원문 삭제 가능성 또는 release cut 회귀 시 fail.
- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입
  - CPO `partial`: 지정된 항목만 CTO 재구현 후 재리뷰
  - CPO `fail`: plan/scope 재검토 또는 구현 재작업
- **사용자 최종 결정이 필요한 지점**:
  - 명령 이름을 `sfs tidy` 로 확정한다. 현재 plan 은 `tidy` 를 기본안으로 잡되, 구현 중 충돌이 발견되면 사용자에게 재확인한다.
