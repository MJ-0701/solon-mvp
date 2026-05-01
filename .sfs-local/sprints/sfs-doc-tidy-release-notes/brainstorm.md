---
phase: brainstorm
gate_id: G0
sprint_id: "sfs-doc-tidy-release-notes"
goal: "SFS doc tidy command + update awareness + release notes policy"
created_at: "2026-05-01T18:27:08+09:00"
last_touched_at: 2026-05-01T18:27:19+09:00
status: ready-for-plan        # draft | ready-for-plan | g0-reviewed
---

# Brainstorm — SFS doc tidy command + update awareness + release notes policy

> Sprint **G0 — Brainstorm Gate** 산출물.
> 목적은 사용자의 raw 요구사항을 바로 plan 으로 굳히지 않고, 문제/대안/제약/범위를 먼저 정리하는 것.
> `/sfs start` 는 workspace 를 만들고, `/sfs brainstorm` 은 raw 를 §8 에 기록한 뒤
> AI runtime 에서 Solon CEO 가 §1~§7 을 채운다. direct bash 는 capture-only 다.
> 생명주기: 본 문서는 진행 중 workbench 이다. Sprint close 후 핵심 문제/성공상태만
> `report.md` 로 정리되고, 원문은 archive 로 이동해 보존된다. Raw history 는
> `retro.md` / session log 가 담당한다.

---

## §1. Raw Brief / Conversation Notes

기존 SFS 산출물이 작업 진행 중에는 노트패드/화이트보드처럼 쌓이는 것이 맞지만,
완료 후에도 `brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md` 가
그대로 최종 산출물처럼 남는 문제가 있다. 사용자는 삭제가 아니라 보존형 정리를 원한다.

이번 sprint 는 세 가지를 하나의 운영 규칙으로 묶는다.

1. 기존 SFS workbench 문서를 정리하는 새 명령을 만든다.
2. 사용자가 새 버전을 어떻게 알 수 있는지 명확히 한다.
3. 버전업 시 추가/변경/수정 사항을 release note 로 남기는 규칙을 세운다.

SFS 는 **Solo Founder System** 이다. Sprint Flow 는 SFS 내부 workflow 이며,
SFS 약자 정의를 Sprint Flow System 으로 바꾸지 않는다.

---

## §2. Problem Space

- 누가 이 문제를 겪는가: SFS 로 여러 sprint 를 돌리는 Solo Founder / AI coding runtime 사용자.
- 왜 지금 풀어야 하는가: 하네스 엔지니어링 철학이 이미 SSoT 에 반영됐고, 다음 릴리즈부터 실제 명령과 배포 규칙으로 고정해야 한다.
- 기존 방식의 불편함: 구현량보다 문서량이 더 커지고, 완료 후에도 사고 과정/시도/로그가 최종 문서처럼 남아 검색과 재진입 비용을 키운다.
- 성공하면 어떤 상태가 되는가: 완료된 sprint 는 `report.md` 중심으로 읽히고, workbench 원문은 삭제 없이 보존되며, 새 버전과 변경 내용은 사용자가 스스로 확인할 수 있다.

## §3. Constraints / Context

- 기술 제약: 현재 SFS runtime 은 bash adapter 중심이고, `report --compact` / `retro --close` 에 이미 compact 개념이 있다. 새 명령은 이 흐름을 재사용해야 한다.
- 배포/운영 제약: Homebrew/Scoop/source package 에 모두 같은 UX 가 반영되어야 한다. 기존 `sfs update` alias 와 `sfs upgrade` 주 명령도 유지해야 한다.
- 시간/비용 제약: 이번 sprint 는 작은 수술식 변경을 우선한다. 대규모 문서 DB/인덱서/웹 UI 는 제외한다.
- 사용자 역량/학습 맥락: 사용자는 “과정의 먼지”와 “최종 보고서”를 분리하는 하네스 철학을 SFS 전 과정에 적용하기로 결정했다.
- 아직 모르는 것: 명령 이름은 `sfs tidy` 가 가장 자연스럽지만, 기존 `report --compact` 와 역할 중복을 어떻게 설명할지 구현 전 확인이 필요하다.

## §4. Options

최소 2개 이상. "아무것도 안 한다" 도 유효한 옵션이다.

- **Option A: `sfs report --compact` 만 강화**
  - 장점: 기존 명령 재사용, UX 표면 증가 없음.
  - 단점: “기존 지저분한 문서 정리”라는 사용자의 명시적 니즈가 잘 드러나지 않는다. report 작성과 정리 실행의 책임이 섞인다.
  - 버릴/보류할 이유: 명령 discoverability 가 낮다.
- **Option B: 새 명령 `sfs tidy` 신설**
  - 장점: 정리 목적이 명확하다. default dry-run, `--apply`, `--sprint`, `--all` 같은 UX 를 줄 수 있다.
  - 단점: 새 명령이므로 docs/skill/installer/dispatch/release note 모두 갱신해야 한다.
  - 버릴/보류할 이유: 구현 범위가 커지면 `report --compact` helper 재사용으로 줄인다.
- **Option C: release/retro close 때만 정리**
  - 장점: 사용자 행동이 적고 lifecycle 이 자연스럽다.
  - 단점: 기존 산출물을 별도로 정리하기 어렵고, 자동 정리는 사용자 동의 원칙과 충돌할 수 있다.
  - 버릴/보류할 이유: 사용자 동의하의 명시 명령을 우선한다.

## §5. Scope Seed

- 이번 sprint 에 넣을 것:
  - `sfs tidy` 또는 동등한 새 명령 설계/구현.
  - 삭제 없는 보존 정책: dry-run 기본, `--apply` 시 원문 archive 후 visible sprint folder 에는 남겨야 할 문서만 유지.
  - 버전 인지 UX: `sfs version --check`, `sfs upgrade`, README/GUIDE/skill 안내 정리.
  - release note 규칙: CHANGELOG entry 구조와 릴리즈 컷 전 preflight.
- 이번 sprint 에서 뺄 것:
  - 과거 모든 docset 의 수동 대청소.
  - 웹 대시보드/GUI/검색 인덱스.
  - 사용자에게 묻지 않는 자동 삭제 또는 자동 정리.
- 다음 sprint 후보:
  - `sfs status` 에 update notice 를 선택적으로 붙이는 UX.
  - release note 를 GitHub Release body 로 자동 생성.
  - 오래된 archive 탐색/복원 명령.

## §6. Plan Seed

`/sfs plan` 으로 넘길 때 필요한 최소 재료.

- Goal: SFS 문서 생명주기 하네스를 실행 가능한 정리 명령과 릴리즈 운영 규칙으로 만든다.
- Acceptance Criteria 후보:
  - AC1: `sfs tidy` 는 기본 dry-run 이고, `--apply` 없이는 파일을 바꾸지 않는다.
  - AC2: `--apply` 는 원문 workbench/tmp 산출물을 삭제하지 않고 archive 위치에 보존한다.
  - AC3: 완료된 sprint 의 workbench/tmp 산출물은 archive 로 이동하고, visible sprint folder 에는 `report.md`/`retro.md` 같은 durable artifact 만 남는다.
  - AC4: README/GUIDE/skill 에 SFS = Solo Founder System, `sfs upgrade`, `sfs version --check`, release note 확인 방법이 명시된다.
  - AC5: release cut preflight 는 대상 버전의 CHANGELOG/release note entry 누락을 감지한다.
- 주요 risk: 기존 `report --compact` helper 와 중복 구현, archive 경로가 과하게 커지는 문제, release preflight 가 hotfix 흐름을 막는 문제.
- generator agent 가 만들 산출물: CLI dispatch, tidy adapter/helper, docs, changelog policy, release script preflight.
- evaluator agent 가 검증할 기준: dry-run 무변경, apply 후 원문 archive 보존, visible sprint/tmp cleanup, docs 용어 정합, release note 누락 시 preflight 실패.

## §7. G0 Checklist

- [x] raw brief / 대화 메모가 남아 있다
- [x] 문제와 성공 상태가 한 줄로 설명된다
- [x] 대안 2개 이상을 비교했다
- [x] in/out scope seed 가 있다
- [x] generator/evaluator 계약에 넘길 재료가 있다

> checklist 가 대체로 채워지면 `/sfs plan` 으로 이동한다.

## §8. Append Log

`/sfs brainstorm <text>` 또는 `/sfs brainstorm --stdin` 입력이 append 되는 영역.

### 2026-05-01T18:27:19+09:00 — raw input

```text
기존 SFS가 산출한 지저분한 workbench 문서들을 정리할 수 있는 새 명령을 만든다. 삭제가 아니라 원본 보존/아카이브/redirect stub 압축이어야 한다. 작업 중 brainstorm/plan/implement/log/review는 노트패드로 많이 쌓일 수 있지만 sprint 완료 후에는 report.md 중심의 결론/결정/검증/리스크만 남아야 한다. 또한 사용자가 버전업이 됐을 때 어떻게 알 수 있는지 명확해야 한다. 현재 sfs version --check와 sfs upgrade가 있으나 사용자 입장에서 발견 가능성이 더 좋아야 한다. 마지막으로 버전업 때 어떤 기능이 추가/변경/수정됐는지 알 수 있도록 release note 규칙을 세워야 한다. 릴리즈 컷 전 CHANGELOG 또는 release note entry가 없으면 막는 preflight도 고려한다. SFS는 Solo Founder System이며 Sprint Flow는 내부 workflow일 뿐 약자 정의가 아니다.
```
