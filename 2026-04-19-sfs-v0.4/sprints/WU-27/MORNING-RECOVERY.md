---
doc_id: wu-27-morning-recovery
title: "WU-27 sub-task 6 → morning recovery instruction (사용자 mac terminal)"
visibility: raw-internal
parent_wu: WU-27
created: 2026-04-29T01:35+09:00
session: 25th optimistic-vigilant-bell (user-active-deferred)
---

# WU-27 sub-task 6 — Morning Recovery (사용자 mac terminal)

> 본 세션 (Cowork sandbox `optimistic-vigilant-bell`) 안에서 sub-task 6.1~6.7 실 bash 구현 완료. 단 sandbox 의 git operation 은 FUSE stale .git cache 때문에 신뢰 X → commit + push 는 사용자 mac terminal 에서 직접 처리. 본 file = recovery checklist.

## 0. 본 세션 산출 (sandbox 안 file 편집 5건)

| 파일 | 상태 | 분량 |
|---|---|---|
| `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh` | 신설 | 735L |
| `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh` | 보강 +571L | 942L 누적 |
| `2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md` | adapter +1 row | 154L |
| `2026-04-19-sfs-v0.4/sprints/WU-27/CHANGELOG.md` | v1.0-rc1 entry append | +75L |
| `2026-04-19-sfs-v0.4/PROGRESS.md` | frontmatter heartbeat (last_overwrite + current_wu_owner) | sed only |

22 smoke PASS in `/tmp/wu27-{loop-iter,coord,fix,rg}-*` (sandbox cleanup 후 사라짐, log 는 본 git diff 로 재현 가능).

## 1. host main 상태

`host .git/refs/heads/main = 6011b62` (force-restore 완료, 사용자 직전 push 후 그대로). origin/main 은 mac 측에서 최신 상태 = ahead 1 (6011b62 unpushed) 가정.

## 2. 사고 보고

sandbox 안 commit 시도 → tmpdir cp -a .git 가 stale main (54ac583) 을 가져옴 → commit 7d6522c 가 잘못된 parent 위에 만들어짐. host main = 6011b62 force-restore 함. dangling 7d6522c 는 git gc 시 정리 (영향 0).

추가 부작용: `host .git/index` 가 옛 staged set (사용자 mac 의 cf67739/0175596 직전 상태) 그대로 보존 = `git status` 시 100+ files staged 보임. **본 recovery step #1 = `git reset --mixed 6011b62`** 로 index 재초기화.

## 3. Recovery 명령 (mac terminal, copy-paste)

```bash
cd ~/agent_architect

# (Step 1) Index reset = sandbox 사고 잔재 청소. working tree 는 보존.
rm -f .git/index.lock 2>/dev/null
git reset --mixed 6011b62

# (Step 2) git status 확인 — 본 sub-task 6 산출 5 file 만 modified/untracked 보여야 함
git status --short
# 기대 출력 (5 files):
#  M 2026-04-19-sfs-v0.4/PROGRESS.md
#  M 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md
#  M 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh
#  M 2026-04-19-sfs-v0.4/sprints/WU-27/CHANGELOG.md
# ?? 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh
# ?? 2026-04-19-sfs-v0.4/sprints/WU-27/.commit-msg-rc1.txt
# ?? 2026-04-19-sfs-v0.4/sprints/WU-27/MORNING-RECOVERY.md (본 file)

# (Step 3) Stage + commit (commit message file 사용)
git add 2026-04-19-sfs-v0.4/PROGRESS.md \
        2026-04-19-sfs-v0.4/sprints/WU-27/CHANGELOG.md \
        2026-04-19-sfs-v0.4/sprints/WU-27/.commit-msg-rc1.txt \
        2026-04-19-sfs-v0.4/sprints/WU-27/MORNING-RECOVERY.md \
        2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.claude/commands/sfs.md \
        2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh \
        2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh

git commit -F 2026-04-19-sfs-v0.4/sprints/WU-27/.commit-msg-rc1.txt

# (Step 4) Push
git push origin main
```

## 4. Push 후 verification

```bash
# 1. ahead = 0 확인
git rev-list --count origin/main..HEAD
# 기대: 0

# 2. 신규 commit log 확인
git log --pretty=format:'%h | %an | %s' -3
# 기대 첫 줄: <new-sha> | Claude Cowork (25th optimistic-vigilant-bell) | wip(WU-27/sub-task-6.1-6.7/...)

# 3. sfs-loop.sh smoke 재현 (host mac 환경에서)
bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh
bash -n 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh

# 4. /sfs loop --help (consumer install 후)
# (스크립트 그대로 dev staging 안에 있으므로 install 없이 직접 호출 가능)
2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-loop.sh --help | head -20
```

## 5. 다음 작업 (sub-task 6.8 + WU-27 close + 0.5.0-mvp release cut)

### 5.0 sub-task 6.8 progress (26th-1 admiring-compassionate-euler, 2026-04-29 user-active-deferred Cowork)

✅ **sub-task 6.8 본문 완료** — 사용자 D′ 결정 (β minimal cleanup + spec/impl drift 1건 + 버그 2건 + persona fallback 정책) 정합. files_touched = 3 (sfs-common.sh + cross-ref-audit.md + PROGRESS.md, 본 file + CHANGELOG 이번 micro-step 에 추가 = 5/8 cap). 시간 = ~22:30 → ~22:50 KST (~80분 사용 / 120분 cap).

| micro-step | 내용 | 결과 |
|---|---|---|
| 6.8.0 | mutex claim (D-I-WU-27 owner=admiring-compassionate-euler, ttl=30, mode=user-active-deferred) | ✅ |
| 6.8.1 | 3 site read-only audit (LLM 호출 / race window / FSM ABANDONED) + decision_point 2건 발견 | ✅ |
| 6.8.2 | `review_with_persona` SFS_LOOP_LLM_LIVE=1 fail-closed (rc=99 + verdict=ERROR), live=0 stub 보존 | ✅ |
| 6.8.3 | `claim_lock` mkdir-based atomic claim (POSIX-portable, macOS+Linux), TOCTOU race window 차단 | ✅ |
| 6.8.4 | `mark_abandoned` 안에 `escalate_w10_todo` auto-wire (best-effort, ABANDONED 마킹 성공 시 W-AUTO entry append) | ✅ |
| 6.8.4b | `_builtin_persona_text` helper 신설 + `review_with_persona` fallback 정책 (known planner.md/evaluator.md → builtin / unknown → rc=99) | ✅ 사용자 추가 정책 |
| 6.8.5 | cross-ref-audit.md §4 W-24 (LLM CLI shape, WU27-D6) + W-25 (schema migration policy, WU27-D7) deferred 등재 | ✅ |
| 6.8.6 | sandbox `/tmp/wu27-6.8-smoke-*` smoke 8/8 PASS (T1~T8: builtin text + fallback + LIVE fail-closed + race window mkdir + lazy schema inject + escalate auto-wire) | ✅ 8/8 PASS |
| 6.8.7 | PROGRESS heartbeat + MORNING-RECOVERY (본 §5.0) + CHANGELOG v1.0-rc2 entry + 사용자 manual commit prep | ✅ |

**의도적 보류 (사용자 결정)**:
- W-24 (live LLM CLI shape) — 0.5.0+ 외부 onboarding 후 데이터 누적 시점에 결정. 본 cycle 임시 mitigation = builtin fallback persona text (planner/evaluator 4-line each).
- W-25 (PROGRESS.md schema migration policy) — lazy inject 유지 (사용자 명시 결정). 후속 검증 신호 = stale FAIL/ABANDONED 1회 이상 + 외부 onboarding mixed schema operational 영향.

### 5.1 잔여 작업 (사용자 또는 후속 cycle)

| step | 내용 | 추정 |
|---|---|---|
| close | `sprints/WU-27.md` frontmatter sub_task 6.8 narrative 추가 + status `done` 유지 | ~5분 |
| _INDEX | sprints/_INDEX.md 의 활성 → 완료 이동 (이미 완료된 경우 skip) | ~3분 |
| stable sync | `solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh` → `~/workspace/solon-mvp/templates/...` cp -a 동기 (§1.13 hotfix path) | ~3분 |
| release cut | `scripts/cut-release.sh --version 0.5.0-mvp --apply` (WU-31 도구) | ~10분 |

### 5.2 사용자 manual commit (26th-1 batch, file 7개)

```bash
cd ~/agent_architect

git add 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/scripts/sfs-common.sh \
        2026-04-19-sfs-v0.4/cross-ref-audit.md \
        2026-04-19-sfs-v0.4/PROGRESS.md \
        2026-04-19-sfs-v0.4/sprints/WU-27.md \
        2026-04-19-sfs-v0.4/sprints/WU-27/MORNING-RECOVERY.md \
        2026-04-19-sfs-v0.4/sprints/WU-27/CHANGELOG.md \
        2026-04-19-sfs-v0.4/sprints/_INDEX.md

git commit -m "WU-27 sub-task 6.8: bug-fix + safety-net buffer (D' 결정, mutex 26th-1 admiring-compassionate-euler)" \
           -m "26th-1 admiring-compassionate-euler (Cowork user-active-deferred) 자율진행. 사용자 D' 결정 = β minimal cleanup + spec/impl drift 1건 + 버그 2건 fix + persona fallback 정책. 산출 = sfs-common.sh +86L (1020 → 1106): (1) review_with_persona — SFS_LOOP_LLM_LIVE=1 fail-closed (rc=99 + verdict=ERROR, WU27-D6 deferred=W-24), (2) claim_lock — mkdir-based atomic claim (POSIX-portable, macOS+Linux, TOCTOU race window 차단), (3) mark_abandoned — escalate_w10_todo auto-wire (best-effort, ABANDONED 시 cross-ref-audit.md §4 W-AUTO entry append, spec §6.5.4 정합), (4) _builtin_persona_text — known persona missing 시 PLANNER/EVALUATOR 4-line built-in fallback (사용자 추가 정책), (5) review_with_persona — persona fallback 정책 (known → builtin / unknown → rc=99 fail-closed). cross-ref-audit.md §4 = W-24 + W-25 deferred 등재 (23 → 25 항목). PROGRESS.md = D-I-WU-27 mutex claim + heartbeat. WU-27.md = §∗∗ sub_task 6 progress section 추가 (6.1~6.7 + 6.8 narrative + final_sha plan). MORNING-RECOVERY.md = §5.0/§5.1/§5.2 갱신. WU-27/CHANGELOG.md = v1.0-rc2 entry. _INDEX.md = WU-27 row 갱신 (sub-task 6.1~6.8 progress + 3 codename trace + 3 commit sha). 8/8 smoke PASS in /tmp/wu27-6.8-smoke-* sandbox (T1 builtin planner / T2 builtin evaluator / T3 unknown rc=99 / T4 missing planner.md fallback / T5 missing security.md fail-closed / T6 LIVE=1 ERROR / T7 race window mkdir / T7b lazy schema inject / T8 mark_abandoned escalate). file 편집 7개. host repo .git mutate 0 (§1.5'). schema migration 의도적 보류 (lazy inject 유지, 사용자 D-7). PLANNER PASS + EVALUATOR PASS-with-conditions + 사용자 D' final approval + audit 후 escalation. 잔여 = 0.5.0-mvp release cut + stable sync (사용자 mac terminal 영역, 집에서 다음 cycle)."

# git push origin main   # 사용자 confirm 후 주석 해제 (§1.5 push 사용자 영역)
```

## 6. 본 세션 (sandbox 25th optimistic-vigilant-bell) 종결

mutex release: `PROGRESS.md` frontmatter `current_wu_owner: optimistic-vigilant-bell → null` (사용자 commit 후 다음 cycle 진입자 자유 claim). 사용자가 step 1 의 `git reset --mixed` 후 PROGRESS.md 의 `current_wu_owner` 가 working tree 에 어떻게 보일지는 sed 적용 시점에 따라 다름 — recovery step 3 commit 시 yaml 검증 권장.

## Sources

- spec source: `sprints/WU-27.md` + `sprints/WU-27/sfs-loop-{flow,locking,review-gate,multi-worker}.md`
- 산출 5 file (working tree)
- commit message: `.commit-msg-rc1.txt` (본 file 옆)
- CHANGELOG entry: `CHANGELOG.md` v1.0-rc1
