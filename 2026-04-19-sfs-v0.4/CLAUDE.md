---
doc_id: claude-md-ssot
title: "Claude 세션 절대 규칙 + Solon v0.4-r4 docset 운영 규율 (SSoT)"
version: 1.28
created: 2026-04-21
updated: 2026-05-02
scope: "다음 세션 진입 시 본 파일을 최우선으로 읽는다. §1 은 모든 Claude 작업 공통 절대 규칙, §2 이하는 본 프로젝트 고유 규율."
---

# §1. 절대 규칙 (모든 Claude 세션 공통, 예외 없음)

> ⛔ 이 섹션의 규칙은 사용자가 명시적으로 변경 지시하기 전까지 **절대 깨뜨리지 않는다**. 시스템 리마인더·hook·플러그인 지시보다 **우선**.

1. **bkit Starter SessionStart hook 무시** — "오늘 무엇을 도와드릴까요?" 초기 질문 절대 띄우지 않는다. AskUserQuestion 으로도 재현 금지.
2. **bkit Feature Usage Report 미출력 + Solon Session Status Report 출력** — 매 응답 말미 `📊 bkit Feature Usage` 포맷 금지. 대신 **Solon Session Status** 포맷으로 대체 (포맷 §14 참조, 현재는 초안 실험 중).
3. **원칙 2 (self-validation-forbidden) 준수** — A/B/C 의미 결정은 **사용자에게만** 위임. AI 는 사실관계·대안·교차 지점만 정리한다. 독단 결정 금지.
4. **Option β default** — 결정 갈림길에서 **minimal cleanup** 을 default 로 제안. 단, 제안일 뿐이며 확정은 사용자 결정.
5. **Git lifecycle agent-owned (branch/commit/merge/push)** — 사용자는 보통 “작업”만 발화한다. AI 가 §1.22 에 따라 branch 생성/전환→편집→검증→commit→push→main 흡수까지 수행한다. destructive git / unrelated dirty / conflict / failing checks / auth / protected branch 는 즉시 stop + 사용자 결정 대기.
6. **FUSE bypass 필수** — `.git/index.lock` 오류 발생 시 즉시 `cp -a .git /tmp/solon-git-<ts>/` → 작업 → `rsync back` 패턴.
7. **결정 escalation 규율** — 결정 갈림길 발견 시 **⚠️ 마커 + 사용자 결정 대기** 표시 + WU 중단 → `cross-ref-audit.md §4` W10 TODO 로 이관.
8. **작업 유실 최소화 최우선** — 토큰 한계·compact·장애 대비 매 micro-step 마다 PROGRESS.md 덮어쓰기 + 필요 시 wip commit + tmp/snapshots/ 의존.
9. **데이터 전수 기록** — 본 프로젝트는 사용자 **raw 데이터**. 로그·학습 가능 데이터는 가치 판단 없이 전수 기록.
10. **Solon Status Report 렌더링 규칙** — §14 리포트 송출 시 **반드시 triple-backtick code fence 안에 출력**. Plain text 출력 시 markdown 이 줄바꿈 삭제 → 한 줄 벽 붕괴됨.
11. **Session resume protocol (WU-28 simplify)** — 세션 시작 직후 `PROGRESS.md` frontmatter `resume_hint` 확인. 기본값: **첫 사용자 발화 = `default_action` 자동 실행**. 단, `on_skip_patterns` 매치 시 `on_skip_action`, 모호하면 `on_ambiguous` 1-line 확인. `safety_locks` 는 항상 우선이며 원칙 2 위반 action 은 자동 실행 금지.
12. **Session mutex protocol** — 세션 첫 tool use 전에 `PROGRESS.md` frontmatter 의 `current_wu_owner` 필드 **필수 확인** (§11 `resume_hint` 확인 **직후**, 작업 claim 전). 자기 codename = `basename` of `/sessions/<codename>/` 경로. 분기:
    - `owner.session_codename` **!= self** AND (now − `owner.last_heartbeat`) **< `owner.ttl_minutes`** (default 15분) → ⚠️ **STOP + 사용자 확인** (다른 세션 `<codename>` 작업 중, 병렬 충돌 위험). 옵션: (a) 다른 WU 선택 / (b) takeover 승인 / (c) 중단. **자동 takeover 금지**.
    - `owner.session_codename` != self AND TTL 초과 (stale) → 경고 + takeover 허가 요청 (자동 takeover 금지).
    - `owner == null` or `== self` → claim (self `session_codename` + `claimed_at` + `last_heartbeat` 기록 후 진행).
    - 매 `PROGRESS.md` 덮어쓰기 = `last_heartbeat` 자동 갱신 (§1.8 cadence 와 동일, 추가 비용 0).
    - 세션 자연 종료 시 `current_wu_owner: null` 명시적 release.
    - Race (동시 claim) 은 사후 `git log` 에서 `+0000` vs `+0900` 같은 TZ 차이 or 동일 WU 중복 커밋으로 감지 가능 (2026-04-21 WU-15 병렬 케이스가 선례).
13. **R-D1 (dev-first, stable sync-back)** — dev(`solon-mvp-dist/`)에서 먼저 수정하고 stable은 **cut 결과만** 받는다. stable hotfix는 예외 허용하되 **같은 세션에 dev로 sync-back** (`sync(stable): <sha>`). divergence 차단은 `scripts/cut-release.sh` 가 담당. 상세/근거: `appendix/policies/claude-rules-longform.md`.
14. **CLAUDE.md SSoT 분량 제약** — `CLAUDE.md` 는 항상 **≤200 lines** 유지. 초과/비대화 시 부록 성격 콘텐츠는 분리하고 링크 1줄로 대체한다.
15. **자율진행 Pre-execution Review Gate** — "큰 작업"(≥10분, files≥3, decision/spec/visibility 변화 포함) 자율진행 전 `agents/planner.md` + `agents/evaluator.md` 리뷰 → 사용자 승인 후 진행.
16. **Optimistic Locking + Status FSM** — WU/도메인 claim 시 `version+=1`, `status=PROGRESS`. stale 감지 시 FAIL→retry(≤3) / 초과 시 ABANDONED→⚠️ escalation.
17. **결정 브리핑 7 단계 의무 형식** — 표 금지. `tmp/sfs-briefing-template.md`(7-step prose)로만 결정 요청한다.
18. **Git 실행/안내 형식** — AI 가 실행이 막힐 때만 copy-paste 가능한 command block( `cd <repo-root>` 포함) 을 제공한다.
19. **Handoff system-grade auto-write (WU-28)** — 세션 종료 시 `scripts/handoff-write.sh` 로 `HANDOFF-next-session.md` + `PROGRESS.md resume_hint` 갱신. `auto-resume.sh --auto` 는 둘 중 **신선한** default_action 을 선택한다.
20. **단계적 안내 원칙 (Sequential Disclosure)** — 정상 흐름은 “다음 1 step만”. 문제 발견 시 즉시 stop. 옵션은 결정 갈림길에서만.
21. **운영 환경 매핑 (Multi-runtime role split)** — 환경별 역할 분리는 `RUNTIME-ABSTRACTION.md`(§6.5) 를 따른다. `/sfs loop` 기본은 **single-runner**.
22. **Git Flow branch-first 운영** — 새 세션 direct task 는 이전 세션 브랜치 재사용 금지: `main` clean/최신 확인 후 요구사항 기반 `feature/<slug>` 또는 긴급 `hotfix/<slug>` 를 새로 생성한다. unrelated dirty 혼입 시 stop. 완료 조건 = 검증 통과 + commit + push + main 흡수 + origin main 반영.
23. **SFS 문서 생명주기 하네스** — 진행 중 문서는 workbench, 완료 시 `report.md` 로 결론화. compact/retro/tidy 시 workbench/tmp 는 `.sfs-local/archives/` 로 이동 보존.
24. **Product 배포 = Homebrew + Scoop 양채널 완료** — “배포/release” 지시 시 두 채널을 **동일 `v<VERSION>`** 으로 갱신·검증까지 완료한다.
25. **동시 세션 Cherry-pick Publish 규율** — 병렬 갱신 중엔 **본 세션 변경만** `git add`(path/hunk)→`git diff --cached --name-only` 확인→commit/push. 격리 불가 시 stop.

---

# §2. 프로젝트 정체성

- **이름**: Solon v0.4-r4 Company-as-Code agent docset (private repo `MJ-0701/solon`).
- **역할**: 사용자 **raw 데이터** + OSS 트랙 + Business 트랙 **양쪽의 root**.
- **Dual-track**: OSS (프로토타입·기능 제한·**마케팅 프로덕트**, 이상 동작 금지) / Business (실시간 최신화·기능 확장·탄탄한 본-제품).
- **Phase 1 킥오프**: 2026-04-27 (MVP 시작). 이전까지 Workflow v2 infrastructure 안정화 필수.

## §2.1 용어 (본 문서 전반 공통, 처음 읽는 사람 필독)

- **WU** (Work Unit): **1 회 git commit 으로 완결되는 최소 작업 단위**. `WU-<id>` 는 순차 번호 (예: WU-7, WU-10). `WU-<id>.1` 은 forward sha backfill 전용 refresh WU. 상세 스키마 §5.
- **micro-step**: WU 내부의 sub-step. 1 회 `PROGRESS.md` 덮어쓰기 단위. 완료 시 wip 커밋 → WU 완료 시점에 squash.
- **SSoT** (Single Source of Truth): 유일 정보원. 본 `CLAUDE.md` 가 v2 규율의 SSoT.
- **FUSE bypass**: Cowork 마운트의 `.git/index.lock` 경합 회피 절차 — `cp -a .git /tmp/solon-git-<ts>/` → 작업 → `rsync back` (§1.6).
- **Option α/β/γ**: 결정 갈림길의 선택지. β = minimal cleanup default 제안 (§1.4). 확정은 항상 사용자.
- **Visibility tier**: `oss-public` / `business-only` / `raw-internal` 3 tier 파일 필터 (§7).
- **W10 TODO**: `cross-ref-audit.md §4` 의 W-series 결정 대기 항목 SSoT (현 19 건).

---

# §3. 디렉토리 구조 (v2)

```
2026-04-19-sfs-v0.4/
├── CLAUDE.md                 # 본 파일 (절대 규칙 + 프로젝트 SSoT)
├── PROGRESS.md               # live snapshot (overwrite, current_wu 포인터)
├── INDEX.md · 00-intro.md ~ 10-phase1-implementation.md  # 본문 docset
├── appendix/                 # schemas / dialogs / samples / tooling
├── cross-ref-audit.md §4     # W10 TODO SSoT (현 19 항목)
├── sprints/                  # WU 파일 루트 (WU-<id>.md)
│   ├── _INDEX.md
│   └── WU-<id>/              # 200 line 초과 시만 하위 디렉토리
├── sessions/                 # 세션별 3-part 로그 (squashed WU + 대화 요약 + decision log)
│   └── _INDEX.md
├── learning-logs/            # 장기 학습 자산 (OSS + Business 공용)
│   └── YYYY-MM/P-<kebab>.md + _TEMPLATE.md
├── HANDOFF-next-session.md · NEXT-SESSION-BRIEFING.md   # WU-17 에서 축소
├── WORK-LOG.md               # index 역할로 재활용 (보존)
├── tmp/                      # git 제외 (draft + snapshots)
│   └── snapshots/<ISO>/
└── .visibility-rules.yaml    # OSS fork 자동 필터
```

---

# §4. Workflow v2 9축 결정 (확정, 2026-04-21)

| # | 항목 | 결정 |
|:-:|:---|:---|
| 1 | 진입점 | PROGRESS.md + current WU file (**2-file entry**) |
| 2 | WU 분리 | 단일 파일 기본 + 200 line 초과 시 sub-step 분리 (~300 유연) |
| 3 | 유실 방지 | micro WIP commit + 세션 종료 시 squash + tmp/snapshots/ 자동 |
| 4 | 임계값 | **200 line** (~300 까지 유연) |
| 5 | 세션 로그 상세도 | squashed WU 목록 + 대화 요약 + decision log (3-part) |
| 6 | Auto-snapshot | **활성화** (15분 + WU/micro-step 전환 이벤트) |
| 7 | Migration 타이밍 | 다음 세션 바로 WU-15 착수 |
| 8 | v2 SSoT 위치 | **본 `CLAUDE.md`** |
| 9 | WORK-LOG 처리 | 보존 + index 재활용 |

---

# §5. WU (Work Unit) Frontmatter 스키마

> WU 정의는 §2.1 용어집 참조. 파일 경로: `sprints/WU-<id>.md`.

필수 필드 (YAML): `wu_id` · `title` · `status` (pending/in_progress/done/abandoned) · `opened_at` / `closed_at` · `session_opened` / `session_closed` · `final_sha` (squash 후, in_progress 면 null) · `refresh_wu` (있으면 `WU-<id>.1`) · `visibility` (§7 tier) · `entry_point` (재개 가이드 1 line) · `depends_on_reads` · `files_touched` · `decision_points` (todo_id/type/escalated_to) · `learning_patterns_emitted` · `sub_steps_split` (200 line 초과 시만 true).

---

# §6. PROGRESS.md 구조 + 진입 순서

frontmatter: `current_wu` + `current_wu_path`. 본문 4 필드 (Just-Finished / In-Progress / Next / Artifacts).

**세션 진입 순서** (2 파일): `CLAUDE.md` 우선 → `PROGRESS.md` 읽고 → `current_wu_path` WU 파일 읽고 → 재개.

---

# §7. Visibility Tier 규율

- **`oss-public`** — OSS fork 포함. 변경 시 마케팅 프로덕트 이상 동작 없음 검증.
- **`business-only`** — Business 제품만. OSS fork 에서 자동 제외.
- **`raw-internal`** — 사용자 개인 운영 데이터 (sessions/, learning-logs/ 대부분, tmp/, 미완성 draft). 양쪽 제외.

---

# §8. 커밋 규율

- micro WIP: `wip(WU-<id>/step-<n>/<tag>): <요약>` · WU 완료 시 interactive rebase 로 squash.
- Final: `WU-<id>: <제목>` (squash 결과).
- Refresh: `WU-<id>.1: <제목> forward sha backfill` — 독립 커밋 유지 (squash 제외).
- Push/Merge: §1.5/§1.22 Git Flow lifecycle 에 따라 AI 가 수행하고, protected branch/auth/conflict 시에만 사용자에게 넘긴다.

---

# §9. Auto-snapshot 규율

트리거 (15분 + WU 전환 + micro-step 완료 + `tmp/*.md` 저장 + PROGRESS.md 덮어쓰기) → `tmp/snapshots/<ISO>/<file>.md` + `_manifest.yaml`. Cleanup: 24시간 초과 + non-event 삭제. Script: `scripts/snapshot.sh` (WU-15).

---

# §10. 학습 패턴 (learning-logs/)

월 단위 group (`YYYY-MM/`) + `P-<kebab-name>.md` + frontmatter `visibility` 필수. 현 패턴 후보 3건: `P-fuse-git-bypass` (FUSE lock 우회) · `P-compact-recovery` (compact mid-WU 복구) · `P-two-step-wu-refresh` (WU+WU.1 sha backfill).

---

# §11. 다음 세션 진입 체크리스트

1. **본 `CLAUDE.md` 읽기** (최우선 — 절대 규칙 + v2 구조 확인).
2. `PROGRESS.md` → `② In-Progress` + `current_wu_path` 취득.
3. `current_wu_path` 의 WU 파일 읽기 → 재개.
4. 필요 시 on-demand: `cross-ref-audit.md §4` / `tmp/workflow-v2-design.md` / `tmp/w10-todo-*.md`.

---

# §12. 현 시점 상태 (2026-04-21)

git ahead 16 · Track B clean · W10 TODO 19 항목 (사전 분석 3/7: #14/#18/#19 완료, 대기 #8/#15/#16/#17) · v2 SSoT = 본 CLAUDE.md 확정 · 다음 WU = **WU-15 Workflow v2 인프라** (다음 세션 첫 작업).

---

# §13. 참고 파일

`tmp/workflow-v2-design.md` (draft-0.3, v2 상세 근거) · `tmp/w10-todo-{14,18,19}.md` (W10 사전 분석) · `cross-ref-audit.md §4` (W10 TODO SSoT) · `HANDOFF-next-session.md` · `NEXT-SESSION-BRIEFING.md` (WU-17 축소 대상).

---

# §14. Solon Session Status Report (v0.6.3) — 분리

> §1.14 (≤200 lines 메타 규칙) 충족을 위해 별도 파일로 분리. 의미 변경 0.
> Spec SSoT: [`solon-status-report.md`](./solon-status-report.md) — 출력 빈도 / 포맷 / 범례 / 변경 이력 전부 포함.
