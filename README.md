# Solon 제품

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon 은 AI 가 일을 빠르게 만들 때, 사람이 놓치기 쉬운 의도, 결정, 검증, 마무리를
> 프로젝트 안에 붙잡아 두는 작업 운영판입니다.

**언어**: 한국어 / [영어 문서](./docs/en/index.md)

---

## SFS란

SFS 는 두 가지 의미를 함께 가집니다.

- **Sprint Flow System**: 매일 쓰는 `sfs` / `/sfs` 명령 흐름입니다.
  `start → brainstorm → plan → implement → review → retro` 로 생각과 실행을 통과시킵니다.
- **Solo Founder System**: 혼자 제품을 만드는 사람이 여러 AI agent 를 팀처럼 쓰기 위한
  운영 시스템입니다. 역할, 결정 기록, 검토, 회고, 인수인계를 프로젝트 안에 고정합니다.

핵심 약속은 단순합니다.

- AI 는 실행을 돕습니다.
- Solon 은 흐름과 기록을 잡아줍니다.
- 사용자는 방향, 우선순위, 최종 통과 여부를 결정합니다.

---

## 현재 흐름

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
- `retro` 는 sprint 마무리 명령입니다. 회고, 짧은 report, 마무리 기록을 함께 정리합니다.

`sfs report` 와 `sfs tidy` 는 기본 흐름의 필수 단계가 아닙니다. 보고서만 먼저 보고 싶거나,
이미 끝난 sprint workbench 를 따로 정리할 때 쓰는 보조 명령입니다.

상세 설명:

- [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md)
- [Solon 10x 가치](./docs/ko/10x-value.md)
- [30분 온보딩 가이드](./GUIDE.md)

---

## 설치

개발, 터미널, CLI 환경이 낯설다면 먼저 [BEGINNER-GUIDE.md](./BEGINNER-GUIDE.md) 를 보세요.

> **0.6.1 기준**: `brew install` / `scoop install` 한 번으로 Claude Code (`/sfs`),
> Gemini CLI (`sfs`), Codex CLI (`$sfs`) 가 모두 Solon 을 찾습니다.
> 프로젝트 폴더에는 사용자가 읽고 고칠 문서와 작업 기록만 남도록 정리했습니다.

### Windows (Scoop)

```powershell
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

# 위 한 줄이 끝나면 /sfs (Claude), sfs (Gemini), $sfs (Codex) 모두 등록 완료.

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

### Mac (Homebrew)

```bash
brew install MJ-0701/solon-product/sfs
# /sfs (Claude), sfs (Gemini), $sfs (Codex) 자동 등록.

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

### 세 AI 도구 연결 확인

```bash
sfs doctor    # ✅ Claude Code  /  ✅ Gemini CLI  /  ✅ Codex CLI
```

세 줄 모두 ✅ 면 Claude, Gemini, Codex 에서 바로 Solon 을 쓸 수 있습니다.
어떤 줄이 ⚠️ 면 그 옆에 출력되는 한 줄 안내를 그대로 실행하세요.

### 업데이트

재설치하지 말고 프로젝트 루트에서 실행합니다.

```bash
sfs upgrade
sfs version --check
```

Windows PowerShell/cmd:

```powershell
sfs.cmd update
sfs.cmd version --check
```

Windows 에서는 `sfs.cmd update` 하나만 기억하면 됩니다. Solon 본체를 최신화하고,
현재 프로젝트에 필요한 정리까지 이어서 처리합니다.

업데이트 후에도 사용하던 기록은 사라지지 않습니다. 오래된 설치 방식에서 생긴 파일은
가능한 한 조용히 접고, 지금 사용자가 봐야 할 표면만 남기는 쪽으로 정리합니다.
예전처럼 프로젝트 안에 Solon 본체 파일을 보관해야 하는 경우에만
`sfs upgrade --layout vendored` 를 사용하세요.

---

## 새 앱에서 시작하기

처음 쓰는 사람이 Next.js, Spring, Java, API 같은 말을 알고 있을 필요는 없습니다.
사용자는 그냥 만들고 싶은 것을 말하면 됩니다. Solon 을 쓰는 AI 는 대화나 brainstorm 중
"앱 뼈대가 먼저 필요하겠다"는 신호를 보면 이렇게 물어보는 흐름을 권장합니다.

```text
초기 프로젝트 구성해드릴까요?
```

사용자가 동의하면 현재 AI 가 만들고 싶은 것의 크기와 성격을 보고 native 방식으로 구성합니다.
예를 들어 단순 소개 페이지, 예약 폼, 관리자 화면, 서버가 필요한 서비스는 시작점이 다릅니다.
Solon 은 특정 프레임워크 starter 를 고정하지 않고, Claude, Codex, Gemini 또는 각 프레임워크의
공식 CLI 로 알맞은 뼈대를 만든 뒤 돌아오는 흐름을 씁니다.

AI 는 필요할 때 내부 handoff 로 `sfs bootstrap "<만들고 싶은 것>"` 를 사용할 수 있습니다.
이 명령은 Solon 이 자체 템플릿을 남기는 기능이 아니라, 현재 AI 에게 "알맞은 초기 구성을
제안하고, 동의받고, native 방식으로 만든 뒤 Solon 으로 돌아오라"는 실행 신호입니다. 사용자가
이 명령을 외울 필요는 없습니다.

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "첫 작업 목표"
```

Solon 의 강점은 앱 generator 가 아니라, 그 다음부터의 의도 정리, 범위 결정, 실행 기록,
검토, 회고를 프로젝트 안에 남기는 데 있습니다.

0.6.1부터는 backend, 전략/PM, QA, 디자인, 운영, 경영관리, taxonomy 같은 분야별 지식팩도
실제 안내로 채워졌습니다. 재무, 경리, 세무, 회계처럼 solo founder 가 놓치기 쉬운 기준도
필요할 때만 조용히 꺼내 review 나 plan 에 반영합니다.

---

## 명령어

| 명령 | 용도 |
|---|---|
| `sfs status` | 지금 열려 있는 작업과 최근 상태 확인 |
| `sfs guide` | 설치된 프로젝트에서 짧은 in-terminal 가이드 출력 |
| `sfs start <goal>` | 새 작업 묶음 시작 |
| `sfs brainstorm [--simple|--hard] [text|--stdin]` | 만들기 전에 의도, 기준, 빠진 결정을 정리 |
| `sfs plan` | 목표/범위/완료 기준 계약 작성 |
| `sfs implement [slice|--stdin]` | 작은 실행 조각을 진행하고 근거를 남김 |
| `sfs review [--lens ...]` | 산출물이 받아들일 만한지 검토 |
| `sfs report` | 필요할 때만 짧은 보고서를 먼저 확인 |
| `sfs retro [--draft]` | 작업을 회고하고 마무리. 초안만 열려면 `--draft` |
| `sfs bootstrap "<만들고 싶은 것>"` | agent-facing 초기 프로젝트 구성 handoff trigger |
| `sfs measure --alive -- <command>` | 긴 명령이 멈춘 것처럼 보이지 않게 진행 신호를 남김 |
| `sfs decision <title>` | ADR-style 결정 기록 |
| `sfs tidy [--apply]` | 이미 끝난 작업의 긴 임시 기록을 접어둠 |
| `sfs adopt [--apply]` | 오래된 프로젝트를 Solon 으로 처음 들여옴 |
| `sfs auth ...` | 검토 실행 계정 연결 상태 확인 |
| `sfs profile` | `SFS.md` 프로젝트 개요만 좁게 감지/보정 |
| `sfs division ...` | 분야별 역할 묶음 관리 |
| `sfs loop ...` | 큰 작업을 여러 조각으로 길게 진행하는 고급 모드 |

runtime 별 호출 표기:

| Runtime | 진입 명령 |
|---|---|
| Claude Code | `/sfs status` |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Windows PowerShell/cmd | `sfs.cmd status` |

---

## 문서 지도

| 문서 | 한국어 | 영어 |
|---|---|---|
| 문서 index | [docs/ko](./docs/ko/index.md) | [docs/en](./docs/en/index.md) |
| 현재 제품 흐름 | [KO](./docs/ko/current-product-shape.md) | [EN](./docs/en/current-product-shape.md) |
| 10x 가치 | [KO](./docs/ko/10x-value.md) | [EN](./docs/en/10x-value.md) |
| 30분 가이드 | [KO](./GUIDE.md) | [EN](./docs/en/guide.md) |
| 초보자 가이드 | [KO](./BEGINNER-GUIDE.md) | 예정 |
| 릴리스 노트 | [RELEASE-NOTES.md](./RELEASE-NOTES.md) | 예정 |
| 상세 변경 이력(archive) | [CHANGELOG.md](./CHANGELOG.md) | [CHANGELOG.md](./CHANGELOG.md) |

---

## 설치되는 파일

| 경로 | 역할 |
|---|---|
| `SFS.md` | 프로젝트 운영 지침 |
| `CLAUDE.md` | Claude Code 가 Solon 을 찾는 입구 |
| `AGENTS.md` | Codex 가 Solon 을 찾는 입구 |
| `GEMINI.md` | Gemini CLI 가 Solon 을 찾는 입구 |
| `.sfs-local/` | sprint, 결정, 진행 기록, 설정이 쌓이는 곳 |
| `.claude/`, `.gemini/`, `.agents/` | 꼭 필요한 프로젝트에서만 추가로 설치하는 AI 도구별 바로가기 |

0.6.1 기준 기본 설치는 가볍습니다. Solon 본체는 패키지 쪽에 두고, 프로젝트에는
읽어야 할 문서와 쌓아야 할 기록만 남깁니다. AI 도구별 native 파일이 꼭 필요한 팀만
`sfs agent install all` 로 추가 설치하면 됩니다.

---

## 안전 계약

- install/upgrade/uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.
- 사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은
  install/upgrade 과정에서 덮어쓰지 않습니다.
- `sfs review` 는 만든 쪽이 스스로 통과시키지 않도록 검토 역할, 근거, 판정을 분리합니다.
- `sfs retro` 는 사용자가 명시적으로 호출했을 때만 sprint 마무리와 정리 commit 을 수행합니다.
- gate 는 진행을 강제로 막지 않는 신호입니다. 최종 판단은 사용자에게 남깁니다.

---

## 패키지 지도

| 경로 | 역할 |
|---|---|
| `bin/sfs` | Mac/Git Bash 에서 실행하는 Solon 명령 |
| `bin/sfs.cmd` / `bin/sfs.ps1` | Windows 에서 실행하는 Solon 명령 |
| `install.sh` / `install.ps1` | 프로젝트에 Solon 을 처음 붙이는 설치 스크립트 |
| `upgrade.sh` / `upgrade.ps1` | 이미 설치된 프로젝트를 최신 흐름으로 맞추는 스크립트 |
| `templates/` | 새 프로젝트와 운영 문서의 기본 틀 |
| `docs/ko`, `docs/en` | 한국어/영어 안내 문서 |
| `packaging/` | Homebrew/Scoop 릴리스 템플릿 |
| `CHANGELOG.md` | 버전별 변경 기록 |
| `VERSION` | 현재 배포 버전 |
