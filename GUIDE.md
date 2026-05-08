# Solon 제품 사용 가이드

> 목표는 설치 직후 30분 안에 첫 작업 묶음(sprint)을 시작하고, 생각 정리부터 마무리까지
> 어떤 순서로 진행하면 되는지 편하게 감을 잡는 것입니다.

**언어**: 한국어 / [영어 문서](./docs/en/guide.md)

자세한 제품 철학과 최신 변화는 [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md),
AI 시대에 Solon 이 주는 가치는 [Solon 10x 가치](./docs/ko/10x-value.md) 에서 이어서 볼 수 있습니다.

---

## 0. 이 문서가 알려주는 것

이 가이드는 처음 쓰는 분이 그대로 따라 할 수 있는 길에 집중합니다.

- 어떤 파일이 생기는지
- 첫 sprint 를 어떻게 시작하는지
- `brainstorm`, `plan`, `implement`, `review`, `retro` 가 각각 무엇을 하는지
- `report` 와 `tidy` 는 언제 따로 쓰는지
- 깊은 백엔드/디자인/QA/운영 기준은 어디서 보면 되는지

깊은 판단 기준은 [현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 와
[Solon 10x 가치](./docs/ko/10x-value.md) 에 따로 모아두었습니다.

---

## 1. 설치와 초기화

> **0.6.41 기준** brew/scoop 한 줄이면 Claude Code, Gemini CLI, Codex CLI 가 모두
> Solon 을 찾습니다. 별도 plugin/extension 설치 명령을 기억하지 않아도 됩니다.

Mac:

```bash
brew install MJ-0701/solon-product/sfs
# /sfs (Claude), sfs (Gemini), $sfs (Codex) 모두 자동 등록 완료.
sfs doctor   # 세 줄 모두 ✅ 면 OK

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

Windows PowerShell/cmd:

```powershell
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
# 위 한 줄이 /sfs, sfs, $sfs 세 CLI 모두에 등록을 끝냅니다.
sfs.cmd doctor

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

설치 뒤 프로젝트에는 대략 이런 파일이 생깁니다.

| 경로 | 내가 알아야 할 역할 |
|---|---|
| `SFS.md` | 이 프로젝트의 운영 지침과 정체성 |
| `CLAUDE.md` | Claude Code 가 Solon 을 찾는 입구 |
| `AGENTS.md` | Codex 가 Solon 을 찾는 입구 |
| `GEMINI.md` | Gemini CLI 가 Solon 을 찾는 입구 |
| `.sfs-local/` | sprint, 결정, 이벤트, 설정이 쌓이는 곳 |
| `.claude/`, `.gemini/`, `.agents/` | 꼭 필요한 프로젝트에서만 추가로 설치하는 AI 도구별 바로가기 |

처음에는 `SFS.md` 의 프로젝트 이름, 도메인, 스택, 배포 환경만 실제 프로젝트에 맞게 바꾸시면 됩니다.
자동으로 좁게 채우고 싶으면 agent 안에서는 `/sfs profile`, 터미널에서는 `sfs profile --apply` 를 씁니다.
기본 설치는 프로젝트 안을 가볍게 유지합니다. Solon 본체는 패키지 쪽에 두고, 프로젝트에는
사용자가 읽을 문서와 작업 기록을 중심으로 남깁니다. AI 도구별 native 파일이 꼭 필요한 팀만
`sfs agent install all` 로 추가 설치하면 됩니다.

0.6.41 기준으로는 분야별 지식팩이 실제 안내로 채워져 있습니다. 사용자가 backend, QA, infra, 재무,
세무, 회계 같은 말을 정확히 몰라도 괜찮습니다. Solon 을 쓰는 AI 가 작업 성격을 보고 필요한
관점만 읽고, 사용자에게는 평범한 질문과 판단 기준으로 풀어 설명하는 쪽이 기본입니다.

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

처음 하루에는 아래 세 가지만 기억하셔도 충분합니다.

- `sfs status`: 지금 Solon 이 프로젝트를 어떻게 보고 있는지 확인
- `sfs start "..."`: 새 작업 묶음 시작
- `sfs brainstorm "..."`: 바로 만들기 전에 의도와 기준 정리

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

`start` 는 sprint 포인터만 만들고 빈 문서를 우르르 만들지 않습니다. 각 단계 문서는
해당 명령을 실행할 때 하나씩 생깁니다. 작업 전에는 노출을 최소화하고, 작업 중에는
지금 읽어야 할 절차 문서만 남기는 방식입니다.

`start` 가 끝나면 다음 단계 선택지를 출력합니다. 보통은 brainstorm 으로 이어집니다.

```text
sfs brainstorm --simple "..."  # 이미 방향이 뚜렷할 때 빠른 정리
sfs brainstorm "..."           # 기본값, 몇 가지 핵심 질문으로 생각 정리
sfs brainstorm --hard "..."    # product owner hard training
```

직전 sprint 의 `plan.md` 나 ADR 을 그대로 이어받는 구현 sprint 라면 `brainstorm` 을 두껍게
반복하지 않아도 됩니다. 그때는 `plan.md` 에 "어디서 이어받는지"와 "이번에 끝낼 작은 범위"만
적고 바로 `implement` 로 갈 수 있습니다.

빈 앱 뼈대가 먼저 필요할 때도 사용자가 프레임워크 이름을 알아야 하는 것은 아닙니다.
사용자는 그냥 만들고 싶은 것을 말하면 됩니다. brainstorm 중 AI 는 만들고 싶은 것의 크기와
성격을 보고, 필요하면 먼저 이렇게 물어봅니다.

```text
초기 프로젝트 구성해드릴까요?
```

동의하면 현재 AI 가 단순 페이지, 작은 웹앱, 서버가 필요한 서비스처럼 크기를 나누어 알맞은
초기 구성을 잡습니다. Solon 은 자체 템플릿을 남기지 않고, 현재 AI 가 native 방식으로 앱을
만든 뒤 아래 흐름으로 복귀하게 안내합니다. 필요하면 AI 가 내부 handoff 로
`sfs bootstrap "<만들고 싶은 것>"` 를 사용할 수 있지만, 사용자가 이 명령을 외울 필요는 없습니다.

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "첫 작업 목표"
```

Solon 의 역할은 앱 generator 가 아니라, 이후 작업의 의도, 범위, 검증, 회고를 잃지 않게
운영하는 것입니다.

---

## 6. Brainstorm - 생각 정리 단계

`brainstorm` 은 요구사항을 받아 적는 명령이 아닙니다. plan 으로 넘어가기 전에 사용자의 의도,
우선순위, 포기할 것, 성공 기준을 드러내는 단계입니다.

| Mode | 언제 쓰나 | 결과 |
|---|---|---|
| `--simple` | 이미 답이 거의 정해졌을 때 | 요구사항을 짧게 정리하고 plan seed 로 넘김 |
| 기본 `normal` | 대부분의 새 작업 | 2~5개의 핵심 질문으로 빠진 결정을 확인 |
| `--hard` | 의도, 경계, 용어, 검증 방식이 흐릿할 때 | 사용자가 product owner 로 깊게 생각할 때까지 계속 캐묻기 |

예시는 아래와 같습니다.

```bash
sfs brainstorm "사용자가 결제 실패 이유를 더 빨리 파악하게 하고 싶다"
```

긴 내용을 파일로 정리해 두셨다면 아래처럼 입력하시면 됩니다.

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

Plan 에는 아래 내용이 들어가야 합니다.

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

구현 전에는 아래 질문을 확인합니다.

- 기존 프로젝트는 어떤 구조와 이름 규칙을 쓰고 있나?
- 이번 조각이 증명할 완료 기준은 무엇인가?
- 바뀐 것을 어떻게 확인할 것인가?
- 사용자가 직접 결정해야 하는 경계가 남아 있나?

디자인/frontend 조각이면 `design.md` 또는 `docs/solon/design.md` 를 먼저 봅니다. 없다면 넓은 UI
생성 전에 색, type scale, spacing, radius, icon style 의 작은 seed 를 만들거나 gap 으로
기록합니다. review 에서는 token 밖 임의 색상, 임의 spacing, 섞인 icon weight, generic AI 슬롭
느낌을 확인합니다.

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
| `management-admin` | 재무 기록, 경리, 세무/회계 질문, 현금 evidence |
| `release` | 버전, changelog, package, 배포 검증 |

대부분은 그냥 `sfs review` 라고 입력하면 됩니다. Solon 의 추론이 틀렸을 때만
`sfs review --lens docs` 처럼 직접 지정합니다.
`strategy-pm` 같은 본부 이름은 alias 로 받지만, 문서나 자동화에는 `strategy` 처럼 공개 lens 이름을 남깁니다.

---

## 10. Retro - sprint 마무리

```bash
sfs retro
```

`retro` 는 sprint 를 마무리하는 명령입니다. 한 번 실행하면 다음을 함께 처리합니다.

- `retro.md` 를 회고로 정리
- `report.md` 가 없으면 만들거나 최신 내용으로 정리
- 길어진 임시 기록을 private archive 로 접어 다음 사람이 볼 표면을 정리
- sprint 상태를 close
- local close commit 생성

그래서 일반적인 흐름은 `sfs review -> sfs retro` 두 단계로 끝납니다. 보고서만 먼저
보고 싶거나 sprint 를 닫지 않고 회고 초안만 열고 싶을 때 쓰는 옵션은 §11 에
정리되어 있습니다.

보고서가 사용자 결정을 요구할 때는 `Q1` 같은 번호만 던지지 않습니다. 무엇을 결정해야 하는지,
왜 지금 필요한지, 권장 기본값과 각 선택지의 결과를 짧게 풀어 설명해야 합니다.

---

## 11. 필요할 때만 쓰는 명령

일상적인 흐름은 `status -> start -> brainstorm -> plan -> implement -> review -> retro` 입니다.
아래 명령은 필요할 때만 꺼내면 됩니다.

| 명령 | 언제 쓰나 |
|---|---|
| `sfs report` | sprint 를 닫기 전에 보고서만 먼저 보고 싶을 때 |
| `sfs report --sprint <id>` | 과거 sprint 의 보고서를 다시 만들거나 정리할 때 |
| `sfs retro --draft` | sprint 를 닫지 않고 회고 초안만 열어두고 싶을 때 |
| `sfs bootstrap "<만들고 싶은 것>"` | AI 가 동의받은 초기 프로젝트 구성을 이어가기 위한 handoff trigger |
| `sfs measure --alive -- <command>` | 오래 걸리는 명령이 멈춘 것처럼 보이지 않게 진행 신호를 남길 때 |
| `sfs tidy --sprint <id> --apply` | 이미 끝난 sprint 의 긴 임시 기록을 접어둘 때 |
| `sfs decision "<title>"` | 오래 남겨야 하는 결정을 ADR 로 기록할 때 |
| `sfs adopt --apply` | 오래된 프로젝트를 요약하고 `docs/solon/` 공유 문서만 남길 때 |
| `sfs profile --apply` | `SFS.md` 프로젝트 개요만 자동 보정할 때 |
| `sfs upgrade` | 설치된 프로젝트를 최신 Solon 흐름으로 갱신할 때 |
| `sfs version --check` | 현재 프로젝트와 Solon 버전 상태를 볼 때 |
| `sfs loop ...` | 큰 작업을 queue 로 나누어 장시간 진행할 때 |

---

## 12. 업데이트

Solon 을 새로 깔아도 기존 프로젝트를 지우고 다시 만들 필요는 없습니다.

Mac/Git Bash:

```bash
sfs upgrade
sfs version --check
```

Mac Homebrew 설치본에서 `sfs` 자체가 오래됐거나 `sfs upgrade` 가 본체 업데이트를
못 하면 Homebrew 런타임을 먼저 직접 올려 주세요.
이때는 `brew upgrade sfs` 보다 tap 이름까지 적은 아래 명령을 권장합니다.

```bash
brew upgrade MJ-0701/solon-product/sfs
sfs upgrade
sfs version --check
```

Windows PowerShell/cmd:

```powershell
sfs.cmd update
sfs.cmd version --check
```

Windows 에서 완전한 한 방 명령은 `sfs.cmd update` 입니다. Solon 본체를 최신화하고,
현재 프로젝트에 필요한 정리까지 이어서 처리합니다.

오래된 프로젝트에서는 `sfs` 실행 시 부드러운 update notice 가 뜹니다. 강제 업데이트는
아니고, 업데이트할지 묻는 안내입니다. 끄려면 `SFS_VERSION_NOTICE=0` 을 사용합니다.

SFS 는 AI 가 너무 많은 문서를 한 번에 읽어 낭비가 생길 것 같을 때 짧은 안내를 띄웁니다.
대부분의 사용자는 이 안내를 그대로 따라가시면 됩니다. 더 자세한 내용은
[현재 제품 흐름과 최근 변화](./docs/ko/current-product-shape.md) 에서 볼 수 있습니다.

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
[Solon 10x 가치](./docs/ko/10x-value.md) 에서 확인합니다. 자세한 운영 규칙은 Solon 본체에
들어 있고, AI agent 는 필요할 때 같은 내용을 찾아 읽습니다.

### `/sfs` 가 인식되지 않는다.

Claude Code 에서는 `/sfs`, Gemini CLI 에서는 `sfs`, Codex CLI 에서는 `$sfs` 를 씁니다.
Windows PowerShell/cmd 에서는 `sfs.cmd` 를 씁니다.

Windows 의 Claude/Gemini/Codex 에서 Git Bash 시작 전
`couldn't create signal pipe, Win32 error 5` 가 나오면 실행 sandbox 가 Bash 생성을 막은
경우입니다. 0.6.30 부터 `sfs.cmd status`, `sfs.cmd version`,
`sfs.cmd context cat kernel`, `sfs.cmd context cat index` 는 Git Bash 없이 바로
읽습니다. AI 에게 Windows 내부 확인은 native read-only 인 `sfs.cmd status` 와
`sfs.cmd context cat ...` 로 하라고 말해 주세요.
0.6.35 부터 `start` 같은 상태 변경 명령도 `sfs.cmd` 가 raw Git Bash 직행 대신
PowerShell bridge 를 거쳐 Bash runtime 으로 내려갑니다. 그래도 상태 변경 명령이 빈 출력으로
"성공" 처리되면 성공이 아닙니다. PowerShell 에서 `sfs.cmd start "<목표>"` 를 직접 실행하고
`sfs.cmd status` 로 확인하세요.
이 장애의 증상, 실제 원인, 발견된 추가 문제점은
[Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.41.md) 에 정리되어
있습니다.
0.6.37 부터 `sfs.cmd upgrade` 도 실행 중인 batch 파일 안에서 직접 `scoop update sfs` 를 실행하지
않고, `sfs.ps1` self-upgrade 경로로 넘깁니다. `TIVE_READONLY_DONE` 또는 `LF_UPGRADE_DONE` 같은
조각 문자열이 명령처럼 보이면 0.6.36 self-update 경로에서 발견된 batch replacement 문제입니다.
0.6.41 기준으로는 `sfs.ps1` 이 Windows PowerShell `-File` 호출 인자를 `$args` /
`$MyInvocation.UnboundArguments` 로 직접 읽고, `sfs.cmd` 가 PowerShell 호출 뒤 같은 parsed line 에서
종료합니다. 그래서 `sfs.cmd context cat ...` 과 `sfs.cmd start ...` 가 usage 만 출력하던
Windows wrapper 인자 손실을 막습니다.

0.6.41 기준 brew/scoop 가 세 CLI 모두에 자동 등록합니다. 그래도
`/sfs` 가 안 나오면 아래 명령으로 상태를 확인해 주세요.

```bash
sfs doctor   # ✅/⚠️ 줄별 상태 확인. 옆에 출력되는 한 줄 recovery 그대로 실행
```

대부분은 `sfs doctor` 가 보여주는 한 줄 안내로 해결됩니다. 그래도 꼬였다고 느껴지면
프로젝트 폴더에서 업데이트를 한 번 다시 실행해 주세요.

```bash
sfs upgrade
```

Mac 에서 `sfs` 명령 자체가 낡았거나 업데이트가 막히면 Homebrew 쪽을 먼저 올려 주세요.
`brew upgrade sfs` 가 기대대로 동작하지 않을 때는 tap 이름까지 적은 아래 명령을 사용하시면 됩니다.

```bash
brew upgrade MJ-0701/solon-product/sfs
sfs upgrade
```

Windows PowerShell/cmd 라면 아래 명령을 사용해 주세요.

```powershell
sfs.cmd update
```

### 완료된 sprint 는 무엇을 보면 되나?

팀과 공유할 요약은 `docs/solon/` 를 봅니다. 진행 중인 private sprint 는
`.sfs-local/sprints/<sprint-id>/report.md` 를 먼저 보고, 더 자세한 배경은 필요한 경우에만
private archive 또는 retro 를 봅니다.

### Claude, Codex, Gemini 를 팀처럼 써도 되나?

네. 다만 SFS 에서는 여러 agent 를 항상 동시에 켜는 방식보다, 필요한 순간에만 얇게 나누는 방식을
권장합니다.

- 낯선 코드베이스나 도메인은 read-only researcher 가 먼저 정리합니다.
- 구현은 plan 과 files_scope 가 고정된 뒤 작은 worker slice 로 나눕니다.
- review 는 생성자와 다른 context, 가능하면 다른 executor 로 맡깁니다.
- 공유할 내용은 긴 대화록이 아니라 sprint workbench 와 `docs/solon/domain-map.md` 에 짧게 남깁니다.

모델도 같은 원칙으로 나눕니다. 이 라우팅은 기본값이라 사용자가 따로 설정하지 않아도 적용됩니다.
Helper-grade 단순 I/O 는 가벼운 intake 모델이 맡고, 질문 생성/facilitation 은 standard 모델이
맡습니다. Codex 기준으로는 단순 intake 가 `gpt-5.4-mini`, 질문 생성이 `gpt-5.4` 입니다.
C-Level 과 review 는 강한 판단 모델이 맡고, 구현 worker 는 고정된 slice 를 실행합니다.
Codex 쪽 기본 구현 worker 는 `gpt-5.3-codex` 입니다.
하위모델 출력이 질문/선택지를 설계하거나 답변을 해석하거나 product identity, architecture,
gate, AC, files_scope 를 흔들면 최상위 advisor 검토가 필수입니다. advisor 는 Claude Opus 4.7,
Codex `gpt-5.5` xhigh, Gemini `gemini-3.1-pro-preview` 입니다. Gemini helper-grade fallback 은
`gemini-3-flash-preview` 이며 2.5 fallback 은 쓰지 않습니다. Helper-grade 단순 relay/누락 인자
질문은 advisor 검토를 생략할 수 있습니다.
advisor 호출은 self-CPO PASS 가 아닙니다. external/cross review 전에 작성자는 self-CPO
mini-check 를 남깁니다: 요구사항 → AC → 구현 slice → ADR/decision id 추적, 각 AC 의
file/artifact/evidence 매핑, SEED/placeholder/mock/fallback 이 실제 산출물 전에는
non-acceptance 로 남는지 확인합니다.
`gpt-5.3-codex-spark` 는 일반 구현 worker 가 아니라 grep, 포맷, 동기화처럼 범위가 잠긴
기계적 helper subtask 용도입니다. architecture, public contract, security, privacy,
data-loss, release gate, 반복 실패가 보이면 worker 도 high reasoning 으로 승격합니다.

`implement` 에서는 기본적으로 Single Agent 가 작업합니다. Claude, Codex, Gemini 를 동시에 쓰고
싶다면 작업이 먼저 커밋 단위로 나뉘어야 합니다. 각 lane 이 "이 커밋은 무엇을 바꾸는가"를 한
문장으로 설명하지 못하면 나누지 않습니다. 조건이 맞을 때만
`sfs implement --agent-mode parallel --agents codex,claude[,gemini] "<work slice>"` 를 씁니다.
병렬 구현이 끝난 뒤에는 agent 간 cross review 를 남기고, 그 다음 `sfs review --gate 6` 를
통과해야 합니다. Single Agent 모드도 구현 직후 review 는 필수입니다.

커밋 메시지는 사용자의 native 언어 또는 workspace 언어가 기본입니다. 한국어 사용자에게는
`수정: 결제 실패 안내 문구 개선` 처럼 한국어로 제안하고 작성합니다. repo 가 영어 커밋을
명시적으로 요구하거나 사용자의 native 언어가 영어일 때만 영어를 기본값으로 둡니다.

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
