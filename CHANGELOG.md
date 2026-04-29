## [0.4.0-mvp] - 2026-04-29

- (release: cut from dev staging via cut-release.sh)

## [0.3.1-mvp] - 2026-04-29

- (release cut → stable caec8de)

## [0.3.0-mvp] - 2026-04-29

- (release cut → stable d28591f)

# CHANGELOG — Solon MVP

모든 릴리스는 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다. `-mvp` suffix 는
아직 풀스펙 (사용자 개인 방법론 docset) 으로 수렴하지 않은 최소 배포판임을 표시.

## [0.4.0-mvp] — Unreleased (예약, WU-25 + WU-26 완료 후 cut 대기)

> **상태**: WU-25 (#1 sfs slash 구현 part 2 = `/sfs plan` + `/sfs review`) 완료 + WU-26 (#1 sfs slash 구현 part 3 = `/sfs decision` + `/sfs retro --close`) 완료 후 본 entry 활성. 실 release cut 은 WU-31 `cut-release.sh --version 0.4.0-mvp` 실행 시점에 `Unreleased` → `YYYY-MM-DD` 로 치환.
> **β bundle 매핑**: WU-22 §3 β release roadmap 의 0.4.0-mvp = #1 sfs slash 6 명령 완성. part 1 (status/start, 0.3.0-mvp) + 본 entry (plan/review) + WU-26 (decision/retro --close) 통합 = 6 명령 (status/start/plan/review/decision/retro --close).
> **§0.3.0-mvp 와 관계**: 0.3.0-mvp Unreleased (part 1) 가 cut 대기 중. cut 시점에 사용자 결정 영역 — (a) 0.3.0-mvp 단독 cut + 0.4.0-mvp 후속 cut (2단 cut) / (b) 0.3.0-mvp + 0.4.0-mvp 통합 cut (entry 합쳐서 0.4.0-mvp 단일 cut, 0.3.0-mvp Unreleased 흡수). cut-release.sh --version 0.4.0-mvp 시 0.3.0-mvp Unreleased 자동 흡수 옵션은 후속 WU 검토.

### Added

- **`templates/.sfs-local-template/scripts/sfs-plan.sh`** — `/sfs plan` 어댑터 (170 lines, sfs-common.sh source). plan.md template cp + frontmatter `phase: plan` + `last_touched_at: <ISO8601+TZ>` 갱신 + events.jsonl `plan_open` event append + stdout `plan.md ready: <path>` (WU-25 §1.1 verbatim, WU22-D4 deterministic output 정합). Exit codes: 0=ok / 1=no `.sfs-local` or current-sprint / 2=corrupt events.jsonl / 4=missing template / 99=unknown (WU-25 §1.3 verbatim). 7 smoke PASS (row 2).
- **`templates/.sfs-local-template/scripts/sfs-review.sh`** — `/sfs review --gate <id>` 어댑터 (225 lines). `validate_gate_id` (gates.md §1 7-enum: G-1, G0, G1, G2, G3, G4, G5) 검증 + `infer_last_gate_id` (events.jsonl review_open scan) fallback. review.md template cp + frontmatter `phase: review` / `gate_id: <id>` / `last_touched_at` 갱신 + events.jsonl `review_open` event append (verdict 필드는 WU-26 close 시 채움) + stdout `review.md ready: <path> | gate <id> awaiting verdict` (WU-25 §2.1 verbatim). Exit codes: 0=ok / 1=no `.sfs-local` or current-sprint / 4=missing template / 6=invalid/required gate / 7=unknown CLI flag / 99=unknown (WU-25 §2.3 verbatim). 15 smoke PASS (row 3).

### Changed

- **`templates/.sfs-local-template/scripts/sfs-common.sh`** — 293L→364L (+71L, 3 함수 추가). `validate_gate_id` (gates.md §1 7-enum exact match, case-sensitive, hyphen 포함). `infer_last_gate_id` (events.jsonl tac+grep+sed pipeline, no-match → empty stdout + rc=0, `set -o pipefail` 호환 위해 pipeline 끝 `|| true` + 명시 `return 0`). `update_frontmatter <path> <key> <value>` (sfs-plan.sh 의 local helper 그대로 이관, awk-based atomic tmp+mv, BSD/GNU portable, missing-key append + existing-key replace). 8 smoke PASS (row 4).
- **`templates/.sfs-local-template/sprint-templates/plan.md`** + **`review.md`** — frontmatter `last_touched_at: ""` 필드 placeholder 추가 (4줄→5줄). 효과: update_frontmatter 의 missing-key append path 가 매 호출마다 트리거되던 것 → existing-key replace path 로 전환 = 결정적 frontmatter key order 보장 (phase / gate_id / sprint_id / created_at / last_touched_at). 5 smoke PASS (row 5).
- **`templates/.claude/commands/sfs.md`** — 136L→146L (+10L, +1059 bytes). Adapter dispatch table 4-row (status / start / plan / review) + procedure step 1 brace-list `sfs-{status,start,plan,review}.sh` 확장 + step 4 exit code 매핑 4 commands + step 5 stop hint `WU-25 §1.1/§2.1` (output 형식 verbatim) + 닫는 Rules 4-cmd 확장. plan/review fallback (Claude-driven mode) 도 보존 (script 부재 시 graceful degradation). 9 smoke PASS (row 6).
- **`VERSION`** — 첫 줄 `0.2.4-mvp` 유지 (cut 시점 bump). 주석 블록에 `next-next: 0.4.0-mvp` 예약 추가.

### Notes

- **gates.md §1 SSoT cross-ref** — sfs-review.sh validate_gate_id 함수 안 case 7-enum 은 gates.md §1 의 verbatim 사본. 변경 시 양쪽 동시 갱신.
- **WU-25 §1.3 / §2.3 verbatim** — sfs-plan.sh + sfs-review.sh exit codes 는 WU-25 spec 의 verbatim. 향후 sfs-common.sh 의 SFS_EXIT_* 환경변수 정식 정의 시 양쪽 fallback 패턴 (`: "${SFS_EXIT_*:=N}"`) 으로 충돌 회피.
- **R-D1 dev-first** — 본 entry 의 모든 산출물은 `solon-mvp-dist/templates/` (dev staging) 안. stable repo 동기화는 cut-release.sh 시점.
- **Smoke 누적** — sfs-plan.sh 7건 + sfs-review.sh 15건 + sfs-common.sh 8건 + sprint-templates 5건 + sfs.md 9건 = **44 smoke 0 FAIL**. dry-run sandbox 통합 (row 8) 은 후속.

## [0.3.0-mvp] — Unreleased (예약, WU-31 cut 대기)

> **상태**: WU-24 (#1 sfs slash 구현 part 1) 완료 후 본 entry 예약. 실 release cut 은 WU-31 `cut-release.sh --version 0.3.0-mvp` 실행 시점에 `Unreleased` → `YYYY-MM-DD` 로 치환.
> **β bundle 매핑**: WU-22 §3 β release roadmap 의 0.3.0-mvp = #1 (sfs slash) + #4 + #6. 본 entry 는 #1 만 우선 반영, #4/#6 은 cut 직전 일괄 추가.

### Added

- **`templates/.sfs-local-template/scripts/sfs-common.sh`** — `.sfs-local/` 검증 + state reader + sprint-id 생성 + status line 렌더 + events.jsonl append helper 군 (293 lines, bash 4+, jq optional). 함수 시그니처: `validate_sfs_local` / `read_current_sprint` / `read_current_wu` / `read_last_gate` / `read_last_gate_verdict` / `git_ahead_count` / `read_last_event_ts` / `generate_sprint_id_iso_week` / `render_status_line` / `append_event`.
- **`templates/.sfs-local-template/scripts/sfs-status.sh`** — `/sfs status` 어댑터 (129 lines). Output 형식: `sprint <id> · WU <wu_id> · gate <last>:<verdict> · ahead <N> · last_event <ISO8601>` (WU22-D4 정합). `--color=auto/always/never` flag (auto = tty 감지). Exit codes: 0=ok / 1=no `.sfs-local/` / 2=corrupt events.jsonl / 3=not git repo / 99=unknown.
- **`templates/.sfs-local-template/scripts/sfs-start.sh`** — `/sfs start [<sprint-id>] [--force]` 어댑터 (182 lines). Sprint-id pattern: `<YYYY-Wxx>-sprint-<N>` (ISO 8601 week, WU22-D5 정합). 4 templates copy + `current-sprint` 갱신 + events.jsonl `sprint_start` JSONL append. Path traversal 거부 + JSON-escape 보강. Exit codes: 0=ok / 1=sprint id 충돌 / 4=templates 부재 / 5=권한 / 99=unknown.
- **`templates/.sfs-local-template/sprint-templates/plan.md`** — `phase: plan` / `gate_id: G1` + 요구사항·AC·범위·G1 자기점검 4 §.
- **`templates/.sfs-local-template/sprint-templates/log.md`** — `phase: do` (no gate_id) + 시간순 append·결정/블로커·핸드오프 메모 3 §.
- **`templates/.sfs-local-template/sprint-templates/review.md`** — `phase: review` / `gate_id: ""` (`/sfs review --gate G2|G3|G4` 가 set) + 대상 gate·평가 항목·verdict·다음 액션 4 §.
- **`templates/.sfs-local-template/sprint-templates/retro.md`** — `phase: retro` / `gate_id: G5` / `closed_at: ""` (`/sfs retro --close` 가 set) + KPT·PDCA 학습·정량 메트릭·다음 sprint 인계·G5 close 체크 5 §.

### Changed

- **`templates/.claude/commands/sfs.md`** — Adapter dispatch 섹션 추가. `status` / `start` 두 모드는 `.sfs-local/scripts/sfs-{status,start}.sh` 가 single source of truth (Claude paraphrase 금지). 5단계 절차 (Existence check → Quote args safely → Execute → Print output verbatim → Stop) + dispatch table + exit code mapping + empty `$ARGUMENTS`→status default fallback. Claude-driven mode (`help` / `plan` / `sprint` / `review` / `decision` / `log` / `retro` 7개) 는 fallback 으로 보존, `status` / `start` 는 fallback only.
- **`VERSION`** — 첫 줄은 `0.2.4-mvp` 유지 (cut-release.sh 가 release cut 시점에 bump). 주석 블록으로 next 버전 (`0.3.0-mvp`) 예약.

### Notes

- **gates.md SSoT 정합** — sprint-templates 4 파일 모두 gates.md §1 (7-Gate enum) + §2 (verdict 3-value) + 05-gate-framework.md §5.1 SSoT pointer 명시.
- **R-D1 dev-first** — 본 entry 의 모든 산출물은 `solon-mvp-dist/templates/` (dev staging) 안에서 작업. stable repo (`~/workspace/solon-mvp/templates/`) 동기화는 cut-release.sh 시점.

## [0.2.4-mvp] — 2026-04-24

### Fixed

- **upgrade.sh** — `prompt()`가 프롬프트 문구를 stdout으로 출력해 기본값 Enter가 취소로 처리되던 문제 수정.

## [0.2.3-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — checksum 기반 자동 적용 정책으로 전환. 파일별 추가 질문 없이 신규 파일 설치,
  managed 파일 backup+overwrite, 프로젝트 지침 파일 보존을 자동 수행.

## [0.2.2-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — 프리뷰 마지막에 사용자가 실제로 누를 키와 기본값 의미를 명시.

## [0.2.1-mvp] — 2026-04-24

### Changed

- **upgrade.sh** — 변경 프리뷰를 line diff 대신 checksum 기반으로 표시.
- **upgrade.sh** — 파일별 추천 선택(`install`, `skip`, `backup+overwrite`)과 checksum 값을 함께 출력.
- **upgrade.sh** — non-TTY dry-run 에서 `/dev/tty` 경고가 노출되지 않도록 보정.

## [0.2.0-mvp] — 2026-04-24

### Added

- **templates/SFS.md.template** — Claude Code / Codex / Gemini CLI 가 공유하는 공통 SFS core 지침.
- **templates/AGENTS.md.template** — Codex adapter 추가.
- **templates/GEMINI.md.template** — Gemini CLI adapter 추가.

### Changed

- **templates/CLAUDE.md.template** — 전체 방법론 복제 대신 `SFS.md` 를 참조하는 Claude Code adapter 로 축소.
- **install.sh / upgrade.sh / uninstall.sh** — SFS core + Claude/Codex/Gemini adapter 파일을 함께 관리.
- **README.md** — runtime abstraction 을 MVP 범위로 명시하고 런타임별 사용법 추가.

## [0.1.1-mvp] — 2026-04-24

### Added

- **templates/.claude/commands/sfs.md** — Claude Code 프로젝트 slash command (`/sfs`) 추가.
  `status/start/plan/sprint/review/decision/log/retro` 모드로 `.sfs-local/` 기반 SFS 운용.

### Changed

- **install.sh** — consumer 프로젝트에 `.claude/commands/sfs.md` 를 설치하도록 확장.
- **/sfs command** — `/sfs` 또는 `/sfs help` 실행 시 사용법과 추천 첫 명령을 함께 안내.
- **README.md** — 설치 후 시작 명령을 `/sfs status` / `/sfs start` 중심으로 갱신.

## [0.1.0-mvp] — 2026-04-24

### Added

- **install.sh** — dual-mode 설치 스크립트 (`curl | bash` + local exec). 대화형 파일 충돌 처리
  (skip / backup / overwrite / diff). `.sfs-local/` merge 모드 (기존 sprint 산출물 보존).
  `.gitignore` 마커 기반 idempotent append.
- **upgrade.sh** — consumer `.sfs-local/VERSION` 와 distribution VERSION 비교. 파일별 diff
  미리보기 + 대화형 갱신.
- **uninstall.sh** — `.sfs-local/` 제거 + `.gitignore` 블록 제거. sprint 산출물 보존 옵션.
- **templates/CLAUDE.md.template** — 도메인 중립 (관리자 페이지 특화 제거). 7-step flow + 4
  Gate 운용 + 6 본부 abstract/active 구조만 포함.
- **templates/.gitignore.snippet** — `.sfs-local/events.jsonl` + `.sfs-local/tmp/` 등
  Solon 운영 파일 규칙. 프로젝트 일반 개발 규칙 (node_modules 등) 은 제외 (consumer 가 이미
  가지고 있을 가능성 높음, 중복 append 방지).
- **templates/.sfs-local-template/** — `divisions.yaml` + `events.jsonl` + `sprints/.gitkeep`
  + `decisions/.gitkeep` 스캐폴드.

### Scope 확정

- `solon-mvp` repo 정체: **Solon/SFS 시스템의 설치 가능한 MVP 배포**. consumer 프로젝트가
  `install.sh` 로 Solon 을 주입받아 7-step flow 운용 가능.
- consumer 프로젝트 자체는 별도 repo. `solon-mvp` 는 도구, consumer 는 도구 사용자.

### 이전 세션 (Solon docset WU-17/18/19) 과의 연결

- Solon docset `2026-04-19-sfs-v0.4/phase1-mvp-templates/` 가 본 distribution 의 모태.
  WU-18/19 에서 만든 setup-w0.sh / verify-w0.sh 는 `solon-mvp` repo **내부에서는 제거** —
  이 둘은 "consumer 프로젝트 처음 생성" 용이므로 distribution repo 에는 부적합.
- setup/verify 스크립트 기능은 `install.sh` 에 대화형 + idempotent 형태로 재흡수.

## Unreleased (예정)

- **foundation note** — 7-step flow 가 full startup team-agent artifact chain 의 lightweight projection 임을 README / SFS template / installer banner 에 명시. Production open 전 Release Readiness evidence 를 review 또는 retro-light 에 남기도록 보강.
- **0.3.0** — `install.sh` 원격 모드 (`curl | bash`) 에 따른 보안 강화 (hash 검증).
- **0.4.0** — `claude plugin install solon` 네이티브 플러그인 변환 검토 (HANDOFF §0 #13 end-state).
