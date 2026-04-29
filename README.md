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

---

## Quickstart

설치할 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-product/main/install.sh | bash
```

Claude Code 에서는 바로 `/sfs` 를 사용할 수 있습니다.

```text
/sfs status
/sfs start "첫 번째 sprint 목표"
/sfs plan
/sfs review --gate G2
/sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
/sfs retro --close
```

Codex 와 Gemini CLI 에서는 설치된 adapter 문서를 읽고 같은 흐름을 자연어로 호출합니다.

```text
SFS.md 와 AGENTS.md 읽고 sfs status 처럼 현재 상태 요약해줘
SFS.md 와 GEMINI.md 읽고 이번 sprint plan 작성해줘
```

---

## Product Surface

| 명령 | 역할 |
|---|---|
| `/sfs status` | 현재 sprint, WU, gate, ahead count, last event 를 한 줄로 표시 |
| `/sfs start <goal>` | 새 sprint 시작 또는 기존 sprint 이어가기 (`--id <sprint-id>` 지원) |
| `/sfs plan` | 현재 sprint 의 `plan.md` 작성 또는 갱신 |
| `/sfs review --gate <id>` | gate 기준으로 `review.md` 작성 또는 갱신 |
| `/sfs decision <title>` | `.sfs-local/decisions/` 아래 ADR-style 결정 기록 생성 |
| `/sfs retro` | 현재 sprint 의 `retro.md` 작성 또는 갱신 |
| `/sfs retro --close` | review 실행 여부 확인 후 sprint close + auto commit |
| `/sfs loop` | 큰 작업에서 micro-step 단위 반복 실행을 돕는 고급 모드 |

Claude Code 는 `.claude/commands/sfs.md` 를 통해 bash adapter 를 직접 dispatch 합니다. Codex 와
Gemini CLI 는 `AGENTS.md` / `GEMINI.md` adapter 를 통해 같은 파일 계약을 따릅니다.

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
| `SFS.md` | 프로젝트가 따르는 Solon 7-step + gate 공통 지침 |
| `CLAUDE.md` | Claude Code adapter |
| `AGENTS.md` | Codex adapter |
| `GEMINI.md` | Gemini CLI adapter |
| `.claude/commands/sfs.md` | Claude Code `/sfs` command layer |
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
- 새 marker 는 `solon-product` 를 사용하지만, upgrade/uninstall 은 legacy `solon-mvp` marker 도 인식합니다.

---

## Upgrade

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-product/upgrade.sh
```

Upgrade 는 `.sfs-local/VERSION` 과 배포판 `VERSION` 을 비교하고, 파일을 쓰기 전에
dry-run preview 를 보여줍니다.

- `SFS.md`, `.claude/commands/sfs.md`, runtime scripts 는 배포판 관리 영역으로 갱신 대상입니다.
- `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.sfs-local/divisions.yaml` 은 프로젝트별 편집 가능성이 커서 기본 보존합니다.
- sprint/decision 산출물과 event log 는 보존합니다.

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
| `templates/SFS.md.template` | 공통 운영 지침 |
| `templates/CLAUDE.md.template` | Claude Code adapter template |
| `templates/AGENTS.md.template` | Codex adapter template |
| `templates/GEMINI.md.template` | Gemini CLI adapter template |
| `templates/.claude/commands/sfs.md` | Claude Code slash command template |
| `templates/.sfs-local-template/` | runtime scripts, sprint templates, decision templates |
| `CHANGELOG.md` | release history |
| `VERSION` | distribution version |

---

## Release Channel

현재 distribution version 은 `0.4.0-mvp` 입니다. `-mvp` suffix 는 기존 설치본과의 semver 호환을
위해 유지하지만, repo identity 와 README 는 product track 기준으로 운영합니다.

릴리스 기록은 [CHANGELOG.md](./CHANGELOG.md) 를 참조하세요.
