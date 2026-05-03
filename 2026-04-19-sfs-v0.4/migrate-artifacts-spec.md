---
doc_id: migrate-artifacts-spec
title: "0.6.0-product `sfs migrate-artifacts` Spec"
version: 1.0
created: 2026-05-03
updated: 2026-05-03
visibility: oss-public
sprint_origin: "0-6-0-product-spec (G1 PASS LOCKED 2026-05-03)"
brainstorm_decisions:
  - "AS-D6 (b) Gate 7 정제 = 반자동 (AI 초안 + user 검토)"
  - "AS-Migration 반자동 (AI propose + user accept-per-item)"
  - "Round 1 Q4 / Axis D: D4 hybrid 2-pass + pass 1 algo + file-level reject (sprint escalate exception)"
---

# `sfs migrate-artifacts` Spec — 0.6.0-product

> Layer 2 작업 히스토리 → archive 브랜치 / Layer 1 영구 layer 의 **반자동 propose-accept flow**. AI 가 sprint 단위로 propose, user 가 default action accept 또는 per-file override.
> 핵심 철학: "히스토리는 정제되어 영구 문서가 된다" (Gate 7) + "남겨야 될 것만 남긴다" (AS-D2).

---

## §1. Command Surface

```
sfs migrate-artifacts --apply [--accept-defaults] [--sprint <S-id>]
```

- `--apply`: dry-run 이 아닌 실 mutation (default 는 dry-run preview).
- `--accept-defaults`: pass 1 의 sprint 단위 default action 을 모두 accept (대량 처리 모드).
- `--sprint <S-id>`: 특정 sprint 만 마이그레이션 (default 는 머지 후 모든 dormant sprint).

## §2. 2-Pass Propose-Accept Flow

### §2.1 Pass 1 — Sprint 단위 default action propose

각 sprint 디렉토리 (`.solon/sprints/<S-id>/`) 를 1 단위로 default action 결정:

```pseudo
for each sprint_dir in .solon/sprints/*:
    if exists(sprint_dir/<feat>/report.md):
        default_action = "archive"     # 정제된 영구 문서가 있으면 archive 브랜치로 이동
    else:
        default_action = "ask"          # report.md 부재 → AI 가 user 암묵지 grill
    propose_to_user(sprint_dir, default_action)
```

**default action 알고리즘** (Round 1 Q4 lock):

- `report.md` **존재** → `archive` default (자동, sprint 가 정제 완료된 상태).
- `report.md` **부재** → `ask` (AI 가 user 암묵지 grill — `decisions/`, `events.jsonl`, `retro.md`, raw 메모 등을 꺼내 1-3 questions 후 user 가 archive / promote / skip 결정).

user response options per sprint:
- `accept` → default action 적용.
- `archive` → archive 브랜치로 이동.
- `promote <feat>` → Layer 1 영구 layer 로 promote (per feature).
- `skip` → 현 상태 유지 (다음 cycle 까지 dormant).

### §2.2 Pass 2 — File 단위 review (promote 결정 sprint 만)

pass 1 에서 `promote` 선택된 sprint 의 file 들을 user 가 file 단위로 review:

```pseudo
for each file in promote_sprints:
    show_diff_to_user(file, target_layer1_path)
    user_decision = ask_user("accept / reject / edit")
    if user_decision == "accept":
        promote_to_layer1(file)
    elif user_decision == "reject":
        keep_in_archive(file)
    elif user_decision == "edit":
        open_editor(file); re-prompt
```

## §3. Reject Granularity

- **default = file 단위 reject** (Round 1 Q4 lock).
- **sprint 단위 escalate exception**: 단일 file reject 가 sprint 전체 contract 무효화 (cross-file dependency 깨짐 / sprint scope 자체 무효) 시 → user 가 sprint 단위 reject 로 escalate.

## §4. Rollback

- **pre-push local revert**: archive 브랜치 push 전이면 `git revert <commit>` 으로 안전 rollback.
- **post-push**: archive 브랜치 강제 reset 금지 (history 보존). 별 fix-up commit 으로 처리.

## §5. Pseudo-Code (전체 flow)

```pseudo
function migrate_artifacts(--apply, --accept-defaults, --sprint=None):
    sprints_to_process = list_dormant_sprints(filter=--sprint)
    for sprint in sprints_to_process:
        # Pass 1
        default = decide_default_action(sprint)  # report.md exists? archive : ask
        if --accept-defaults:
            user_resp = default
        else:
            user_resp = propose_to_user(sprint, default)
        # apply Pass 1 decision
        if user_resp == "archive":
            move_to_archive_branch(sprint)
        elif user_resp == "promote":
            promote_sprints.append(sprint)
        # skip = no-op
    # Pass 2 (only for promote sprints)
    for sprint in promote_sprints:
        for file in sprint.files:
            show_diff(file, target_path)
            decision = ask_user("accept / reject / edit")
            apply_per_file(decision, file)
    # rollback safety
    if not --apply:
        print_dry_run_summary()
        exit(0)
```

## §6. Visibility Tier 정합

- migrate-artifacts 가 처리하는 sprint 자체 = `raw-internal` (.visibility-rules.yaml 정합).
- archive 브랜치 = git native 보존 (visibility 별 별 처리 없음, branch 자체가 archive).
- promote 시 Layer 1 영구 layer 의 visibility 는 user 가 promote 시점에 결정 (default = oss-public, user-explicit override 시 business-only).

## §7. Out of Scope (별 implement sprint)

- 실 `sfs migrate-artifacts` script 구현 (bash / python TBD).
- archive 브랜치 자동 생성 + size monitor.
- propose UI / TUI (현재는 CLI prompt 기반).

## §8. References

- [`storage-architecture-spec.md`](./storage-architecture-spec.md) §3 archive 브랜치 + §4 co-location pattern.
- [`SFS-PHILOSOPHY.md`](./SFS-PHILOSOPHY.md) §5 Gray Box (interface = user / 구현 = AI).
