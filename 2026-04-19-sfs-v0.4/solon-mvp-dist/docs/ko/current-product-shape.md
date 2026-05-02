# 현재 제품 흐름과 최근 변화

**Language**: 한국어 / [English](../en/current-product-shape.md)

이 문서는 최근 Solon Product 패치들의 결과를 한 번에 이해하기 위한 문서입니다. 핵심은
명령어를 더 많이 외우게 만드는 것이 아니라, 사용자가 AI 시대에도 product owner 로서
생각의 근육을 잃지 않게 하는 흐름을 만드는 것입니다.

## 한 줄 요약

Solon 은 `start → brainstorm → plan → implement → review → retro` 를 통해
모호한 의도를 검증 가능한 작업 계약으로 바꾸고, AI 가 빠르게 실행하더라도 사람의 판단,
용어, 설계, 검증 흐름이 사라지지 않게 합니다.

```text
fuzzy intent
→ shared understanding
→ plan contract
→ small implementation slice
→ artifact acceptance review
→ retro close with report
```

## Start 이후의 인계

`sfs start "<goal>"` 는 sprint workspace 를 만들고 끝나는 명령입니다. 다만 새 요구 탐색에는
대부분 brainstorm 이 필요하므로, start 성공 출력은 사용자가 가이드를 읽지 않았어도 다음 선택지를
볼 수 있게 안내합니다.

```text
next: sfs brainstorm --simple "..."  # 빠른 정리
      sfs brainstorm "..."           # 기본값, normal thinking scaffold
      sfs brainstorm --hard "..."    # product owner hard training
```

사용자가 입력하는 명령어는 그대로 `sfs brainstorm` 입니다. Solon 이 지금 작업에 맞는
depth 옵션을 함께 보여줄 뿐입니다.

## Brainstorm 3단계

| Mode | 별칭 | 역할 |
|---|---|---|
| `--simple` | `--easy`, `--quick` | 이미 방향이 뚜렷한 작업을 빠르게 정리하고 plan seed 로 넘김 |
| 기본 `normal` | 없음 | 요구사항을 정리하면서도 핵심 모순, 우선순위, 성공 기준, 검증 방식을 몇 가지 질문함 |
| `--hard` | 없음 | 사용자가 product owner 로 깊게 생각하도록 의도, 포기할 것, 경계, 용어를 집요하게 캐물음 |

세 모드는 단순 요약 → 사고 scaffold → 강도 있는 훈련 순으로 압력이 올라갑니다.

- `simple`: 이미 답이 있을 때 빠른 정리
- `normal`: 대부분의 작업에 맞는 기본 사고 scaffold
- `hard`: 제품 판단과 설계가 흐릿할 때 쓰는 hard training

## Hard Mode 의 목적

`brainstorm --hard` 는 AI 가 "좋아, 바로 할게" 하고 달려가는 흐름을 일부러 늦춥니다.
사용자에게 자잘하지만 중요한 질문을 계속 던져서 아래 항목을 드러냅니다.

- 진짜 해결하려는 문제
- 서로 충돌하는 욕구
- 우선순위와 포기할 것
- 성공/실패를 판정할 방식
- 작업의 경계와 하지 않을 것
- 프로젝트 안에서 써야 하는 용어

이 모드는 AI 도움을 줄이는 기능이 아니라, AI 가 일을 시작하기 전에 사용자의 소유권과 판단력을
더 강하게 세우는 기능입니다.

## Plan 은 transcript 가 아니라 계약

`sfs plan` 은 brainstorm 대화를 예쁘게 옮기는 단계가 아닙니다. plan 은 다음 항목을 포함해야 합니다.

- measurable acceptance criteria
- 이번 sprint 에 포함할 scope 와 제외할 scope
- feedback loop 또는 smoke/test/review 방식
- evaluator 가 어떤 기준으로 통과/보류/실패를 판단할지
- 다음 구현 slice 가 무엇인지

중요한 owner decision 이 비어 있으면 plan 을 추측으로 채우지 않습니다. 질문을 유지하고,
사용자의 판단을 기다립니다.

## Implement 는 코드만 뜻하지 않는다

`sfs implement` 의 산출물은 코드일 수도 있지만, Solon 에서는 아래도 모두 implementation artifact 입니다.

- documentation update
- strategy memo
- design handoff
- taxonomy 또는 domain language 정리
- QA evidence
- ops/runbook
- release packaging

AI coding 시대에는 "구현"이라는 말이 코드 파일만 가리키면 작업 흐름이 좁아집니다. Solon 은
사용자가 만든 실제 artifact 를 기준으로 다음 review lens 를 정합니다.

## Review 는 artifact acceptance review

`sfs review` 는 코드리뷰 하나가 아닙니다. 같은 명령어를 유지하되 Solon 이 sprint evidence 와
변경 artifact 를 보고 lens 를 자동 추론합니다.

| Lens | 주로 보는 것 |
|---|---|
| `code` | correctness, tests, regressions, maintainability |
| `docs` | reader flow, accuracy, stale claims, missing links |
| `strategy` | decision quality, tradeoffs, feasibility, next action |
| `design` | user flow, consistency, visual/interaction evidence |
| `taxonomy` | terms, categories, naming boundaries |
| `qa` | coverage, smoke evidence, reproduction, residual risk |
| `ops` | runbook, deployment, rollback, observability |
| `release` | version, changelog, package channel, verification |

사용자는 계속 `sfs review` 라고만 말하면 됩니다. `--lens` 는 Solon 의 추론이 틀렸을 때만 쓰는
override 입니다.

## Retro 는 기본적으로 sprint close

`sfs retro` 한 명령이 sprint 를 close 까지 마무리합니다.

```text
sfs retro
```

이 명령은 `report.md` 와 `retro.md` 를 정리하고, workbench 원문과 임시 review scratch 를 하나의
cold archive bundle 로 압축한 뒤, sprint close 상태와 local close commit 까지 연결합니다.
초안만 열고 sprint 는 닫지 않고 싶을 때는 `sfs retro --draft` 를 씁니다.
예전 설치본에 남아 있던 loose sprint archive 나 별도 review-run archive 는 `sfs upgrade` 때
압축 migration 으로 정리됩니다. runtime upgrade / agent install / profile rollback 백업도
loose 파일 대신 `*.tar.gz` + `manifest.txt` bundle 로 남습니다.
thin layout 에서는 project-local `.claude/`, `.gemini/`, `.agents/` command/skill adapter 도
기본 표면에서 빠집니다. root adapter 문서가 global `sfs` runtime 을 안내하고, native
slash/skill 파일이 필요한 프로젝트만 `sfs agent install all` 로 opt-in 설치합니다.

## 문서 구조

README 는 전체 설명을 다 담는 파일이 아니라 큰 흐름과 목차입니다. 자세한 철학과 판단 기준은
별도 문서로 분리합니다.

```text
README.md
GUIDE.md
docs/ko/index.md          docs/en/index.md
docs/ko/current-product-shape.md   docs/en/current-product-shape.md
docs/ko/10x-value.md       docs/en/10x-value.md
docs/en/guide.md
```

각 문서 상단의 `Language` 링크로 한국어/영어 짝을 오갈 수 있습니다.

## Token / Harness Hygiene

SFS 는 토큰과 어텐션 낭비를 줄이는 운영 규칙을 routed context 안에 자동으로 깔아둡니다.
사용자가 별도 plugin 을 설치하지 않아도 같은 효과를 얻도록 다음 원칙을 흐름 안에 흡수합니다.

- 토큰 사용량 점검: 토큰이 빨리 닳는 느낌이 있으면 추측보다 usage report 를 먼저 확인한다.
- 어댑터 문서 슬림: `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` 같은 어댑터는 얇게 유지하고,
  긴 규칙은 routed context 또는 docs 로 분리한다.
- 큰 코드베이스 검색 우선순위: 전체 파일을 읽기 전에 symbol / semantic search 를 먼저 쓴다.
- 반복 실수의 자동화: 같은 실수를 말로 다시 설명하지 않고 guardrail / check / hook 으로 바꾼다.

이 원칙은 특정 agent 에 묶이지 않습니다. Claude, Codex, Gemini 등 각 agent 의 usage report,
LSP/index, hook 수단으로 동일하게 적용할 수 있습니다.

## 언제 어떤 모드를 고르나

| 상황 | 추천 |
|---|---|
| 이미 구현할 범위가 분명함 | `sfs brainstorm --simple` 또는 바로 `sfs plan` |
| 새 기능을 처음 정의함 | `sfs brainstorm` |
| 사용자의 의도와 우선순위가 흔들림 | `sfs brainstorm --hard` |
| 설계/용어/검증 기준이 불명확함 | `sfs brainstorm --hard` |
| 이전 sprint 의 plan/ADR 을 이어받음 | inherit 기록 후 바로 `sfs implement` |

Solon 의 좋은 사용감은 빠르게 달리는 것이 아니라, 피드백 없이 너무 멀리 달리지 않는 것입니다.
