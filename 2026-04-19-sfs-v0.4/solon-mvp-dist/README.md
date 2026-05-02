# Solon Product

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon 은 제품 개발에 필요한 생각 정리, 역할 분리, 실행 기록, 검증, 회고, 인수인계를
> 프로젝트 안에 설치합니다.

**Language**: 한국어 / [English](./docs/en/index.md)

---

## What Is SFS

SFS 는 두 가지 의미를 함께 가집니다.

- **Sprint Flow System**: 매일 쓰는 `sfs` / `/sfs` 명령 흐름입니다.
  `start → brainstorm → plan → implement → review → retro` 로 생각과 실행을 통과시킵니다.
- **Solo Founder System**: 혼자 제품을 만드는 사람이 여러 AI agent 를 팀처럼 쓰기 위한
  운영 시스템입니다. 역할, 결정 기록, 검토, 회고, 인수인계를 프로젝트 안에 고정합니다.

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
→ sfs retro
```

Solon 의 흐름은 명령어를 많이 외우게 만들지 않습니다. 각 단계는 하나의 역할만 가집니다.

- `start` 는 새 작업 공간을 만들고, 다음 단계 선택지를 보여줍니다.
- `brainstorm` 은 의도, 우선순위, 포기할 것, 성공 기준을 묻고 plan 으로 넘길 준비를 합니다.
- `plan` 은 대화록이 아니라 목표, 범위, 완료 기준, 확인 방법을 담는 짧은 계약입니다.
- `implement` 는 코드뿐 아니라 문서, 전략, 디자인 handoff, QA evidence, 운영/runbook 도 산출물로 봅니다.
- `review` 는 산출물 검토입니다. Solon 이 code/docs/strategy/design/QA/ops/release lens 를 자동 추론합니다.
- `retro` 는 sprint 마무리 명령입니다. report 정리, archive, sprint close 를 함께 처리합니다.

`sfs report` 와 `sfs tidy` 는 기본 흐름의 필수 단계가 아닙니다. 보고서만 먼저 보고 싶거나,
이미 끝난 sprint workbench 를 따로 정리할 때 쓰는 보조 명령입니다.

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

`sfs upgrade` 는 누락된 routed context 파일도 같은 버전 안에서 자동 복구합니다.

오래된 프로젝트에서는 `sfs` 실행 시 부드러운 업데이트 안내가 뜹니다. 끄려면
`SFS_VERSION_NOTICE=0` 을 씁니다. 토큰 낭비 가능성이 보일 때(어댑터 문서 비대,
큰 코드베이스 등) 띄우는 hygiene 안내는 `SFS_HYGIENE_NOTICE=0` 으로 끕니다. 자세한 동작은
[현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 참고.

---

## Command Surface

| Command | Purpose |
|---|---|
| `sfs status` | 현재 sprint, gate, ahead count, last event 확인 |
| `sfs guide` | 설치된 프로젝트에서 짧은 in-terminal 가이드 출력 |
| `sfs start <goal>` | 새 sprint workspace 생성 |
| `sfs brainstorm [--simple|--hard] [text|--stdin]` | 요구사항 정리와 PO 사고 훈련. 기본은 normal |
| `sfs plan` | 목표/범위/완료 기준 계약 작성 |
| `sfs implement [slice|--stdin]` | plan 기반 실행 slice + evidence 기록 |
| `sfs review [--lens ...]` | 산출물 검토. lens 는 기본 자동 추론 |
| `sfs report` | 필요할 때만 보고서 먼저 생성/재정리 |
| `sfs retro [--draft]` | 기본은 sprint close + archive + local close commit. 초안만 열려면 `--draft` |
| `sfs decision <title>` | ADR-style 결정 기록 |
| `sfs tidy [--apply]` | 이미 끝난 sprint workbench/tmp archive 정리 |
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
| 10x value | [KO](./docs/ko/10x-value.md) | [EN](./docs/en/10x-value.md) |
| 30-minute guide | [KO](./GUIDE.md) | [EN](./docs/en/guide.md) |
| Beginner guide | [KO](./BEGINNER-GUIDE.md) | planned |
| Release history | [CHANGELOG.md](./CHANGELOG.md) | [CHANGELOG.md](./CHANGELOG.md) |

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
- `sfs review` 는 만든 쪽이 스스로 통과시키지 않도록 검토 역할, 근거, 판정을 분리합니다.
- `sfs retro` 는 사용자가 명시적으로 호출했을 때만 archive, sprint close, local close commit 을 수행합니다.
- gate 는 진행을 강제로 막지 않는 신호입니다. 최종 판단은 사용자에게 남깁니다.

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
