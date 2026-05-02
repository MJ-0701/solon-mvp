# Solon Product - 사용 가이드

> 목표: 설치 직후 30분 안에 첫 작업 묶음(sprint)을 시작하고, 생각 정리부터 마무리까지
> 어떤 순서로 가야 하는지 감을 잡는 것.

**Language**: 한국어 / [English](./docs/en/guide.md)

자세한 제품 철학과 최신 변화는 [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md),
AI 시대에 Solon 이 주는 가치는 [Solon 10x 가치](./docs/ko/10x-value.md) 에서 이어서 볼 수 있습니다.

---

## 0. 이 문서가 알려주는 것

이 가이드는 처음 쓰는 사람이 그대로 따라 할 수 있는 길에 집중합니다.

- 어떤 파일이 생기는지
- 첫 sprint 를 어떻게 시작하는지
- `brainstorm`, `plan`, `implement`, `review`, `retro` 가 각각 무엇을 하는지
- `report` 와 `tidy` 는 언제 따로 쓰는지
- 깊은 백엔드/디자인/QA/운영 기준은 어디서 보면 되는지

깊은 판단 기준은 [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 와
[Solon 10x 가치](./docs/ko/10x-value.md) 에 따로 모아두었습니다.

---

## 1. 설치와 초기화

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
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd agent install all
sfs.cmd status
```

설치 뒤 프로젝트에는 대략 이런 파일이 생깁니다.

| Path | 내가 알아야 할 역할 |
|---|---|
| `SFS.md` | 이 프로젝트의 운영 지침과 정체성 |
| `CLAUDE.md` | Claude Code 가 읽는 얇은 연결 파일 |
| `AGENTS.md` | Codex 가 읽는 얇은 연결 파일 |
| `GEMINI.md` | Gemini CLI 가 읽는 얇은 연결 파일 |
| `.sfs-local/` | sprint, 결정, 이벤트, 설정이 쌓이는 곳 |
| `.claude/`, `.gemini/`, `.agents/` | 각 agent runtime 과 연결하는 배포 파일 |

처음에는 `SFS.md` 의 프로젝트 이름, 도메인, 스택, 배포 환경만 실제 프로젝트에 맞게 바꾸면 됩니다.
자동으로 좁게 채우고 싶으면 agent 안에서는 `/sfs profile`, 터미널에서는 `sfs profile --apply` 를 씁니다.

---

## 2. 5초 그림

SFS 는 두 가지 뜻을 함께 가집니다.

- **Sprint Flow System**: 매일 쓰는 `sfs` 명령 흐름
- **Solo Founder System**: 혼자 제품을 만들 때 AI agent 들을 팀처럼 쓰기 위한 운영 구조

기본 흐름은 아래입니다.

```text
sfs status
-> sfs start "<goal>"
-> sfs brainstorm [--simple|--hard] "<raw context>"
-> sfs plan
-> sfs implement "<first slice>"
-> sfs review
-> sfs retro
```

여기서 중요한 점은 `sfs retro` 가 일반적인 sprint 마무리라는 것입니다.
`sfs report` 와 `sfs tidy` 는 자주 쓰는 보조 명령이지만, 기본 마무리 순서에 끼워 넣을 필요는 없습니다.

---

## 3. 어디서 어떻게 입력하나

같은 SFS runtime 을 쓰지만, 사용하는 agent 에 따라 앞의 표기만 다릅니다.

| 환경 | 예시 |
|---|---|
| Claude Code | `/sfs status` |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Windows PowerShell/cmd | `sfs.cmd status` |

이 문서의 예시는 대부분 `sfs ...` 로 적습니다. Claude Code 에서는 앞에 `/` 를 붙이고,
Codex CLI 에서는 앞에 `$` 를 붙이면 됩니다.

---

## 4. 첫 상태 확인

프로젝트 루트에서 실행합니다.

```bash
sfs status
```

처음에는 아래처럼 sprint 가 비어 있을 수 있습니다.

```text
sprint - · WU - · gate -:- · ahead 0 · last_event -
```

대시는 "아직 시작한 sprint 가 없다"는 뜻입니다.

---

## 5. 새 작업 시작

```bash
sfs start "todo 앱 v0 - 일정 추가/완료/삭제 + 저장"
```

`start` 는 작업 공간을 만듭니다. 보통 아래 파일들이 `.sfs-local/sprints/<sprint-id>/` 아래에 생깁니다.

| File | 역할 |
|---|---|
| `brainstorm.md` | 아직 정리되지 않은 생각과 질문 |
| `plan.md` | 이번 작업의 목표, 범위, 완료 기준 |
| `implement.md` | 실제 실행 조각과 변경 내용 |
| `log.md` | 진행 로그와 검증 흔적 |
| `review.md` | 검토 결과와 다음 조치 |
| `retro.md` | 마무리 회고 |
| `report.md` | 완료 시점에 만들어지는 짧은 보고서 |

`start` 가 끝나면 다음 단계 선택지를 함께 출력합니다. 보통은 brainstorm 으로 이어집니다.

```text
sfs brainstorm --simple "..."  # 이미 방향이 뚜렷할 때 빠른 정리
sfs brainstorm "..."           # 기본값, 몇 가지 핵심 질문으로 생각 정리
sfs brainstorm --hard "..."    # product owner hard training
```

직전 sprint 의 `plan.md` 나 ADR 을 그대로 이어받는 구현 sprint 라면 `brainstorm` 을 두껍게
반복하지 않아도 됩니다. 그때는 `plan.md` 에 "어디서 이어받는지"와 "이번에 끝낼 작은 범위"만
적고 바로 `implement` 로 갈 수 있습니다.

---

## 6. Brainstorm - 생각을 정리하는 단계

`brainstorm` 은 요구사항을 받아 적는 명령이 아닙니다. plan 으로 넘어가기 전에 사용자의 의도,
우선순위, 포기할 것, 성공 기준을 드러내는 단계입니다.

| Mode | 언제 쓰나 | 결과 |
|---|---|---|
| `--simple` | 이미 답이 거의 정해졌을 때 | 요구사항을 짧게 정리하고 plan seed 로 넘김 |
| 기본 `normal` | 대부분의 새 작업 | 2~5개의 핵심 질문으로 빠진 결정을 확인 |
| `--hard` | 의도, 경계, 용어, 검증 방식이 흐릿할 때 | 사용자가 product owner 로 깊게 생각할 때까지 계속 캐묻기 |

예시:

```bash
sfs brainstorm "사용자가 결제 실패 이유를 더 빨리 파악하게 하고 싶다"
```

긴 내용을 파일로 정리해 둔 경우:

```bash
sfs brainstorm --stdin < requirements.txt
```

`--hard` 는 일부러 빠른 실행을 늦춥니다. AI 가 바로 달려가서 완성물을 만드는 대신,
사용자가 제품의 주인으로 판단해야 하는 질문을 계속 꺼냅니다. 이 모드는 AI 도움을 줄이는 기능이
아니라, AI 시대에 생각하는 근육을 잃지 않게 하는 훈련 모드입니다.

---

## 7. Plan - 실행 전 약속 만들기

```bash
sfs plan
```

좋은 plan 은 대화록이 아닙니다. 이번 작업을 끝냈다고 말하려면 무엇이 필요하고, 무엇은 하지
않을지 적는 짧은 계약입니다.

Plan 에 꼭 들어가야 하는 것:

- 이번 작업의 목표
- 완료 기준, 즉 "무엇이 되면 끝인가"
- 이번에 할 것과 하지 않을 것
- 확인 방법: 테스트, 화면 확인, 문서 검토, 수동 점검 등
- 첫 번째로 실행할 작은 조각

중요한 결정이 비어 있으면 AI 가 알아서 추측하게 두지 않습니다. 질문을 남기고 사용자의 판단을
기다리는 것이 Solon 의 기본값입니다.

---

## 8. Implement - 작은 조각 하나를 실제로 움직이기

```bash
sfs implement "첫 실행 조각"
```

Solon 에서 `implement` 는 코드만 뜻하지 않습니다. 제품을 앞으로 움직인 산출물이라면 모두 구현
대상입니다.

| 작업 종류 | 예시 |
|---|---|
| 코드 | API, UI, 배치, DB migration, 테스트 |
| 문서 | README, GUIDE, runbook, 고객 안내 |
| 전략 | PRD, 가격 정책, 실험 계획, 우선순위 결정 |
| 디자인 | 화면 흐름, component handoff, interaction spec |
| QA | 재현 절차, smoke test, regression checklist |
| 운영 | 배포 절차, rollback 방법, 모니터링 메모 |
| 용어 정리 | 도메인 단어, naming, taxonomy |

첫 실행 조각은 작아야 합니다. 전체 기능을 한 번에 맡기기보다, 완료 기준 하나를 증명하는
변경부터 갑니다.

구현 전에 확인할 질문:

- 기존 프로젝트는 어떤 구조와 이름 규칙을 쓰고 있나?
- 이번 조각이 증명할 완료 기준은 무엇인가?
- 바뀐 것을 어떻게 확인할 것인가?
- 사용자가 직접 결정해야 하는 경계가 남아 있나?

백엔드, 디자인, QA, 운영의 깊은 기준은 중요하지만 모든 사용자에게 첫 가이드에서 같은 무게로
설명할 내용은 아닙니다. 필요할 때
[현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 를 참고하세요.

---

## 9. Review - 산출물이 받아들일 만한지 확인하기

```bash
sfs review
```

`review` 는 항상 코드리뷰라는 뜻이 아닙니다. 코드 작업이면 코드리뷰가 맞고, 문서 작업이면 문서
검토, 전략 작업이면 전략 검토, 디자인 작업이면 디자인 검토가 됩니다.

Solon 은 sprint evidence 와 변경 산출물을 보고 review lens 를 자동으로 고릅니다.

| Lens | 보는 것 |
|---|---|
| `code` | 동작, 테스트, 회귀, 유지보수성 |
| `docs` | 읽는 흐름, 정확성, 오래된 설명, 링크 |
| `strategy` | 결정의 질, tradeoff, 실행 가능성 |
| `design` | 사용자 흐름, 일관성, 화면/상호작용 evidence |
| `taxonomy` | 용어, 분류, 이름 경계 |
| `qa` | 검증 범위, 재현성, 남은 위험 |
| `ops` | 배포, rollback, 운영 절차 |
| `release` | 버전, changelog, package, 배포 검증 |

대부분은 그냥 `sfs review` 라고 입력하면 됩니다. Solon 의 추론이 틀렸을 때만
`sfs review --lens docs` 처럼 직접 지정합니다.

---

## 10. Retro - sprint 마무리

```bash
sfs retro
```

`retro` 는 sprint 를 마무리하는 명령입니다. 한 번 실행하면 다음을 함께 처리합니다.

- `retro.md` 를 회고로 정리
- `report.md` 가 없으면 만들거나 최신 내용으로 정리
- 긴 workbench 원문과 임시 review 산출물을 archive 로 이동
- sprint 상태를 close
- local close commit 생성

그래서 일반적인 흐름은 `sfs review -> sfs retro` 두 단계로 끝납니다. 보고서만 먼저
보고 싶거나 sprint 를 닫지 않고 회고 초안만 열고 싶을 때 쓰는 옵션은 §11 에
정리되어 있습니다.

---

## 11. 필요할 때만 쓰는 명령

일상적인 흐름은 `status -> start -> brainstorm -> plan -> implement -> review -> retro` 입니다.
아래 명령은 필요할 때만 꺼내면 됩니다.

| Command | 언제 쓰나 |
|---|---|
| `sfs report` | sprint 를 닫기 전에 보고서만 먼저 보고 싶을 때 |
| `sfs report --sprint <id>` | 과거 sprint 의 보고서를 다시 만들거나 정리할 때 |
| `sfs retro --draft` | sprint 를 닫지 않고 회고 초안만 열어두고 싶을 때 |
| `sfs tidy --sprint <id> --apply` | 이미 끝난 sprint 의 긴 workbench/tmp 파일을 archive 로 접을 때 |
| `sfs decision "<title>"` | 오래 남겨야 하는 결정을 ADR 로 기록할 때 |
| `sfs adopt --apply` | 오래된 프로젝트를 Solon 으로 처음 들여올 때 |
| `sfs profile --apply` | `SFS.md` 프로젝트 개요만 자동 보정할 때 |
| `sfs upgrade` | 설치된 프로젝트를 최신 Solon 문서/adapter/runtime 으로 갱신할 때 |
| `sfs version --check` | 현재 프로젝트와 runtime 버전 상태를 볼 때 |
| `sfs loop ...` | 큰 작업을 queue 로 나누어 장시간 진행할 때 |

---

## 12. 업데이트

Solon 을 새로 깔아도 기존 프로젝트를 지우고 다시 만들 필요는 없습니다.

Mac/Git Bash:

```bash
sfs upgrade
sfs version --check
```

Windows PowerShell/cmd:

```powershell
sfs.cmd upgrade
sfs.cmd version --check
```

오래된 프로젝트에서는 `sfs` 실행 시 부드러운 update notice 가 뜹니다. 강제 업데이트는
아니고, 업데이트할지 묻는 안내입니다. 끄려면 `SFS_VERSION_NOTICE=0` 을 사용합니다.

SFS 는 토큰 낭비 가능성이 보일 때 (어댑터 문서가 비대하거나, sprint workbench 가 너무
크거나, 큰 코드베이스에서 작업할 때) hygiene 안내를 띄웁니다. 끄려면
`SFS_HYGIENE_NOTICE=0` 을 씁니다. 어떤 동작을 SFS 가 자동으로 적용하는지는
[현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 의 "Token / Harness Hygiene"
섹션에 정리되어 있습니다.

---

## 13. 자주 헷갈리는 것

### `sfs report` 를 꼭 먼저 해야 하나?

아니요. 일반적인 sprint 마무리는 `sfs retro` 입니다. `retro` 가 report 를 함께 정리합니다.
`report` 는 보고서만 먼저 보고 싶거나 과거 sprint 를 다시 정리할 때 따로 씁니다.

### `review` 는 코드리뷰인가?

코드 작업이면 코드리뷰가 맞습니다. 하지만 문서, 전략, 디자인, QA, 운영 작업에서는 해당 산출물이
받아들일 만한지 보는 review 입니다.

### GUIDE 에 없는 깊은 백엔드 기준은 어디 있나?

초보 가이드에서는 깊은 기준을 줄였습니다. 백엔드 구조, 트랜잭션, 본부별 정책,
AI 시대의 설계 원칙은 [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 와
[Solon 10x 가치](./docs/ko/10x-value.md) 에서 확인합니다. 더 자세한 운영 규칙은 설치된
프로젝트의 `.sfs-local/context/` 폴더에 routed context 문서로 들어 있습니다.

### `/sfs` 가 인식되지 않는다.

Claude Code 에서는 `/sfs`, Gemini CLI 에서는 `sfs`, Codex CLI 에서는 `$sfs` 를 씁니다.
Windows PowerShell/cmd 에서는 `sfs.cmd` 를 씁니다.

### 완료된 sprint 는 무엇을 보면 되나?

가장 먼저 `.sfs-local/sprints/<sprint-id>/report.md` 를 봅니다. 더 자세한 배경과 학습은
`retro.md`, 장기 결정은 `.sfs-local/decisions/` 를 봅니다.

---

## 14. 첫 sprint 예시

```bash
sfs status
sfs start "todo 앱 v0 - 일정 추가/완료/삭제 + 저장"
sfs brainstorm "처음 사용자가 일정 하나를 추가/완료까지 보는 흐름이 가장 짧아야 한다"
sfs plan
sfs implement "일정 추가 + 목록 표시"
sfs review
sfs retro
```

이 정도가 기본 길입니다. Solon 의 목적은 명령어를 많이 외우게 하는 것이 아니라, AI 가 빠르게
움직이더라도 사용자의 의도, 판단, 검증, 마무리가 사라지지 않게 하는 것입니다.
