# Solon Product

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon 은 제품 개발에 필요한 생각 정리, 역할 분리, 실행 기록, 검증, 회고, 인수인계를
> 프로젝트 안에 설치합니다.

**Language**: 한국어 / [English](./docs/en/index.md)

GitHub Markdown 은 네이티브 언어 전환 탭을 지원하지 않습니다. 그래서 Solon 문서는
README 를 큰 흐름과 목차로 두고, 상세 문서는 `docs/ko` / `docs/en` 링크로 나눕니다.

---

## What Is SFS

SFS 는 두 가지 의미를 함께 가집니다.

- **Sprint Flow System**: 매일 쓰는 `sfs` / `/sfs` 명령 흐름입니다.
  `start → brainstorm → plan → implement → review → report → retro` 로 생각과 실행을 통과시킵니다.
- **Solo Founder System**: 혼자 제품을 만드는 사람이 여러 AI agent 를 팀처럼 쓰기 위한
  운영 시스템입니다. role boundary, decision log, review/retro loop, handoff state 를
  프로젝트 안에 고정합니다.

핵심 약속은 단순합니다.

- AI 는 실행 속도를 높입니다.
- Solon 은 역할, 기록, 검증, 인수인계 구조를 고정합니다.
- 사용자는 방향과 최종 통과 여부를 결정합니다.

---

## Current Flow

```text
sfs status
→ sfs start "<goal>"
→ sfs brainstorm [--simple|--hard] "<raw context>"
→ sfs plan
→ sfs implement "<first slice>"
→ sfs review
→ sfs report
→ sfs retro
```

최신 Solon Product 의 중요한 변화는 명령어를 많이 외우게 만드는 것이 아니라, 아래 흐름을
더 선명하게 만든 것입니다.

- `start` 는 workspace 를 만들고, 새 요구 탐색에는 brainstorm depth 선택지를 보여줍니다.
- `brainstorm` 은 raw 요구사항을 바로 plan 으로 굳히지 않고 사용자가 product owner 로 생각하게 만듭니다.
- `plan` 은 transcript 가 아니라 measurable AC, scope, feedback loop, evaluator criteria 를 담는 계약입니다.
- `implement` 는 코드만 뜻하지 않습니다. docs, strategy, design handoff, taxonomy, QA evidence,
  infra/runbook 도 artifact 입니다.
- `review` 는 code review 하나가 아니라 artifact acceptance review 입니다. Solon 이 code/docs/
  strategy/design/taxonomy/QA/ops/release lens 를 자동 추론합니다.
- `retro` 는 기본 sprint close 명령입니다. 초안만 열려면 `sfs retro --draft` 를 씁니다.

상세 설명:

- [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md)
- [Solon 10x 가치](./docs/ko/10x-value.md)
- [30분 온보딩 가이드](./GUIDE.md)

---

## Installation

개발, 터미널, CLI 환경이 낯설다면 먼저 [BEGINNER-GUIDE.md](./BEGINNER-GUIDE.md) 를 보세요.

### Windows (Scoop)

```powershell
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

### Mac (Homebrew)

```bash
brew install MJ-0701/solon-product/sfs
cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

### Upgrade

재설치하지 말고 프로젝트 루트에서 실행합니다.

```bash
sfs upgrade
sfs version --check
```

Windows PowerShell/cmd:

```powershell
sfs.cmd upgrade
sfs.cmd version --check
```

최근 버전의 upgrade 는 이미 최신이라고 표시되는 프로젝트도 managed context router 를 다시 점검합니다.
`.sfs-local/context/_INDEX.md`, `kernel.md`, routed command modules 가 빠져 있으면 같은 버전에서도
복구하고, 핵심 router 파일이 여전히 없으면 실패로 멈춥니다.

---

## Command Surface

| Command | Purpose |
|---|---|
| `sfs status` | 현재 sprint, gate, ahead count, last event 확인 |
| `sfs start <goal>` | 새 sprint workspace 생성 |
| `sfs brainstorm [--simple|--hard] [text|--stdin]` | 요구사항 정리와 PO 사고 훈련. 기본은 normal |
| `sfs plan` | Gate 3 plan 계약 작성 |
| `sfs implement [slice|--stdin]` | plan 기반 실행 slice + evidence 기록 |
| `sfs review [--lens ...]` | artifact acceptance review. lens 는 기본 자동 추론 |
| `sfs report` | 최종 작업보고서 생성 |
| `sfs retro [--draft]` | 기본은 sprint close + archive + local close commit. 초안만 열려면 `--draft` |
| `sfs decision <title>` | ADR-style 결정 기록 |
| `sfs tidy [--apply]` | 완료된 sprint workbench/tmp archive |
| `sfs adopt [--apply]` | legacy 프로젝트 baseline 생성 |
| `sfs auth ...` | review executor 인증/bridge 확인 |
| `sfs profile` | `SFS.md` 프로젝트 개요만 좁게 감지/보정 |
| `sfs division ...` | strategy/dev/qa/design/infra/taxonomy 본부 활성 관리 |
| `sfs loop ...` | queue 기반 자율 진행 고급 모드 |

Runtime 별 호출 표기:

| Runtime | Entry |
|---|---|
| Claude Code | `/sfs status` |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Windows PowerShell/cmd | `sfs.cmd status` |

---

## Documentation Map

| Page | Korean | English |
|---|---|---|
| Docs index | [docs/ko](./docs/ko/index.md) | [docs/en](./docs/en/index.md) |
| Current product shape | [KO](./docs/ko/current-product-shape.md) | [EN](./docs/en/current-product-shape.md) |
| 10x value | [KO](./docs/ko/10x-value.md) | [EN](./10X-VALUE.md) |
| 30-minute guide | [KO](./GUIDE.md) | [EN](./docs/en/guide.md) |
| Beginner guide | [KO](./BEGINNER-GUIDE.md) | planned |
| Release history | [CHANGELOG.md](./CHANGELOG.md) | [CHANGELOG.md](./CHANGELOG.md) |

문서 원칙:

- README 는 큰 흐름과 목차를 담당합니다.
- 상세 판단 기준은 별도 문서로 보냅니다.
- sprint 중 생긴 긴 workbench 는 완료 시 `report.md` / `retro.md` 로 압축합니다.
- 좋은 문서는 다음 사람/AI 가 "무엇을 했고, 왜 했고, 어떻게 검증했고, 다음 action 이 무엇인지"
  바로 알 수 있게 합니다.

---

## Installed Files

| Path | Role |
|---|---|
| `SFS.md` | 프로젝트 운영 지침 |
| `CLAUDE.md` | Claude Code adapter |
| `AGENTS.md` | Codex adapter |
| `GEMINI.md` | Gemini CLI adapter |
| `.sfs-local/` | sprint, decision, event, config, custom override |
| `.claude/`, `.gemini/`, `.agents/` | runtime 별 얇은 SFS entry point |

thin layout 에서는 runtime scripts/templates/personas 는 global `sfs` package 에 남고, consumer
project 에는 state/config/custom override 만 설치됩니다.

---

## Safety Contract

- install/upgrade/uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.
- 사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은
  install/upgrade 과정에서 덮어쓰지 않습니다.
- `sfs review` 는 generator self-approval 을 막기 위해 CPO role/evidence/verdict 를 분리합니다.
- `sfs retro` 는 사용자가 명시적으로 호출했을 때만 archive, sprint close, local close commit 을 수행합니다.
- gate 는 진행을 강제로 막지 않는 signal 입니다. 최종 판단은 사용자에게 남깁니다.

---

## Repository Map

| Path | Role |
|---|---|
| `bin/sfs` | global Bash CLI entrypoint |
| `bin/sfs.cmd` / `bin/sfs.ps1` | Windows global wrapper |
| `install.sh` / `install.ps1` | project init installer |
| `upgrade.sh` / `upgrade.ps1` | project upgrade |
| `templates/` | SFS adapter/templates/runtime assets |
| `docs/ko`, `docs/en` | detailed bilingual documentation |
| `packaging/` | Homebrew/Scoop release templates |
| `CHANGELOG.md` | release history |
| `VERSION` | distribution version |
