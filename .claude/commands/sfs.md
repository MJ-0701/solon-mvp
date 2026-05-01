---
name: sfs
description: |
  Solon SFS workflow command.

  Usage: /sfs [command] [goal/details]

  Commands:
  help      사용법 보기
  status    현재 SFS 상태 확인 (bash adapter)
  start     새 sprint workspace 초기화 (bash adapter)
  guide     사용 맥락 브리핑/guide 출력
  auth      Codex/Claude/Gemini review executor 인증 확인/로그인
  update    현재 설치된 Solon runtime 기준으로 project adapter/docs 갱신
  brainstorm G0 raw 요구사항/대화 맥락 기록
  plan      현재 sprint plan.md 작성/갱신 + G1 sprint contract refinement
  implement plan 기반 실제 코드 구현 + 테스트/evidence 기록
  sprint    plan을 구현 단계와 gate 체크로 정리
  review    CPO review bridge run/verdict (adapter-run by default)
  decision  결정 기록 생성 + ADR refinement
  report    최종 작업보고서 작성/갱신 (+ --compact workbench 압축)
  log       events.jsonl에 이벤트 기록
  retro     sprint 회고 작성/갱신 (+ --close before/after guard)
  commit    working tree 의미 그룹 분류 + branch preflight + 선택 그룹 local commit
  loop      Ralph Loop + Solon mutex 기반 자율 진행 (bash adapter, WU-27)
argument-hint: "[command] [goal/details]"
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# Solon SFS Command

You are running the Solon SFS workflow for this project.

## Runtime Boundary — Solon Owns `/sfs`

`/sfs` is a Solon command. Solon is the primary workflow owner for this command.

Do not render non-Solon usage footers after Solon commands. If usage facts are
useful or requested by the runtime, fold those facts into the existing Solon
Session Status Report shape as evidence/health/next information. The report
design is Solon-owned:

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SOLON STATUS — SFS command
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Command <command> · <goal/gate>              [<status>]
⏱️ Time    <started> → <finished>  (<duration>)
───────────────────────────────────────────────────
🔧 Steps   <N>건 — Bash adapter / CEO refinement / CPO review 등 실제 사용 경로
📁 Files   <N>개 — 수정·생성된 Solon 산출물 요약
💾 Commits <N>건 — 없음 또는 local commit sha
📊 Health  Solon SSoT ✓ | adapter <✓/−> | CEO <✓/−> | CTO/CPO <✓/−> | Solon owner ✓
───────────────────────────────────────────────────
⚠️ Escalation <N>건 — <1줄 요약 또는 "없음">
📚 Learning   <N>건 — <1줄 요약 또는 "없음">
───────────────────────────────────────────────────
⏭️ Next  <다음 Solon action 1줄>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Do not imply any non-Solon tool owns or orchestrates the Solon workflow. Do not
add any other Claude-driven commentary after deterministic SFS commands, except
for the documented hybrid/conditional flows below.

### Solon Report Output Rule

For hybrid commands (`brainstorm`, `plan`, `implement`, `decision`, `report`, `retro`) and adapter-run
`review`, the final answer must be a **Solon report**, not a plain bullet list
such as `plan.md refined: ...`. Put the whole report in a fenced `text` block.
Render the report in the user's visible language (for example, Korean for a
Korean user), even when executor evidence is in English. For `review`, do not
dump raw executor markdown or `CPO RESULT EXCERPT` blocks into the user-facing
answer. Treat adapter stdout as compact metadata, read `output_path` /
`result_path` / `review.md` when needed, then summarize and translate verdict,
findings, and required actions into the report.

Use this shape and fill only evidence-backed values:

Decision references in user-facing reports must be self-describing. Never output
naked shorthand such as `D6`, `D6·D7·D8`, `WU27-D6`, or `W-24` in `Next`,
`Actions`, `Questions`, `Escalation`, or `Learning` unless the same line expands
each id as `<id> — <one-line title> (source: <file/section>)`. If the title or
source cannot be found, say so explicitly and put the missing lookup under
`Questions` instead of treating the shorthand as an actionable next step.

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

Never render non-Solon feature usage, `Used`, `Not Used`, or `Recommended` as a
separate footer. If those facts are useful, map them into `Steps`, `Health`, and
`Next` inside the Solon report.

For `/sfs review`, surface the executor-provided result that already exists in
adapter stdout, `result_path`, or `review.md`: verdict, key findings, and
required CTO actions. Show a concise report, not the source markdown body. Do
not create a new verdict in the current runtime.

The user's arguments are interpolated below. Treat the first whitespace-delimited
token as the subcommand and the remainder as that subcommand's arguments.

```text
$ARGUMENTS
```

## Adapter Dispatch (status / start / guide / auth / brainstorm / plan / implement / review / decision / report / retro / commit / loop) — execute first

If the first argument is **`status`**, **`start`**, **`guide`**, **`auth`**, **`update`**, **`brainstorm`**, **`plan`**, **`implement`**, **`review`**,
**`decision`**, **`report`**, **`retro`**, **`commit`**, or **`loop`**, dispatch the request through the
`sfs` runtime command first. The runtime normalizes command surfaces
(`/sfs`, `$sfs`, `sfs`) and delegates to the deterministic bash adapter. In
vendored layout only, `.sfs-local/scripts/sfs-dispatch.sh` is an acceptable fallback.

Command modes:
- **Bash-first**: `status`, `start`, `guide`, `auth`, `update`, `commit`, `loop`. Print verbatim
  adapter output first. A compact recap/status line is allowed when it helps
  the user see state and the next action, but adapter stdout remains SSoT.
- **Always hybrid**: `brainstorm`, `plan`, `implement`, `decision`, `report`, `retro`. Run the adapter,
  then perform the documented file refinement.
- **Adapter-run**: `review`. The bash adapter executes the selected CPO
  executor bridge by default. Stop after adapter output. If `--prompt-only` is
  used, treat the prompt path as manual handoff material and do not write a
  Claude verdict in the current runtime.
- **Adapter-run local commit**: `commit`. Run only when the user explicitly
  invokes it. It groups staged/unstaged/untracked files into `product-code`,
  `sprint-meta`, `runtime-upgrade`, and `ambiguous`, then commits only the
  selected group. It prints Git Flow branch preflight guidance, auto-generates
  a Conventional Commit message unless `-m` is supplied. Branch push/main
  merge/main push are handled by the AI runtime Git Flow lifecycle.

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
`retro.md`, run/refine `report.md`, then run `retro --close` exactly once.
The close adapter compacts active workbench docs, so the report must be the
canonical work summary before close.

⚠️ AI 자율 호출 금지 — 사용자 명시 호출 시에만 동작 (§1.5' 정합). 특히 `retro --close`
는 sprint close + auto commit 을 트리거하므로 사용자 의도 없이 호출 금지.

Dispatch table:

| First arg | Script to run | Notes |
|:--|:--|:--|
| `status`   | `sfs status <remaining args>`   | passes flags such as `--color=auto/always/never` verbatim |
| `start`    | `sfs start <remaining args>`    | passes free-text `<goal>`, optional `--id <sprint-id>`, and `--force` verbatim |
| `guide`    | `sfs guide <remaining args>`    | passes `--path` / `--print` verbatim; default prints a short context briefing |
| `auth`     | `sfs auth <remaining args>`     | passes `status`, `check`, `login`, `probe`, `path`, `--executor`, `--all`, and `--timeout` verbatim |
| `update`   | `sfs update <remaining args>`   | updates managed project adapter/docs from the installed runtime; preserves sprint/decision/event history |
| `brainstorm` | `sfs brainstorm <remaining args>` | accepts raw/multiline G0 context, appends it to `brainstorm.md`, then Claude fills §1~§7 as Solon CEO |
| `plan`     | `sfs plan <remaining args>`     | opens plan.md, then Claude fills G1 requirements/AC/scope + CTO/CPO contract from brainstorm.md |
| `implement` | `sfs implement <remaining args>` | opens implement.md/log.md, then Claude performs actual code changes with DDD/TDD guardrails and records evidence |
| `review`   | `sfs review <remaining args>`   | CPO Evaluator bridge run by default. `--prompt-only` creates manual handoff prompt/log. `--show-last` prints compact metadata for the latest recorded review without rerunning executor |
| `decision` | `sfs decision <remaining args>` | creates ADR file, then Claude fills Context/Decision/Alternatives/Consequences |
| `report`   | `sfs report <remaining args>`   | opens report.md, then Claude fills the compact final work report |
| `retro`    | `sfs retro <remaining args>`    | opens retro.md, then Claude fills KPT/PDCA. With `--close`, refine report before close |
| `commit`   | `sfs commit <remaining args>`   | groups working tree changes and commits only the selected group. AI runtime handles branch push/main merge/main push |
| `loop`     | `sfs loop <remaining args>`     | Ralph Loop + Solon mutex + executor convention (claude/gemini/codex). passes `--mode`, `--executor`, `--max-iters`, `--parallel`, `--dry-run`, etc. verbatim (WU-27 §3) |

Procedure (apply in order):

1. **Existence check** — Use the Bash tool to verify `sfs` is available
   (`command -v sfs`). If missing, tell the user in 1 line and stop.
   In vendored layout only, `.sfs-local/scripts/sfs-dispatch.sh <command>` is
   an acceptable fallback. Windows users should run global `sfs` through Git
   Bash/WSL, or use `.sfs-local/scripts/sfs.ps1` only in vendored layout.
2. **Quote args safely** — Re-quote `<remaining args>` for the shell. Reject
   any argument containing a newline or NUL byte by reporting `unknown arg`,
   except for `brainstorm`, where multiline raw requirement context is allowed.
3. **Execute** — Run the script via the Bash tool. Capture stdout, stderr, and
   exit code. Do not pipe through any other transformer.
4. **Print output verbatim** — Emit the script's stdout exactly as produced
   (preserve whitespace and any ANSI color escape codes from `--color=always`).
   If exit code is non-zero, also print stderr and the exit code on a final
   line: `exit <code>`. Map known exit codes per the script contract:
   - status: `0`=ok, `1`=no `.sfs-local/`, `2`=corrupt `events.jsonl`,
     `3`=not a git repo, `99`=unknown.
   - auth: `0`=ok, `1`=no `.sfs-local/`, `7`=unknown CLI flag or missing
     executor for login/probe, `9`=auth missing/bootstrap failed, `99`=unknown.
   - start: `0`=ok, `1`=sprint id conflict (suggest `--force`), `4`=templates
     missing, `5`=permission, `99`=unknown.
   - guide: `0`=ok, `1`=no `.sfs-local/`, `4`=guide missing,
     `99`=unknown.
   - brainstorm: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `2`=corrupt `events.jsonl` / `current-sprint`, `3`=not a git repo,
     `4`=template missing, `5`=permission, `99`=unknown.
   - plan: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `2`=corrupt `current-sprint`, `4`=template missing, `99`=unknown.
   - implement: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `2`=corrupt `events.jsonl` / `current-sprint`, `3`=not a git repo,
     `4`=template missing, `5`=permission, `99`=unknown.
   - review: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `4`=template missing, `6`=gate id invalid or required
     (`unknown gate <id>, valid: G-1, G0, G1, G2, G3, G4, G5`),
     `7`=unknown CLI flag, `9`=executor bridge missing/failed, `99`=unknown.
   - decision: `0`=ok, `1`=`--id` conflict (decision already exists),
     `2`=corrupt `events.jsonl`, `3`=not a git repo,
     `4`=`decisions-template/ADR-TEMPLATE.md` missing, `5`=permission,
     `7`=`<title>` missing or unknown CLI flag, `99`=unknown.
   - report: `0`=ok, `1`=no `.sfs-local/` or no sprint, `4`=template
     missing, `5`=permission, `7`=usage, `99`=unknown.
   - retro: `0`=ok, `1`=no `.sfs-local/` or no active sprint,
     `4`=`sprint-templates/retro.md` missing, `7`=unknown CLI flag,
     `8`=`--close` requested but `review.md` missing (run /sfs review first),
     `99`=unknown.
   - commit: `0`=ok, `1`=no matching files/nothing to commit, `3`=not a git
     repo, `5`=unsafe staged files or git commit failed, `7`=usage,
     `99`=unknown.
   - loop: `0`=ok, `1`=invalid usage, `2`=PROGRESS frontmatter parse,
     `3`=drift detected (resume-check exit 16), `4`=mutex claim failed,
     `5`=safety_lock tripped, `6`=WU spec missing/corrupt,
     `7`=artifact verify fail, `8`=heartbeat write fail (FUSE),
     `9`=executor resolve fail, `99`=unknown.
5. **Stop or continue by command mode** — After dispatch, bash-first commands
   must preserve adapter stdout exactly. A compact Solon recap/status is allowed
   only when it adds state or the next action, and must not contradict the
   sprint mode. Do not emit non-Solon branded reports or "usage" footers.
   The bash script is the single source of truth for command output. Hybrid
   commands continue only via the documented flow below:
   - `brainstorm` → Brainstorm CEO Refinement
   - `plan` → Plan G1 Refinement
   - `implement` → Implementation Execution
   - `decision` → Decision ADR Refinement
   - `report` → Final Report Refinement
   - `retro` → Retro G5 Refinement
   - `commit` → stop after adapter output. Do not add files or create a second
     commit outside the adapter result.
   - `review` → Review CPO Handling. Use adapter stdout as metadata, read the
     recorded result path when present, then render a localized Solon report
     from recorded adapter/executor evidence only. Do not echo raw result bodies.

## Brainstorm CEO Refinement

`/sfs brainstorm` is not capture-only in AI runtimes. After the bash adapter
succeeds and its stdout has been printed verbatim:

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

`/sfs plan` is not adapter-only in AI runtimes. `plan.md ready` means the bash
adapter has opened the G1 file; Claude must then fill the plan from the current
G0 context.

1. Resolve the active `plan.md` path from adapter stdout. If stdout cannot be
   parsed, read `.sfs-local/current-sprint` and open
   `.sfs-local/sprints/<current-sprint>/plan.md`.
2. Open the same sprint's `brainstorm.md`. Treat `brainstorm.md` §1~§7 and
   §8 Append Log as the source of truth for G1 planning.
3. Act as **Solon CEO** for requirements and scope, then write the
   **CTO Generator ↔ CPO Evaluator** sprint contract:
   - `§1` measurable requirements from brainstorm problem/context.
   - `§2` binary or verifiable acceptance criteria, including anti-AC.
   - `§3` in scope / out of scope / dependencies and decision points.
   - `§4` checklist based only on what is actually satisfied.
   - `§5` CEO decision, CTO deliverables, CPO validation criteria,
     rework contract, and user decision points.
   - Add `§6 Phase 1 구현 Backlog Seed` when it materially helps the next
     implementation sprint.
4. Preserve user edits already present in `plan.md`; refine or complete them
   rather than replacing with a generic template.
5. If `brainstorm.md` is still too sparse for a usable plan, fill known
   assumptions, leave explicit open questions, and ask up to 3 questions in the
   final response.
6. Do not implement code, choose irreversible infrastructure, or run
   `/sfs review` automatically.
7. Final response: render a Solon report. Include `plan.md` path in `Files`,
   question count in `Questions`, and `Next: /sfs review --gate G1 ... then /sfs implement "<first code slice>"`
   when ready; otherwise `Next: answer questions, then /sfs plan`.

## Implementation Execution

`/sfs implement` is the command that turns plan into code. It is never
artifact-only in AI runtimes. After the bash adapter succeeds and stdout has
been printed verbatim, continue into actual implementation unless blocked.

1. Resolve `implement.md`, `plan.md`, and `log.md` from adapter stdout. If
   stdout cannot be parsed, read `.sfs-local/current-sprint` and open those
   files under `.sfs-local/sprints/<current-sprint>/`.
2. Read `plan.md`, `implement.md`, `log.md`, and relevant project files. If the
   requested slice conflicts with the plan, state the conflict and ask before
   editing.
3. Apply the AI coding guardrails from `implement.md`:
   - shared design concept before editing,
   - DDD terms used consistently in code/tests/docs,
   - TDD or smallest useful verification loop,
   - existing codebase regularity over one-off cleverness.
4. Implement the smallest coherent code slice. Prefer test-first when the
   codebase has a usable test harness. If no test harness exists, create or run
   the smallest practical smoke check and record the limitation.
5. Update `implement.md` §1~§5 and `log.md` with changed files, decisions,
   tests/commands, result, and review handoff. Set `implement.md` frontmatter
   `status: ready-for-review` only when code and verification evidence exist.
6. Run relevant tests/checks. Do not claim success without evidence.
7. Final response: render a Solon report with actual code files in `Files`,
   checks in `Actions` or `Steps`, and `Next: /sfs review --gate G4` when ready.

## Decision ADR Refinement

`/sfs decision` is not adapter-only in AI runtimes. After the bash adapter
succeeds and stdout has been printed verbatim:

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

`/sfs review` is mandatory in the Solon flow, but the current Claude runtime
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
   `prompt_path` as manual handoff material. Do not write a Claude verdict
   unless the user explicitly starts a separate review task with that prompt.
5. Final response after normal adapter output: render a Solon report in the
   user's visible language. Fill `Review` and `Actions` from the executor
   result path or `review.md` when present, translating/summarizing as needed.
   Do not print the raw result markdown unless the user explicitly asks for the
   raw source. Do not add an extra CPO verdict from the current runtime.

## Final Report Refinement

`/sfs report` is not adapter-only in AI runtimes. It turns active workbench
artifacts into the canonical completed-sprint report.

1. Resolve `report.md` from stdout or active/selected sprint.
2. Read sprint artifacts as source material: `brainstorm.md`, `plan.md`,
   `implement.md`, `log.md`, `review.md`, `retro.md`, related decisions, and
   `.sfs-local/events.jsonl`.
3. Fill `report.md` as a compact final work report, not a process dump:
   - `§1` goal, outcome, final verdict, one-line result.
   - `§2` delivered / not delivered / carried forward.
   - `§3` key decisions and why they matter.
   - `§4` implementation summary and changed modules.
   - `§5` verification evidence and result.
   - `§6` remaining risks, follow-ups, open questions.
   - `§7` artifact map stays short.
4. Keep `report.md` concise. Raw chronology belongs in `retro.md`, `log.md`,
   session logs, and events. Do not paste long logs or executor output into the
   report.
5. If `--compact` was requested, only proceed when the user explicitly asked
   for compaction. Treat compacted workbench files as redirect stubs; do not
   try to restore process detail from memory.
6. Final response: render a Solon report. Include `report.md` path in `Files`,
   compact status in `Health`, and `Next: /sfs retro --close` when closing the
   active sprint or `Next: continue current sprint` otherwise.

## Retro G5 Refinement

`/sfs retro` is not adapter-only in AI runtimes. After the adapter succeeds and
stdout has been printed verbatim:

1. Resolve `retro.md` from stdout or active sprint.
2. Read sprint artifacts: `brainstorm.md`, `plan.md`, `implement.md`,
   `log.md`, `review.md`, `report.md` when present, `.sfs-local/events.jsonl`,
   and related decisions.
3. Fill or update `§1` KPT, `§2` PDCA learning, `§3` metrics when evidence
   exists, `§4` next sprint handoff, and `§5` close checklist.
4. Preserve user edits. Do not invent completed work; mark unknowns explicitly.
5. If the user invoked `retro --close`, refine `retro.md` first, run/refine
   `/sfs report`, then run `bash .sfs-local/scripts/sfs-dispatch.sh retro --close`
   exactly once and print its output verbatim. Close compacts workbench docs.
6. Final response when not closing: render a Solon report. Include `retro.md`
   path in `Files`, close-readiness in `Health`, and `Next: /sfs retro --close`
   if ready; otherwise the next required action.

If `$ARGUMENTS` is empty, treat it as if the user typed `status` (run the
status adapter) so that bare `/sfs` produces the canonical compact status line.

## Read Context (Claude-driven modes only)

For the remaining subcommands (`help`, `sprint`, `log`), first read these files
if they exist:

- `CLAUDE.md`
- `.sfs-local/VERSION`
- `.sfs-local/divisions.yaml`
- `.sfs-local/events.jsonl`
- Recent files under `.sfs-local/sprints/`
- Recent files under `.sfs-local/decisions/`

## Command Behavior (Claude-driven modes)

If `$ARGUMENTS` is empty and the status adapter is unavailable, show a compact
SFS status and a short usage guide:

- Current Solon version from `.sfs-local/VERSION`
- Latest sprint directory, if any
- Recent gate or decision signals from `.sfs-local/events.jsonl`
- Suggested next SFS action
- Quick examples for `help`, `start`, `plan`, `review`, and `decision`

If the first argument is one of the modes below, follow that mode.

- `help`: Explain how to use `/sfs`, show available modes, and recommend the best first command.
- `status`: **Adapter (above).** Fallback only: summarize the current SFS state and next action from the files listed under "Read Context".
- `start`: **Adapter (above).** Fallback only: scaffold a sprint under `.sfs-local/sprints/<YYYY-Wxx-sprint-n>/` based on `sprint-templates/`.
- `guide`: **Adapter (above).** Fallback only: point the user to `.sfs-local/GUIDE.md` if it exists, otherwise `GUIDE.md`.
- `auth`: **Adapter (above).** Fallback only: tell the user to run `.sfs-local/scripts/sfs-auth.sh --help`.
- `brainstorm`: **Adapter first + CEO refinement (above).** Fallback only: produce or update the current sprint `brainstorm.md` based on `sprint-templates/brainstorm.md`, then fill §1~§7 as Solon CEO if file editing is available.
- `plan`: **Adapter first + G1 refinement (above).** Fallback only: produce or update the current sprint `plan.md` from `brainstorm.md` + `sprint-templates/plan.md`.
- `implement`: **Adapter first + implementation execution (above).** Fallback only: prepare `implement.md`/`log.md`; in AI runtimes, continue to actual code changes and tests.
- `sprint`: Convert the current plan into implementation steps and gate checks.
- `review`: **Adapter-run by default (above).** CPO review is mandatory, executor/tool is configurable, and the default path must use a real CLI/plugin bridge. If the user explicitly asks to use a Claude-connected Codex plugin, do not treat metadata as a review: create a `--prompt-only` CPO prompt, invoke the connected plugin if available, then append the plugin result to `review.md`.
- `decision`: **Adapter first + ADR refinement (above).** Fallback only: write a short ADR-style decision under `.sfs-local/decisions/` based on `sprint-templates/decision-light.md`.
- `report`: **Adapter first + Final Report Refinement (above).** Fallback only: prepare or update the current sprint `report.md` from sprint artifacts; compact workbench docs only when explicitly requested.
- `log`: Append a one-line JSON event to `.sfs-local/events.jsonl`.
- `retro`: **Adapter first + G5 refinement (above).** Fallback only: write or update the current sprint `retro.md` based on `sprint-templates/retro.md` (no auto commit / no sprint close in fallback).
- `commit`: **Adapter (above).** Fallback only: explain the commit grouping model and recommend running `sfs commit plan` directly.
- `loop`: **Adapter (above).** Fallback only: explain Ralph Loop + Solon mutex pattern and recommend running `.sfs-local/scripts/sfs-loop.sh --help` directly (WU-27).

## Usage Guide Output

When showing usage, keep it compact and practical. Include this shape:

```text
/sfs help                 사용법 보기
/sfs status               현재 SFS 상태 확인
/sfs start <goal>         새 sprint workspace 초기화
/sfs guide                처음 사용 맥락 브리핑
/sfs auth status          review executor 인증 상태 확인
/sfs brainstorm <context> G0 raw 기록 + CEO 맥락 정리
/sfs plan                 현재 sprint plan.md 작성/갱신
/sfs implement <slice>    plan 기반 실제 코드 구현 + 테스트/evidence 기록
/sfs review --gate G4 --executor codex --generator claude
                          CPO Evaluator review bridge 실행/기록
/sfs decision <decision>  짧은 결정 기록 남기기
/sfs report               최종 작업보고서 작성/갱신
/sfs retro                sprint 회고 작성/갱신
/sfs commit plan          working tree 의미 그룹 확인
/sfs commit apply --group product-code
```

Also explain this in one or two sentences:

- Solon MVP is a lightweight scaffold, not the full Solon system yet.
- The main artifacts live under `.sfs-local/`, and `/sfs` is the Claude Code command layer for operating them.

## Rules

- Preserve existing user work.
- Ask only when a decision changes project behavior or could discard work.
- Keep sprint artifacts concise and operational.
- Do not invent completed work. If evidence is missing, mark it as unknown.
- Prefer concrete next actions over broad methodology explanations.
- For `status`, `start`, `guide`, `auth`, `commit`, and `loop`, the bash adapter is authoritative — do not paraphrase or augment its output.
- `/sfs retro --close` compacts workbench docs after report refinement. Run it
  only when the user explicitly requested close.
- `/sfs commit apply ...` creates a local git commit. Run it only when the
  user explicitly requested commit grouping/apply. It prints branch preflight,
  auto-generates a Git Flow-aware Conventional Commit message. Branch push/main
  merge/main push are handled by the AI runtime Git Flow lifecycle.
- For `brainstorm`, `plan`, `decision`, and `retro`, the bash adapter is authoritative for command I/O, and the documented refinement is the authoritative AI-side follow-up. `review` is adapter-run by default; do not add a current-runtime CPO verdict after successful adapter output.
