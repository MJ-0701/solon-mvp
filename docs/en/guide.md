# Solon Product - 30-Minute Guide

**Language**: [한국어](../../GUIDE.md) / English

This guide is the short English path for running a first Solon sprint after
install. For beginner Git/terminal help, use the Korean [BEGINNER-GUIDE.md](../../BEGINNER-GUIDE.md).

## 0. Install And Initialize

Mac:

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

Windows PowerShell/cmd:

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

## 1. Mental Model

Solon installs two things into a project:

- a global `sfs` runtime
- project-local operating state in `.sfs-local/`

The files you normally edit are:

| File | Role |
|---|---|
| `SFS.md` | Project operating identity |
| `CLAUDE.md` | Claude Code adapter |
| `AGENTS.md` | Codex adapter |
| `GEMINI.md` | Gemini CLI adapter |

Project-local `.claude/`, `.gemini/`, and `.agents/` command/skill files are
optional. In thin layout, the default surface is clean: root `CLAUDE.md`,
`AGENTS.md`, and `GEMINI.md` point agents at the global `sfs` runtime. Install
native slash/skill files only when a project needs them:

```bash
sfs agent install all
```

Global `sfs` / `sfs.cmd upgrade` promotes old vendored projects to the thin
surface as well. Use `sfs upgrade --layout vendored` only when local runtime
files must stay inside the project.

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
the report exists, packs workbench evidence and temporary review scratch into
one cold archive bundle, closes sprint state, and creates the local close
commit. Use `sfs retro --draft` only when you want to open the draft without
closing the sprint.
Older loose sprint archives and separate review-run archives are compacted by
`sfs upgrade` into compressed migration bundles.
Runtime upgrade, agent install, and profile rollback backups are also kept as
`*.tar.gz` + `manifest.txt` bundles instead of loose project files.

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
scoop update
scoop update sfs
sfs.cmd version --check
```

For Scoop installs, running `scoop update sfs` from an initialized Solon project
updates the runtime and then continues into the project upgrade. If Scoop says
the runtime is already current but the project still needs cleanup, run
`sfs.cmd upgrade`.

Recent upgrades also repair missing managed context-router files even when the
project already reports the latest version.
