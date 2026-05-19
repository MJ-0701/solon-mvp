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

> brew/scoop 한 줄이면 Claude Code, Gemini CLI, Codex CLI 가 모두
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
| `.sfs-local/` | 현재 sprint 를 진행하기 위한 private workbench 와 설정 |
| `.claude/`, `.gemini/`, `.agents/` | 꼭 필요한 프로젝트에서만 추가로 설치하는 AI 도구별 바로가기 |

처음에는 `SFS.md` 의 프로젝트 이름, 도메인, 스택, 배포 환경만 실제 프로젝트에 맞게 바꾸시면 됩니다.
자동으로 좁게 채우고 싶으면 agent 안에서는 `/sfs profile`, 터미널에서는 `sfs profile --apply` 를 씁니다.
기본 설치는 프로젝트 안을 가볍게 유지합니다. Solon 본체는 패키지 쪽에 두고, 프로젝트에는
사용자가 읽을 문서와 작업 기록을 중심으로 남깁니다. AI 도구별 native 파일이 꼭 필요한 팀만
`sfs agent install all` 로 추가 설치하면 됩니다.

`.sfs-local/` 은 계속 쌓아 두는 history 폴더가 아닙니다. 현재 sprint 를 이어가기 위해 필요한
파일만 보이고, 닫힌 sprint 이력은 공유 문서와 git history 로 인수인계합니다. 그래서
`events.jsonl` 은 현재 sprint active ledger 일 때만 남고, orphan/stale 이벤트는 upgrade/tidy 때
제거 또는 archive 됩니다. 반복 cleanup evidence 는 날짜별로
`.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/surface-cleanup.tar.gz` 하나에 묶여
바깥 파일 트리를 어지럽히지 않습니다.

현재 Solon 은 본부, 지식팩, review lens 를 같은 층위로 섞지 않습니다.
`.sfs-local/divisions.yaml` 은 기존 프로젝트 호환을 위한 6개 core activation slot
(`dev`, `strategy-pm`, `qa`, `design`, `infra`, `taxonomy`) 입니다. 실제 guidance 는
backend, 전략/PM, QA, 디자인/frontend, infra/DevOps, management-admin, taxonomy 같은
지식팩/review lens 로 읽습니다. backend 는 dev 의 기술 specialization, management-admin 은
재무/경리/세무/회계 관점, taxonomy 는 모든 본부에 걸치는 언어/분류 lens 입니다.
사용자가 이 이름을 정확히 몰라도 괜찮습니다. Solon 을 쓰는 AI 가 작업 성격을 보고 필요한
관점만 읽고, 사용자에게는 평범한 질문과 판단 기준으로 풀어 설명하는 쪽이 기본입니다.

또 source-driven 구현, stop-the-line 디버깅, deprecation/migration, shipping
check 같은 agent-skills 류 practice 는 새 명령어가 아니라 기존 `implement`, `review`,
`adopt`, `tidy`, `release` 안의 정책과 렌즈로 흡수됩니다.

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

출력을 짧게 보고 싶을 때는 Token Diet compact output 을 켤 수 있습니다.

```bash
SFS_OUTPUT_STYLE=compact sfs status
sfs status --compact
sfs start "첫 작업 목표" --output-style compact
SFS_OUTPUT_STYLE=compact sfs report
```

compact output 은 path, next action, alternative mode, archive path,
verification 같은 추적 필드를 없애지 않습니다. destructive/security/privacy/data-loss warning,
사용자 decision, review finding, raw-source traceability 는 짧게 줄여 품질이 낮아질 수 있으면
full clarity 로 남깁니다. Caveman/persona 말투는 기본값이 아닙니다.

0.6.85부터 release verifier 도 같은 원칙을 따릅니다. 내부 install/upgrade smoke 로그는
성공하면 조용히 접고, 실패하면 캡처한 stdout/stderr 를 `[verify-product-release]` prefix 로
다시 보여줍니다. 배포 확인 로그는 짧아지지만 실패 원문 추적은 사라지지 않습니다.

Session Continuation Guard 는 compact output 과 다른 문제를 다룹니다. `sfs upgrade` 는 runtime 과
project-local context 를 최신화하지만, 이미 열린 Claude/Codex/Gemini 대화의 누적 토큰을 지우지는
못합니다. 새 WU/sprint 첫 구현·review 전에 host token meter 가 30% 이상이거나, 새 gate/loop/
cross-review 시작 전에 50% 이상이면 같은 대화를 더 끌지 말고 `report.md`, `review.md`, capture id,
commit/branch, 다음 SFS 명령만 남긴 뒤 fresh session 으로 이어가야 합니다. `.sfs-local/` 크기는
tidy 신호일 뿐 token meter 대체값은 아닙니다.

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

GitHub 의 `@codex` PR/code review 는 외부 코드리뷰 evidence 일 뿐입니다. PR approval,
GitHub check PASS, `@codex` comment 가 있어도 `sfs review`, self-CPO, SFS cross review,
Gate 3/Gate 6 PASS 를 대체하지 않습니다.

외부 리뷰/check PASS 는 continuation trigger 이며, 멈추라는 신호가 아니라 다음 SFS review 단계로
이어가라는 신호입니다.
Codex, Claude, Gemini, 기타 LLM Agent 모두 self-CPO 를 먼저 실행하고, self-CPO PASS 뒤에
정해진 cross-review 순서로 넘어갑니다. 닫힌 sprint 라면 `.sfs-local/current-sprint` 를 손으로
복구하지 말고 `sfs review --sprint <id> --gate <n>` 를 사용합니다.

Solon 은 sprint evidence 와 변경 산출물을 보고 review lens 를 자동으로 고릅니다.

| Lens | 보는 것 |
|---|---|
| `code` | 동작, 테스트, 회귀, 유지보수성 |
| `docs` | 읽는 흐름, 정확성, 오래된 설명, 링크 |
| `source-docs` | 공식 문서/소스/버전 근거가 있는지 |
| `simplify` | 동작을 보존하면서 복잡도와 dead code 를 줄였는지 |
| `security` | auth, secret, PII, 입력 신뢰 경계 |
| `performance` | 측정 근거, baseline, target, 회귀 위험 |
| `api-contract` | public API, schema, error semantics, migration |
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

review 결과가 partial/fail 이어도 모든 경우를 사용자에게 다시 묻지 않습니다. grep 범위 누락,
실측 명령 갱신, AC와 파일/산출물 매핑 누락, evidence 경로 오타, 의미가 바뀌지 않는 문서 일관성
같은 작은 결정론적 finding 은 agent 가 같은 cycle 안에서 patch 하고, 가장 작은 검증을 실행한 뒤,
같은 gate review 를 다시 호출해야 합니다. 사용자 판단이 필요한 경우는 범위, architecture,
public contract, 보안/개인정보/data-loss, 비용/지연/model policy, destructive action, AC 의미 변경처럼
제품 판단이 들어가는 경우입니다.

현재 `sfs review` 는 clean tree 에서도 직전 commit 의 reviewable 산출물을 evidence 로 싣습니다.
그래서 ADR 과 `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` 를 commit 한 뒤 Gate review 를
돌려도, review agent 가 "본문을 못 봤다"는 이유로 partial 을 내지 않도록 prompt 가 구성됩니다.

---

## 10. Retro - sprint 마무리

```bash
sfs retro
```

`retro` 는 sprint 를 마무리하는 명령입니다. 한 번 실행하면 다음을 함께 처리합니다.

- `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/retro.md` 를 회고로 정리
- `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` 가 없으면 만들거나 최신 내용으로 정리
- 길어진 임시 기록을 private archive 로 접어 다음 사람이 볼 표면을 정리
- sprint 상태를 close
- local close commit 생성

일반 사용자는 도메인 플래그를 직접 줄 필요가 없습니다. 예를 들어
`sfs start "주문상품 수량 수정"` 처럼 자연어 목표만 주면 SFS 가 높은 확신의 도메인 신호를 추론해
인계 문서를 `docs/solon/order/order-items/quantity-update/<yyyyMMdd>/` 아래에 남깁니다.
`--domain`, `--subdomain`, `--feature` 는 추론이 틀렸을 때의 override 용도입니다. 도메인이 아직
불명확한 탐색 작업만 `--workspace <english-name>` fallback 을 씁니다.
`report.md` 와 `retro.md` 본문은 커밋 메시지 규칙과 같이
사용자의 native/workspace 언어로 작성해도 됩니다.

그래서 일반적인 흐름은 `sfs review -> sfs retro` 두 단계로 끝납니다. 보고서만 먼저
보고 싶거나 sprint 를 닫지 않고 회고 초안만 열고 싶을 때 쓰는 옵션은 §11 에
정리되어 있습니다.

보고서가 사용자 결정을 요구할 때는 `Q1` 같은 번호만 던지지 않습니다. 무엇을 결정해야 하는지,
왜 지금 필요한지, 권장 기본값과 각 선택지의 결과를 짧게 풀어 설명해야 합니다. 확정도
`A/A/A/C/C 확정` 같은 내부 option bundle 이 아니라 `권장안 그대로 확정` 같은 자연어를 씁니다.

---

## 11. 필요할 때만 쓰는 명령

일상적인 흐름은 `status -> start -> brainstorm -> plan -> implement -> review -> retro` 입니다.
아래 명령은 필요할 때만 꺼내면 됩니다.

| 명령 | 언제 쓰나 |
|---|---|
| `sfs report` | sprint 를 닫기 전에 보고서만 먼저 보고 싶을 때 |
| `sfs report --sprint <id>` | 과거 sprint 의 보고서를 다시 만들거나 정리할 때 |
| `sfs status --compact` | routine status 를 한 줄로 보되 sprint/wu/gate/verdict/ahead/last_event 를 유지할 때 |
| `sfs start "..." --output-style compact` | 생성 경로와 brainstorm 대안을 한 줄로 보고 싶을 때 |
| `sfs capture --kind review-order "..."` | 자연어 대화에서 바뀐 리뷰 순서/예외/결정을 다음 명령 전에 남길 때 |
| `sfs note "..."` | 짧은 flow note 를 현재 sprint `log.md` 에 남길 때 |
| `sfs report --output-style compact` | report/archive 경로를 한 줄로 보고 싶을 때 |
| `sfs review --sprint <id> --gate <n>` | 닫힌 sprint 의 cold archive 를 복원해 review 를 재개할 때 |
| `sfs retro --draft` | sprint 를 닫지 않고 회고 초안만 열어두고 싶을 때 |
| `sfs bootstrap "<만들고 싶은 것>"` | AI 가 동의받은 초기 프로젝트 구성을 이어가기 위한 handoff trigger |
| `sfs measure --alive -- <command>` | 오래 걸리는 명령이 멈춘 것처럼 보이지 않게 진행 신호를 남길 때 |
| `sfs tidy --sprint <id> --apply` | 이미 끝난 sprint 의 긴 임시 기록을 접어둘 때 |
| `sfs tidy --all --apply` | adopt/upgrade 뒤 남은 cache, orphan log, 분산 archive bucket 을 표면에서 치울 때 |
| `sfs decision "<title>"` | 오래 남겨야 하는 결정을 ADR 로 기록할 때 |
| `sfs commit plan` | 남은 변경을 의미별 commit 그룹으로 확인할 때 |
| `sfs commit apply --group <name>` | 선택 그룹을 commit 하고 현재 branch 를 push 할 때. 로컬 sandbox 에서만 `--no-push` |
| `sfs adopt --apply` | 오래된 프로젝트를 요약하고 `docs/solon/<english-workspace>/<yyyyMMdd>/handoff.md` 공유 문서만 남길 때 |
| `sfs profile --apply` | `SFS.md` 프로젝트 개요만 자동 보정할 때 |
| `sfs upgrade` | 설치된 프로젝트를 최신 Solon 흐름으로 갱신할 때 |
| `sfs version --check` | 현재 프로젝트와 Solon 버전 상태를 볼 때 |
| `sfs loop ...` | 큰 작업을 queue 로 나누어 장시간 진행할 때 |

`sfs capture` 는 flow checkpoint 이지 prompt/transcript 저장소가 아닙니다. 긴 prompt,
전체 대화, bridge/review scratch, command log 는 archive 나 evidence path 로만 참조하고,
core product docs 와 routed context 에는 결론과 현재 계약만 남깁니다.

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
[Windows SFS 래퍼 장애 요약 보고서](./docs/ko/windows-wrapper-incident-0.6.56.md) 에 정리되어
있습니다.
0.6.37 부터 `sfs.cmd upgrade` 도 실행 중인 batch 파일 안에서 직접 `scoop update sfs` 를 실행하지
않고, `sfs.ps1` self-upgrade 경로로 넘깁니다. `TIVE_READONLY_DONE` 또는 `LF_UPGRADE_DONE` 같은
조각 문자열이 명령처럼 보이면 0.6.36 self-update 경로에서 발견된 batch replacement 문제입니다.
현재 Windows PowerShell/cmd 의 성공 기준은 `sfs.cmd` 경로로 고정합니다.
Scoop manifest 는 generated shim 을 packaged `bin\sfs.ps1` 로 직접 연결하지만, generated
`sfs.cmd` / `sfs.ps1` shim 이 인자를 버리는 경로가 확인되어 post-install hook 이 shims
디렉터리의 `sfs.cmd`, `sfs.ps1`, extensionless `sfs` 를 deterministic wrapper 로 덮어씁니다.
bare `sfs` PowerShell shim 은 Windows 사용자 계약으로 보지 않습니다. `sfs.cmd` 는 직접 실행/호환용 thin PowerShell trampoline 으로 남고,
`SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 번호 환경 변수 bridge 로 `sfs.ps1` 에 인자를 넘깁니다.
그 경로도 비면 `sfs.ps1` 이 `SFS_NATIVE_RAW_ARGS`, `SFS_NATIVE_CMDLINE`, parent `cmd.exe` command line,
`CMDCMDLINE` 순서로 fallback 을 읽습니다.
`sfs.ps1` 이 numbered env bridge, raw arg tail, saved cmdline, parent command line,
`CMDCMDLINE`, `$MyInvocation.UnboundArguments` 순서로
인자를 정규화하고, `version`, `status`, `guide`, `context`, Scoop self-upgrade, Bash fallback 을
소유합니다. 0.6.50 의 hardened Scoop `sfs.cmd` shim 은 numbered env bridge 를 먼저 기록한 뒤
saved raw tail 도 automatic `$args` 로 함께 넘깁니다. 이는 generated Scoop shim 아래에서 실패했던
단일 `-File ... %*` bridge 와 다릅니다. 그래서 batch label forwarding, 단일 `-File ... %*`,
`-Command @args`, empty `%1..%n`, generated bare `sfs` shim, generated `sfs.cmd` shim, generated shim -> packaged `.cmd` 때문에
`sfs.cmd context cat ...` 과 `sfs.cmd start ...` 가 usage 만 출력하던 Windows wrapper 인자 손실을
막습니다.
이미 0.6.49 이하의 깨진 wrapper 에 갇혀 `sfs.cmd update` 자체가 usage 만 출력한다면, 최초 1회는
PowerShell 에서 `scoop update` 후 `scoop update sfs` 를 직접 실행한 뒤 프로젝트 폴더에서
`sfs.cmd upgrade --no-self-upgrade` 를 실행하세요.

현재 brew/scoop 가 세 CLI 모두에 자동 등록합니다. 그래도
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

팀과 공유할 요약은 `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/report.md` 와
`retro.md` 를 봅니다.
진행 중인 private workbench 는 `.sfs-local/sprints/<sprint-id>/` 에 있고, 더 자세한 배경은
필요한 경우에만 private archive 를 봅니다.

### Claude, Codex, Gemini 를 팀처럼 써도 되나?

네. 다만 SFS 에서는 여러 agent 를 항상 동시에 켜는 방식보다, 필요한 순간에만 얇게 나누는 방식을
권장합니다.

- 낯선 코드베이스나 도메인은 read-only researcher 가 먼저 정리합니다.
- 구현은 plan 과 files_scope 가 고정된 뒤 작은 worker slice 로 나눕니다.
- review 는 생성자와 다른 context, 가능하면 다른 executor 로 맡깁니다.
- 공유할 내용은 긴 대화록이 아니라 sprint workbench 와 `docs/solon/domain-map.md` 에 짧게 남깁니다.

모델도 같은 원칙으로 나눕니다. 이 라우팅은 기본값이라 사용자가 따로 설정하지 않아도 적용됩니다.
Helper-grade 단순 I/O 는 가벼운 intake 모델이 맡고, 질문 생성/facilitation 은 standard 모델이
맡습니다. Codex 기준으로는 단순 intake 와 non-coding helper 가 `gpt-5.4-mini`, 질문 생성과
일반 구현 worker 가 `gpt-5.4` 입니다. C-Level 과 review 는 강한 판단 모델이 맡고, 구현 worker 는
고정된 slice 를 실행합니다.
하위모델 출력이 질문/선택지를 설계하거나 답변을 해석하거나 product identity, architecture,
gate, AC, files_scope 를 흔들면 최상위 advisor 검토가 필수입니다. advisor 는 Claude Opus 4.7,
Codex `gpt-5.5` xhigh, Gemini `gemini-3-pro-auto` 입니다. Gemini 는 모든 role 을
`gemini-3-pro-auto` 로 두며 Flash/2.5 fallback 은 쓰지 않습니다. Helper-grade 단순 relay/누락 인자
질문은 advisor 검토를 생략할 수 있습니다.
advisor 호출은 self-CPO PASS 가 아닙니다. external/cross review 전에 작성자는 self-CPO
mini-check 를 남깁니다: 요구사항 → AC → 구현 slice → ADR/decision id 추적, 각 AC 의
file/artifact/evidence 매핑, SEED/placeholder/mock/fallback 이 실제 산출물 전에는
non-acceptance 로 남는지 확인합니다.
Codex 에서 `gpt-5.3-codex` 는 일반 worker 기본값이 아니라 bounded repo-aware coding helper 입니다.
이미 범위가 잠겼지만 약간의 코드 판단이 남은 좁은 보조 작업에 씁니다.
`gpt-5.3-codex-spark` 는 이미 결정된 사항에 대해 판단이 필요 없는 기계적 구현 보조 작업에만 씁니다.
scope, files_scope, AC, 정확한 수정 의도가 모두 잠긴 file move, import/path rewrite, generated index
sync, deterministic test expectation update 같은 작업이 여기에 해당합니다. architecture, public
contract, security, privacy, data-loss, release gate, 반복 실패가 보이면 worker 를 high reasoning 으로
승격합니다. Claude 쪽 코딩 가능한 worker/helper 는 Sonnet 4.6이고, Haiku 는 코딩하지 않는
relay, 요약, 작은 read-only helper 전용입니다. 실질 research 는 가능하면 Gemini 3 Pro auto
researcher 로 보냅니다.

`implement` 에서는 기본적으로 Single Agent 가 작업합니다. Claude, Codex, Gemini 를 동시에 쓰고
싶다면 작업이 먼저 커밋 단위로 나뉘어야 합니다. 각 lane 이 "이 커밋은 무엇을 바꾸는가"를 한
문장으로 설명하지 못하면 나누지 않습니다. 조건이 맞을 때만
`sfs implement --agent-mode parallel --agents codex,claude[,gemini] "<work slice>"` 를 씁니다.
병렬 구현이 끝난 뒤에는 agent 간 cross review 를 남기고, 그 다음 `sfs review --gate 6` 를
통과해야 합니다. Single Agent 모드도 구현 직후 review 는 필수입니다.

Gemini, Codex, Claude 같은 named executor 로 review 를 처음 실행할 때는 SFS 가 full CPO prompt 를
만들기 전에 인증 상태를 먼저 봅니다. 인증이 없으면 review 기록을 남기지 않고 멈추므로, 실제
터미널에서 `sfs auth login --executor gemini` 처럼 한 번 로그인한 뒤
`sfs auth probe --executor gemini` 로 bridge 를 확인하고 같은 `sfs review ... --executor gemini`
명령을 다시 실행하면 됩니다. 웹/앱에 직접 넘길 때는 `--prompt-only` 를 사용합니다.

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
