# CLAUDE.md — Claude Code adapter for Solon Product SFS

This project uses Solon Product SFS (multi-adaptor by design — Claude Code / Codex / Gemini CLI 동등 1급).

Solon owns the `/sfs` workflow in this project. Do not render bkit-style
`Feature Usage`, `Used`, `Not Used`, or `Recommended` footers after Solon
commands. If runtime usage facts are useful, fold them into the existing Solon
Session Status Report shape as evidence/health/next information. `/sfs` output
must remain Solon-first and bash-adapter anchored.

Before planning or editing, read:

- `SFS.md`
- `.sfs-local/VERSION`
- `.sfs-local/divisions.yaml`
- recent files under `.sfs-local/sprints/`
- recent files under `.sfs-local/decisions/`

## SFS commands — bash adapter SSoT

Solon Product SFS 의 10 슬래시 명령은 모두 `sfs <command>` global runtime 이
deterministic bash adapter 로 내려보낸다. `.sfs-local/scripts/` 는 vendored layout 의
fallback 이고, 기본 방향은 project-local state + packaged runtime 이다.
Claude Code 의 native slash 진입점은 `.claude/commands/sfs.md` 가 자동 install 되며,
동일한 dispatch table 을 따른다 (paraphrase 금지, 결정성 유지):

| 슬래시 | 실행 |
|:--|:--|
| `/sfs status [--color=auto/always/never]` | `sfs status [--color=auto/always/never]` |
| `/sfs start <goal> [--id <sprint-id>] [--force]` | `sfs start <goal> [--id <sprint-id>] [--force]` |
| `/sfs guide [--path|--print]` | `sfs guide [--path|--print]` |
| `/sfs auth status|check|login|probe [--executor <tool>]` | `sfs auth status|check|login|probe [--executor <tool>]` |
| `/sfs brainstorm [text|--stdin]` | `sfs brainstorm [text|--stdin]` raw capture 후 Claude 가 Solon CEO 로 §1~§7 정리 |
| `/sfs plan` | `sfs plan` 후 Claude 가 `brainstorm.md` 기반 G1 plan + CTO/CPO contract 작성 |
| `/sfs review --gate <id> [--executor <tool>] [--prompt-only]` / `/sfs review --show-last` | `sfs review --gate <id> [--executor <tool>] [--prompt-only]` 또는 `sfs review --show-last`; 기본은 선택된 CPO executor bridge 실행 + verdict/output path 메타데이터 출력, `--prompt-only` 는 수동 handoff, `--show-last` 는 executor 재실행 없이 기존 결과를 사용자 언어의 요약/action report 로 확인 |
| `/sfs decision <title> [--id <id>]` | `sfs decision "<title>" [--id <id>]` 후 Claude 가 ADR 본문 작성 |
| `/sfs retro [--close]` | `sfs retro [--close]`; `--close` 는 Claude 가 `retro.md` 를 먼저 채운 뒤 close adapter 1회 실행 |
| `/sfs loop [OPTIONS]` | `sfs loop [OPTIONS]` (Ralph Loop + Solon mutex) |
| `/sfs`, `/sfs help` | usage 출력 (`.claude/commands/sfs.md` 의 self-help) |

`sfs` runtime 이 PATH 에 없으면 그 사실을 1줄로 사용자에게 알리고 install/upgrade 를 안내한다.
stdout / stderr / exit code 는 verbatim 보고한다 (paraphrase 금지).

명령 모드는 고정이다:
- **Bash-only**: `status`, `start`, `guide`, `auth`, `loop`.
- **Always hybrid**: `brainstorm`, `plan`, `decision`, `retro`.
- **Adapter-run**: `review` — 기본적으로 bash adapter 가 선택된 CPO executor bridge 를 실행하고 stdout 에는 verdict/output path 메타데이터만 보여준다. Claude 는 result 원문을 그대로 덤프하지 않고 사용자 언어로 요약/action report 를 렌더링한다. `--prompt-only` 일 때도 현재 Claude runtime 이 대신 verdict 를 작성하지 않고 prompt handoff 로 멈춘다.

부족한 정보가 있으면 1~3개 질문만 남기고, 다음 gate 를 자동 실행하지 않는다.

## `/sfs loop` — multi-adaptor LLM executor convention

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site 다. Claude Code 환경에서 호출하든
다른 CLI 에서 호출하든 동일한 `--executor` flag (또는 `SFS_EXECUTOR` env) 로 LLM CLI 를 명시:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini --skip-trust --yolo --output-format text -p "Read stdin and execute the requested task."`
- `--executor codex` → `codex exec --full-auto --ephemeral --output-last-message <result> -`
- `--executor "<custom command>"` → 그대로 passthrough

이 convention 은 Solon-wide invariant 다 — `loop` 만 multi-adaptor 가 아니라, Solon 의 모든
슬래시 명령이 어느 1급 CLI 에서든 동등한 deterministic bash adapter SSoT 로 동작한다. 본
CLAUDE.md (Claude Code adapter) 와 짝이 되는 AGENTS.md (Codex) / GEMINI.md (Gemini CLI) 도
동일 규약을 따른다.

## 운영 규율

- 사용자 작업 보존 (Preserve user work). 결정으로 인해 동작이 바뀌거나 작업이 삭제될 수
  있을 때만 묻는다.
- `git push origin *` 자동 실행 금지 — push 는 사용자 터미널에서만 (Solon §1.5).
- Bash adapter 출력 paraphrase 금지 — 결정성 유지.
