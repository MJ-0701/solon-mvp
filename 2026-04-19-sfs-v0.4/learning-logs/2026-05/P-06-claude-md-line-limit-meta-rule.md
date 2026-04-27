---
pattern_id: P-06-claude-md-line-limit-meta-rule
title: "CLAUDE.md SSoT 분량 ≤200 lines 메타 규칙 — 부록 강한 § 분리 + 사례 append"
status: resolved
severity: low
first_observed: 2026-04-25
observed_by: adoring-trusting-feynman (22번째 세션, 8 step batch 중 §1.14 신설 + §14 분리 결정 수신)
resolved_at: 2026-04-25
resolved_by: adoring-trusting-feynman (22번째 세션, 같은 batch 내 즉시 적용)
resolved_via: |
  (1) CLAUDE.md SSoT 에 §1.14 메타 규칙 신설 — "≤ 200 lines hard cap, 초과 시 가장 부록 성격 강한 § 을 별도 파일로 분리 + link 1줄로 대체" +
  (2) 분리 priority 명문화 — "부록 > 본문 § / 라인 수 > 의미 밀도" (의사결정 모호성 제거) +
  (3) 첫 적용 사례 = §14 (Solon Session Status Report v0.6.3) → `solon-status-report.md` 분리, 의미 변경 0 (link 1줄 + 분리 사유 inline 기록) +
  (4) 후속 분리 시 §1.14 본문에 "사례 append + 분리 사유 1줄" 규칙 추가 — 분리 이력 자체가 SSoT 안에 trace 로 보존.
related_wu: null   # 메타 규칙 (SSoT 자체 관리), 특정 WU 산출물 아님. 22nd 세션 8 step batch 의 step 2-3 commit `a35b669` 에 적용.
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.14 (SSoT 메타 규칙 본문 + 분리 사례 §14 inline 기록)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §14 (분리 후 stub: link 1줄 + 의미 변경 0 명시)
  - 2026-04-19-sfs-v0.4/solon-status-report.md (분리된 본문 SSoT, 85 lines, v0.6.3 spec 전체)
  - git commit `a35b669 wip(22nd/step2-3/claude-md-slim): §1.14 ≤200 lines 메타 규칙 신설 + §14 → solon-status-report.md 분리`
visibility: business-only
applicability:
  - "단일 SSoT 파일 (예: CLAUDE.md, README, INDEX) 의 line 수가 200 lines 임계값 도달 또는 초과"
  - "신규 § 추가 결정 시 '본 SSoT 본문 vs 별도 부록 파일' 갈림길 발생"
  - "다음 세션 진입 시 SSoT 1회 read 비용 안정화 필요 (가독성 + scrolling 비용 + 진입 cost)"
  - "분리 후에도 SSoT 안에 분리 사실 + 위치 + 사유 trace 보존 필요 (분리 이력 자체가 history)"
reuse_count: 1   # 22nd 세션이 §14 → solon-status-report.md 분리 시 1회 적용. 후속 분리 (있다면) 시 §1.14 사례 append + 본 P-06 reuse_count 증가.
related_patterns:
  - P-01   # solon-mvp scope pivot (메타 결정 + SSoT 변경 결정 선례)
  - P-02   # dev-stable divergence (SSoT 분리·동기 다른 도메인 사례, R-D1 연결)
---

# P-06 — claude-md-line-limit-meta-rule

> **visibility: business-only** — SSoT 분량 관리 메타 규칙 (재사용 가능한 일반 패턴). OSS 공개 본격 검토 시 oss-public 승급 후보 (사용자 codename / 운영 데이터 0건).

---

## 문제

`CLAUDE.md` 같은 **단일 SSoT 파일** 은 매 세션 진입 시 1회 read 가 강제되는 critical path 자산이다. 본 프로젝트는 §1 (절대 규칙 13~14 항) + §2~§14 (프로젝트 SSoT) 구조로 설계되었는데, 결정 + 규율 + 사례 추가가 누적되면서 본문이 무한 확장되는 경향이 발생했다.

- **증상**: CLAUDE.md 가 200+ lines 로 커지면 (a) 진입 시 1회 read 비용 증가, (b) `tail` / `grep` 으로 부분 access 시 scrolling 비용 증가, (c) "본문 § vs 부록 §" 경계가 모호해져 결정 갈림길마다 "여기에 추가하나? 별도 파일?" 모호성 발생.
- **발생 조건**: 결정 escalation (§1.7), 규율 신설 (§1.5' 격상 등), 사례 inline 기록 (R-D1 학습 로그 inline 등) 이 누적될 때 자연 발생. 본 프로젝트 22nd 세션 시점 = §14 (Solon Session Status Report v0.6.3 spec) 가 80+ lines 차지하면서 CLAUDE.md 가 240 lines 에 근접 → 가독성 임계 초과.
- **원인**: SSoT 의 "응집도 (의미 1원성)" 와 "분량 (read 비용)" 사이의 **trade-off** 가 명문화 안 됨. 결정자 (사용자) 가 "지금 inline 으로 둘까, 분리할까?" 매번 즉흥 판단 → 일관성 없음.
- **영향**: (a) 새 세션 진입 비용 증가 (compact 위험 증가), (b) 분리 결정 모호성 → 의사결정 stall, (c) 본문에 부록성 spec (랜더링 포맷, 변경 이력 표 등) 이 섞여 SSoT 핵심 규율 가독성 저하.

## 해결 패턴

### 메타 규칙 (CLAUDE.md §1.14 본문)

> **CLAUDE.md SSoT 분량 제약** — 본 CLAUDE.md 의 합산 line 수는 항상 **≤ 200 lines** 유지. 초과 시 가장 부록 성격 강한 § 을 별도 파일로 분리하고 link 1줄로 대체. 분리 우선순위 = **부록 > 본문 § / 라인 수 > 의미 밀도**. 다른 § 후속 분리 시 본 §1.14 에 **사례 append + 분리 사유 1줄** 기록.

### 단계 (실행 절차)

1. **임계값 점검** — 새 § 추가 또는 기존 § 확장 commit 직전에 `wc -l CLAUDE.md` 실행. 현재 + 예상 증가 = 200 초과 예측 시 분리 결정 트리거.
2. **분리 후보 선정 (priority 적용)**:
   - 1순위 = 부록 성격 (rendering spec, 변경 이력 표, 외부 도구 출력 포맷)
   - 2순위 = 본문 § 중 라인 수 큰 것
   - 3순위 = 의미 밀도 낮은 것 (cross-ref 이 SSoT 안에 적게 걸린 §)
3. **분리 파일 위치 결정** — `2026-04-19-sfs-v0.4/<separated-name>.md` (CLAUDE.md 와 같은 directory 유지, link 안정성 확보).
4. **본문 § 자리에 link stub 작성** — 형식: `> §1.14 (≤200 lines 메타 규칙) 충족을 위해 별도 파일로 분리. 의미 변경 0. \n> Spec SSoT: [\`<file>.md\`](./<file>.md) — <분량/내용 1줄 요약>.`
5. **분리 commit message 표준화** — `wip(<session-id>/step-<n>/claude-md-slim): §<N> ≤200 lines 메타 규칙 + §<X> → <file>.md 분리`
6. **§1.14 사례 추가** — 분리 후 §1.14 본문 끝에 "분리 사례 append + 분리 사유 1줄" (예: "첫 분리 사례: §14 → `solon-status-report.md` (22nd 세션 적용, 의미 변경 0)").
7. **사후 검증** — `wc -l CLAUDE.md` 가 < 200 확인 + 분리 파일 link 동작 확인 + 의미 변경 0 (semantic diff = 본문에 있던 정보가 모두 분리 파일에 보존되는지 verify).

### 샘플 명령 / 코드

```bash
# 1. 임계값 점검
wc -l 2026-04-19-sfs-v0.4/CLAUDE.md

# 2. 분리 후보 후 line 수 분포
awk '/^# §/{print NR, $0}' 2026-04-19-sfs-v0.4/CLAUDE.md
# → 각 § 시작 라인 위치 → diff 로 § 별 line 수 산출

# 3. 분리 파일 신설 (예: §14 → solon-status-report.md)
sed -n '<§14_start>,<§14_end>p' 2026-04-19-sfs-v0.4/CLAUDE.md > 2026-04-19-sfs-v0.4/solon-status-report.md

# 4. CLAUDE.md 의 §14 자리를 link stub 으로 교체 (Edit 도구 권장 — sed 시 마커 escape 위험)

# 5. 분리 commit
git add 2026-04-19-sfs-v0.4/CLAUDE.md 2026-04-19-sfs-v0.4/<separated>.md
git commit -m "wip(<session-id>/step-N/claude-md-slim): §1.14 ≤200 lines 메타 규칙 + §<X> → <file>.md 분리"

# 6. 검증
wc -l 2026-04-19-sfs-v0.4/CLAUDE.md   # < 200 확인
diff <(awk '/<X>_start/,/<X>_end/' before-CLAUDE.md) 2026-04-19-sfs-v0.4/<file>.md
# → 의미 변경 0 (semantic diff)
```

## 재사용 체크리스트

- [ ] 전제 조건: CLAUDE.md (또는 다른 단일 SSoT 파일) 의 현재 line 수가 200 근접 또는 초과.
- [ ] 분리 priority 적용: 부록 성격 강한 § 우선 (rendering spec / 변경 이력 표 / 외부 출력 포맷). 본문 § 분리는 마지막 수단.
- [ ] 의미 변경 0 검증: 분리 전후 semantic diff 가 0 (단순 위치 이동 + link stub 만). 사고 변경 + 분리 동시 진행 금지 (분리는 mechanical only).
- [ ] 분리 사실 trace 보존: §1.14 본문에 분리 사례 append + 분리 사유 1줄. 분리 이력 자체가 SSoT 안에 history 로 남음.
- [ ] 사후 검증: `wc -l CLAUDE.md` < 200 확인 + link 동작 확인 + 별도 파일 frontmatter (visibility tier 등) 정합 확인.
- [ ] 원칙 2 (self-validation-forbidden) 위반 여부: 분리 결정 자체는 mechanical (분량 임계값 초과 → 자동 트리거) 이므로 의미 결정 아님. 단 **어느 § 을 분리할지** 의 priority 적용 모호 시 사용자 confirm 필요.

## 관련 WU / 세션

- **최초 발견 + 적용**: 22번째 세션 `adoring-trusting-feynman` (2026-04-25, user-active). 8 step batch 중 step 2-3 commit `a35b669` 에서 §1.14 신설 + §14 → `solon-status-report.md` 첫 분리.
- **재사용**: 미발생 (24th 시점 1회 적용만). CLAUDE.md 현재 167 lines = 200 임계값 미달 = 추가 분리 트리거 없음.
- **후보**: 향후 §1 절대 규칙이 14 → 15+ 로 늘거나 §2~§13 본문 § 중 큰 것 (예: §3 디렉토리 구조, §5 WU 스키마) 이 inline 사례 누적으로 확장될 시 본 P-06 패턴 재적용.

## Notes

- **OSS 공개 가능성**: 본 패턴은 사용자 codename / 운영 데이터 / 내부 mutex 프로토콜 0건. 단순히 "SSoT 분량 관리" 일반 노하우 → 향후 OSS docset (`solon-mvp-dist/`) 본격 공개 시 `oss-public` 승급 후보. 현 단계 = `business-only` (보수적 default).
- **상위 규율**: §1 절대 규칙 자체에 §1.14 로 임베딩 (자기참조 메타 규칙). §1.4 (Option β minimal cleanup default) 와 정합 — 분리는 minimal mechanical change, 의미 결정 아님.
- **관련 패턴**:
  - P-01 (solon-mvp scope pivot): 메타 결정 (전체 scope 변경) 의 선례 = SSoT 자체에 결정 trace 보존하는 패턴.
  - P-02 (dev-stable divergence): SSoT 분리·동기 다른 도메인 사례 (`solon-mvp-dist/` ↔ stable repo) — R-D1 §1.13 으로 일반화됨. P-06 은 단일 repo 안의 § 수준 분리, P-02 는 repo 간 파일 수준 분리 = 분리 단위 차이.
- **변종 / 후속 작업 후보**:
  - **변종 1**: 단일 § 의 line 수가 임계값 (예: 50 lines) 초과 시 § 안에 sub-§ 으로 분리하는 패턴 (현재는 § 단위 분리만). 본 P-06 의 한계 = 분리 단위가 § level 만.
  - **변종 2**: PROGRESS.md (live snapshot) 도 같은 임계값 도입 검토 — 단 PROGRESS 는 frontmatter 누적 + 본문 4 필드 구조라 다름. 별도 패턴 후보.
  - **자동 감지 후속 작업**: `scripts/check-claude-md-size.sh` 신설 → CI 또는 pre-commit hook 으로 200 lines 초과 시 분리 권고 출력 (0.4.0-mvp 후보).
  - **분리 파일 visibility tier 정책**: 분리 결과 파일이 raw-internal/business-only/oss-public 어느 tier 에 들어가는지 별도 결정 필요 (예: §14 → solon-status-report.md 의 tier = raw-internal, 22nd 세션 미명시 후 24th-21 fervent-sweet-hamilton 가 .visibility-rules.yaml 추가 확정). 본 P-06 적용 시 분리 파일 tier 도 동시 결정 권장.
