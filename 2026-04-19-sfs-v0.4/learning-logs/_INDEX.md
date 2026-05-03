---
doc_id: learning-logs-index
title: "learning-logs/ — 장기 학습 패턴 자산 인덱스"
visibility: raw-internal
updated: 2026-05-03   # affectionate-trusting-thompson session — P-16 (0.5.96-product hotfix multi-CLI plugin umbrella, captured but unindexed by determined-focused-galileo) backfill + P-17 (0.6.0-product spec sprint G1 4-round + G6 3-stage cross-instance verify cycle canonical pattern) 신설.
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
| [P-06-claude-md-line-limit-meta-rule](2026-05/P-06-claude-md-line-limit-meta-rule.md) | CLAUDE.md SSoT 분량 ≤200 lines 메타 규칙 — 부록 강한 § 분리 + 사례 append | business-only | 22nd 8 step batch (adoring-trusting-feynman, §1.14 신설 + §14 → solon-status-report.md 분리) | 1 | resolved |
| [P-08-fuse-bypass-cp-a-broken](2026-05/P-08-fuse-bypass-cp-a-broken.md) | FUSE 마운트 위 `cp -a .git` 부분 누락 + `rsync back --delete` 가 host repo 깨뜨림 — low-level git plumbing fallback + sandbox file:// clone 격리 | raw-internal | WU-31 (dazzling-sharp-euler, 23번째 후반 사고 + 사용자 manual 복구) | 1 | resolved |
| [P-09-sandbox-file-clone-isolation](2026-05/P-09-sandbox-file-clone-isolation.md) | sandbox `file://` clone 격리 — host repo `.git` mutate 0 보장 (P-08 직접 후속, §1.5' 격상 동반) | business-only | 23rd 사용자 결정 (단기 α 변형 = β 보강) + 24th 첫 작업 §1.5' 격상 (CLAUDE.md §1.5 1줄 수정) | 1 | resolved |
| [P-10-stable-stale-git-lock-recovery](2026-05/P-10-stable-stale-git-lock-recovery.md) | stable stale `.git/index.lock` recovery | business-only | 25th-2 0.3.0-mvp 첫 release cut | 1 | documented |
| [P-11-sequential-disclosure](2026-05/P-11-sequential-disclosure.md) | sequential-disclosure | business-only | 26th-1 사용자 비판 + CLAUDE.md §1.20 | 0 | documented |
| [P-13-dev-stable-divergence-on-cut](2026-05/P-13-dev-stable-divergence-on-cut.md) | dev-stable-divergence-on-cut | business-only | 26th-3 0.5.0-mvp cut 회귀 진단 | 0 | documented |
| [P-14-mental-coupling-on-rename-fix](2026-05/P-14-mental-coupling-on-rename-fix.md) | mental-coupling-on-rename-fix | business-only | 26th-3 사용자 비판 + codex narrative sync-back | 0 | documented |
| [P-15-claude-worktree-gitlink-committed](2026-05/P-15-claude-worktree-gitlink-committed.md) | claude-worktree-gitlink-committed | raw-internal | 2026-05-01 Codex cleanup session + commit `78ee0f0` | 1 | documented |
| [P-16-multi-cli-plugin-umbrella](2026-05/P-16-multi-cli-plugin-umbrella.md) | 단일 brew/scoop install 이 Claude Code + Gemini CLI + Codex CLI 슬래시 명령을 한꺼번에 등록하는 multi-CLI plugin umbrella 패턴 | oss-public | 0.5.96-product hotfix (determined-focused-galileo, 2026-05-03) | 0 | documented |
| [P-17-cross-instance-verify-cycle](2026-05/P-17-cross-instance-verify-cycle.md) | Multi-runtime multi-stage cross-instance verify cycle — SFS self-validation 회피 mechanism 운영 패턴 (G1 4-round + G6 3-stage canonical evidence) | oss-public | 0.6.0-product spec sprint G1+G6 (elegant-hopeful-maxwell + affectionate-trusting-thompson, 2026-05-03) | 0 | documented |

---

## Template

`_TEMPLATE.md` 참조. 필수 섹션: 문제 / 해결 패턴 / 재사용 체크리스트 / 관련 WU·세션.

## Visibility 규칙

- **`oss-public`**: 기술 일반론 패턴 (FUSE, git, 세션 복구 등) — OSS repo 공개 가능.
- **`business-only`**: Business 제품 특화 로직 / Solon 독자 알고리즘 — Business repo 한정.
- **`raw-internal`**: 개인 운영 경험 / 고객 raw 데이터 연관 / 미정 단계 — 양쪽 제외.

## OSS 배포 (Phase 2 이후)

`.visibility-rules.yaml` 의 `learning-logs/**` 규칙 참조 — 기본 제외, `oss-public` 라벨 패턴만 선별 포함.
