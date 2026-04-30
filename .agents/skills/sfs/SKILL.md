---
name: sfs
description: Solon SFS workflow for Codex — use $sfs status/start/guide/auth/update/brainstorm/plan/review/decision/retro/loop or natural language to dispatch to bash adapter SSoT; brainstorm/plan/decision/retro are AI-hybrid refinements, review is adapter-run by default through the selected CPO executor bridge. Trigger when a Codex surface delivers $sfs, sfs <command>, /sfs text that reaches the model, or a Solon SFS workflow request (e.g., "현재 상태 확인", "guide 보기", "auth 확인", "update", "sprint 시작", "브레인스토밍", "plan 작성", "review 작성", "decision 기록", "retro close", "loop 자율 진행"). Bash adapter is single source of truth for command I/O — paraphrase forbidden, exit codes verbatim.
---

# Solon SFS — Codex Skill

This project uses Solon SFS. In Codex, prefer `$sfs <command>` or a natural
language Solon workflow request. Bare `/sfs` may be intercepted by the Codex
native slash UI before this Skill sees it (`커맨드 없음` / `Unrecognized command`).
When the user invokes `$sfs <command>`, types `sfs <command>`, sends `/sfs`
text that actually reaches the model, or expresses a Solon SFS workflow intent,
dispatch the request to the `sfs` runtime command first. The runtime may be a
global package (thin layout) or a project-local vendored fallback.

Command modes are explicit:
- **Bash-first**: `status`, `start`, `guide`, `auth`, `update`, `loop`. Print verbatim
  adapter output first. A compact recap/status line is allowed when it helps
  the user see state and the next action, but adapter stdout remains SSoT.
- **Always hybrid**: `brainstorm`, `plan`, `decision`, `retro`. Run the
  adapter first, then perform the documented AI-side file refinement.
- **Adapter-run**: `review`. The bash adapter executes the selected CPO
  executor bridge by default. Stop after adapter output. If `--prompt-only` is
  used, treat the prompt path as manual handoff material and do not write a
  Codex verdict in the current runtime.

Sprint mode guidance:
- Do not treat every new sprint as a fresh discovery/planning sprint. If the
  user just closed a planning sprint whose `plan.md`, review, or ADR already
  defines the implementation backlog, the next sprint is an implementation
  sprint by default.
- For an implementation sprint, G0/G1 should be thin: record `inherit-from:
  <prior sprint/plan/ADR>`, scope, and binary AC only when useful, then proceed
  to the first code slice and `log.md` evidence. Do not recommend repeating a
  full `brainstorm -> plan` loop unless the inherited contract is missing or
  ambiguous.
- If the sprint goal names concrete build work such as repo scaffold, dev
  compose, DB schema, API boot, tests, or UI behavior, do not recap G1 contract
  completion as sprint completion. Sprint completion requires implementation
  evidence, test/smoke evidence, review, and retro, unless the user explicitly
  scoped it as planning-only.
- After `start`, a short recap is allowed and often useful. Its `Next` must be
  inferred from sprint mode: fresh discovery can point to `brainstorm`, while
  inherited implementation work should point to the first code slice, `log.md`
  evidence, and later G4 review.

Special close guard: if the user invokes `retro --close` in an AI runtime, do
not run the close adapter first. Run `retro` without `--close`, refine
`retro.md`, then run `retro --close` exactly once.

If you can read a user message that begins with `/sfs`, the runtime has already
delivered the Solon command to this Skill. Dispatch it. But do not claim Codex
native slash registration exists: current Codex app/CLI surfaces can block
unknown slash commands before the model sees them. In that case the user should
invoke `$sfs status`, `sfs status`, natural language, or direct bash
(`sfs status`, or `bash .sfs-local/scripts/sfs-dispatch.sh status` only in
vendored layout).

The bash adapter execution is **deterministic** and must NOT be
re-interpreted by the model. Bash adapter is single source of truth (SSoT) for
command I/O. Hybrid commands have documented AI-side follow-ups:
Solon CEO refinement of `brainstorm.md` §1~§7, G1 plan + CTO/CPO sprint
contract refinement of `plan.md`, ADR refinement for `decision`, and G5 retro
refinement for `retro`. Review verdicts come from the selected CPO executor
bridge or a manual `--prompt-only` handoff.

## Solon Report Output Rule

For hybrid commands (`brainstorm`, `plan`, `decision`, `retro`) and adapter-run
`review`, the final answer must be a **Solon report**, not a plain bullet list
such as `plan.md refined: ...`. Put the whole report in a fenced `text` block.
Render the report in the user's visible language (for example, Korean for a
Korean user), even when executor evidence is in English. For `review`, do not
dump raw executor markdown or `CPO RESULT EXCERPT` blocks into the user-facing
answer. Treat adapter stdout as compact metadata, read `output_path` /
`result_path` / `review.md` when needed, then summarize and translate verdict,
findings, and required actions into the report.

Use this shape and fill only evidence-backed values:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SOLON REPORT — /sfs <command>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Command <command> · <goal/gate/artifact>      [<status>]
⏱️ Time    <started> → <finished>  (<duration or "n/a">)
───────────────────────────────────────────────────
🔧 Steps   <N>건 — <adapter/refinement/review path summary>
📁 Files   <N>개 — <created/updated artifact paths>
💾 Commits <N>건 — <sha or "없음 (planning/review artifact)">
📊 Health  Solon SSoT ✓ | adapter <✓/−> | CEO <✓/−> | CTO/CPO <✓/−> | Solon owner ✓
🔎 Review  <verdict/skipped/prompt-only/n/a> — <executor result summary for review only>
🛠 Actions <N>건 — <Required CTO actions summary, or "없음/unknown">
───────────────────────────────────────────────────
❓ Questions <N>건 — <질문 요약 또는 "없음">
⚠️ Escalation <N>건 — <1줄 요약 또는 "없음">
📚 Learning   <N>건 — <1줄 요약 또는 "없음">
───────────────────────────────────────────────────
⏭️ Next  <next Solon command/action>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Never render non-Solon usage footers such as `Used`, `Not Used`, or
`Recommended` after SFS commands. If those facts are useful, map them into
`Steps`, `Health`, and `Next` inside the Solon report.

For `/sfs review`, surface the executor-provided result that already exists in
adapter stdout, `result_path`, or `review.md`: verdict, key findings, and
required CTO actions. Show a concise report, not the source markdown body. Do
not create a new verdict in the current runtime.

## Dispatch Table

| User intent / first arg | Script to run | Notes |
|:--|:--|:--|
| `status` (또는 "현재 상태", "어디까지 했는지") | `sfs status [--color=auto/always/never]` | 1줄 dashboard |
| `start <goal>` (또는 "sprint 시작", "새 sprint") | `sfs start <goal> [--id <sprint-id>] [--force]` | sprint workspace 초기화 + sprint files cp |
| `guide [--path|--print]` (또는 "가이드", "처음 사용법") | `sfs guide [--path|--print]` | 기본은 짧은 맥락 브리핑, `--path` 는 경로만, `--print` 는 full guide 본문 |
| `auth status|check|login|probe` (또는 "인증 확인", "Gemini 로그인") | `sfs auth <args>` | Codex/Claude/Gemini review executor 인증 점검/부트스트랩/더미 요청 |
| `update [--skip-existing]` (또는 "Solon 업데이트", "adapter 갱신") | `sfs update [--skip-existing]` | 현재 설치된 runtime 기준으로 managed adapter/docs 갱신. sprint/decision/event history 보존 |
| `brainstorm [text|--stdin]` (또는 "브레인스토밍", "요구사항 정리") | `sfs brainstorm <raw context>` | G0 raw 요구사항/대화 맥락을 brainstorm.md 에 기록한 뒤 §1~§7을 Solon CEO로 정리. newline 허용 |
| `plan` (또는 "plan 작성", "이번 sprint 계획") | `sfs plan` | plan.md 진입 + plan_open event 후 brainstorm.md 기반 G1 plan/contract 작성 |
| `review --gate <id> [--executor <tool>] [--prompt-only]` / `review --show-last` (또는 "CPO review", "검증 기록", "이전 리뷰 확인") | `sfs review --gate <id> [--executor <tool>] [--generator <tool>] [--prompt-only]` 또는 `sfs review --show-last [--gate <id>]` | CPO Evaluator bridge run by default. `--prompt-only` creates prompt/log for manual handoff. `--show-last` prints compact metadata for the latest recorded result without rerunning executor. id ∈ G-1, G0, G1, G2, G3, G4, G5 |
| `decision <title>` (또는 "결정 기록", "ADR 추가") | `sfs decision "<title>" [--id <id>]` | ADR file 생성 후 Context/Decision/Alternatives/Consequences refinement |
| `retro [--close]` (또는 "회고", "sprint close") | `sfs retro [--close]` | retro.md 진입 후 KPT/PDCA refinement. `--close` 는 refinement 후 1회 실행 |
| `loop [OPTIONS]` (또는 "자율 진행", "loop 시작") | `sfs loop [OPTIONS]` | Ralph Loop + Solon mutex (see `--help`) |

## Procedure

1. **Existence check** — Use the shell tool to verify `sfs` is available
   (`command -v sfs`). If it is missing, tell the user in 1 line and stop (do
   NOT try to recreate the runtime — install/upgrade is user's responsibility
   via Homebrew/source package or `install.sh --layout vendored` fallback).

   In vendored layout only, `.sfs-local/scripts/sfs-dispatch.sh <command>` is
   an acceptable fallback. Windows users should run global `sfs` from Git
   Bash/WSL, or use `.sfs-local/scripts/sfs.ps1` only in vendored layout.

2. **Quote args safely** — Re-quote `<remaining args>` for the shell. Reject
   any argument containing a newline or NUL byte by reporting `unknown arg`,
   except for `brainstorm`, where multiline raw requirement context is allowed.

3. **Execute** — Run the script via the shell tool. Capture stdout, stderr,
   and exit code. Do not pipe through any other transformer.

4. **Print output verbatim** — Emit the script's stdout exactly as produced.
   If exit code is non-zero, also print stderr and the exit code on a final
   line: `exit <code>`. Map known exit codes per the script contract:
   - status: `0`=ok, `1`=no `.sfs-local/`, `2`=corrupt `events.jsonl`,
     `3`=not a git repo, `99`=unknown.
   - start: `0`=ok, `1`=sprint id conflict (suggest `--force`), `4`=templates
     missing, `5`=permission, `99`=unknown.
   - guide: `0`=ok, `1`=no `.sfs-local/`, `4`=guide missing,
     `99`=unknown.
   - auth: `0`=ok, `1`=no `.sfs-local/`, `7`=usage,
     `9`=auth missing/bootstrap failed, `99`=unknown.
   - brainstorm: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `2`=corrupt `events.jsonl` / `current-sprint`, `3`=not a git repo,
     `4`=template missing, `5`=permission, `99`=unknown.
   - plan: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
     missing, `99`=unknown.
   - review: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
    missing, `6`=gate id invalid or required, `7`=usage,
    `9`=executor bridge missing/failed, `99`=unknown.
   - decision: `0`=ok, `1`=id conflict, `4`=template missing, `7`=usage,
     `99`=unknown.
   - retro: `0`=ok, `1`=no `.sfs-local/` or no active sprint, `4`=template
     missing, `7`=usage, `8`=`--close` requested but review.md missing,
     `99`=unknown.
   - loop: `0`=success, `1`=invalid usage, `2`=PROGRESS parse error,
     `3`=drift, `4`=mutex claim failed, `5`=safety_lock, `6`=spec missing,
     `7`=verify fail, `8`=heartbeat fail, `9`=executor resolve fail,
     `99`=unknown.

5. **Stop or continue by command mode** — After dispatch, bash-first commands
   must preserve adapter stdout exactly. A compact Solon recap/status is allowed
   only when it adds state or the next action, and must not contradict the
   sprint mode. Hybrid commands continue only via the documented flow below:
   - `brainstorm` → Brainstorm CEO Refinement
   - `plan` → Plan G1 Refinement
   - `decision` → Decision ADR Refinement
   - `retro` → Retro G5 Refinement
  - `review` → Review CPO Handling. Use adapter stdout as metadata, read the
    recorded result path when present, then render a localized Solon report
    from recorded adapter/executor evidence only. Do not echo raw result bodies.

## Brainstorm CEO Refinement

`/sfs brainstorm` is not capture-only in AI runtimes. After the bash adapter
succeeds and stdout has been shown verbatim:

1. Resolve the active `brainstorm.md` path from adapter stdout. If stdout cannot
   be parsed, read `.sfs-local/current-sprint` and open
   `.sfs-local/sprints/<current-sprint>/brainstorm.md`.
2. Read `brainstorm.md`, especially `§8. Append Log`. Treat the append log as
   user raw data and preserve it.
3. Act as **Solon CEO**. Fill or update `§1` through `§6` from the raw input and
   existing context:
   - `§1` concise raw brief / conversation notes.
   - `§2` problem owner, urgency, current pain, success state.
   - `§3` technical, deployment, cost/time, and user learning constraints.
   - `§4` at least two options, including a deliberately smaller MVP option.
   - `§5` in scope / out of scope / next sprint candidates.
   - `§6` goal, acceptance criteria candidates, major risks, CTO Generator
     deliverables, and CPO Evaluator review criteria.
4. Update `§7` checklist based only on what is actually satisfied.
5. If critical information is missing, add concise open questions inside `§6`
   or immediately before `§7`, and ask up to 3 questions in the final response.
   Still fill known sections with explicit assumptions and unknowns.
6. Set frontmatter `status: ready-for-plan` only when `§6` is usable for
   `/sfs plan`; otherwise keep `status: draft`.
7. Do not implement code, choose a framework, or run `/sfs plan` automatically.
8. Final response: render a Solon report. Include `brainstorm.md` path in
   `Files`, question count in `Questions`, and `Next: /sfs plan` when status is
   `ready-for-plan`; otherwise `Next: answer questions, then /sfs brainstorm`.

## Plan G1 Refinement

`/sfs plan` is not adapter-only in AI runtimes. `$sfs plan` / `sfs plan` should
first run the bash adapter, then fill `plan.md` from the current G0 context.

1. Resolve the active `plan.md` path from adapter stdout. If stdout cannot be
   parsed, read `.sfs-local/current-sprint` and open
   `.sfs-local/sprints/<current-sprint>/plan.md`.
2. Open the same sprint's `brainstorm.md`. Treat `brainstorm.md` §1~§7 and
   §8 Append Log as the source of truth.
3. Act as **Solon CEO** for requirements and scope, then write the
   **CTO Generator ↔ CPO Evaluator** sprint contract:
   - `§1` measurable requirements.
   - `§2` binary/verifiable acceptance criteria and anti-AC.
   - `§3` in scope / out of scope / dependencies and decision points.
   - `§4` G1 checklist based only on satisfied items.
   - `§5` CEO decision, CTO deliverables, CPO validation criteria,
     rework contract, and user decision points.
   - Add `§6 Phase 1 구현 Backlog Seed` when it materially helps the next
     implementation sprint.
4. Preserve user edits already present in `plan.md`; refine or complete them
   rather than replacing with a generic template.
5. If `brainstorm.md` is too sparse, fill known assumptions, leave explicit
   open questions, and ask up to 3 questions in the final response.
6. Do not implement code, choose irreversible infrastructure, or run
   `/sfs review` automatically.
7. Final response: render a Solon report. Include `plan.md` path in `Files`,
   question count in `Questions`, and `Next: /sfs review --gate G1 --executor codex --generator claude`
   when ready; otherwise `Next: answer questions, then /sfs plan`.

## Decision ADR Refinement

`/sfs decision` is not adapter-only in AI runtimes. After the bash adapter
succeeds and stdout has been shown verbatim:

1. Resolve the created ADR path from `decision created: <path>`. If stdout
   cannot be parsed, open the newest file under `.sfs-local/decisions/`.
2. Read the active sprint context when available: `brainstorm.md`, `plan.md`,
   `review.md`, `retro.md`, and `.sfs-local/events.jsonl`.
3. Act as **Solon CEO**. Fill or update ADR sections:
   - `Context`: why this decision is needed, sprint/gate reference, known
     constraints.
   - `Decision`: the selected option and 1-3 core reasons. If the title is only
     a question, keep `status: proposed` and write the most likely proposal.
   - `Alternatives`: at least one rejected/deferred alternative, or
     `none considered` with a reason.
   - `Consequences`: positive effects, trade-offs, risks, and affected areas.
   - `References`: sprint artifact paths, event ids/commit sha if known, and
     related decisions.
4. Preserve frontmatter and user edits. Do not implement code.
5. Ask up to 3 questions only if the ADR cannot be understood without them.
6. Final response: render a Solon report. Include the ADR path in `Files`,
   question count in `Questions`, and `Next: continue current sprint`.

## Review CPO Handling

`/sfs review` is mandatory in the Solon flow, but the current Codex runtime
must not silently self-validate after the adapter succeeds.

1. The default command executes the selected CPO executor bridge and appends the
   result summary to `review.md`.
2. If there is no reviewable evidence, the adapter exits 0 with "리뷰할 항목이
   없습니다" and suggests `/sfs auth probe --executor <tool>` for bridge tests.
3. If `--show-last` / `--show` / `--last` is used, the adapter prints compact
   metadata for the latest recorded CPO result without invoking an executor.
   Read the referenced result file/review.md and surface that prior result in
   the report.
4. If `--prompt-only` is used, stop after adapter output and treat
   `prompt_path` as manual handoff material. Do not write a Codex verdict unless
   the user explicitly starts a separate review task with that prompt.
5. Final response after normal adapter output: render a Solon report in the
   user's visible language. Fill `Review` and `Actions` from the executor
   result path or `review.md` when present, translating/summarizing as needed.
   Do not print the raw result markdown unless the user explicitly asks for the
   raw source. Do not add an extra CPO verdict from the current runtime.

## Retro G5 Refinement

`/sfs retro` is not adapter-only in AI runtimes. After the adapter succeeds and
stdout has been shown verbatim:

1. Resolve `retro.md` from stdout or active sprint.
2. Read sprint artifacts: `brainstorm.md`, `plan.md`, `log.md`, `review.md`,
   `.sfs-local/events.jsonl`, and related decisions.
3. Fill or update `§1` KPT, `§2` PDCA learning, `§3` metrics when evidence
   exists, `§4` next sprint handoff, and `§5` close checklist.
4. Preserve user edits. Do not invent completed work; mark unknowns explicitly.
5. If the user invoked `retro --close`, refine `retro.md` first, then run
   `bash .sfs-local/scripts/sfs-dispatch.sh retro --close` exactly once and
   print its output verbatim.
6. Final response when not closing: render a Solon report. Include `retro.md`
   path in `Files`, close-readiness in `Health`, and `Next: /sfs retro --close`
   if ready; otherwise the next required action.

## If first arg is empty or `help`

Print this 3-line usage and stop:

```
Usage: /sfs <command> [args]
Commands: status, start, guide, auth, update, brainstorm, plan, review, decision, retro, loop
Help: bash .sfs-local/scripts/sfs-<command>.sh --help
```

## ⚠️ Safety Locks

- `/sfs retro --close` triggers an auto-commit. In AI runtimes, refine
  `retro.md` before running the close adapter, and only when the user explicitly
  requested close.
- Never run `git push origin *` automatically — push is user-only (§1.5).
- If the bash adapter is missing, do NOT try to fall back to a paraphrase
  workflow that simulates Solon SFS — instead tell the user the adapter is
  missing and suggest `install.sh` / `upgrade.sh`.

## Multi-adaptor Parity

This Skill is the Codex 1급 entry point for Solon SFS. The same workflow is
also exposed through these entry points:

- **Claude Code**: `.claude/commands/sfs.md` (slash command, native dispatch)
- **Gemini CLI**: `.gemini/commands/sfs.toml` (TOML custom command, native slash)
- **Codex**: 본 Skill (`.agents/skills/sfs/SKILL.md`, project-scoped).
  `$sfs ...` / `sfs ...` / natural language are the practical Codex entry paths
  because current Codex app/CLI surfaces may intercept bare `/sfs` before the
  model sees it. If `/sfs ...` text does reach this Skill, dispatch it.

All entry points dispatch to the SAME bash adapter (`.sfs-local/scripts/sfs-*.sh`).
Vendor-asymmetry between adapters is forbidden — if you find drift, it's a
bug to escalate via `/sfs decision` or report upstream.
