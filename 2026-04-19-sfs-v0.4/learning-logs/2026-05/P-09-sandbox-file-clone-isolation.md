---
pattern_id: P-09-sandbox-file-clone-isolation
title: "sandbox `file://` clone 격리 — host repo `.git` mutate 0 보장 (P-08 직접 후속, §1.5' 격상 동반)"
status: resolved
severity: medium
first_observed: 2026-04-25
observed_by: dazzling-sharp-euler (23번째 세션 후반, P-08 fuse-bypass 사고 후 사용자 결정 = "단기 = sandbox file:// clone 패턴 (α 변형 = β 보강) 채택, 장기 = ε VM (UTM/Multipass/Lima)")
resolved_at: 2026-04-25
resolved_by: dazzling-sharp-euler (23번째 세션, 사용자 결정 수신 + 24th 첫 작업 §1.5' 격상 1줄 수정 동반)
resolved_via: |
  (1) **§1.5' commit-manual 격상 (24th 첫 작업)** — CLAUDE.md §1.5 1줄 수정: "AI 는 file 편집 + sandbox `file://` clone 안 commit 까지만 (P-08 사고 방지). host repo 의 `git add/commit/push origin *` 모두 사용자 터미널에서만 실행." → AI 의 host `.git` mutate 권한 자체 회수 +
  (2) **sandbox 패턴 명문화** — `git clone file://$SRC /tmp/work-NN-clone` → 격리된 work dir 안에서 commit/branch/rebase 등 free, 결과는 patch (`git format-patch`) 또는 push back (`git push file://$SRC main:tmp-N`) 으로 host 에 전달 + 사용자가 host 측에서 검토 후 merge +
  (3) **자동화 후속 작업 보존** — sync-stable-to-dev.sh / cut-release.sh 같은 release tooling sh 도 sandbox 안에서 dry-run 검증 후 host 적용 시 사용자 manual commit (Phase 0 = 로컬 sh, Phase 1+2 후속) +
  (4) **§1.6 FUSE bypass 와 비교 우선순위 명시** — 본 패턴 = 1차 옵션 (host `.git` 안 만짐, 안전), §1.6 cp -a `.git` = 사용 안 함 권고 (FUSE partial copy 위험), low-level git plumbing (GIT_INDEX_FILE 등) = 2차 fallback (사고 발생 후 복구).
related_wu: null   # 메타 운영 패턴 (P-08 직접 후속). 24th 사이클 §1.5' 격상 = 본 패턴 SSoT 적용 시점 (CLAUDE.md §1.5 1줄 수정 commit, 24th 첫 작업).
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.5' (commit-manual 격상 본문 — 본 패턴의 SSoT 규율)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.6 (FUSE bypass 원본 — 본 P-09 도입 후 우선순위 ↓)
  - learning-logs/2026-05/P-08-fuse-bypass-cp-a-broken.md (직접 짝 패턴 — P-08 사후 복구 + P-09 재발 방지)
  - 2026-04-19-sfs-v0.4/PROGRESS.md resume_hint.safety_locks "23번째 가상화 결정 (사용자 final): 단기 = sandbox file:// clone 패턴 (α 변형 = β 보강), 장기 = ε VM"
visibility: business-only
applicability:
  - "Cowork / FUSE 마운트 위에서 host repo 작업 시 host `.git` 직접 mutate 회피 필요"
  - "AI 가 commit/branch/rebase 등 git 작업 진행하되 사고 (P-08 류) 재발 방지 원칙 적용"
  - "release tooling (cut-release.sh / sync-stable-to-dev.sh / check-drift.sh 등) dry-run 검증 단계"
  - "host repo 의 hot path lock 충돌 방지 (사용자 mac terminal 동시 작업 가능성)"
reuse_count: 1   # 24th 사이클 §1.5' 격상 1회 적용 (CLAUDE.md §1.5 1줄 수정 commit). WU-31 sandbox 통합 검증 (24th-23 nifty-wizardly-bardeen `/tmp/wu31-dry-20260427T001837/`) 도 본 패턴 적용 사례 (host 자산 mutate 0).
related_patterns:
  - P-08   # fuse-bypass-cp-a-broken (직접 짝 — P-08 = 사후 복구, P-09 = 재발 방지)
  - P-03   # staged-uncommitted-on-session-crash (작업 유실 패턴 — P-09 의 sandbox commit 도 host 동기화 전까지 staged 잔존 위험)
  - P-02   # dev-stable-divergence (release tooling 도 본 패턴 적용 = 8 allowlist hard-coded)
---

# P-09 — sandbox-file-clone-isolation

> **visibility: business-only** — Solon 운영 메타 패턴 (host repo + AI session + FUSE 마운트 환경의 격리 디자인). OSS 마케팅 프로덕트에 일반화 시 추상화 후 oss-public 승급 후보 — 사용자 codename / 사고 narrative 없이 "Cowork-like 환경에서 host `.git` 안 만지고 AI 가 git 작업하는 법" 으로 추출 가능.

---

## 문제

23rd 세션 P-08 사고 (FUSE 마운트 위 `cp -a .git` 부분 누락 + `rsync back --delete` host repo 깨뜨림) 후, 사용자 결정 = "AI 가 host `.git` 을 직접 mutate 하지 않게 만들자". 그러나 commit / branch / rebase / merge 등 git 작업은 AI 협업 중에 빈번히 필요. 두 요구사항 (host `.git` mutate 0 + git 작업 free) 의 균형점 = sandbox `file://` clone 격리.

- **증상 (이전 환경)**: AI 가 host repo 안에서 직접 `git commit` 시도 → `.git/index.lock` FUSE race → cp -a 시도 → partial copy → `rsync back` 으로 host `.git` 깨뜨림 (P-08 사고 chain). 또는 사용자 mac terminal 에서 동시 작업 시 lock 충돌.
- **발생 조건**: (a) Cowork / FUSE 마운트 환경 + (b) AI session 의 git 작업이 host repo `.git` 을 직접 건드림 + (c) 사용자 mac terminal 도 동일 host repo `.git` 을 건드림 (또는 cron 등 백그라운드 프로세스).
- **원인**: AI 와 사용자 (또는 hourly cron) 간 host `.git` 공유 = race condition 잠재. FUSE 마운트의 atomicity 보장 부족 = `.git` 디렉토리 wholesale copy 위험.
- **영향**: P-08 류 사고 재발 가능성, 사용자 작업 흐름 차단, 복구 비용 (RECOVERY.md 백업 + 사용자 manual commit 절차).

## 해결 패턴

### 핵심 디자인 원칙

> **AI 는 host repo `.git` 을 직접 mutate 하지 않는다.** 모든 git 작업 (commit / branch / rebase / push 등) 은 sandbox `file://` clone 안에서. 결과는 patch 또는 사용자 검토 후 host 적용.

### 단계 (24th+ 운영 패턴)

1. **§1.5' 정합 file 편집만** (default) — AI 가 host repo file 을 Edit/Write 하되, `git add/commit/push` 안 함. 사용자가 mac terminal 에서 검토 후 manual commit + push (heredoc inline `git commit -F - << EOF ... EOF` 권장).
2. **sandbox 필요 시** (예: dry-run 검증, multi-step rebase, 복잡한 merge) — `/tmp/work-NN-clone/` 에 `git clone file://$HOST_PATH` 후 그 안에서 작업.
3. **결과 host 적용 옵션**:
   - **(a) patch**: `git format-patch HEAD~N..HEAD -o /tmp/patches/` → 사용자 mac terminal 에서 `git am /tmp/patches/*.patch` (가장 안전, 사용자 검토 단계 보존).
   - **(b) push back**: `git push file://$HOST_PATH HEAD:tmp-NN` → 사용자가 host 에서 `git merge tmp-NN` 또는 `git cherry-pick`. (AI 가 host `.git` 직접 안 만짐, push 만 transactional).
   - **(c) bundle**: `git bundle create /tmp/work.bundle HEAD` → 사용자가 `git fetch /tmp/work.bundle` 후 처리. (offline 시나리오, 거의 안 씀).
4. **sandbox cleanup** — 작업 완료 후 `rm -rf /tmp/work-NN-clone/` (host 자산 mutate 0 검증). cleanup 누락 = 다음 세션 진입 시 `/tmp` 잔존 = 디스크 낭비.
5. **release tooling 적용** — cut-release.sh / sync-stable-to-dev.sh / check-drift.sh 도 본 패턴 정합. dry-run 은 sandbox 안에서, --apply 시 사용자 manual commit 분리.

### 샘플 명령 / 코드

```bash
# === 1. §1.5' 정합 default (file 편집만) ===
# AI 가 Edit/Write 도구로 host repo file 변경
# 사용자 mac terminal 에서:
cd ~/agent_architect
git add 2026-04-19-sfs-v0.4/sprints/WU-NN.md
git commit -F - << 'EOF'
WU-NN: <작업 요약>

- 변경 1
- 변경 2
EOF
git push origin main

# === 2. sandbox file:// clone (필요 시) ===
SRC="/Users/mj/agent_architect"
WORK="/tmp/work-$$-clone"
git clone "file://$SRC" "$WORK"
cd "$WORK"
git checkout -b tmp-feature
# ... edit + commit ... (AI 가 자유롭게)
git log --oneline -5

# === 3a. 결과 host 적용 (patch 방식, 가장 안전) ===
cd "$WORK"
git format-patch HEAD~3..HEAD -o /tmp/patches-$$/
# 사용자 mac terminal:
cd ~/agent_architect
git am /tmp/patches-*/0*.patch

# === 3b. 결과 host 적용 (push back) ===
cd "$WORK"
git push "file://$SRC" tmp-feature:tmp-feature
# 사용자 mac terminal:
cd ~/agent_architect
git merge tmp-feature   # 또는 cherry-pick
git branch -d tmp-feature   # cleanup

# === 4. sandbox cleanup ===
rm -rf /tmp/work-$$-clone
ls /tmp/work-* 2>/dev/null || echo "no leftover sandboxes"
```

## 재사용 체크리스트

- [ ] 전제 조건: Cowork / FUSE 마운트 환경 + host repo + AI session.
- [ ] 1차 default = file 편집만 (§1.5' 정합), AI 의 host `.git` mutate 0. 사용자 manual commit + push.
- [ ] sandbox 필요한지 판단: 단순 file 편집이면 sandbox 불필요. multi-commit / rebase / merge / dry-run 검증 시 sandbox 필요.
- [ ] sandbox 결과 host 적용 = patch (3a, 안전) > push back (3b, 빠름) > bundle (3c, offline). 매 작업 단위 cleanup.
- [ ] release tooling sh (cut-release/sync-stable-to-dev/check-drift) 도 본 패턴 정합 — dry-run sandbox 안에서, --apply 시 사용자 manual commit 분리.
- [ ] cleanup 검증: `ls /tmp/work-*` + `ls /tmp/wu*-dry-*` 가 비어있는지 확인. 누적 시 디스크 낭비.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부: 본 패턴 자체는 mechanical (host `.git` mutate 0 보장 절차), 의미 결정 아님. 단 sandbox 결과 host 적용 시 (3a/3b/3c 선택) 가 모호하면 사용자 confirm 필요.

## 관련 WU / 세션

- **최초 발견 + 결정**: 23번째 세션 `dazzling-sharp-euler` (2026-04-25, user-active). P-08 사고 후 사용자 final 결정 = "단기 = sandbox file:// clone 패턴 (α 변형 = β 보강) 채택, 장기 = ε VM (UTM/Multipass/Lima) 검토 항목". CLAUDE.md §1.5 1줄 수정 = 24th 첫 작업 (commit `10f5e8f` 까지 push 완료, 24th 진입 시 git ahead=0 확인).
- **재사용 / 재발견**:
  - **24th-23 (`nifty-wizardly-bardeen`, 2026-04-27 09:18 KST)**: WU-31 row 9 dry-run sandbox 통합 검증 = `/tmp/wu31-dry-20260427T001837/` (cleanup 완료, host 자산 mutate 0). 9 smoke 전부 PASS. 본 P-09 패턴 직접 적용 사례.
  - **24th-32 (`bold-festive-euler`, 2026-04-27 21:55 KST)**: D-C-WU-30 row 6 dry-run sandbox 4 smoke = `/tmp/wu30-row6-dry-$$/` (cleanup 완료, host 자산 mutate 0). 본 P-09 패턴 정합.
  - **CLAUDE.md §1.5' (24th 첫 작업)**: AI commit 권한 회수 = 본 P-09 의 §1.5' 격상 단계 SSoT.
- **재발 방지**: 24th 부터 `current_wu_owner` mutex + domain_locks + §1.5' 정합 file 편집 default 로 host `.git` mutate 0 보장. P-08 류 사고 재발 가능성 ↓.

## Notes

- **OSS 승급 가능성 (business-only → oss-public)**: 본 패턴 핵심 = "Cowork-like 환경에서 host `.git` 안 만지고 AI 가 git 작업하는 법". 사용자 codename / Solon 내부 narrative 추상화 시 일반 노하우. 향후 OSS docset (`solon-mvp-dist/`) 본격 공개 시 추출 후 별도 oss-public 패턴 문서로 발행 권장 (사용자 codename + 사고 narrative 분리 + sandbox 디자인 일반화).
- **상위 규율**: §1.5' (commit-manual, 24th 첫 작업) + §1.6 (FUSE bypass 원본 — 본 패턴 도입 후 우선순위 ↓) + §1.8 (작업 유실 최소화, sandbox 결과 host 적용 단계 분리) + §1.13 R-D1 (dev-first, release tooling 도 본 패턴 정합).
- **관련 패턴**:
  - **P-08 (fuse-bypass-cp-a-broken)**: 본 P-09 의 직접 짝 — P-08 = 사후 복구 (사고 발생 시), P-09 = 재발 방지 (default 디자인). 둘 다 raw-internal/business-only tier (Solon 운영 trace) 이지만 P-09 는 일반 노하우라 OSS 승급 후보 더 높음.
  - **P-03 (staged-uncommitted-on-session-crash)**: sandbox commit 도 host 동기화 전까지 staged 잔존 위험 = P-03 패턴 재사용. patch (3a) 가 가장 안전한 이유 = 사용자 검토 단계 보존 + staged 잔존 시 git am 으로 idempotent 적용.
  - **P-02 (dev-stable-divergence)**: release tooling (cut-release/sync-stable-to-dev/check-drift) 도 본 P-09 패턴 정합 — 8 allowlist hard-coded + dry-run sandbox 검증 + --apply 시 사용자 manual commit. R-D1 §1.13 과 P-09 가 dual layer (R-D1 = repo level, P-09 = .git level).
- **변종 / 후속 작업 후보**:
  - **변종 1 (장기 ε VM)**: 23rd 사용자 결정의 장기 옵션 = UTM / Multipass / Lima 등 native filesystem VM 안에서 host repo mount 대신 git clone. 0.6.0+ 단계 후보. 현재는 sandbox file:// clone 만으로 충분.
  - **변종 2 (worktree)**: `git worktree add` 로 같은 repo 의 별도 directory 에서 작업 = sandbox file:// clone 보다 가벼움 (object DB 공유). 단 host `.git` 직접 건드리므로 §1.5' 정합 위반 위험 = 우선순위 ↓.
  - **자동 감지 후속 작업 후보**:
    - `scripts/check-host-git-mutate.sh` 신설 → AI session 시작 / 종료 시 host `.git` ref / index inode 변화 검출 → 0 mutate 검증. 0.5.0-mvp 후보.
    - `scripts/sandbox-clone.sh` helper 신설 → `git clone file://...` + cleanup trap 자동화. 0.4.0-mvp 후보 (현재는 manual `git clone` + `rm -rf` 명령).
- **본 패턴 분리 파일 visibility tier**: business-only default. P-08 (raw-internal) 와 다른 이유 = P-09 는 사고 narrative 없이 디자인 패턴만, 일반 노하우로 추출하기 쉬움. 향후 OSS 승급 시 raw-internal 의 P-08 사고 narrative 와 추상 P-09 디자인을 분리 발행.
