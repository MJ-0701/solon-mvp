# Solon MVP

> AI 와 함께 제품을 만들 때 필요한 **역할 분리, 결정 기록, 검증, 회고, 인수인계**를
> 프로젝트 안에 설치하는 Company-as-Code 운영 레이어.

Solon MVP 는 1인 창업가와 소규모 제품 팀이 Claude Code, Codex, Gemini CLI 같은
LLM agent 와 일할 때 작업 맥락을 잃지 않도록 돕는 로컬 스캐폴드입니다. 설치하면
프로젝트에 7-step flow, `/sfs` 명령, sprint 산출물, decision log, review gate,
runtime adapter 가 함께 들어갑니다.

**버전**: `0.4.0-mvp` · **상태**: MVP / private beta · **라이선스**: 개인 IP,
정식 라이선스 TBD

---

## What It Solves

AI 는 구현 속도를 크게 올려 주지만, 제품 작업에는 코드 생성보다 더 오래 남는 문제가
있습니다.

- 결정 근거가 사라져 같은 논의를 반복한다.
- 설계 없이 구현한 코드가 다음 sprint 의 부채가 된다.
- 만든 agent 와 검증 agent 가 섞여 자기검증이 발생한다.
- 세션이 바뀔 때마다 현재 상태와 다음 행동을 다시 추측한다.
- 출시 직전 secret, auth, data, monitoring, rollback, cost 같은 readiness evidence 가 누락된다.

Solon 은 이 문제를 "더 똑똑한 프롬프트"가 아니라 **운영 구조**로 다룹니다. AI 가 일을
수행하게 하되, 방향 결정과 최종 통과 권한은 사용자에게 남깁니다.

---

## Core Model

Solon MVP 는 회사를 움직이는 최소 단위를 파일과 명령으로 재현합니다.

```text
Company = Org x Process x Artifact x Observability
```

| 축 | MVP 에서의 형태 |
|---|---|
| Org | 6 Division + 3 C-Level 관점의 역할/책임 분리 |
| Process | 브레인스토밍 → plan → sprint → 구현 → review → commit → 문서화 |
| Artifact | `plan.md`, `review.md`, `retro.md`, ADR-style decision |
| Observability | `/sfs status`, `.sfs-local/events.jsonl`, current sprint state |

7-step flow 는 full startup artifact chain 의 lightweight projection 입니다. Discovery,
PRD, Taxonomy, UX, Technical Design, Release Readiness 를 제거했다는 뜻이 아니라,
MVP 배포판에서 운용 가능한 최소 단위로 접은 형태입니다.

Gate 는 all signal-only 입니다. Solon 은 위험을 표시하고 evidence 를 남기지만, 진행을
강제로 막지 않습니다.

---

## Quickstart

설치할 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash
```

설치 후 Claude Code 에서는 바로 `/sfs` 를 사용할 수 있습니다.

```text
/sfs status
/sfs start "첫 번째 sprint 목표"
/sfs plan
/sfs review --gate G2
/sfs decision "초기 인증 방식은 세션 기반으로 시작한다"
/sfs retro --close
```

Codex 와 Gemini CLI 에서는 프로젝트에 설치된 `SFS.md` 와 runtime adapter 문서를 읽고
같은 흐름을 자연어로 호출합니다.

```text
SFS.md 와 AGENTS.md 읽고 sfs status 처럼 현재 상태 요약해줘
SFS.md 와 GEMINI.md 읽고 이번 sprint plan 작성해줘
```

`/sfs retro --close` 는 사용자가 명시적으로 호출했을 때만 sprint close 와 auto commit 을
수행합니다. push 는 하지 않습니다.

---

## Commands

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

Claude Code 에서는 `/sfs` slash command 가 bash adapter 를 dispatch 합니다. Codex 와
Gemini CLI 는 설치된 adapter 문서를 통해 같은 파일 계약을 따릅니다.

---

## Installation

### Remote One-Liner

```bash
cd ~/workspace/my-project
curl -sSL https://raw.githubusercontent.com/MJ-0701/solon-mvp/main/install.sh | bash
```

### Local Clone

```bash
git clone https://github.com/MJ-0701/solon-mvp ~/tmp/solon-mvp
cd ~/workspace/my-project
bash ~/tmp/solon-mvp/install.sh
```

### Non-Interactive

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-mvp/install.sh --yes
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

주요 배포 템플릿은 이 repo 의 `templates/` 아래에 있습니다.

---

## Idempotency And Conflict Handling

`install.sh` 는 재실행 가능하도록 설계되어 있습니다. 기존 파일과 충돌하면 다음 옵션 중
하나를 선택합니다.

| 옵션 | 동작 |
|---|---|
| `s` | skip, 기존 파일 유지 |
| `b` | backup + overwrite, `.bak-YYYYMMDD-HHMMSS` 생성 후 덮어쓰기 |
| `o` | overwrite, 즉시 덮어쓰기 |
| `d` | diff 확인 후 다시 선택 |

사용자가 만든 `.sfs-local/sprints/`, `.sfs-local/decisions/`, `.sfs-local/events.jsonl` 은
install/upgrade 과정에서 덮어쓰지 않습니다.

---

## Upgrade

```bash
cd ~/workspace/my-project
bash ~/tmp/solon-mvp/upgrade.sh
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
bash ~/tmp/solon-mvp/uninstall.sh
```

Uninstall 은 대화형으로 실행됩니다.

- 전체 제거
- scaffold 만 제거하고 sprint/decision/event 산출물 보존
- 취소

install, upgrade, uninstall 은 consumer 프로젝트에 자동 push 하지 않습니다.

---

## Repository Map

| 파일/디렉토리 | 역할 |
|---|---|
| `install.sh` | consumer 프로젝트에 Solon MVP scaffold 설치 |
| `upgrade.sh` | 설치된 scaffold 를 새 배포판으로 갱신 |
| `uninstall.sh` | 설치된 scaffold 제거 |
| `templates/SFS.md.template` | 공통 운영 지침 |
| `templates/CLAUDE.md.template` | Claude Code adapter template |
| `templates/AGENTS.md.template` | Codex adapter template |
| `templates/GEMINI.md.template` | Gemini CLI adapter template |
| `templates/.claude/commands/sfs.md` | Claude Code slash command template |
| `templates/.sfs-local-template/` | runtime scripts, sprint templates, decision templates |
| `CHANGELOG.md` | release history |
| `VERSION` | 현재 배포판 버전 |

---

## Operating Principles

- **Human final filter**: AI 는 제안하고 실행할 수 있지만, 방향과 통과 여부는 사용자가 결정합니다.
- **Record over memory**: 중요한 결정과 gate signal 은 파일과 event 로 남깁니다.
- **No self-verification**: 만든 주체와 검증 주체를 분리하는 방향으로 workflow 를 구성합니다.
- **Never hard-block by default**: gate 는 진행 차단 장치가 아니라 위험 신호와 evidence 기록 장치입니다.
- **Respect consumer git**: 설치/업그레이드/제거 스크립트는 consumer 의 commit/push 정책을 대신하지 않습니다.
- **Domain-neutral distribution**: templates 는 특정 제품 도메인이나 회사 맥락을 하드코딩하지 않습니다.

---

## Changelog

릴리스 기록은 [CHANGELOG.md](./CHANGELOG.md) 를 참조하세요.
