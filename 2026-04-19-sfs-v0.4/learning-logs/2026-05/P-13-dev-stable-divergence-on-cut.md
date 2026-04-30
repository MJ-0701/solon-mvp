---
pattern_id: P-13
title: dev-stable-divergence-on-cut
status: documented
severity: high
first_observed: 2026-04-30
observed_by: 26th-3 ε continuation 3 (Cowork user-active conversation, 사용자 'release 실행완료됐고 ... 코덱스 수정사항이 합리적이면 그걸 반영하란 소린데' 비판 직후 진단)
resolved_at: 2026-04-30
resolved_by: 26th-3 ε continuation 3 + 본 cycle 0.5.1-product hotfix release
resolved_via:
  - "[1] cut-release.sh Pre-flight 강화 — stable HEAD 의 narrative key (VERSION suffix / README h1 / CHANGELOG h1 / SOLON_REPO 상수) 와 dev staging 비교 → divergence 감지 시 warn (dry-run) / abort (--apply, exit 7 신설)."
  - "[2] CLAUDE.md §1.13 R-D1 보강 — sync-back 단계 누락 시 다음 cut 회귀 risk 명시 + 본 P-13 link."
  - "[3] 본 P-13 신설 (사고 narrative + detect / prevent / recover 3 path)."
  - "[4] cross-ref-audit.md §4 W-AUTO-13 entry (1~2 사이클 재현 검증)."
related_rule: CLAUDE.md §1.13 (R-D1 dev-first, stable sync-back)
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.13 (R-D1 invariant)
  - 2026-04-19-sfs-v0.4/scripts/cut-release.sh §1 Pre-flight (강화 영역)
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-02-dev-stable-divergence.md (선례, 역방향 reverse reconcile)
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-10-stable-stale-git-lock-recovery.md (cousin, lock 만 감지)
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-14-mental-coupling-on-rename-fix.md (직접 짝 = 본 사고의 AI 측 안티패턴)
visibility: business-only
applicability:
  - "dev↔stable 양 repo 운영 환경 (R-D1 §1.13 정합)"
  - "cut-release.sh / sync-stable-to-dev.sh 같은 release tooling"
  - "외부 hotfix worker (codex / collaborator) 가 stable 직접 commit 하는 환경"
reuse_count: 0   # 본 신설 자체가 dogfooding 첫 case, 적용 검증은 0.5.1-product 후속 1~2 사이클
---

# P-13 — dev-stable narrative divergence on cut

## 1. 사고 narrative (26th-3 발견 시점)

### 1.1 timeline

| 시각 (KST) | commit | 의미 |
|:--|:--|:--|
| Apr 29 ~16:30 | (26th-2 ε continuation 2 file 편집 18+) | 본 conversation 가 dev staging 편집 (mvp 본 narrative, multi-adaptor 1급 추가) |
| Apr 29 23:52 | `ced9cc1` | codex stable 직접 편집: "prepare solon mvp product docs" — README "친구야" 톤 제거 + product positioning rewrite + AGENTS/CLAUDE narrative |
| Apr 29 23:59 | `5765abb` | codex stable 직접 편집: "rename repository to solon product" — SOLON_REPO + GIT_MARKER + legacy fallback 패턴 신설 |
| Apr 30 00:03 | `7977a75` | codex stable 직접 편집: "harden readme for product positioning" — README 본문 다시 다듬기 |
| Apr 30 09:07 | **`99b2313`** | **26th-2 helper 0.5.0-mvp release cut → cut-release.sh `--apply` 가 dev (mvp 본) → stable rsync = codex 작업 3 commits overwrite** |

### 1.2 외부 onboarding 차단 위험

- `install.sh` curl URL `MJ-0701/solon-mvp` 잔존 → GitHub repo rename redirect 만료 시 친구 첫 install 즉시 404.
- README h1 `# Solon MVP` 잔존 → 외부 독자가 "MVP / private beta" 단계로 인식 → 신뢰도 하락.

### 1.3 26th-3 첫 시도 = 단순 string rename (P-14 mental coupling 안티패턴)

26th-3 첫 시도 때 AI 가 "회귀 fix" 라고 부르며 단순 `solon-mvp` → `solon-product` string replace 만 함. codex 의 narrative 개선분 (product positioning rewrite, public terminology cleanup, /sfs start <goal> contract, runtime asset sync, non-TTY handling, decision JSONL escape, distribution hygiene 등 11항목) 보존 안 함. 사용자 비판 verbatim "코덱스 수정사항이 합리적이면 그걸 반영하란 소린데... 너 그냥 무작정 회귀만했지" 즉시 수신 → P-14 자가 인지 + sync-back path 정합.

→ P-13 = release tooling 측 결함 (dev-stable divergence 미감지) / P-14 = AI worker 측 결함 (codex narrative read 안 함). 두 결함이 결합되어 사고 발생.

## 2. 근본 원인 분석

### 2.1 cut-release.sh 의 부재 invariant

본 cycle 시점 `cut-release.sh §1 Pre-flight` 검증 항목:
1. dev staging path 존재 (`exit 2`)
2. stable repo path 존재 + `.git` 존재 (`exit 3`)
3. stable working tree clean (`exit 4`, `--allow-dirty` bypass)
4. stable `.git/index.lock` stale (`exit 6`, P-10)
5. dev working tree clean (warn only, `--allow-dirty` bypass)
6. TBD final_sha placeholder 잔존 (`exit 5`)

**누락**: stable HEAD 의 narrative key (VERSION suffix / README h1 / CHANGELOG h1 / SOLON_REPO 상수 등) 와 dev staging 의 동일 영역 divergence 감지. → cut-release.sh 가 codex 의 stable hotfix 결과를 인식 못 하고 dev 본을 그대로 rsync overwrite.

### 2.2 R-D1 §1.13 의 hotfix path 인식 불충분

CLAUDE.md §1.13 verbatim: "stable 에서 발견된 버그는 stable 에서 수정 허용 — 단 ① 같은 세션 안에 staging 에 동일 문안을 동기화 (cp + git add), ② staging commit message 에 `sync(stable): <commit-sha>` 표기, ③ 다음 release 때 staging VERSION 을 stable VERSION 과 skip 없이 맞춘다."

→ ① sync-back 단계 누락 시 다음 cut 회귀 risk **명시 안 됨**. codex 가 ① 단계를 안 하고 stable 만 commit + 사용자 sleep + 26th-2 helper 가 dev rsync = 회귀 사고.

### 2.3 stable working tree review 시점의 사용자 case-by-case 한계

26th-2 helper Step 2 (stable working tree review, C invariant) 시점에 사용자가 codex 의 13 file divergence 를 **본인이 case-by-case 결정** 해야 했음. 하지만:
- 사용자 sleep 위임 mode = 사용자가 그 시점에 부재
- helper 가 "stable working tree clean 확인 후 진행" 으로 fallback
- 결과: codex 의 commit (이미 push 완료, working tree clean) 위에 dev rsync overwrite

즉 helper 의 Step 2 가 "dirty working tree 만 검출" 하고 "이미 commit 된 stable HEAD 의 dev divergence" 는 검출 안 한 게 결함.

## 3. Detect — 조기 감지 path (cut-release.sh 강화 후)

### 3.1 narrative key divergence 감지 (cut-release.sh §1 신설)

cut-release.sh `Pre-flight` 에 다음 비교 추가:

```sh
# stable HEAD 의 narrative key 추출
STABLE_VERSION="$(cat "${STABLE_REPO}/VERSION" 2>/dev/null || echo unknown)"
STABLE_README_H1="$(head -1 "${STABLE_REPO}/README.md" 2>/dev/null | sed 's/^# //')"
STABLE_CHANGELOG_H1="$(grep -E '^# CHANGELOG' "${STABLE_REPO}/CHANGELOG.md" 2>/dev/null | head -1)"
STABLE_SOLON_REPO="$(grep -E '^readonly SOLON_REPO=' "${STABLE_REPO}/install.sh" 2>/dev/null | head -1)"

# dev staging 의 같은 영역
DEV_VERSION="$(cat "${DEV_STAGING}/VERSION" 2>/dev/null)"
DEV_README_H1="$(head -1 "${DEV_STAGING}/README.md" 2>/dev/null | sed 's/^# //')"
DEV_CHANGELOG_H1="$(grep -E '^# CHANGELOG' "${DEV_STAGING}/CHANGELOG.md" 2>/dev/null | head -1)"
DEV_SOLON_REPO="$(grep -E '^readonly SOLON_REPO=' "${DEV_STAGING}/install.sh" 2>/dev/null | head -1)"

# divergence 감지
DIVERGENCE=()
[ "${STABLE_README_H1}" != "${DEV_README_H1}" ] && DIVERGENCE+=("README h1: stable='${STABLE_README_H1}' dev='${DEV_README_H1}'")
[ "${STABLE_CHANGELOG_H1}" != "${DEV_CHANGELOG_H1}" ] && DIVERGENCE+=("CHANGELOG h1: stable='${STABLE_CHANGELOG_H1}' dev='${DEV_CHANGELOG_H1}'")
[ "${STABLE_SOLON_REPO}" != "${DEV_SOLON_REPO}" ] && DIVERGENCE+=("SOLON_REPO: stable='${STABLE_SOLON_REPO}' dev='${DEV_SOLON_REPO}'")

if [ ${#DIVERGENCE[@]} -gt 0 ]; then
  warn "stable HEAD narrative key divergence 감지 (codex hotfix sync-back 누락 가능):"
  for d in "${DIVERGENCE[@]}"; do warn "    - ${d}"; done
  if [ "${APPLY}" == "1" ]; then
    fail "stable narrative divergence — sync-back 후 재시도 (--allow-divergence bypass 필요)" 7
  else
    warn "(dry-run 이므로 진행, --apply 시는 abort 단 --allow-divergence 명시 시 통과)"
  fi
fi
```

→ exit 7 신설 (dev-stable narrative divergence). `--allow-divergence` bypass flag 도 추가 (의도된 dev-only 변경 시).

### 3.2 git log 비교 (선택, deep verification)

stable repo 의 마지막 release commit 이후 commit history 와 dev staging 의 wip commit history 를 비교. stable 에 sync-back 없는 codex / collaborator commit 검출 시 동일 warn.

```sh
LAST_RELEASE_TAG="$(git -C "${STABLE_REPO}" describe --tags --abbrev=0 'v*-mvp' 'v*-product' 2>/dev/null | head -1)"
STABLE_NEW_COMMITS="$(git -C "${STABLE_REPO}" log --oneline "${LAST_RELEASE_TAG}..HEAD" 2>/dev/null | wc -l)"
if [ "${STABLE_NEW_COMMITS}" -gt 0 ]; then
  warn "stable 에 ${LAST_RELEASE_TAG} 이후 ${STABLE_NEW_COMMITS} commit (sync-back 누락 가능):"
  git -C "${STABLE_REPO}" log --oneline "${LAST_RELEASE_TAG}..HEAD" | sed 's/^/    /' >&2
fi
```

## 4. Prevent — 사전 차단 invariant

### 4.1 R-D1 §1.13 sync-back 의무 강조 (CLAUDE.md 보강)

§1.13 invariant 본문에 다음 1줄 추가:

> "**①sync-back 누락 → 다음 cut 회귀 risk** (P-13 사고 패턴). cut-release.sh §1 Pre-flight 가 narrative key divergence 감지 + abort 로 강제."

### 4.2 외부 worker 협업 invariant

codex / collaborator 가 stable hotfix 후 본인 sync-back 안 하면 워크플로우 깨짐. `AGENTS.md` (Codex adapter) 에 명시:

> "이 repository 는 dev↔stable 분리 운영. stable 에서 hotfix 시 본인이 dev staging 으로 sync-back 한 commit 도 같은 batch 로 push 할 것. 안 하면 다음 cut 시 회귀 (P-13)."

→ 본 invariant 는 별도 cycle 에서 codex AGENTS.md root 에 추가.

## 5. Recover — 사후 정합 path

### 5.1 즉시 path (단순)

`git revert <cut-commit>` → codex 의 작업 회복 → dev sync-back → 새 cut.

단점: history revert 흔적, force-push (있다면) 위험.

### 5.2 본 cycle 채택 path (roll-forward)

cut 결과는 그대로 보존 (tag 도 그대로 잔존) + 다음 cut (0.5.1-hotfix) 에서 codex narrative 를 dev 로 sync-back 하면서 정합. P-12 (legacy marker fallback) 도 같이 도입 = consumer 하위 호환.

## 6. 검증 데이터

- 본 사고 fact 모두 git log + git show 로 verify 가능 (Apr 29 23:52 ~ Apr 30 09:07 KST window).
- cut-release.sh 강화 효과는 다음 cut (`v0.5.2+` 또는 `v0.6.0-product`) 시 stable 에 codex hotfix 가 있을 때 abort 되는지 1~2 사이클 검증 후 reuse_count 갱신.

## 7. 변경 이력

- 2026-04-30 (26th-3 ε continuation 3): 신설 (status: documented, severity: high, reuse_count: 0).
