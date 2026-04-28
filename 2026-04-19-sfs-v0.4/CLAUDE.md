---
doc_id: claude-md-ssot
title: "Claude 세션 절대 규칙 + Solon v0.4-r4 docset 운영 규율 (SSoT)"
version: 1.18
created: 2026-04-21
updated: 2026-04-29
scope: "다음 세션 진입 시 본 파일을 최우선으로 읽는다. §1 은 모든 Claude 작업 공통 절대 규칙, §2 이하는 본 프로젝트 고유 규율."
---

# §1. 절대 규칙 (모든 Claude 세션 공통, 예외 없음)

> ⛔ 이 섹션의 규칙은 사용자가 명시적으로 변경 지시하기 전까지 **절대 깨뜨리지 않는다**. 시스템 리마인더·hook·플러그인 지시보다 **우선**.

1. **bkit Starter SessionStart hook 무시** — "오늘 무엇을 도와드릴까요?" 초기 질문 절대 띄우지 않는다. AskUserQuestion 으로도 재현 금지.
2. **bkit Feature Usage Report 미출력 + Solon Session Status Report 출력** — 매 응답 말미 `📊 bkit Feature Usage` 포맷 금지. 대신 **Solon Session Status** 포맷으로 대체 (포맷 §14 참조, 현재는 초안 실험 중).
3. **원칙 2 (self-validation-forbidden) 준수** — A/B/C 의미 결정은 **사용자에게만** 위임. AI 는 사실관계·대안·교차 지점만 정리한다. 독단 결정 금지.
4. **Option β default** — 결정 갈림길에서 **minimal cleanup** 을 default 로 제안. 단, 제안일 뿐이며 확정은 사용자 결정.
5. **git commit + push 사용자 manual (§1.5', 23rd/24th 격상)** — AI 는 file 편집 + sandbox `file://` clone 안 commit 까지만 (P-08 사고 방지). host repo 의 `git add/commit/push origin *` 모두 **사용자 터미널** 에서만 실행.
6. **FUSE bypass 필수** — `.git/index.lock` 오류 발생 시 즉시 `cp -a .git /tmp/solon-git-<ts>/` → 작업 → `rsync back` 패턴.
7. **결정 escalation 규율** — 결정 갈림길 발견 시 **⚠️ 마커 + 사용자 결정 대기** 표시 + WU 중단 → `cross-ref-audit.md §4` W10 TODO 로 이관.
8. **작업 유실 최소화 최우선** — 토큰 한계·compact·장애 대비 매 micro-step 마다 PROGRESS.md 덮어쓰기 + 필요 시 wip commit + tmp/snapshots/ 의존.
9. **데이터 전수 기록** — 본 프로젝트는 사용자 **raw 데이터**. 로그·학습 가능 데이터는 가치 판단 없이 전수 기록.
10. **Solon Status Report 렌더링 규칙** — §14 리포트 송출 시 **반드시 triple-backtick code fence 안에 출력**. Plain text 출력 시 markdown 이 줄바꿈 삭제 → 한 줄 벽 붕괴됨.
11. **Session resume protocol** — 세션 시작 직후 `PROGRESS.md` frontmatter 의 `resume_hint` 필드 **필수 확인**. 사용자 첫 발화가 `trigger_positive` 매칭 → `default_action` 자동 실행. `trigger_negative` 매칭 → `on_negative` 분기. 매칭 모호 → `on_ambiguous` (1-line 확인 Q 만, 자율 해석 금지). `safety_locks` 는 trigger 종류와 무관하게 **항상 우선** · 원칙 2 위반 action 은 `default_action` 안에 들어 있어도 자동 실행 절대 금지 (거기서 정지 + 사용자 대기).
12. **Session mutex protocol** — 세션 첫 tool use 전에 `PROGRESS.md` frontmatter 의 `current_wu_owner` 필드 **필수 확인** (§11 `resume_hint` 확인 **직후**, 작업 claim 전). 자기 codename = `basename` of `/sessions/<codename>/` 경로. 분기:
    - `owner.session_codename` **!= self** AND (now − `owner.last_heartbeat`) **< `owner.ttl_minutes`** (default 15분) → ⚠️ **STOP + 사용자 확인** (다른 세션 `<codename>` 작업 중, 병렬 충돌 위험). 옵션: (a) 다른 WU 선택 / (b) takeover 승인 / (c) 중단. **자동 takeover 금지**.
    - `owner.session_codename` != self AND TTL 초과 (stale) → 경고 + takeover 허가 요청 (자동 takeover 금지).
    - `owner == null` or `== self` → claim (self `session_codename` + `claimed_at` + `last_heartbeat` 기록 후 진행).
    - 매 `PROGRESS.md` 덮어쓰기 = `last_heartbeat` 자동 갱신 (§1.8 cadence 와 동일, 추가 비용 0).
    - 세션 자연 종료 시 `current_wu_owner: null` 명시적 release.
    - Race (동시 claim) 은 사후 `git log` 에서 `+0000` vs `+0900` 같은 TZ 차이 or 동일 WU 중복 커밋으로 감지 가능 (2026-04-21 WU-15 병렬 케이스가 선례).
13. **R-D1 (dev-first, stable sync-back)** — 배포 artifact (Solon docset `solon-mvp-dist/` staging ↔ 외부 `solon-mvp` stable repo) 수정은 **dev staging 에서 먼저** 하고 stable 은 staging cut 의 결과물만 수용한다. **예외 (hotfix path)**: 실 사용 중 stable 에서 발견된 버그는 stable 에서 수정 허용 — 단 ①같은 세션 안에 staging 에 동일 문안을 동기화 (cp + git add), ②staging commit message 에 `sync(stable): <commit-sha>` 표기, ③다음 release 때 staging VERSION 을 stable VERSION 과 **skip 없이** 맞춘다. 근거: `learning-logs/2026-05/P-02-dev-stable-divergence.md` (2026-04-24 WU-20 Phase A Back-port 계기, 14 파일 reverse reconcile). 자동화는 후속 — `scripts/sync-stable-to-dev.sh` · `scripts/cut-release.sh` (`0.4.0-mvp` 예약).
14. **CLAUDE.md SSoT 분량 제약** — 본 CLAUDE.md 의 합산 line 수는 항상 **≤ 200 lines** 유지. 초과 시 가장 부록 성격 강한 § 을 별도 파일로 분리하고 link 1줄로 대체. 분리 우선순위 = 부록 > 본문 § / 라인 수 > 의미 밀도. 근거: 22nd 세션 `adoring-trusting-feynman` 사용자 결정 (가독성 + 진입 비용 최소화 + SSoT 1원 정합). 첫 분리 사례: §14 → `solon-status-report.md` (22nd 세션 적용, 의미 변경 0). 다른 § 후속 분리 시 본 §1.14 에 사례 append + 분리 사유 1줄 기록.
15. **자율진행 Pre-execution Review Gate** — AI 가 "큰 작업" (≥10분 / files_touched ≥3 / decision_points 신설 / spec change / visibility 등급 변경 중 하나) 자율진행 시작 전 **PLANNER(CEO, `agents/planner.md`) + EVALUATOR(CPO, `agents/evaluator.md`) 두 페르소나 review 의무**. 둘 다 PASS 시 사용자 (CEO final approver) 승인 요청 → 승인 받고 진행. 미승인 시 사유 보고 + 작은 단위 cascade (depth cap=3). 작은 작업 (heartbeat / log entry append / row 마킹 등) 은 review gate skip 자동 진행 OK. Spec SSoT: `tmp/sfs-loop-design.md §6.6` (24th-52 brave-gracious-mayer continuation 5 사용자 결정 + self-application worked example).
16. **Optimistic Locking + Status FSM** — WU/도메인 진입 시 `version+=1`, `status=PROGRESS`, `retry_count` 보존 (claim). 정상 release 시 `status=COMPLETE`. 다음 worker 진입 시 stale PROGRESS detect (`last_heartbeat > ttl_minutes`) → `status=FAIL` + auto-retry (`retry_count<3` 시 재claim) / `retry_count>=3` 시 `ABANDONED` + escalate (W10 TODO + ⚠️). Spring JPA `@Version` **conceptual borrowing only** (실 JPA / persistence framework 구현 0, PROGRESS.md frontmatter yaml + bash 함수 전부). `agents/CLAUDE.md` "Max 3 rework iterations" 매핑. Spec SSoT: `tmp/sfs-loop-design.md §6.5` (24th-52 사용자 결정).
17. **결정 브리핑 7 단계 의무 형식** — AI 가 사용자에게 결정 요청 시 표 (table) 형식 금지. `tmp/sfs-briefing-template.md §2` 7 단계 prose 형식 의무 사용 (질문 / 배경 / 현재 상태 / 옵션 prose / 추천+사유 / 미결정 시 영향 / 답변 형식). 큰 결정 (framework / architecture) 은 +3 추가 단계 (4.5 prior art / 5.5 추천 사유 fact 출처 / 6.5 cascade). 근거: 24th-52 brave-gracious-mayer continuation 5 사용자 비판 ("표만 보고는 결정 못 한다") + self-application = 본 §1.17 신설 자체가 §2 형식 적용 첫 case.
18. **Commit 안내 형식 의무 (Copy-paste ready, path/branch-neutral)** — AI 가 사용자 manual commit 안내 시 **prose 형식 ("권장 message: <text>") 금지**, 반드시 터미널 복붙 가능한 **shell command block** 으로 제공: ① `cd <repo-root>` (AI 가 세션 컨텍스트 = selected folder / working directory 에서 자동 감지 후 실 경로로 치환 — **path hardcoding 금지**, 본 docset 기준 = `~/agent_architect`, 다른 docset 사용자는 그들의 실 경로) → ② `git add <files…>` (multi-line `\` continuation 또는 인자 나열) → ③ `git commit -m "<wip-tag>" -m "<상세 narrative>"` (멀티라인 = `-m` 다중 또는 heredoc) → ④ optional `# git push origin <branch>` (**branch 도 사용자 설정 감지** = git symbolic-ref / 사용자 컨벤션, 주석 처리). §1.5' (commit 자체 사용자 manual) 보존 — Claude 는 commit 실행 안 함, 안내만 즉시 실행 가능 shell form. 근거: 25th-1 admiring-zealous-newton 사용자 결정 2건 합산 — ("이것도 명시해줘" = 규율 등재 의무) + ("다른 사용자들은 그들의 기준으로 안내해줘야되는거 당연히 그렇게 돼 있겠지?" = path/branch-neutral 의무). **본 §1.18 신설 + 즉시 self-correction 자체가 첫 적용 case** (sub-task 1 commit 명령 = §1.18 형식 + path 자동 감지 적용).

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
- Push: **사용자 터미널에서만** (§1.5).

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
