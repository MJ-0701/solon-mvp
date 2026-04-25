---
doc_id: learning-logs-index
title: "learning-logs/ — 장기 학습 패턴 자산 인덱스"
visibility: raw-internal
updated: 2026-04-25   # 21번째 세션 trusting-stoic-archimedes — P-04 / P-05 신설.
---

# learning-logs/ — 학습 패턴 인덱스

> **역할**: WU 진행 중 발견된 재사용 가능한 문제-해결 패턴을 장기 자산으로 축적. Dual-track (OSS + Business) 양쪽에 재활용 가능한 지식 베이스.
> **그룹화**: 월 단위 디렉토리 (`YYYY-MM/`) + 개별 패턴 파일 (`P-<kebab-name>.md`).
> **필수 필드**: 각 패턴 파일 frontmatter 에 `visibility` 명시 (`raw-internal` | `business-only` | `oss-public`).

---

## 패턴 목록

### 2026-04 (WU-15 ~ WU-18 시점)

> WU-18 ("v2 운영 1주 검증 + retrospective") 에서 패턴 후보 3건 실체화 예정. 현재는 후보 명세만 보존.

| pattern_id | title | visibility | captured_from | reuse_count | status |
|:---|:---|:-:|:---|:-:|:-:|
| P-fuse-git-bypass | FUSE mount .git/index.lock 경합 우회 | oss-public | WU-7 ~ WU-14 (반복 관찰) | 0 | 후보 (WU-18) |
| P-compact-recovery | Compact mid-WU 복구 절차 (tmp/ + wip commit 보존) | raw-internal | WU-10 실전 | 0 | 후보 (WU-18) |
| P-two-step-wu-refresh | WU + WU.1 forward sha backfill 패턴 | oss-public | WU-7.1 / WU-10.1 / WU-14.1 | 0 | 후보 (WU-18) |

### 2026-05 (WU-15 ~ WU-23 실체화)

| pattern_id | title | visibility | captured_from | reuse_count | status |
|:---|:---|:-:|:---|:-:|:-:|
| [P-01-solon-mvp-scope-pivot](2026-05/P-01-solon-mvp-scope-pivot.md) | solon-mvp MVP scope pivot (Phase 1) | business-only | WU-20 (amazing-happy-hawking) | 0 | resolved |
| [P-02-dev-stable-divergence](2026-05/P-02-dev-stable-divergence.md) | dev (docset) ↔ stable (solon-mvp) divergence + R-D1 채택 | business-only | WU-20 Phase A Back-port (laughing-keen-shannon) | 1 | resolved |
| [P-03-staged-uncommitted-on-session-crash](2026-05/P-03-staged-uncommitted-on-session-crash.md) | 세션 종료 시 staged diff 유실 위험 + check.sh 자동 감지 | raw-internal | WU-20.1 (admiring-nice-faraday, 15번째) | 1 | resolved |
| [P-04-session-hang-takeover](2026-05/P-04-session-hang-takeover.md) | 세션 활성 유지하지만 진척 0 (hang) → 다음 세션이 mutex stale takeover | raw-internal | WU-22 (epic-brave-galileo, 20번째 takeover) | 1 | resolved |
| [P-05-agent-loader-startup-only](2026-05/P-05-agent-loader-startup-only.md) | Claude Code agent loader 가 startup-only — mid-session 등록 reload 안 됨 | business-only | WU-23 (trusting-stoic-archimedes, 21번째 fallback A) | 1 | resolved |

---

## Template

`_TEMPLATE.md` 참조. 필수 섹션: 문제 / 해결 패턴 / 재사용 체크리스트 / 관련 WU·세션.

## Visibility 규칙

- **`oss-public`**: 기술 일반론 패턴 (FUSE, git, 세션 복구 등) — OSS repo 공개 가능.
- **`business-only`**: Business 제품 특화 로직 / Solon 독자 알고리즘 — Business repo 한정.
- **`raw-internal`**: 개인 운영 경험 / 고객 raw 데이터 연관 / 미정 단계 — 양쪽 제외.

## OSS 배포 (Phase 2 이후)

`.visibility-rules.yaml` 의 `learning-logs/**` 규칙 참조 — 기본 제외, `oss-public` 라벨 패턴만 선별 포함.
