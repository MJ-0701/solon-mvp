---
pattern_id: P-02-dev-stable-divergence
title: "dev (Solon docset staging) ↔ stable (solon-mvp repo) divergence — 양쪽에서 병렬 작업하면 SSoT 무너짐"
status: resolved
severity: medium
first_observed: 2026-04-24
observed_by: dreamy-busy-tesla (11번째 세션)
resolved_at: 2026-04-24
resolved_by: laughing-keen-shannon (12번째 세션)
resolved_via: "CLAUDE.md v1.17 §1.13 R-D1 규칙 정식 채택 (dev-first + stable sync-back hotfix path)"
related_wu: WU-20
related_docs:
  - RUNTIME-ABSTRACTION.md v0.2-mvp-correction
  - sprints/WU-20.md
  - CLAUDE.md §1.13 R-D1 (Solon docset 루트 규율)
resolution_target: "COMPLETED — CLAUDE.md §1.13 R-D1 채택 (2026-04-24). 자동화 (sync-stable-to-dev.sh / cut-release.sh) 는 0.4.0-mvp 예약 (후속 WU)"
---

# P-02 — dev/stable divergence

## 현상

**WU-20 Phase A** 에서 Solon docset 내 `solon-mvp-dist/` staging (= dev SSoT)
에 4-파일 adapter 구조를 작성한 뒤, **같은 날 저녁 사용자가 Codex CLI 에서
`~/workspace/solon-mvp` (= stable release) 에 직접 6 커밋 추가** (0.1.1 →
0.2.4-mvp). 결과:

| 레포 | 커밋 수 (WU-20 이후) | 버전 | 구조 |
|------|---|---|---|
| dev (Solon docset staging) | 1 (df0887a = Phase A) + 보강 1회 | 0.2.0-mvp | `.claude-template/` 사용 |
| stable (solon-mvp) | 6 (786900a → ac98497) | 0.2.4-mvp | `.claude/` 사용 |

dev 쪽이 "선행 기획" 역할을 해야 하는데, 실제 구현 / 검증은 stable 쪽에서 먼저
진행돼서 **방향이 역전**. 11번째 세션 시작 시 사용자가 명시: **"mvp 는 배포버전
이고 solon (dev) 이 개발버전"**.

## 원인 분석

1. **Staging 배포 접근성 차이**: dev 쪽 staging 은 `2026-04-19-sfs-v0.4/`
   하위 깊숙한 경로 + agent 만 접근. stable 은 `~/workspace/solon-mvp` 로
   consumer 에서 실제로 install/upgrade 테스트 가능 → 사용자가 stable 에서
   직접 고치는 게 빠름.
2. **규율 부재**: "어느 repo 가 SSoT 인가" 가 문서화되지 않음. Phase A 산출물
   을 만들면서 사용자 의도 (solon=dev / solon-mvp=stable) 를 명시적으로 선언
   하지 않음.
3. **검증 피드백 루프**: checksum-based upgrade.sh 는 실 사용 테스트 하면서
   발견되는 요구라, staging 에서는 발견하기 어려움. 즉 **stable 에서 발견 →
   stable 에서 바로 수정** 이 자연스러움.
4. **Cowork 샌드박스 제약**: agent 는 `~/workspace/solon-mvp` 가 workspace
   folder 로 연결돼 있어야 직접 접근 가능. 연결 안 된 상태에서 사용자는
   Codex CLI 로 수정하는 게 편함 → dev 쪽 staging 과 독립 진화.

## 2026-04-24 reconcile (11번째 세션)

dev (staging) 을 stable 에 맞춰 full back-port.

| 파일 | 변경 |
|---|---|
| VERSION | 0.2.0-mvp → 0.2.4-mvp |
| CHANGELOG.md | 2 entry → 6 entry (0.1.0 / 0.1.1 / 0.2.0 / 0.2.1 / 0.2.2 / 0.2.3 / 0.2.4) |
| README.md | runtime별 사용법 + `/sfs` 사용법 섹션 추가 |
| install.sh | `--yes` 플래그 + stderr prompt + `.claude/` 경로 |
| upgrade.sh | checksum-based 자동 정책 + placeholder 치환 + TTY 감지 개선 |
| uninstall.sh | SFS/CLAUDE/AGENTS/GEMINI/sfs.md 5 파일 loop |
| templates/SFS.md.template | 간결 축소 (장황 → 운영 필수) |
| templates/{CLAUDE,AGENTS,GEMINI}.md.template | 영문 thin adapter (10~22줄) |
| templates/.claude/commands/sfs.md | `name:` frontmatter + `description:` 다중 줄 |
| templates/.claude-template/ | **deprecated**, 사용자 터미널에서 `git rm -rf` |

14 파일 checksum 완전 일치 (`diff -q` 모두 same 확인).

## Lesson (R-D1 규율 제안)

### R-D1 초안

> **배포 artifact 수정은 dev (Solon docset staging) 에서 먼저 한다.**
> stable (solon-mvp) 은 staging cut 의 결과물만 받는다. 단 실 사용 중 발견된
> hotfix 는 stable 에서 수정해도 되지만, **같은 세션 내에 staging 으로 back-port
> 커밋을 생성**한다 (24시간 내가 아니라 즉시).

### R-D1 예외 (hotfix path)

1. stable 에서 버그 발견 → stable 에서 수정 커밋 (예: `fix:` prefix).
2. **같은 세션 안에** 내용을 staging 에 동일 문안으로 복제 (cp + git add).
3. staging commit message 에 `sync(stable): <commit-sha>` 표기.
4. 다음 release 시 staging VERSION 을 stable VERSION 과 맞춤 (skip 없이).

### 자동화 idea (후속)

- `scripts/sync-stable-to-dev.sh` — stable HEAD 를 dev staging 으로 일방향 복사
  + checksum diff 리포트 출력 + 자동 커밋 메시지 제안.
- `scripts/cut-release.sh` — staging 검증 완료 후 stable 에 force-push (VERSION
  bump + tag 자동).
- pre-commit hook: stable 커밋 시 "이 커밋을 staging 에 복제했나?" 체크.

## 후속 TODO

- [x] Solon docset `CLAUDE.md §1` 에 R-D1 규칙 정식 추가 — **2026-04-24 laughing-keen-shannon (12번째 세션) 에서 §1.13 로 채택 완료. CLAUDE.md v1.16 → v1.17.**
- [ ] stable `CLAUDE.md` (distribution 유지보수 지침, `~/workspace/solon-mvp/CLAUDE.md`) 에도 "본 repo 는 stable. 개발은 dev staging 에서. hotfix 는 sync-back 필수" 명시 — 다음 stable back-port 시 함께 (R-D1 자체 규율에 따라 dev-first).
- [ ] WU-20.1 refresh 커밋에 본 P-02 링크 (WU-20 close 시).
- [ ] sync/cut-release 스크립트는 `0.4.0-mvp` 로 예약 (현 `0.3.0-mvp` 가 plugin 네이티브화라 별도).

## Changelog

- v0.1 (2026-04-24, dreamy-busy-tesla): P-02 초안 — divergence 현상 / 원인 / reconcile / R-D1 제안.
- v0.2 (2026-04-24, laughing-keen-shannon): **status: observed → resolved**. R-D1 이 Solon docset `CLAUDE.md §1.13` 로 정식 채택 (v1.16 → v1.17). 후속 TODO 1건 체크 완료, 3건 open 유지 (stable CLAUDE.md 동기화 / WU-20.1 refresh / 스크립트 0.4.0-mvp 예약).
