---
doc_id: scripts-readme
title: "Solon v0.4-r3 · scripts/ 사용 가이드 (WU-31 신설 3 sh + 기존 helper 4 sh)"
version: 0.1
created: 2026-04-27
updated: 2026-04-27
visibility: business-only   # 운영자 도구 가이드. OSS fork 동봉 여부는 후속 결정 (WU-31 decision_points (1)).
wu_origin: WU-31            # 본 문서 자체는 WU-31 §7 row 8 산출물.
---

# `scripts/` 사용 가이드

본 디렉토리는 Solon v0.4-r3 docset 운영용 helper sh 모음이다. **7개 sh** = WU-31 신설 3개 (release tooling) + 기존 4개 (mutex / scheduled / snapshot / squash). 모든 sh 는 repository root (`agent_architect/` 가 아니라 `2026-04-19-sfs-v0.4/`) 에서 호출하는 것을 기본 가정으로 작성됨.

> ⚠️ **§1.5' 정합 (24th 격상)** — AI 는 본 sh 들을 **호출만** 하며, 그 결과로 발생하는 host repo `git add/commit/push` 는 모두 사용자 터미널 manual. AI 가 sandbox `file://` clone 안에서 dry-run 검증하는 것은 허용 (host `.git` mutate 0).

---

## 한눈에 보기

| sh | 역할 | 호출 빈도 | 위험도 | WU |
|:---|:---|:---|:---|:---|
| **cut-release.sh** | dev → stable 정방향 release sync (VERSION bump + CHANGELOG + tag) | release cut 직전 1회 | 중 (`--apply` 시 stable commit + tag 생성) | WU-31 §2 |
| **sync-stable-to-dev.sh** | stable → dev 역방향 hotfix back-port | hotfix 발생 시 (드묾) | 저 (dev `git add` 까지만, commit 사용자) | WU-31 §3 |
| **check-drift.sh** | dev↔stable diff preview (변경 0) | 매일 / release cut 직전 | 0 (read-only) | WU-31 §5 |
| append-scheduled-task-log.sh | hourly cron 진입 시 PROGRESS scheduled_task_log 한 줄 append | scheduled run 매 시간 | 저 | (17번째 신설) |
| resume-session-check.sh | 세션 진입 직후 sanity check (P-03 / sha / drift / TTL) | 매 세션 1회 | 0 (감지만) | (15번째 신설) |
| snapshot.sh | 15분 / 이벤트 단위 file-level snapshot | 자동 cron / 수동 | 저 | (workflow v2 §10) |
| squash-wu.sh | WU 완료 시 wip 커밋 squash | WU close 시 1회 | 중 (interactive rebase) | (workflow v2 §8) |

---

## 1. WU-31 신설 — Release tooling (3 sh)

### 1.1 `cut-release.sh` — 정방향 release cut (dev → stable)

dev staging (`solon-mvp-dist/`) 의 allowlist 8 파일 + templates/ 디렉토리를 stable repo (`~/workspace/solon-mvp/`) 로 sync 하고 VERSION bump + CHANGELOG entry + (옵션) tag 생성. **push 는 안 함** (§1.5 정합).

```sh
# dry-run (default — 변경 0, preview 만)
bash scripts/cut-release.sh --version 0.3.0-mvp

# 실 적용 — stable commit + tag v0.3.0-mvp 생성
bash scripts/cut-release.sh --version 0.3.0-mvp --apply

# tag 안 만들고 commit 만
bash scripts/cut-release.sh --version 0.3.0-mvp --apply --no-tag

# stable repo 에 uncommitted 변경 있어도 강행
bash scripts/cut-release.sh --version 0.3.0-mvp --apply --allow-dirty
```

**Allowlist (현 hard-coded 파일/디렉토리)**:
- VERSION · CHANGELOG.md · README.md · 10X-VALUE.md · CLAUDE.md · AGENTS.md · GUIDE.md · install.sh · install.ps1 · upgrade.sh · upgrade.ps1 · uninstall.sh · uninstall.ps1 · templates/ · bin/ · packaging/ · .github/ (recursive where directory)

**Blocklist (1 파일, stable 잔존 시 leak 검출)**:
- APPLY-INSTRUCTIONS.md (dev staging 전용 운영자 instruction)

**Exit codes**: 0=성공 / 1=invalid usage 또는 allowlist 위반 / 2=dev missing / 3=stable missing / 4=stable git not clean (without `--allow-dirty`) / 5=TBD final_sha 검출 (release blocker — `final_sha: TBD_*` WU 잔존) / 99=unknown.

**TBD final_sha 안전망**: `--apply` 시 sprints/ 안에 `final_sha: TBD_*` placeholder 가 남아있으면 abort (exit 5). dry-run 시에는 warn-only proceed.

**Push 는 사용자 manual** — sh 종료 후 출력되는 hint 그대로:
```sh
cd ~/workspace/solon-mvp
git push origin main && git push origin --tags
```

### 1.2 `sync-stable-to-dev.sh` — 역방향 hotfix back-port (stable → dev)

stable 에서 발견된 hotfix (R-D1 §1.13 예외 path) 를 dev staging 으로 back-port. dev `git add` 까지만, commit 은 사용자 manual (`WU-31/sync(stable): <sha>` 표준).

```sh
# dry-run (default)
bash scripts/sync-stable-to-dev.sh --stable-sha abc1234

# 실 적용 — dev 에 cp + git add + CHANGELOG hotfix entry prepend
bash scripts/sync-stable-to-dev.sh --stable-sha abc1234 --apply

# CHANGELOG 안 건드림
bash scripts/sync-stable-to-dev.sh --stable-sha abc1234 --apply --no-changelog
```

**동작**: stable repo 에서 `git show --name-only <sha>` 로 변경 파일 추출 → cut-release.sh 와 동일 allowlist + blocklist 검증 → allowed 만 cp + dev `git add` + CHANGELOG hotfix entry prepend.

**안전망**: blocklist hit 시 WARN + sync skip. allowlist 외 파일은 silent skip.

**Exit codes**: 0=성공 / 1=invalid usage / 2=dev missing / 3=stable missing / 4=stable-sha invalid 또는 not in repo / 99=unknown.

### 1.3 `check-drift.sh` — drift preview helper (read-only)

dev ↔ stable diff 한눈 가시화. **`--apply` 플래그 없음** — 영구히 dry-run only. release cut 직전 / 매일 health check 용.

```sh
# 표준 출력 (verbose preview)
bash scripts/check-drift.sh

# summary 1줄만 (cron / dashboard 용)
bash scripts/check-drift.sh --quiet

# stable repo 경로 override
SOLON_STABLE_REPO=/custom/path bash scripts/check-drift.sh
```

**출력 예시**:
```
M VERSION (dev: 0.3.0-mvp / stable: 0.2.4-mvp)
M CHANGELOG.md (~8 diff lines)
A templates/sfs-common.sh (dev only, stable 없음)
D templates/old.txt (stable only, dev 없음)
─────────────────────────
drift=4  identical=4  leak=0
```

**Status 마커**:
- `M` = modified (양쪽 존재, 내용 다름)
- `A` = added (dev only, 다음 cut 에서 stable 로 추가됨)
- `D` = deleted (stable only, 다음 cut 에서 stable 에서 삭제될 예정)

**Exit codes**: 0=no drift / 1=invalid usage / 2=dev missing / 3=stable missing / 8=drift 존재 (정상 preview) / 9=leak 검출 (BLOCKLIST hit, release blocker) / 99=unknown.

---

## 2. 표준 워크플로우

### 2.1 정상 release cut (가장 흔한 경로)

```sh
# 1. 현 drift 확인
bash scripts/check-drift.sh
#    → 의도한 변경만 있는지 사용자 검토

# 2. dry-run cut — preview
bash scripts/cut-release.sh --version 0.3.0-mvp
#    → "6 modified, stable VERSION 0.2.4-mvp → 0.3.0-mvp" 같은 summary 출력

# 3. 실 적용
bash scripts/cut-release.sh --version 0.3.0-mvp --apply
#    → stable commit + tag 생성 (push 안 함)

# 4. 사용자 manual push (별도 터미널)
cd ~/workspace/solon-mvp
git push origin main && git push origin --tags

# 5. dev-side post-flight VERSION/CHANGELOG bump 은 cut-release.sh 가 자동 처리
#    → 사용자가 dev 에서 commit (§1.5')
cd ~/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist
git add VERSION CHANGELOG.md
git commit -m "WU-31/cut(stable): v0.3.0-mvp <stable-sha>"
```

### 2.2 Product channel publish (Homebrew + Scoop)

`-product` release 는 stable tag push 만으로 끝나지 않는다. 사용자가 "배포" 라고 말하면
release owner 는 **Homebrew tap 과 Scoop bucket 을 모두 같은 tag 로 publish** 한 뒤에만 완료
보고한다. 한쪽만 끝난 상태는 partial release 다.

```sh
# 1. product tag 가 원격에 존재하는지 확인
git -C ~/tmp/solon-product ls-remote --tags origin v<VERSION>

# 2. Homebrew tap 갱신 + push
#    Formula/sfs.rb url 은 v<VERSION>.tar.gz, sha256 은 해당 tarball hash.
cd ~/tmp/homebrew-solon-product
git status --short --branch
# edit Formula/sfs.rb
git add Formula/sfs.rb
git commit -m "sfs <VERSION>"
git push origin main

# 3. Scoop bucket 갱신 + push
#    bucket/sfs.json url 은 v<VERSION>.zip, hash 는 해당 zip SHA256.
cd ~/tmp/scoop-solon-product
git status --short --branch
# edit bucket/sfs.json
git add bucket/sfs.json
git commit -m "sfs <VERSION>"
git push origin main

# 4. 완료 전 확인
git -C ~/tmp/homebrew-solon-product ls-remote origin refs/heads/main
git -C ~/tmp/scoop-solon-product ls-remote origin refs/heads/main
```

최소 검증 기준: product tag 원격 존재, Homebrew formula URL+sha 가 tag tarball 과 일치,
Scoop manifest URL+hash 가 tag zip 과 일치, 두 channel repo `origin/main` 에 반영.

### 2.3 Hotfix back-port (R-D1 예외 path)

```sh
# 1. stable 에서 직접 hotfix commit (사용자, 별도 터미널)
cd ~/workspace/solon-mvp
# … fix … then commit
HOTFIX_SHA=$(git rev-parse HEAD)

# 2. AI / 사용자가 dev 로 back-port
bash scripts/sync-stable-to-dev.sh --stable-sha "$HOTFIX_SHA"
#    → dry-run preview

bash scripts/sync-stable-to-dev.sh --stable-sha "$HOTFIX_SHA" --apply
#    → dev 에 cp + git add + CHANGELOG entry prepend

# 3. 사용자 manual commit (dev)
cd ~/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist
git commit -m "WU-31/sync(stable): $HOTFIX_SHA"

# 4. 사용자 manual push
git push origin main
```

### 2.4 정기 health check (자동화 후보)

```sh
# 매일 / 매 PR 직전
bash scripts/check-drift.sh --quiet
# exit 8 (drift 존재) 은 정상 — 0/9 만 모니터링하면 leak 차단 효과
```

후속 WU-32 (Phase 1 GitHub Action) 에서 본 호출을 cron + Slack 알림 layer 로 이전 예정.

---

## 3. 기존 helper (4 sh, 참고용)

### 3.1 `append-scheduled-task-log.sh` — scheduled run trace

매 hourly scheduled run 진입 시 PROGRESS.md frontmatter `scheduled_task_log` 에 한 줄 entry append + N=20 rolling tail.

```sh
bash scripts/append-scheduled-task-log.sh \
  --codename "<adj-adj-name>" \
  --check-exit "<int>" \
  --action "<1줄 요약>" \
  --ahead-delta "<+N>"
```

17번째 세션 (admiring-fervent-dijkstra) 신설. 24번째 부터 §1.5' 격상으로 file 편집만 (commit 안 함, ahead_delta 는 보고용 placeholder).

### 3.2 `resume-session-check.sh` — 세션 sanity check

세션 진입 직후 1회 실행. **감지만 함, 자동 복구 없음** (원칙 2 self-validation-forbidden 정합).

```sh
bash scripts/resume-session-check.sh
# exit 0 = clean / 0 이외 = 원인 PROGRESS 기록 후 종료 (scheduled run 정합)
```

7 checks: staged/untracked 유실 / TBD placeholder / mutex TTL drift / FUSE index.lock / `<sha>` angle-bracket / scheduled_task_log drift (90분 threshold).

### 3.3 `snapshot.sh` — file-level auto-snapshot

WU 진행 중 compact / FUSE 장애 / 네트워크 유실 대비 마지막 안정 상태 보관.

```sh
bash scripts/snapshot.sh "event:wu-transition"
bash scripts/snapshot.sh "time:15min"
bash scripts/snapshot.sh "event:micro-step-complete"
```

저장 위치: `/tmp/solon-snapshots-<session>/<ISO>/` 1차 + FUSE 2차 (2-step). cleanup = 24시간 + non-event 자동 삭제.

### 3.4 `squash-wu.sh` — WU 완료 시 wip 커밋 squash

```sh
bash scripts/squash-wu.sh WU-15           # 실 squash
bash scripts/squash-wu.sh WU-15 --dry-run # preview
```

**§1.5' 격상 후 24th 부터 사용 빈도 ↓** — AI 가 commit 자체를 안 하므로 wip 가 거의 안 쌓임. 그래도 사용자 manual commit 시 prefix 가 `wip(...)` 인 history 가 누적되면 본 sh 로 정리.

---

## 4. R-D1 + visibility 정합

| sh | dev (`scripts/`) | stable (`~/workspace/solon-mvp/`) | 비고 |
|:---|:-:|:-:|:---|
| cut-release.sh | ✅ | ❌ | 운영자 도구 (business-only) |
| sync-stable-to-dev.sh | ✅ | ❌ | 동상 |
| check-drift.sh | ✅ | ❌ | 동상 |
| append-scheduled-task-log.sh | ✅ | ❌ | 동상 |
| resume-session-check.sh | ✅ | ❌ | 동상 |
| snapshot.sh | ✅ | ❌ | 동상 |
| squash-wu.sh | ✅ | ❌ | 동상 |

**모든 sh = dev only.** stable 에는 동봉 안 함 (현 시점). OSS 공개 시 fork user 도 자기 dev↔stable 운영 시 활용 가능하다면 `oss-public` 으로 승격 검토 (WU-31 decision_points (1) 후속).

`.visibility-rules.yaml` 에서 `scripts/**` 는 frontmatter visibility 미존재 시 default exclude (24th-21 row 7 `enforcement_active=true` 활성). 단 동적 read 는 후속 WU-32 / WU-33 에서 처리 (현재는 cut-release.sh / sync-stable-to-dev.sh / check-drift.sh 모두 8 allowlist + 1 blocklist hard-coded).

---

## 5. Phase 분할 (WU-31 §1)

| Phase | 범위 | 트리거 | 상태 |
|:-:|:---|:---|:-:|
| **Phase 0** | 본 디렉토리 3 sh + `.visibility-rules.yaml` declaration | 사용자 명시 호출 | ✅ 본 WU-31 (24th-17~21 신설) |
| Phase 1 | GitHub Action: drift 알림 (실 sync 안 함) | source push to main | ⏭️ WU-32 (가칭, 후속) |
| Phase 2 | GitHub Action: tag push → 정방향 sync 자동화 | tag push (`v*-mvp`) | ⏭️ WU-33 (가칭, 후속) |

**Phase 0 → 1 승급 조건**: cut-release.sh 를 1~2 사이클 실 운영하여 dry-run 차이가 의도한 만큼인지 검증 완료 후.

**Phase 1 → 2 승급 조건**: drift 알림이 1~2 사이클 정상 작동 + OSS leak 0 확신 후.

---

## 6. 변경 이력

| Date | Change | Codename |
|:---|:---|:---|
| 2026-04-27 | 신설 (WU-31 §7 row 8) | TBD (24th 22nd scheduled run) |

후속 변경은 본 표 행 추가 + WU-32 / WU-33 신설 시 §5 Phase 표 갱신.
