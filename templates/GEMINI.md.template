# GEMINI.md — Gemini CLI adapter for Solon Product SFS

This project uses Solon Product SFS, the **Solo Founder System** for AI-native product work
(multi-adaptor by design — Claude Code / Codex / Gemini CLI 동등 1급).

Before planning or editing, read:

- `SFS.md`
- `.sfs-local/VERSION`
- `.sfs-local/divisions.yaml`
- recent files under `.sfs-local/sprints/`
- recent files under `.sfs-local/decisions/`

## SFS commands — bash adapter 우선 (deterministic SSoT)

Solon Product SFS 의 12 슬래시 명령은 모두 `sfs <command>` global runtime 이
deterministic bash adapter 로 내려보낸다. `.sfs-local/scripts/` 는 vendored layout 의
fallback 이고, 기본 방향은 project-local state + packaged runtime 이다.
Gemini CLI 는 native `/sfs` slash 가 없어도 사용자 발화를 다음 명령으로 해석해서 **bash
adapter 를 직접 호출**한다 (paraphrase 금지, 결정성 유지):

| 사용자 발화 | 실행할 명령 |
|:--|:--|
| `sfs status`, `/sfs status` | `sfs status [--color=auto/always/never]` |
| `sfs start <goal>`, `/sfs start <goal>` | `sfs start <goal> [--id <sprint-id>] [--force]` |
| `sfs guide`, `/sfs guide` | `sfs guide [--path|--print]` |
| `sfs auth ...`, `/sfs auth ...` | `sfs auth status|check|login|probe [--executor <tool>]` |
| `sfs brainstorm`, `/sfs brainstorm` | `sfs brainstorm [text|--stdin]` raw capture 후 Gemini 가 Solon CEO 로 §1~§7 정리 |
| `sfs plan`, `/sfs plan` | `sfs plan` 후 Gemini 가 `brainstorm.md` 기반 G1 plan + CTO/CPO contract 작성 |
| `sfs implement`, `/sfs implement` | `sfs implement [work slice|--stdin]` 후 Gemini 가 `plan.md` 기반 실제 코드 변경 + 테스트/스모크 evidence 작성 |
| `sfs review --gate <id> [--executor <tool>] [--prompt-only]`, `/sfs review --gate <id> [--executor <tool>] [--prompt-only]`, `/sfs review --show-last` | `sfs review --gate <id> [--executor <tool>] [--prompt-only]` 또는 `sfs review --show-last [--gate <id>]`; 기본은 선택된 CPO executor bridge 실행, `--prompt-only` 는 수동 handoff, `--show-last` 는 executor 재실행 없이 기존 결과를 사용자 언어의 요약/action report 로 확인 |
| `sfs decision <title>`, `/sfs decision <title>` | `sfs decision "<title>" [--id <id>]` 후 Gemini 가 ADR 본문 작성 |
| `sfs report [--sprint <id>] [--compact]`, `/sfs report [--sprint <id>] [--compact]` | `sfs report [--sprint <id>] [--compact]`; Gemini 가 workbench 산출물을 한 장짜리 최종 작업보고서로 정리. `--compact` 는 사용자 동의 후 redirect/stub 압축 |
| `sfs retro [--close]`, `/sfs retro [--close]` | `sfs retro [--close]`; `--close` 는 Gemini 가 `retro.md` 와 `report.md` 를 먼저 채운 뒤 close adapter 1회 실행 |
| `sfs loop ...`, `/sfs loop ...` | `sfs loop [OPTIONS]` (Ralph Loop + Solon mutex, see `--help`) |

각 스크립트의 stdout 은 verbatim 그대로 사용자에게 보여주고 (paraphrase 금지),
non-zero exit 시 stderr + exit code 도 함께 보고한다. `sfs` runtime 이 PATH 에 없으면
그 사실을 1줄로 사용자에게 알리고 install/upgrade 를 안내한다.

명령 모드는 고정이다:
- **Bash-only**: `status`, `start`, `guide`, `auth`, `loop`.
- **Always hybrid**: `brainstorm`, `plan`, `implement`, `decision`, `report`, `retro`.
- **Adapter-run**: `review` — 기본적으로 bash adapter 가 선택된 CPO executor bridge 를 실행하고 stdout 에는 verdict/output path 메타데이터만 보여준다. Gemini 는 result 원문을 그대로 덤프하지 않고 사용자 언어로 요약/action report 를 렌더링한다. `--prompt-only` 일 때도 현재 Gemini runtime 이 대신 verdict 를 작성하지 않고 prompt handoff 로 멈춘다.

부족한 정보가 있으면 1~3개 질문만 남기고, 다음 gate 를 자동 실행하지 않는다.

### `/sfs implement` — implementation execution

`/sfs plan` 은 구현 계약을 만드는 명령이고, `/sfs implement` 가 실제 코드를 바꾸는 명령이다.
adapter stdout 을 먼저 그대로 보여준 뒤, Gemini 는 `plan.md`, `implement.md`, `log.md`, 관련
프로젝트 파일을 읽고 구현까지 진행한다.

구현 기본값:
- Think Before Coding: 가정, trade-off, 성공 기준을 짧게 잡고 모호하면 질문한다.
- Simplicity First: AC 를 증명하는 최소 code/document surface 로 구현한다.
- Surgical Changes: 요청 slice 와 직접 연결된 줄만 바꾸고, 관련 없는 정리는 follow-up 으로 남긴다.
- Goal-Driven Execution: 변경 파일만으로 완료 처리하지 않고 검증 evidence + review handoff 까지 남긴다.
- 공유 design concept 과 변경 boundary 를 먼저 확인한다.
- DDD-lite 로 같은 domain term 을 코드/테스트/문서에서 같은 뜻으로 쓴다.
- 가능하면 TDD-lite 로 작은 failing/covering test → pass → refactor 순서로 간다.
- 기존 codebase regularity 를 우선하고, one-off 패턴을 늘리지 않는다.
- 구현 후 `implement.md` 와 `log.md` 에 변경 파일, 검증 명령, 결과, review handoff 를 남긴다.

### `/sfs report` — final report refinement

`brainstorm.md`, `plan.md`, `implement.md`, `log.md`, `review.md` 는 작업 중
workbench 다. Sprint 완료 전 Gemini 는 `/sfs report` 로 `report.md` 를 간결한 최종
작업보고서로 정리한다. 핵심은 결과, 범위, 결정, 구현 요약, 검증 evidence, 남은 리스크다.
Raw chronology 는 `retro.md`, `log.md`, session/events 에 남긴다.

## `/sfs loop` — 멀티 adaptor LLM executor convention

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site 다. 어떤 CLI 환경에서 호출하든
`--executor` flag (또는 `SFS_EXECUTOR` env) 로 LLM CLI 를 명시한다:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini --skip-trust --yolo --output-format text -p "Read stdin and execute the requested task."`
- `--executor codex` → `codex exec --full-auto --ephemeral --output-last-message <result> -`
- `--executor "<custom command>"` → 그대로 passthrough

이 convention 은 Solon-wide invariant 다 — `loop` 만 multi-adaptor 가 아니라, Solon 의 모든
슬래시 명령이 Claude/Codex/Gemini 어느 1급 CLI 에서든 동등한 deterministic bash adapter
SSoT 로 동작한다. 본 GEMINI.md (Gemini CLI adapter) 와 짝이 되는 AGENTS.md / CLAUDE.md 도
동일 규약을 따른다.

## 운영 규율

- 사용자 작업 보존 (Preserve user work). 결정으로 인해 동작이 바뀌거나 작업이 삭제될 수
  있을 때만 묻는다.
- Git Flow lifecycle 은 Gemini 가 소유한다. 새 작업 전 `git status --short` + 현재 branch 확인,
  도메인별 `feature/<domain>-<short-slug>` 또는 `hotfix/<domain>-<short-slug>` 생성/전환,
  검증, commit, branch push, main 흡수, origin main push 까지 완료 조건으로 수행한다.
- destructive git, unrelated dirty set, merge conflict, failing tests, protected branch/remote rejection,
  auth prompt 에서만 stop + 사용자 결정/실행 요청.
- 무차별 `git push origin *` 금지. 정확한 branch/main push 만 수행한다.
