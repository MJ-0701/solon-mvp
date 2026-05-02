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
sfs agent install all
sfs status
```

Windows PowerShell/cmd:

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd agent install all
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

The files under `.claude/`, `.gemini/`, `.agents/`, and packaged templates are
runtime assets. In thin layout, they are managed by the global package.

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

## 7. Report And Retro

```bash
sfs report
sfs retro
```

`retro` is the normal sprint completion command. It refines the retro, ensures
the report exists, archives workbench evidence, closes sprint state, and creates
the local close commit. Use `sfs retro --draft` only when you want to open the
draft without closing the sprint.

## 8. Upgrade

Do not reinstall a project to update Solon. Run:

```bash
sfs upgrade
sfs version --check
```

Windows:

```powershell
sfs.cmd upgrade
sfs.cmd version --check
```

Recent upgrades also repair missing managed context-router files even when the
project already reports the latest version.
