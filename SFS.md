# SFS.md — Solon SFS 운영 지침 (entry-lean)

> 목적: Claude/Codex/Gemini 공통 진입 문서의 **entry-time token cost** 최소화.
> 자세한 설명/배경/긴 표는 on-demand 문서로 이동한다.

## Entry pointers (SSoT)

- Runtime full guide: `.sfs-local/GUIDE.md`
- Project docset entry: `2026-04-19-sfs-v0.4/CLAUDE.md` → `2026-04-19-sfs-v0.4/PROGRESS.md`
- Full pre-compact snapshot (verbatim): `archives/sfs/SFS-2026-05-01T191445Z-precompact.md`

## TL;DR (7-step sprint flow)

1. Gate 2 (Brainstorm) `/sfs brainstorm` → `brainstorm.md`
2. Gate 3 (Plan) `/sfs plan` → `plan.md` (요구사항/AC/scope + 계약)
3. Gate 4 (Design/Entry) `/sfs implement` → `implement.md`/`log.md` (코드 + evidence)
4. Gate 6 (Review) `/sfs review` → `review.md` (결과 원문은 tmp/archives 로)
5. Gate 7 (Retro) `/sfs retro --close` → `report.md`/`retro.md` + workbench/tmp archive

## Quick commands

```text
sfs status
sfs guide
sfs profile
sfs start "<goal>"
sfs brainstorm "<raw>"
sfs plan
sfs implement "<slice>"
sfs review --gate 6 --executor codex|gemini|claude [--prompt-only]
sfs report --compact
sfs tidy --apply
sfs retro --close
```

## Guardrails (must keep)

- Gate 는 hard-block 이 아니라 signal-only (never-hard-block).
- `sfs` runtime/bash adapter 출력은 paraphrase 금지 (결정성 유지).
- Git flow 기본값은 AI-owned(검증+commit). 단 destructive git/충돌/인증 prompt 는 즉시 stop.

## Paths (what matters)

- Sprint workbench: `.sfs-local/sprints/<sprint-id>/{brainstorm,plan,implement,log,review}.md`
- Sprint outputs: `.sfs-local/sprints/<sprint-id>/{report,retro}.md`
- Decisions: `.sfs-local/decisions/` (+ sprint-local mini-ADR)
- Loop queue: `.sfs-local/queue/{pending,claimed,done,failed,abandoned}` + `.sfs-local/queue/runs/`

## Notes

- Multi-adaptor by design: 어떤 CLI 환경에서도 SSoT 는 global `sfs` runtime 이다.
- Windows PowerShell 은 Git Bash/WSL 에서 `sfs` 실행을 기본으로 한다.
