# Solon Product 문서

**Language**: 한국어 / [English](../en/index.md)

README 는 Solon Product 의 큰 흐름과 목차입니다. 이 디렉토리는 실제 판단 기준,
운영 감각, 철학, 예시를 조금 더 깊게 설명합니다.

## 먼저 읽을 문서

| 문서 | 언제 읽나 |
|---|---|
| [현재 제품 흐름과 최근 변화](./current-product-shape.md) | 최신 Solon 이 어떤 사용 감각으로 바뀌었는지 알고 싶을 때 |
| [Windows SFS 래퍼 장애 요약 보고서](./windows-wrapper-incident-0.6.56.md) | Windows 에서 `sfs.cmd` 가 usage 만 출력하거나 빈 출력/한글 깨짐/upgrade 후 batch 오류를 보였던 원인과 조치가 궁금할 때 |
| [Solon 10x 가치](./10x-value.md) | 왜 Solon 이 단순 자동화가 아니라 사고/설계 근육을 키우려 하는지 알고 싶을 때 |
| [30분 온보딩 가이드](../../GUIDE.md) | 설치 직후 첫 sprint 를 직접 돌려보고 싶을 때 |
| [초보자 가이드](../../BEGINNER-GUIDE.md) | Git, 터미널, CLI 가 낯설 때 |
| [릴리스 노트](../../RELEASE-NOTES.md) | 새 버전에서 사용자가 체감할 변화를 확인할 때 |
| [상세 변경 기록](../../CHANGELOG.md) | 구현 단위의 자세한 변경사항을 확인할 때 |

## 현재 핵심 흐름

```text
sfs status
→ sfs start "<goal>"
→ sfs brainstorm [--simple|--hard] "<raw context>"
→ sfs plan
→ sfs implement "<first slice>"
→ sfs review
→ sfs retro
```

이 흐름의 목적은 AI 에게 모든 생각을 맡기는 것이 아닙니다. Solon 은 AI 가 실행을 돕는 동안
사용자가 product owner 로서 의도, 우선순위, 포기할 것, 검증 방식, 용어를 계속 더 선명하게
잡도록 돕습니다.

0.6.79 기준 본부, 지식팩, review lens 는 분리해서 설명합니다. `.sfs-local/divisions.yaml` 은
기존 프로젝트 호환용 6개 core activation slot 이고, 실제 안내는 backend, 전략/PM, QA,
디자인/frontend, infra/DevOps, management-admin, taxonomy 지식팩/review lens 로 읽습니다.
backend 는 dev specialization, management-admin 은 재무/경리/세무/회계 관점, taxonomy 는 모든
본부에 걸치는 언어/분류 lens 입니다. 사용자는 분야 이름을 외울 필요가 없습니다. Solon 이 필요한
관점만 읽고, plan/review 에서는 사용자가 이해할 수 있는 질문과 기준으로 풀어냅니다.

0.6.79 에서는 agent-skills 벤치마크에서 쓸 만한 practice 를 새 명령으로 늘리지 않고
`implement`, `review`, `adopt`, `tidy`, `release` 의 정책과 렌즈로 흡수했습니다.
공식 문서 기반 구현, stop-the-line debugging, deprecation/migration cleanup, shipping check,
`source-docs`/`simplify`/`security`/`performance`/`api-contract` review lens 가 포함됩니다.

모델 라우팅도 같은 원칙을 따르며 기본 적용됩니다. Helper-grade 단순 I/O 는 가벼운 intake 모델
(Codex 는 `gpt-5.4-mini`), 질문 생성/facilitation 은 standard facilitator 모델(Codex 는
`gpt-5.4`)이 맡습니다. 하위모델 출력이 질문/선택지/답변 해석이나 gate/plan 에 영향을 주면
최상위 advisor 검토가 필수입니다. advisor 는 Claude Opus 4.7, Codex `gpt-5.5` xhigh,
Gemini `gemini-3.1-pro-preview` 입니다. Gemini helper-grade fallback 은
`gemini-3-flash-preview` 이며 2.5 fallback 은 쓰지 않습니다. Codex worker 는 `gpt-5.3-codex`,
`gpt-5.3-codex-spark` 는 bounded helper subtask 로 분리됩니다.
advisor 호출은 self-CPO PASS 가 아닙니다. cross review 전에 요구사항 → AC → 구현 slice →
ADR/decision id, AC → file/artifact/evidence, SEED/placeholder/mock/fallback non-acceptance 를
확인한 self-CPO mini-check 를 남겨야 합니다.

`sfs implement` 는 기본적으로 Single Agent 입니다. plan 이 독립 커밋 단위로 나뉘고 agent 별
files_scope 가 겹치지 않을 때만 `--agent-mode parallel --agents codex,claude[,gemini]` 를
선택합니다. 병렬 구현은 agent 간 cross review 를 남긴 뒤 Gate 6 review 로 넘어갑니다.
커밋 메시지는 사용자의 native 언어 또는 workspace 언어로 씁니다.

일반적인 마무리는 `sfs retro` 입니다. `sfs report` 는 보고서만 먼저 보거나 과거 sprint 를
다시 정리할 때 쓰는 보조 명령입니다.
결정 질문이 남아 있으면 `Q1` 같은 번호만 보이지 않고, 무엇을 결정하는지와 선택지별 결과를
사용자 언어로 풀어 설명합니다.

## Brainstorm 깊이

| Mode | 쓰는 경우 | 기대 결과 |
|---|---|---|
| `--simple` | 이미 방향이 뚜렷하고 빠른 정리만 필요할 때 | 요구사항 정리, 빠진 가정 표시, plan seed 준비 |
| 기본 `normal` | 대부분의 새 요구 탐색 | 2~5개 핵심 질문으로 사용자가 더 생각하게 만들고 plan 으로 넘길 준비 |
| `--hard` | 모호성, 제품 판단, 큰 설계가 중요한 작업 | 의도/모순/우선순위/포기할 것/검증 방식/경계/용어를 집요하게 캐묻는 hard training |

`normal` 은 사용자가 plan 으로 넘어가기 전에 한 번 더 생각하도록 핵심 질문을 던지는 기본값입니다.
`hard` 는 더 끝까지 물고 늘어지는 훈련 모드입니다. 차이는 강도입니다.

## 문서 정책

Solon 문서는 많이 쓰는 것이 목표가 아닙니다. 좋은 문서는 다음 사람 또는 다음 AI 세션이
아래 네 가지를 바로 알 수 있게 합니다.

- 무엇을 했는가
- 왜 그렇게 했는가
- 어떻게 검증했는가
- 다음 action 은 무엇인가

그래서 README 는 큰 지도, GUIDE 는 실제 시작 흐름, `docs/ko` / `docs/en` 는 깊은 설명을 맡습니다.
