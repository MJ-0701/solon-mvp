---
pattern_id: P-10
title: stable-stale-git-lock-recovery
status: documented
severity: medium
first_observed: 2026-04-29
observed_by: affectionate-laughing-pascal   # 25번째 사이클 25th-2, 0.3.0-mvp 첫 실 release cut
resolved_at: 2026-04-29
resolved_by: affectionate-laughing-pascal + 사용자 manual
resolved_via:
  - "[1] 진단: cut-release.sh step 4 의 `git -C stable add -A` 단계에서 fatal: Unable to create '<stable>/.git/index.lock': File exists"
  - "[2] 정리: ps aux | grep git 으로 다른 git process 부재 확인 후 rm -f $STABLE_REPO/.git/index.lock"
  - "[3] manual step 4 후속 재현: git add -A + git commit -m 'release: <V>' + git tag v<V>"
  - "[4] manual step 5 dev post-flight 재현: dev/VERSION echo + dev/CHANGELOG prepend + dev commit + push"
related_wu: WU-31
related_docs:
  - 2026-04-19-sfs-v0.4/scripts/cut-release.sh    # step 4 git add 직전, line ~300
  - 2026-04-19-sfs-v0.4/sprints/WU-31.md          # Release tooling Phase 0 spec SSoT
  - 2026-04-19-sfs-v0.4/cross-ref-audit.md        # §4 W-22 후속 자동화 TODO
  - 2026-04-19-sfs-v0.4/PROGRESS.md               # 25th-2 narrative
visibility: business-only
applicability:
  - "release cut --apply 시점 stable repo .git/index.lock 잔존 사고 (1차 사례 = 25th-2)"
  - "cut-release.sh post-mortem 후속 WU 작성 시 reference"
  - "P-07 (release-tooling-phased) 의 phase 승급 검증 데이터"
reuse_count: 0   # 1회 첫 사례, reuse 발생 시 +1
related_patterns:
  - P-07-release-tooling-phased       # phase 승급 invariant SSoT
  - P-08-fuse-bypass-cp-a-broken      # git internals + sandbox 영역
  - P-09-sandbox-file-clone-isolation # host .git mutate 회피 패턴
---

# P-10 — Stable Stale `.git/index.lock` Recovery

## §1 문제

**증상**: `bash 2026-04-19-sfs-v0.4/scripts/cut-release.sh --version 0.3.0-mvp --apply` 실행 시 step 4 (Apply) 의 stable rsync + VERSION bump + CHANGELOG.md prepend 까지 정상 진행한 후, `git -C "${STABLE_REPO}" add -A` 직전에 다음 fatal error 발생:

```
fatal: Unable to create '<stable>/.git/index.lock': File exists.
Another git process seems to be running in this repository, e.g.
an editor opened by 'git commit'. Please make sure all processes
are terminated then try again. If it still fails, a git process
may have crashed in this repository earlier:
remove the file manually to continue.
```

**진행도** (사고 시점 stable + dev 양쪽 상태):
- stable rsync = ✓ 적용 완료 (27 file changed)
- stable/VERSION = ✓ 0.3.0-mvp 로 bump
- stable/CHANGELOG.md = ✓ prepend 됨 (release entry 1회)
- stable git commit = ✗ abort (index.lock 충돌)
- stable git tag = ✗ 도달 못 함
- step 5 dev post-flight = ✗ 도달 못 함 (dev/VERSION 여전히 0.2.4-mvp, dev/CHANGELOG 미변경)

**원인**: 사용자 mac 의 stable repo (`~/workspace/solon-mvp`) `.git/index.lock` 이 stale 상태로 잔존. 다른 git process 0 확인됨 — 이전 git operation 의 abort 흔적 또는 editor 가 `git commit` 시작 후 종료 안 한 상태로 추정. cut-release.sh §1 pre-flight 에 `.git/index.lock` 사전 검증 누락이 root cause (방어 부족).

## §2 해결 패턴 (manual 4-step recovery)

```bash
# (1) stale lock 제거 (다른 git process 0 확인 후)
cd ${STABLE_REPO}
ps aux | grep -i git    # 다른 git process 부재 확인
rm -f .git/index.lock

# (2) cut-release.sh step 4 후속 manual 재현 (commit + tag)
git status --short      # rsync 결과 확인 (~27 file 변경)
git add -A
git commit -m "release: ${VERSION}"
STABLE_SHA=$(git rev-parse HEAD)
git tag "v${VERSION}" "${STABLE_SHA}"

# (3) stable push (cut-release.sh 가 push 안 함, §1.5 정합)
git push origin main
git push origin "v${VERSION}"

# (4) cut-release.sh step 5 dev post-flight manual 재현
cd ${DEV_REPO_ROOT}
TODAY=$(TZ='Asia/Seoul' date +%Y-%m-%d)
echo "${VERSION}" > ${DEV_STAGING}/VERSION
TMPFILE=$(mktemp)
{
  printf '## [%s] - %s\n\n' "${VERSION}" "${TODAY}"
  printf -- '- (release cut → stable %s)\n\n' "${STABLE_SHA:0:7}"
  cat ${DEV_STAGING}/CHANGELOG.md
} > "${TMPFILE}"
mv "${TMPFILE}" ${DEV_STAGING}/CHANGELOG.md
git status --short
git add ${DEV_STAGING}/VERSION ${DEV_STAGING}/CHANGELOG.md
git commit -m "WU-31/cut(stable): v${VERSION} ${STABLE_SHA:0:7}"
git push origin main
```

## §3 재사용 체크리스트

- [ ] cut-release.sh --apply 직전 `ls -la <stable>/.git/index.lock` 사전 확인
- [ ] 충돌 발생 시 `ps aux | grep git` 으로 다른 git process 부재 확인 후 `rm -f .git/index.lock`
- [ ] manual 복구 시 stable rsync 가 이미 끝났는지 (`git status --short` 의 modified count) 확인
- [ ] CHANGELOG.md 가 한 번만 prepend 됐는지 (`head -10 stable/CHANGELOG.md` 에 release entry 1회) — cut-release.sh 재실행 시 dedupe 없어 중복 prepend 위험
- [ ] step 5 dev post-flight 도달 여부 = `cat dev/VERSION` 첫 줄 비교 (이전 0.2.4-mvp vs 현재 0.3.0-mvp)

## §4 관련 WU·세션

- **신설 WU**: WU-31 (Release tooling Phase 0 = cut-release.sh + sync-stable-to-dev.sh + check-drift.sh 3 sh)
- **첫 사례**: 25th-2 affectionate-laughing-pascal (2026-04-29 10:30~11:00 KST), 0.3.0-mvp 첫 실 release cut
- **관련 P-pattern**: P-07 (release-tooling-phased) 의 reuse_count +1 = 본 사고가 P-07 의 phase 승급 검증 invariant 의 실 가치 입증
- **사고 영향**: 사용자 자산 mutate 없음 (rsync/commit 모두 stable repo, 사용자 manual 복구 가능). dev/stable 양쪽 100% 정합 후 진행.

## §5 후속 자동화 후보 (W-22 TODO)

- **WU-31.x refresh** 또는 별도 후속 WU 에서 cut-release.sh §1 pre-flight 보강:
  - `[[ -f "${STABLE_REPO}/.git/index.lock" ]] && abort_with_hint`
  - `[[ -f "${DEV_REPO_ROOT}/.git/index.lock" ]] && warn` (dev side 충돌은 step 5 영향)
  - stable working tree strict clean (`git -C stable status --porcelain --ignored | grep -q .` 류)
- 처리 시점 = 26번째+ 사이클 사용자 결정 영역. β default = WU-31.x refresh (1줄 sed 패치 ~5분, cut-release.sh §1 함수 안 if-block 추가).

## §6 Notes

- **변종 1**: dev side `.git/index.lock` 충돌 — cut-release.sh step 5 의 dev/VERSION echo + CHANGELOG prepend 시 발생 가능. 본 사례는 stable-side 만 발견, dev-side 변종은 미관측 (관측 시 본 P-10 reuse_count +1 + 변종 §1.1 추가).
- **변종 2**: cut-release.sh 자체의 이전 abort 흔적 (signal interrupt + `.git/index.lock` 잔존) — 본 사례는 사용자 mac 의 alien 흔적, cut-release.sh 자체는 idempotent 의도. 단 step 4 git add ~ commit 사이가 atomic 이 아니므로, 두 번째 호출 시 변종 1 (CHANGELOG 중복 prepend) 발생 위험 = manual 복구 권장 사유.
- **자동 감지**: 후속 GitHub Action drift 알림 (WU-32) 에 release cut 사고 detection rule 추가 가능 (탑재 우선순위 ↓).
