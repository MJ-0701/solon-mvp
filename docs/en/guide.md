# Solon Product - 30-Minute Guide

**Language**: [한국어](../../GUIDE.md) / English

This guide is the short English path for running a first Solon sprint after
install. For beginner Git/terminal help, use the Korean [BEGINNER-GUIDE.md](../../BEGINNER-GUIDE.md).

## 0. Install And Initialize

> **Since 0.6.0**, one `brew install` / `scoop install` lets Claude Code
> (`/sfs`), Gemini CLI (`sfs`), and Codex CLI (`$sfs`) find Solon automatically.
> Your project keeps the files you read and the records you create.

Mac:

```bash
brew install MJ-0701/solon-product/sfs
sfs doctor              # ✅ Claude / Gemini / Codex — three green lines

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

Windows PowerShell/cmd:

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
sfs.cmd doctor          # same three-line check on Windows

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

If any line in `sfs doctor` shows `⚠️`, the next line on screen prints the
single-shot recovery command. The `sfs` binary itself is unaffected.

## 1. Mental Model

Solon gives a project two things:

- the `sfs` command
- project-local working records in `.sfs-local/`

The files you normally edit are:

| File | Role |
|---|---|
| `SFS.md` | Project operating identity |
| `CLAUDE.md` | Where Claude Code finds Solon |
| `AGENTS.md` | Where Codex finds Solon |
| `GEMINI.md` | Where Gemini CLI finds Solon |

Project-local `.claude/`, `.gemini/`, and `.agents/` command/skill files are
optional. Install those native shortcuts only when a project needs them:

```bash
sfs agent install all
```

Old projects can be upgraded into the lighter 0.6.0 shape. Use
`sfs upgrade --layout vendored` only when Solon package files must stay inside
the project.

## 2. Start A Sprint

```bash
sfs status
sfs start "todo app v0 - add, complete, delete, persist"
```

`start` creates the sprint workspace and shows the useful next step. For new
requirements, that is usually brainstorm.

```text
sfs brainstorm --simple "..."  # quick cleanup
sfs brainstorm "..."           # default normal thinking scaffold
sfs brainstorm --hard "..."    # product-owner hard training
```

If a blank app would help before a sprint, the user should not need to know words
like Next.js, Spring, Java, or API. The user can simply describe what they want
to make. During brainstorm, the AI should infer when an initial project setup
would help and ask in plain language:

```text
Would you like me to set up the initial project?
```

After consent, the current AI should choose the native setup path, create the app,
then return to Solon. It may use `sfs bootstrap "small booking web app"` as an
internal handoff trigger, but the user should not need to know that command:

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "first goal"
```

## 3. Brainstorm Before Plan

Use `brainstorm` to turn raw context into shared understanding.

| Mode | Use it when |
|---|---|
| `--simple` | The direction is already clear and you only need cleanup |
| default `normal` | You are exploring a normal product change |
| `--hard` | Intent, tradeoffs, validation, or terms are still blurry |

Normal brainstorm should ask a few focused questions. Hard brainstorm should
keep pressing until important owner decisions are clear enough to plan.

## 4. Plan As Contract

```bash
sfs plan
```

A good plan is not a transcript. It should contain:

- measurable acceptance criteria
- in-scope and out-of-scope boundaries
- feedback or verification method
- evaluator criteria
- first implementation slice

If a key decision is missing, keep the question open instead of guessing.

## 5. Implement One Slice

```bash
sfs implement "first slice"
```

Implementation can mean code, docs, strategy, design handoff, taxonomy, QA
evidence, ops/runbook, or release packaging. The artifact that moved the
product forward determines the review lens.

## 6. Review The Artifact

```bash
sfs review
```

Review is artifact acceptance review. Code review is only the `code` lens.
Solon can infer lenses such as `docs`, `strategy`, `design`, `taxonomy`, `qa`,
`ops`, or `release` from sprint evidence. Use `--lens` only when the inference
is wrong.

## 7. Retro

```bash
sfs retro
```

`retro` is the normal sprint completion command. It refines the retro, ensures
the report exists, folds away noisy temporary records, closes sprint state, and
creates the local close commit. Use `sfs retro --draft` only when you want to
open the draft without closing the sprint.

Use `sfs report` separately only when you want to preview or rebuild the report
without closing the sprint. The full list of optional helpers
(`report --sprint <id>`, `tidy`, `decision`, `adopt`, etc.) is in the Korean
GUIDE §11.

## 8. Upgrade

Do not reinstall a project to update Solon. Run:

```bash
sfs upgrade
sfs version --check
```

Windows:

```powershell
sfs.cmd update
sfs.cmd version --check
```

On Windows, `sfs.cmd update` is the one-shot command. It updates Solon and then
continues into the current project cleanup.

Long-running commands can also be wrapped with `sfs measure --alive -- <command>`
when you want visible progress instead of a silent terminal.
