---
pattern_id: P-08-fuse-bypass-cp-a-broken
title: "FUSE 마운트 위 `cp -a .git` 부분 누락 + `rsync back --delete` 가 host repo 깨뜨림 — low-level git plumbing fallback + sandbox file:// clone 격리"
status: resolved
severity: high
first_observed: 2026-04-25
observed_by: dazzling-sharp-euler (23번째 세션 후반, WU-31 신설 spec only commit 시도 중 `.git/index.lock` 0-byte stale 충돌 → §1.6 FUSE bypass `cp -a .git` 시도 → cp 단계 일부 파일 누락 → `rsync back --delete` 가 깨진 .git 으로 host 덮어씀 → `refs/heads/main` 옛 commit `54ac583` 으로 회복 사고 발생)
resolved_at: 2026-04-25
resolved_by: dazzling-sharp-euler (23번째 세션, ref 직접 덮어쓰기 + `GIT_INDEX_FILE` 우회 read-tree 로 깨끗한 index 재생성 — 단 commit 자체는 못 함, .git/index.lock unlink FUSE 거부, 사용자 manual 필요) + 사용자 (24th 사이클 진입 직전 mac terminal manual commit + push, working copy 살아 있어서 그대로 add+commit+push 로 복원, 24th 진입 시 git ahead=0 확인)
resolved_via: |
  (1) **사후 복구 절차** = ref 직접 덮어쓰기 (`echo <good-sha> > .git/refs/heads/main`) + `GIT_INDEX_FILE=/tmp/idx-clean git read-tree HEAD` 로 깨끗한 index 재생성 → working copy 보존 검증 (`git status` HEAD 일관성 + 23rd 산출물 4 파일 무결) +
  (2) **재발 방지 §1.5' commit-manual 격상 (24th 첫 작업)** — AI 는 host repo `.git` mutate 안 함 (file 편집 + sandbox `file://` clone 안 commit 까지만), `git add/commit/push origin *` 모두 사용자 터미널 수동 (P-09 sandbox-file-clone-isolation 와 짝) +
  (3) **§1.6 FUSE bypass 절차 retire** — 23rd 후반 사고 이후 `cp -a $SRC/.git $TMP/` 패턴은 우선순위 ↓ (FUSE 환경 partial copy 위험 검출됨, 21st 작동 / 23rd 깨짐 = 환경/race 의존, 신뢰도 ↓) + low-level git plumbing fallback (`GIT_INDEX_FILE` / `git write-tree` / `git commit-tree` / `git update-ref`) 우선 +
  (4) **`rsync back --delete` 절대 금지** — 단방향 파괴적 동기화는 source (`/tmp/solon-git-<ts>/`) 가 partial copy 일 때 destination (host `.git`) 을 깨뜨림. mirror 의도라도 `--delete` 빼고 `rsync -a` 만, 또는 dry-run (`-n`) 후 cherry-pick.
related_wu: WU-31 (23rd 세션 신설 spec only — commit 시도 단계에서 본 사고 발생) + (간접) WU-22 / WU-30 / WU-24 (24th 사이클 진입 시 사고 후속 영향 = §1.5' 격상 결정)
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.5' (commit-manual 격상, 24th 첫 작업)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.6 (FUSE bypass 원본 — 본 사고 이후 retire 권고)
  - outputs/23rd-session-backup/ (사고 직후 작성된 4 파일 = WU-31.md / _INDEX.md / PROGRESS.md / RECOVERY.md, working copy 죽었을 시 복원 fallback)
  - outputs/23rd-session-backup/RECOVERY.md (사용자 manual 복구 절차 + commit 명령 SSoT)
  - 2026-04-19-sfs-v0.4/PROGRESS.md released_history.last_reason "23번째 세션 ... .git/index.lock FUSE bypass 사고 (P-08 후보, 복구 완료, commit 사용자 manual)"
  - git commit `10f5e8f` (23rd 마지막 push, 24th 진입 시 git ahead=0 확인 = 사용자 mac terminal manual commit + push 로 복원 완료)
visibility: raw-internal
applicability:
  - "Cowork / FUSE 마운트 위에서 host repo `.git/index.lock` 또는 다른 lock 파일 stale 충돌 발생"
  - "`cp -a $SRC/.git $TMP/` 등 디렉토리 wholesale copy 후 sanity check 없이 작업 진행"
  - "`rsync -a --delete` 단방향 파괴적 mirror back 시도 (특히 source 가 cp -a 산출물일 때)"
  - "23rd 사이클 중반~후반 commit 시도 단계에서 lock 충돌 발생 (large WU 다수 wip commit 누적 + FUSE race)"
reuse_count: 1   # 23rd 1회 발생. 24th 부터 §1.5' 격상으로 host .git mutate 자체를 안 함 = 본 패턴 재발 가능성 ↓ (P-09 sandbox-file-clone-isolation 와 함께 원천 차단).
related_patterns:
  - P-03   # staged-uncommitted-on-session-crash (작업 유실 패턴, 본 사고도 staged 잔존 위험 발생)
  - P-09   # sandbox-file-clone-isolation (P-08 의 직접적 후속 = host .git mutate 안 하기, 23rd 사용자 결정)
---

# P-08 — fuse-bypass-cp-a-broken

> **visibility: raw-internal** — 사용자 운영 환경 (Cowork FUSE 마운트) + 23rd 사용자 codename + 내부 host repo 사고 narrative 포함. OSS 마케팅 프로덕트에는 미공개. 단 핵심 패턴 (FUSE 위 cp -a 신뢰도 ↓, rsync --delete 금지, low-level git plumbing fallback) 은 일반 노하우라 향후 OSS 승급 검토 후보 — 사고 narrative 만 떼어내고 추상화 시 `business-only` 또는 `oss-public` 가능.

---

## 문제

`.git/index.lock` 등 git 내부 lock 파일이 FUSE 마운트 race 로 0-byte stale 잔존 시 host repo 의 `git add/commit` 이 무한 wait 또는 fail. §1.6 (FUSE bypass) 의 표준 절차 = `cp -a .git /tmp/solon-git-<ts>/` → `/tmp/` 안에서 작업 → `rsync back` 으로 host 동기화. 그러나 23rd 세션 후반 (WU-31 신설 spec only commit 시도 중) 본 절차가 catastrophic failure 로 이어짐.

- **증상 (23rd 세션 후반 timeline 재구성)**:
  1. `.git/index.lock` 0-byte stale 잔존 → `git add/commit` 무한 wait.
  2. §1.6 FUSE bypass 절차 시도 → `cp -a $SRC/.git /tmp/solon-git-<ts>/` 실행 (정상 종료, exit 0).
  3. `/tmp/solon-git-<ts>/` 안에서 `git commit` 시도 → 일부 ref/object 가 누락되어 git operation 실패 또는 일관성 깨짐 발견.
  4. `rsync -a --delete /tmp/solon-git-<ts>/ $SRC/.git/` (back) 실행 → host `.git` 이 partial copy 의 deletion 까지 받아들여 `refs/heads/main` 이 옛 commit `54ac583` (수일 전) 로 reset.
  5. `git log` 확인 시 23rd 세션 산출물 (WU-31 신설 + PROGRESS 갱신 다수) 이 commit graph 에서 사라진 것처럼 보임 (실제로는 reflog 에 살아 있음, packed objects 도 무결).
- **발생 조건**: (a) Cowork FUSE 마운트 위 host repo + (b) `.git/index.lock` stale 잔존 (이전 세션 abnormal termination 또는 race) + (c) 디렉토리 wholesale copy `cp -a .git` 사용 시 FUSE 가 일부 파일/symlink/permission 을 누락하는 케이스 발견 (21st 세션엔 작동, 23rd 엔 깨짐 = 환경/race 의존, 재현성 낮음) + (d) sanity check 없이 `rsync back --delete` 단방향 파괴적 동기화.
- **원인**:
  - **근본 원인**: FUSE 마운트의 `cp -a` 동작이 native filesystem 와 100% 동치 아님 (특히 git pack files, refs symlink, object loose files 의 atomicity 보장 안 됨). 21st 세션은 운 좋게 통과, 23rd 는 race 로 partial copy 발생.
  - **증폭 원인**: `rsync -a --delete` 의 `--delete` flag 가 source (partial) 의 결손을 destination (정상 host) 으로 propagate. mirror 의도가 host 데이터 파괴로 변환됨.
  - **트리거 원인**: 23rd 세션이 multiple wip commit 누적 + FUSE race 에 노출 (사용자 부재 자율 진행 mode 가 아니었음에도 세션 길이 + commit 빈도 ↑).
- **영향**:
  - host `.git/refs/heads/main` 이 `54ac583` (수일 전 commit) 로 reset, 23rd 산출물 commit graph 표면에서 사라짐 (reflog/objects 는 보존).
  - 이후 commit 시도 시 working copy ↔ HEAD ↔ index 3중 불일치 발생, 정상 commit 경로 차단.
  - 사용자 mac terminal 까지 가야 manual recovery 가능 → `outputs/23rd-session-backup/RECOVERY.md` 작성 + 4 파일 백업 (WU-31.md / _INDEX.md / PROGRESS.md / RECOVERY.md).
  - 23rd → 24th 사이클 진입 시 미완 commit 잔존 위험 (다행히 working copy 살아 있어서 사용자 mac terminal manual commit + push 로 복원, 24th 진입 시 git ahead=0 확인).

## 해결 패턴

### 사후 복구 절차 (이미 사고 발생 시)

> **순서 중요**: ref 복원 먼저 → index 재생성 → working copy 검증 → commit 은 사용자 manual.

1. **reflog 확인** — `git reflog show --all | head -20` 로 잃어버린 commit 들 확인 (sha 추출).
2. **good ref 직접 덮어쓰기** — `echo <good-sha> > .git/refs/heads/main` (또는 `git update-ref refs/heads/main <good-sha>` 가능 시 선호, lock 충돌 회피).
3. **clean index 재생성** — `GIT_INDEX_FILE=/tmp/idx-clean git read-tree HEAD` → host `.git/index` 손대지 않고 임시 index 생성.
4. **working copy 무결성 검증** — `git status` 결과 일관성 + 산출물 파일 (예: 23rd 의 WU-31.md 등) hash 비교.
5. **백업 작성** — `outputs/<session-id>-session-backup/` 에 핵심 산출물 4 파일 + `RECOVERY.md` (manual commit 명령 + push 절차 SSoT).
6. **commit 은 사용자 manual** — `.git/index.lock` unlink 가 FUSE 환경에서 거부될 수 있음, 사용자 mac terminal 에서 native filesystem path 로 `rm -f .git/index.lock` + `git add` + `git commit -F outputs/<session-id>-session-backup/COMMIT-MSG.txt` + `git push origin main`.

### 재발 방지 (24th 부터 적용, §1.5' + P-09 짝)

- **§1.5' commit-manual 격상**: AI 는 host repo `.git` mutate 안 함. file 편집 + sandbox `file://` clone 안 commit 까지만.
- **sandbox file:// clone 격리 (P-09)**: 모든 git 작업은 `git clone file://$SRC /tmp/work-NN-clone` 안에서. 결과물은 patch 또는 push back, host `.git` 0 mutation 보장.
- **§1.6 FUSE bypass `cp -a .git` 절차 retire**: 우선순위 ↓. 사용 시 mandatory sanity check (`git -C $WORKDIR log -1` + `git fsck` 통과 후 작업).
- **`rsync --delete` 절대 금지**: source 가 partial 일 가능성 있는 환경에선 mirror 단방향 파괴적 동기화 안 함. `rsync -a` (no `--delete`) + 사후 stale 수동 정리 only.
- **low-level git plumbing fallback**: lock 충돌 시 `cp -a` 없이 `GIT_INDEX_FILE=<tmp> git read-tree`, `git write-tree`, `git commit-tree`, `git update-ref` 직접 호출. lock 회피 + atomicity 보장.

### 샘플 명령 / 코드

```bash
# 1. 사후 복구 (reflog 확인)
git reflog show --all | head -20
# → 잃어버린 commit sha 추출 (예: 23rd 마지막 wip = 10f5e8f)

# 2. ref 직접 덮어쓰기 (lock 회피)
echo "10f5e8f" > .git/refs/heads/main

# 3. clean index 재생성 (host index 손대지 않음)
GIT_INDEX_FILE=/tmp/idx-clean git read-tree HEAD
GIT_INDEX_FILE=/tmp/idx-clean git status

# 4. working copy 무결성 검증
git status   # HEAD 일관성 확인
git fsck --no-reflogs
sha256sum 2026-04-19-sfs-v0.4/sprints/WU-31.md   # 산출물 hash 일치 확인

# 5. 백업 (working copy 죽었을 시 fallback)
mkdir -p outputs/23rd-session-backup
cp 2026-04-19-sfs-v0.4/sprints/WU-31.md outputs/23rd-session-backup/
cp 2026-04-19-sfs-v0.4/sprints/_INDEX.md outputs/23rd-session-backup/
cp 2026-04-19-sfs-v0.4/PROGRESS.md outputs/23rd-session-backup/
# RECOVERY.md = manual commit 절차 SSoT 작성

# 6. (사용자 mac terminal manual)
rm -f .git/index.lock
git add 2026-04-19-sfs-v0.4/sprints/WU-31.md 2026-04-19-sfs-v0.4/sprints/_INDEX.md 2026-04-19-sfs-v0.4/PROGRESS.md
git commit -F outputs/23rd-session-backup/COMMIT-MSG.txt
git push origin main
```

### 24th+ 부터 권장 (§1.5' + P-09)

```bash
# AI 는 host .git 에 손 안 댐. 작업은 sandbox file:// clone 에서.
SRC="/Users/mj/agent_architect"
TMP="/tmp/work-NN-clone"
git clone "file://$SRC" "$TMP"
cd "$TMP"
# ... edit + commit ...
# 사용자 검토 후 host 로 push back (사용자 manual)
```

## 재사용 체크리스트

- [ ] 전제 조건 확인: Cowork / FUSE 마운트 환경 + host repo `.git` lock 충돌 (특히 `index.lock` 0-byte stale).
- [ ] 1차 옵션: §1.5' (24th+) 정합 — host `.git` mutate 안 함, sandbox `file://` clone 으로 작업 (P-09).
- [ ] 2차 옵션 (사고 이미 발생 시): low-level git plumbing 사후 복구 (ref 덮어쓰기 + `GIT_INDEX_FILE` clean index + 사용자 manual commit).
- [ ] 3차 옵션 (legacy §1.6 FUSE bypass `cp -a` 사용 시): mandatory sanity (`git -C $WORKDIR log -1` + `git fsck`) 통과 후만 작업. `rsync back --delete` 절대 금지 (`rsync -a` only, 또는 dry-run `-n` 후 cherry-pick).
- [ ] 백업 작성: 작업 산출물 핵심 파일 + `RECOVERY.md` (manual commit 절차 SSoT) 를 `outputs/<session-id>-session-backup/` 에 저장. working copy 죽었을 시 fallback.
- [ ] 사이드 이펙트 검토: reflog 보존 확인 (잃어버린 commit 들 sha 추출 가능), `git fsck` 통과, working copy ↔ HEAD ↔ index 3중 일관성 검증.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부: 사후 복구 자체는 mechanical (잃어버린 ref 복원만), 의미 결정 아님. 단 "어느 ref 까지 복원할지" (예: 부분 wip 까지 vs 마지막 stable 까지) 가 모호 시 사용자 confirm 필요.

## 관련 WU / 세션

- **최초 발견**: 23번째 세션 `dazzling-sharp-euler` (2026-04-25, user-active). WU-31 신설 spec only commit 시도 중 발생.
- **사후 복구**: 같은 23번째 세션 후반에 ref 직접 덮어쓰기 + `GIT_INDEX_FILE` clean index 로 working copy 무결성 보존 후, `outputs/23rd-session-backup/` 4 파일 작성. commit 자체는 사용자 mac terminal manual.
- **재발 방지 결정**: 24번째 사이클 진입 직전 사용자 결정 = "가상화 = 단기 α 변형 (sandbox `file://` clone) + 장기 ε (VM)" + "§1.5' commit-manual 격상" (CLAUDE.md §1.5 1줄 수정 = 24th 첫 작업). P-09 (sandbox-file-clone-isolation) 와 짝.
- **재사용 / 재발견**: 미발생 (24th 시점 1회 사고만). 24th 부터 §1.5' 정합 = AI host `.git` mutate 0 = 본 패턴 재발 가능성 ↓.

## Notes

- **OSS 미공개 (raw-internal)**: 23rd 사용자 codename + 사고 narrative + outputs/ 백업 경로 + 24th 결정 = 사용자 운영 데이터. 핵심 패턴 (FUSE 위 `cp -a` 신뢰도 ↓, `rsync --delete` 금지, low-level git plumbing fallback) 만 분리 + 사고 narrative 추상화 시 OSS 승급 후보 (별도 일반 패턴 문서로 추출 권장).
- **상위 규율**: §1.5' (commit-manual, 24th 격상, AI host `.git` mutate 0) + §1.6 (FUSE bypass 원본, 본 사고 이후 retire 권고) + §1.8 (작업 유실 최소화, 백업 작성 강제력 보강) + §1.13 R-D1 (dev-first, stable 동기화는 별도 sh 로 — sync-stable-to-dev.sh 등 cut-release 도구가 host `.git` mutate 안 하도록 sandbox 또는 git plumbing 우선).
- **관련 패턴**:
  - P-03 (staged-uncommitted-on-session-crash): 본 사고도 staged 잔존 위험 (사용자 manual commit 전까지 미반영). P-03 의 staged-diff 패턴 재사용으로 사용자 mac terminal commit 시 일관성 확보.
  - **P-09 (sandbox-file-clone-isolation)**: 본 P-08 의 직접적 재발 방지 패턴. host `.git` mutate 안 함, `file://` clone 격리. 23rd 사용자 결정 = 단기 α 변형 (sandbox), 장기 ε (VM). P-08 + P-09 가 한 쌍 (사후 복구 + 재발 방지).
- **변종 / 후속 작업 후보**:
  - **변종 1**: `cp -a` 대신 `rsync -a --no-delete` 사용 (FUSE partial copy 위험 지속 → 신뢰도 여전히 낮음). 우선순위 ↓.
  - **변종 2**: native filesystem path (Cowork FUSE 우회 = `/private/...` macOS 직접 접근) 에서 작업. 사용자 manual mac terminal 에서만 가능 (Claude session 안에서는 FUSE mount 만 보임).
  - **자동 감지 후속 작업 후보**:
    - `scripts/check-git-fuse-health.sh` 신설 → `.git/index.lock` stale (TTL > 1분) 검출 + `cp -a .git` 후 sanity (`git fsck`) 자동 검증. 0.4.0-mvp 후보 (현 우선순위 낮음, §1.5' 격상으로 자체 회피 가능하므로).
    - `scripts/recovery-from-broken-ref.sh` 신설 → reflog 자동 추출 + ref 덮어쓰기 + `GIT_INDEX_FILE` clean index 재생성을 idempotent 하게 자동화. 0.5.0-mvp 후보.
  - **분리 파일 visibility tier**: 본 P-08 raw-internal default. 사고 narrative 분리 + 추상 패턴만 추출 시 OSS 승급 가능 (별도 패턴 문서로 추출, 본 P-08 은 사용자 운영 trace 보존용으로 raw-internal 유지).
