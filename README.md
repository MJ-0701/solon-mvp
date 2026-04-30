# Solon Product

> AI-native product work 를 위한 Company-as-Code 운영 레이어.
> Solon Product 는 제품 개발에 필요한 역할 분리, 결정 기록, 검증, 회고, 인수인계를
> 프로젝트 안에 설치합니다.

Solon Product 는 Claude Code, Codex, Gemini CLI 같은 LLM agent 와 함께 제품을 만들 때
작업 맥락이 사라지지 않도록 돕는 로컬 운영 시스템입니다. 설치하면 현재 repository 안에
공통 지침, runtime adapter, `/sfs` 명령, sprint 산출물, decision log, review/retro 흐름이
생깁니다.

핵심 약속은 단순합니다.

- AI 는 실행 속도를 높인다.
- Solon 은 역할, 기록, 검증, 인수인계 구조를 고정한다.
- 사용자는 방향과 최종 통과 여부를 결정한다.

---

## Why Solon

AI 로 코드를 빨리 만들 수 있어도 제품 작업에는 반복적으로 같은 문제가 생깁니다.

- 어떤 결정이 왜 내려졌는지 다음 세션에서 다시 추측한다.
- 설계 없이 만든 코드가 다음 sprint 의 부채가 된다.
- 만든 agent 와 검증 agent 가 섞여 자기검증이 발생한다.
- release 직전 secret, auth, data, monitoring, rollback, cost evidence 가 누락된다.
- 여러 도구를 오가며 일할수록 현재 상태와 다음 행동이 흐려진다.

Solon Product 는 이 문제를 프롬프트가 아니라 **운영 구조**로 다룹니다. 작업 단위를
sprint 로 묶고, 계획/결정/review/회고를 파일로 남기며, agent 가 같은 상태를 읽고 이어받을 수
있게 합니다.

---

## How It Works

1. 기존 프로젝트에 Solon Product 를 설치합니다.
2. `/sfs start <goal>` 로 sprint 를 시작합니다.
3. `/sfs plan`, `/sfs decision`, `/sfs review`, `/sfs retro` 로 작업 evidence 를 남깁니다.
4. `/sfs status` 와 `.sfs-local/events.jsonl` 로 현재 상태를 확인합니다.
5. 필요하면 Codex/Gemini/Claude 가 같은 문서 계약을 읽고 다음 작업을 이어갑니다.

```text
Product work = Goal + Role boundary + Artifact + Review signal + Handoff state
```

Solon 은 AI 가 더 많이 결정하게 만드는 도구가 아닙니다. AI 가 더 안정적으로 일하게 만들고,
중요한 판단은 사용자에게 남기는 도구입니다.

---

## Operating Model

| 축 | Solon Product 가 고정하는 것 |
|---|---|
| Role | 6 Division + 3 C-Level 관점의 책임 분리 |
| Process | 브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화 |
| Artifact | `plan.md`, `review.md`, `retro.md`, ADR-style decision |
| State | `/sfs status`, `.sfs-local/current-sprint`, `.sfs-local/events.jsonl` |
| Safety | signal-only gate, human final filter, no automatic push |

7-step flow 는 full startup artifact chain 의 product-facing projection 입니다. Discovery,
PRD, Taxonomy, UX, Technical Design, Release Readiness 를 없애는 것이 아니라, 작은 팀과
1인 창업자가 매일 운용할 수 있는 형태로 접어 둔 것입니다.

각 작업 단위가 통과할 수 있는 7 개의 검증 지점 (`G-1, G0, G1, G2, G3, G4, G5`) 이 있고,
verdict 는 `pass / partial / fail` 3-enum 입니다 (G3 만 binary `block / unblock`). gate 는
진행을 강제로 막지 않는 signal 입니다.

---

## Quickstart

설치할 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

설치 후 Claude Code, Codex, Gemini CLI 셋 다 native `/sfs` 슬래시 1급으로 호출할 수 있습니다
(자동 install 된 entry point 4종 = `.claude/commands/sfs.md` + `.gemini/commands/sfs.toml` +
`.agents/skills/sfs/SKILL.md` + optional `~/.codex/prompts/sfs.md`).

> 📘 **친구 onboarding 30분 walk-through**: 설치 직후 처음 30분 동안 `SFS.md` placeholder 치환,
> 첫 sprint 시작, plan/review/decision/retro 흐름까지 따라 하는 가이드는 [GUIDE.md](./GUIDE.md)
> 참조. "SFS.md 에 프로젝트 스택 적어도 되는지" 같은 자주 묻는 오해도 거기서 해소.

```text
/sfs status
/sfs start "첫 번째 sprint 목표"
/sfs plan
/sfs review --gate G2
/sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
/sfs retro --close
```

세 환경 모두 같은 `.sfs-local/scripts/sfs-*.sh` bash adapter 를 SSoT 로 호출합니다 — paraphrase
금지, vendor 마다 결과 동일성 보장.

---

## Product Surface

| 명령 | 역할 |
|---|---|
| `/sfs status` | 현재 sprint, WU, gate, ahead count, last event 를 한 줄로 표시 |
| `/sfs start <goal>` | 새 sprint 시작 또는 기존 sprint 이어가기 (`--id <sprint-id>` 지원) |
| `/sfs plan` | 현재 sprint 의 `plan.md` 작성 또는 갱신 |
| `/sfs review --gate <id>` | gate 기준으로 `review.md` 작성 또는 갱신 (id ∈ G-1..G5) |
| `/sfs decision <title>` | full ADR (decisions/) 또는 sprint-local mini-ADR 자동 분기 |
| `/sfs retro` | 현재 sprint 의 `retro.md` 작성 또는 갱신 |
| `/sfs retro --close` | review 실행 여부 확인 후 sprint close + auto commit (push 는 manual) |
| `/sfs loop [OPTIONS]` | 큰 작업에서 micro-step 단위 반복 실행을 돕는 자율 진행 모드 |

7 명령 모두 native slash 1급 entry point + 동일 bash adapter SSoT.

### `/sfs loop` 자세히

`/sfs loop` 는 자율 진행 (Ralph Loop 패턴) 의 LLM 호출 site 입니다. LLM 이 한 micro-step →
PROGRESS 갱신 → 자기 review gate → 다음 micro-step 을 cap (`--max-iters` default 5) 까지 반복.
multi-vendor executor 1급 지원:

- `--executor claude` → `claude -p --dangerously-skip-permissions`
- `--executor gemini` → `gemini -p --yolo`
- `--executor codex` → `codex exec --full-auto`
- `--executor "<custom command>"` → 그대로 passthrough

이 convention 은 `/sfs loop` 만 적용되는 게 아니라 Solon-wide invariant — 모든 명령이 어느 1급
CLI 에서든 동등한 deterministic bash adapter SSoT 로 동작합니다.

---

## Runtime Coverage

설치 후 `/sfs` 7 명령은 **세 런타임 모두에서 native 등록**됩니다.

| 런타임 | Entry point (자동 install) | 호출 방법 |
|---|---|---|
| **Claude Code** | `.claude/commands/sfs.md` (Markdown slash) | `/sfs status` |
| **Gemini CLI** | `.gemini/commands/sfs.toml` (TOML slash) | `/sfs status` |
| **Codex** | `.agents/skills/sfs/SKILL.md` (project-scoped Skill, agentskills.io 표준) | `$sfs status` (explicit) 또는 자연어 (implicit) |

Codex 는 native `/sfs` popup slash 도 별도 user-scoped path 에서 지원합니다
(`~/.codex/prompts/sfs.md`). install.sh 가 user `$HOME` 에 자동 cp 하지 않으므로 (사용자 영역
보호), 원하면 manual cp:

```sh
mkdir -p ~/.codex/prompts
cp <consumer-project>/templates/.codex/prompts/sfs.md ~/.codex/prompts/sfs.md
```

---

## Installation

### Remote One-Liner

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

### Local Clone

```bash
git clone https://github.com/MJ-0701/solon-product ~/tmp/solon-product
cd ~/workspace/my-project
bash ~/tmp/solon-product/install.sh
```

### Non-Interactive

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/install.sh --yes
```

`--yes` 는 확인 프롬프트를 승인하지만, 파일 충돌이 있으면 안전한 기본값인 `skip` 을
사용합니다.

---

## Installed Files

| 경로 | 설명 |
|---|---|
| `SFS.md` | 프로젝트가 따르는 Solon 7-step + 7-Gate 공통 지침 |
| `CLAUDE.md` | Claude Code adapter |
| `AGENTS.md` | Codex adapter |
| `GEMINI.md` | Gemini CLI adapter |
| `.claude/commands/sfs.md` | Claude Code `/sfs` slash command |
| `.gemini/commands/sfs.toml` | Gemini CLI `/sfs` slash command |
| `.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `.sfs-local/` | sprint, decision, event, runtime script 를 담는 로컬 운영 디렉토리 |
| `.gitignore` marker block | `.sfs-local/` 운영 파일을 위한 ignore 규칙 |

`templates/` 아래 파일은 consumer 프로젝트에 설치되는 배포 자산입니다.

---

## Safety Contract

- install/upgrade/uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.
- `/sfs retro --close` 는 사용자가 명시적으로 호출했을 때만 sprint close 와 auto commit 을 수행합니다.
- gate 는 진행을 강제로 막지 않는 signal 입니다.
- 사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은 install/upgrade 과정에서 덮어쓰지 않습니다.
- 기존 파일과 충돌하면 `skip`, `backup + overwrite`, `overwrite`, `diff` 중 선택합니다.
- 새 marker 는 `solon-product` 를 사용하지만, install/upgrade/uninstall 은 legacy `solon-mvp` marker 도 인식합니다 (consumer 하위 호환).

---

## Upgrade

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/upgrade.sh
```

Upgrade 는 `.sfs-local/VERSION` 과 배포판 `VERSION` 을 비교하고, 파일을 쓰기 전에
dry-run preview 를 보여줍니다.

- `SFS.md`, `.claude/commands/sfs.md`, `.gemini/commands/sfs.toml`, `.agents/skills/sfs/SKILL.md`, runtime scripts 는 배포판 관리 영역으로 갱신 대상입니다.
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/divisions.yaml` 은 프로젝트별 편집 가능성이 커서 기본 보존합니다.
- sprint/decision 산출물과 event log 는 보존합니다.
- legacy `### BEGIN solon-mvp ###` `.gitignore` marker 가 있으면 product marker 로 자동 교체합니다.

---

## Uninstall

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/uninstall.sh
```

Uninstall 은 대화형으로 실행됩니다.

- 전체 제거
- scaffold 만 제거하고 sprint/decision/event 산출물 보존
- 취소

---

## Repository Map

| 파일/디렉토리 | 역할 |
|---|---|
| `install.sh` | consumer 프로젝트에 Solon Product scaffold 설치 |
| `upgrade.sh` | 설치된 scaffold 를 새 배포판으로 갱신 |
| `uninstall.sh` | 설치된 scaffold 제거 |
| `GUIDE.md` | 친구 onboarding 30분 walk-through (placeholder 치환 + 첫 sprint + FAQ + 트러블슈팅) |
| `templates/SFS.md.template` | 공통 운영 지침 |
| `templates/CLAUDE.md.template` | Claude Code adapter template |
| `templates/AGENTS.md.template` | Codex adapter template |
| `templates/GEMINI.md.template` | Gemini CLI adapter template |
| `templates/.claude/commands/sfs.md` | Claude Code slash command |
| `templates/.gemini/commands/sfs.toml` | Gemini CLI slash command |
| `templates/.agents/skills/sfs/SKILL.md` | Codex Skill (project-scoped) |
| `templates/.codex/prompts/sfs.md` | Codex user-scoped slash fallback (optional) |
| `templates/.sfs-local-template/` | runtime scripts, sprint templates, decision templates |
| `CHANGELOG.md` | release history |
| `VERSION` | distribution version |

---

## Release Channel

현재 distribution version 은 `0.5.2-product` 입니다. `-mvp` suffix (0.5.0-mvp 까지) 는 기존 설치본
과의 semver 호환을 위해 유지하지만, 0.5.1+ 부터 repo identity 와 release suffix 는 product
track 기준으로 운영합니다.

릴리스 기록은 [CHANGELOG.md](./CHANGELOG.md) 를 참조하세요.
