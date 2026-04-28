---
pattern_id: P-07-release-tooling-phased
title: "Release tooling 점진 도입 (Phase 0/1/2) — 1인 운영 자동화 vs 가시성 trade-off"
status: resolved
severity: low
first_observed: 2026-04-25
observed_by: dazzling-sharp-euler (23번째 세션, WU-31 신설 spec only — 사용자 옵션 β + '계획만' 명시)
resolved_at: 2026-04-27
resolved_by: 24번째 사이클 scheduled runs (wizardly-sleepy-brown 04:33 + eager-stoic-pasteur 05:18 + great-kind-turing 06:11 + fervent-sweet-hamilton 08:54 + trusting-funny-volta 09:03 + nifty-wizardly-bardeen 09:18 + pensive-exciting-keller 09:30 + jolly-festive-ramanujan 10:08~12 KST 8 step batch)
resolved_via: |
  (1) Phase 0 = 로컬 sh 우선 (cut-release.sh 351L + sync-stable-to-dev.sh 335L + check-drift.sh 240L + scripts/_README.md 275L + .visibility-rules.yaml 12→16 패턴 + dry-run sandbox 통합 검증 9 smoke PASS) — WU-31 1차 신설 +
  (2) Phase 1 = GitHub Action drift 알림만 (push-trigger 안 함, 1-2 사이클 운영 검증 후 도입) — WU-32 예약 +
  (3) Phase 2 = release tag trigger 정방향 sync 자동화 (Phase 1 운영 검증 통과 시) — WU-33 예약 +
  (4) phase 승급 invariant 명문화 = "1~2 사이클 실 운영 검증 통과 시 다음 phase 진입" (PROGRESS safety_locks 23번째 entry verbatim) +
  (5) push-trigger 자동화 vs §1.5 push manual 절대 규율 사이의 균형 = phase 분할 = (a) raw-internal leak 방지 + (b) 1인 운영 비용 + (c) 사용자 컨펌 영역 보존 3-구속 동시 충족.
related_wu: WU-31   # Release tooling Phase 0 신설 (23rd open spec only → 24th 사이클 8 step batch resolved file 편집 100% + 사용자 manual commit + final_sha=`9fbd999` backfill)
related_docs:
  - 2026-04-19-sfs-v0.4/sprints/WU-31.md (Phase 0 spec + §7 row 4~11 8 step batch trace)
  - 2026-04-19-sfs-v0.4/scripts/cut-release.sh (351L, dev → stable rsync + VERSION bump + CHANGELOG prepend + 옵션 tag, --dry-run default + --apply 가드)
  - 2026-04-19-sfs-v0.4/scripts/sync-stable-to-dev.sh (335L, stable hotfix → dev back-port allowlist 8 + blocklist 1, hotfix CHANGELOG prepend, commit 사용자 manual)
  - 2026-04-19-sfs-v0.4/scripts/check-drift.sh (240L, dry-run only preview helper, --quiet/--help 인자, exit 0/1/2/3/8/9 매트릭스)
  - 2026-04-19-sfs-v0.4/scripts/_README.md (275L, 7 sh 통합 docs + 정상 release cut 5단계 + hotfix back-port 4단계 + 정기 health check 워크플로우)
  - 2026-04-19-sfs-v0.4/.visibility-rules.yaml (12→16 패턴, enforcement_active=true 활성)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.13 (R-D1 dev-first stable sync-back, hotfix 예외 3-condition)
visibility: business-only
applicability:
  - "1인 또는 소규모 팀의 dev↔stable 양 repo 운영 (본 프로젝트 = 사용자 개인 docset + solon-mvp distribution stable repo)"
  - "release tooling 자동화의 'all-or-nothing' 결정 회피 — 점진 도입으로 위험 분산 + 운영 검증 누적"
  - "§1.5 push manual 같은 절대 규율과 release 자동화 욕구 사이 trade-off 균형 필요 시"
  - "release blocker (final_sha=TBD placeholder 등) 자동 감지 + 사용자 manual 영역 보존 동시 보장"
  - "다음 cycle 운영 검증 결과를 phase 승급 trigger 로 활용 (실용적 safety net)"
reuse_count: 1   # WU-31 Phase 0 신설 + WU-32/33 phase 분할 1차 적용. 후속 release tooling 추가 시 본 phased 패턴 재사용 가능.
related_patterns:
  - P-02   # dev-stable divergence (R-D1 본 패턴의 직접 prerequisite)
  - P-08   # FUSE bypass cp -a broken (release tooling 운영 중 사고 사례, sandbox file:// clone 패턴으로 회피)
  - P-09   # sandbox file:// clone isolation (Phase 0 dry-run sandbox 검증 패턴)
---

# P-07 — release-tooling-phased

> **visibility: business-only** — 1인 운영 release 자동화의 점진 도입 패턴 (재사용 가능한 일반 패턴). OSS 공개 본격 검토 시 oss-public 승급 후보 (사용자 codename / 운영 데이터 1건만, generic 패턴).

---

## 문제

dev (사용자 docset, raw-internal 포함) ↔ stable (solon-mvp distribution, 외부 공개 가능) 양 repo 운영 시 release 자동화의 **scope 결정 모호성** 이 발생한다. 완전 수동 = 매 release 마다 사용자 manual 작업 누적 + 오류 위험 / 완전 자동 = §1.5 push manual 같은 절대 규율 위반 + raw-internal leak 위험 + 사용자 컨펌 영역 침범.

- **증상**: WU-31 spec 단계 (23번째 세션 dazzling-sharp-euler) 에서 사용자 결정 영역 = (α) 즉시 GitHub Action push-trigger 자동화 / (β) 로컬 sh 우선 + 점진 / (γ) 완전 수동 유지. 사용자 의사결정 stall 발생 — "어디까지 자동화? 어디부터 manual?".
- **발생 조건**: §1.5 push manual + R-D1 dev-first + raw-internal visibility tier 3 가지 절대 규율이 release 자동화 욕구와 동시 충돌.
- **원인**: release 자동화의 "전부 vs 일부" 결정이 1회 갈림길로 처리되면 의사결정 부담 + 운영 검증 0 상태에서 자동화 채택 위험.
- **영향**: (a) 의사결정 stall → release 자동화 자체 도입 지연, (b) 한꺼번에 도입 시 운영 검증 0 + 사고 위험, (c) 사용자 manual 영역 보존 모호.

## 해결 패턴

### Phase 분할 (3-stage 점진 도입)

- **Phase 0 (즉시)** = 로컬 sh — `cut-release.sh` (dev → stable 정방향) + `sync-stable-to-dev.sh` (역방향 hotfix back-port) + `check-drift.sh` (dry-run preview). 모두 `--dry-run` default + `--apply` 가드. push 0건 (사용자 manual 호출 + commit 사용자 영역). visibility allowlist 8 + blocklist 1 hard-coded.
- **Phase 1 (1-2 사이클 운영 검증 후)** = GitHub Action drift 알림 — push-trigger 없음, 단지 PR/issue comment 로 "dev 와 stable drift N건 발견" 보고. 사용자 결정 보존.
- **Phase 2 (Phase 1 운영 검증 통과 후)** = release tag trigger 정방향 sync 자동화 — `git tag v0.X.Y-mvp` push 시 GitHub Action 이 stable 자동 sync (단, dev manual commit 사후, push 는 사용자 manual 유지).

### Phase 승급 invariant

`1~2 사이클 실 운영 검증 통과 시 다음 phase 진입`. 운영 검증 = (a) drift 발생 빈도 + (b) sandbox dry-run smoke 누적 PASS + (c) release blocker 감지 정확도 + (d) 사용자 manual 영역 침범 0 모두 확인.

### Push-trigger 자동화 vs §1.5 push manual 균형

- Phase 0 = AI / sh 모두 push 0 = §1.5 정합 100%
- Phase 1 = GitHub Action 가 알림만 = push 안 함 = §1.5 정합
- Phase 2 = release tag trigger = 사용자가 tag push 한 시점 → 그 후 자동 sync = 사용자 manual 진입점 보존

→ "사용자가 tag push" = 명시적 release intent → 그 다음 자동화 = §1.5 정신 (사용자 의도 보존) 부합.

### 샘플 워크플로우 (Phase 0)

```sh
# 정상 release cut 5단계 (scripts/_README.md §2.1)
./scripts/check-drift.sh                    # 1. drift preview
./scripts/cut-release.sh --version 0.X.Y-mvp # 2. dry-run cut
./scripts/cut-release.sh --version 0.X.Y-mvp --apply  # 3. apply (TBD detection 안전망)
# 4. 사용자 manual push (stable + tag)
git -C ~/workspace/solon-mvp commit -am "release: 0.X.Y-mvp"
git -C ~/workspace/solon-mvp push origin main --tags
# 5. dev post-flight commit (VERSION/CHANGELOG dev bump)
git add VERSION CHANGELOG.md && git commit -m "wip(release-post-flight): 0.X.Y-mvp 후 dev bump"

# Hotfix back-port 4단계 (scripts/_README.md §2.2)
# stable hotfix commit 후
./scripts/sync-stable-to-dev.sh --stable-sha <sha> --dry-run  # 1. preview
./scripts/sync-stable-to-dev.sh --stable-sha <sha> --apply    # 2. apply (allowlist+CHANGELOG hotfix prepend)
git add <files> && git commit -m "wip(hotfix sync): <sha>"     # 3. dev manual commit
git push origin main                                            # 4. 사용자 manual push
```

## 재사용 체크리스트

- [ ] release 자동화 scope = 단일 phase or 점진? 단일 = all-or-nothing 위험. 점진 = phase 분할 권장.
- [ ] §1.5 push manual 또는 동등 absolute 규율 존재 여부 = phase 분할의 핵심 boundary.
- [ ] visibility tier (raw-internal / business-only / oss-public) leak 검출 mechanism = blocklist + dry-run preview 의무.
- [ ] phase 승급 trigger = 1-2 사이클 운영 검증 통과 (정량적 metrics 명시 권장).
- [ ] release blocker (final_sha=TBD 등) 자동 감지 + abort = `cut-release.sh --apply` 안전망 필수.

## 관련 WU·세션

- **23번째 dazzling-sharp-euler**: WU-31 신설 spec only (β 채택)
- **24번째 사이클 24~25번째 scheduled runs**: 8 step batch resolve = Phase 0 file 편집 100% + dry-run 9 smoke PASS
- **24th-25 jolly-festive-ramanujan 10:08~12 KST**: WU-31 sprints/_INDEX 활성→완료 이동 + frontmatter close (final_sha=TBD placeholder)
- **사용자 manual commit + push**: `9fbd999` (WU-30/31 close batch) + `dff4377` (final_sha backfill)

## Notes

- **변종**: 본 패턴은 **dev↔stable 양 repo** 시나리오 한정. monorepo 또는 단일 repo branch 운영 시 적용 불가 (다른 패턴 필요).
- **Phase 1 GitHub Action 도입 시 검토 사항**: (a) drift 보고 빈도 (매 push? 매일? 주 1회?), (b) 보고 채널 (PR comment / issue / Slack), (c) 사용자 dismiss / acknowledge mechanism.
- **Phase 2 tag trigger 도입 시 검토 사항**: (a) tag push 시점 = 사용자 manual = release intent 명시 / (b) 자동 sync 후 dev post-flight commit 도 자동화 vs manual / (c) rollback 시 stable revert + dev 통지 mechanism.
- **운영 검증 누적 사례**: 24th 사이클 dry-run sandbox 9 smoke + 운영 3 path 재현 (정상 / hotfix / health check) + WU-21 final_sha=TBD 잔존 발견 = cut-release.sh TBD detection 안전망 입증. = Phase 0 의 실 가치 데이터.
