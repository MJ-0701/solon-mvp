---
doc_id: sfs-full-review-2026-07-14
title: "SFS 전체 검토 — 4축 병렬 리뷰 (Fable 5)"
visibility: oss-public
doc_type: review-evidence
language: ko
updated: 2026-07-14
summary: "sfs 전체를 4축(셸 정확성·routed context·문서·테스트)으로 병렬 검토. HIGH eval-injection 1건 + 문서 링크·테스트 안전경계 갭 수정. 결과·조치 기록."
load_when: "Read when tracing the 2026-07-14 full-review findings and their fixes."
---

# SFS 전체 검토 — 2026-07-14

Fable 5 로 sfs 전체를 4개 독립 축으로 병렬 검토(subagent fan-out). baseline
run-all 232/232 · audit self-scan 0 findings 확인 후 착수.

## 축별 결과

### 축 1 — 셸 스크립트 정확성·이식성 (bin/sfs + 50 스크립트)
- **HIGH — eval-injection (`sfs-team-apply.sh:106`)**: `team_runtime_capable`
  이 project-editable `model-profiles.yaml` 유래 runtime 이름을 `eval` 로
  확장 → `x}$(cmd)` 값이 코드 실행. **FIXED**: 런타임 이름 `[a-z0-9-]` 검증 +
  `eval` 제거하고 bash 간접 확장(`${!var}`). 회귀 `test-team-apply-eval-safety.sh`
  (static no-eval 락 + 악성 이름 무실행 락).
- **LOW — verify grep 정규식 `.` (`verify-product-release.sh:68/80`)**: 점이
  any-char 로 해석. **FIXED**: `grep -qF` 고정 문자열.
- **LOW — sfs-loop tmp leak (`901/1192`)**: awk 실패 시 `$tmp` 미정리.
  **FIXED**: `|| { rm -f "$tmp"; return 1; }`.
- **LOW — archive-branch-sync lock TOCTOU**: **DEFERRED** — 인터랙티브 도구,
  경합 가능성 낮음, mkdir-atomic 전환은 별도 작업.
- 이식성(BSD/GNU/bash3.2) 전반 clean: PCRE/mapfile/assoc-array/`${var^^}`
  없음, sed -i Darwin 분기, stat/date fallback, 배열 누적은 here-string.

### 축 2 — routed context SSoT (100 정책 + 21 커맨드)
- **구조적 클린, 결함 0.** 121/121 `load_when` 존재, 라우트 0 broken,
  cross-ref 0 dangling, 200줄 budget 0 초과, dig/audit 배선 정확.
- Low(by-design): glob-only 라우트(ko-mirror·pack)는 literal-route lint 밖.

### 축 3 — 문서 일관성 (README/GUIDE/docs ko↔en)
- **MEDIUM — split-child root-level 링크 `./`→`../`**: README/07(dig·audit
  행 포함)·08, docs windows-incident 3곳 등. **FIXED**: root-prefix 링크 교정.
- dig/audit 는 README 표·feature-overview ko/en·GUIDE ko/en 전부 반영됨(패리티 OK).
- Low: GUIDE ko(18)↔en(13) 절 수 비대칭(en 짧은 경로 — 의도), index.md
  prose drift(adopt-retrofit) — **DEFERRED**(내용 결정 필요, 링크 무관).

### 축 4 — 테스트 커버리지·게이트 (233 테스트)
- 약한 어설션 headline 없음(redaction·phantom-FK·traversal 전부 negative 락).
- **HIGH 갭 — dig 안전경계 미커버**: **FIXED** (`test-dig-scan-erd.sh`):
  determinism 가드를 dig 런타임 경로(`sfs-harness.sh`)까지 확장(정밀 패턴 +
  주석 제외), no-write 기본동작, 대상 source read-only 무결성(checksum
  before/after), `--domain` traversal negative.
- **MED 갭**: audit status/report(+exit-3)/`--lens` 필터 smoke **FIXED**
  (`test-audit-scan.sh`). dig/audit/team categorize 명시 핀 **FIXED**.
- Low: scoop-manifest-validate.sh·*.ps1 은 run-all glob(`test-*.sh`) 밖 —
  별도 packaging/Windows CI 소관(문서 확인 사항).

## 조치 요약
- 수정: eval-injection(HIGH) + 문서 링크(MED) + 테스트 안전경계 갭(HIGH/MED)
  + verify grep + loop tmp leak. run-all 232→233.
- 보류: archive lock TOCTOU(LOW), GUIDE 절 비대칭·index drift(내용 결정),
  glob-route lint 강화(선택).
