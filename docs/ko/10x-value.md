# Solon 10x 가치

**Language**: 한국어 / [English](../en/10x-value.md)

Solon 은 코드를 더 많이 생성해서 10x 를 만들려는 제품이 아닙니다. Solon 의 10x 는
불명확한 의도를 공유 개념, 도메인 언어, 검증 가능한 계약, 작은 작업 단위, 독립 review signal 로
바꾸는 운영 루프에서 나옵니다.

AI coding 은 코드베이스가 바꾸기 쉬울 때 빠릅니다. AI execution 은 프로젝트 전체 표면이
바꾸기 쉬울 때 안전합니다. 구조가 약하고, 용어가 흐릿하고, 피드백이 느린 프로젝트에서 AI 는
종종 엔트로피를 가속합니다. 부분 패치가 쌓이고, 설계 의도는 사라지고, 다음 변경은 점점
믿기 어려워집니다.

Solon 은 그 붕괴를 막는 루프입니다.

```text
Fuzzy idea
→ shared design concept
→ domain language
→ acceptance criteria
→ test/review contract
→ small work unit
→ independent review
→ retro / next action
```

## AI 실행이 실패하는 이유

Solon 은 아래 문제를 prompt 문제가 아니라 product 운영 문제로 봅니다.

1. **공유 design concept 이 없다**
   - 사용자의 머릿속 그림과 AI 가 만든 결과물이 다릅니다.
   - 프롬프트를 더 길게 써도 숨은 모델이 공유되지 않으면 계속 빗나갑니다.

2. **도메인 언어가 없다**
   - 사용자, 도메인 전문가, 개발자, AI 가 같은 단어를 다르게 씁니다.
   - 결과적으로 설명은 장황해지고, 추상화는 어긋나고, artifact 는 실제 일과 맞지 않습니다.

3. **피드백 루프가 느리다**
   - AI 가 너무 많이 바꾼 뒤에야 테스트나 review 가 들어옵니다.
   - 버그는 늦게 드러나고, 수정 범위는 국소가 아니라 광역이 됩니다.

4. **코드베이스/문서베이스의 규칙성이 낮다**
   - 파일마다 패턴이 다릅니다.
   - 사람과 AI 모두 머릿속에 들고 있어야 할 구조가 너무 많아져 context 가 끊깁니다.

## Brainstorm 은 뇌 근육 훈련이다

AI 시대에는 한마디만 해도 작업 진척도가 올라갑니다. 그래서 역설적으로 사용자가 생각을 덜 하게
되는 위험이 생깁니다. Solon 의 brainstorm depth 는 이 문제를 정면으로 다룹니다.

| Mode | 가치 |
|---|---|
| `--simple` | 이미 정해진 방향을 빠르게 정리해 실행 마찰을 줄임 |
| 기본 `normal` | 사용자가 핵심 결정, 모순, 성공 기준을 한 번 더 생각하게 만듦 |
| `--hard` | product owner 로서 의도, 포기할 것, 검증 방식, 경계, 용어를 깊게 설계하게 만듦 |

`--hard` 는 AI 를 덜 쓰는 모드가 아닙니다. AI 를 질문자와 설계 파트너로 써서 사용자의 product
ownership 을 더 강하게 만드는 모드입니다.

## 비개발자 10x 루프

창업자, 기획자, 운영자, 도메인 전문가에게 Solon 은 "내가 원하는 건 아는데 엔지니어처럼
명세할 수는 없다"를 검증 가능한 작업 계약으로 바꿉니다.

| Step | Solon output | Value |
|---|---|---|
| Idea capture | `brainstorm.md` raw log | 원래 생각이 사라지지 않음 |
| Design concept | problem / options / scope seed | 사용자와 AI 가 같은 그림을 봄 |
| Domain language | glossary, actors, objects, states, rules | 단어가 흔들리지 않음 |
| Acceptance criteria | measurable pass/fail conditions | "완료"가 검증 가능해짐 |
| Work units | small implementation slices | 실행이 감당 가능한 크기로 쪼개짐 |
| Review signal | verdict + required actions | 아직 중요한 문제가 무엇인지 보임 |

비개발자가 먼저 소프트웨어 아키텍처를 다 배울 필요는 없습니다. Solon 은 AI 와 개발자가
올바른 것을 만들기 위해 필요한 최소 구조를 뽑아냅니다.

## 실행 10x 루프

개발자에게 Solon 은 domain language 와 tight feedback 을 기본값으로 둡니다. 코드 slice 에서는
DDD-lite, TDD-lite 에 가깝고, 비코드 slice 에서는 명명된 용어, artifact boundary, 가장 작은
검증 루프를 뜻합니다.

| Practice | Solon meaning | Why it matters for AI |
|---|---|---|
| System analysis | 수정 전 기존 패턴을 먼저 읽음 | AI 가 새 규칙을 invent 하지 않게 함 |
| Domain language | 용어, 상태, 규칙, invariant 를 이름 붙임 | AI 가 사용자의 실제 언어를 유지함 |
| Feedback contract | 구현 전 테스트/review/smoke 후보를 정함 | AI 가 작은 루프로 움직이게 함 |
| Small slice | 하나의 bounded change 만 구현 | 실패가 국소적으로 남음 |
| Review gate | 독립 CPO verdict 와 CTO action | 생성자가 스스로 승인하지 않음 |

좋은 implementation artifact 는 계속 바꾸기 쉽습니다. 좋은 AI execution 은 그 성질을 보존합니다.

## 병렬 agent 10x 루프

여러 agent 를 동시에 쓰는 것은 "많이 시키면 빨라진다"가 아닙니다. Solon 에서 병렬성의 10x 는
작업을 **커밋 단위로 설명 가능한 lane** 으로 나누고, 서로 다른 agent 가 서로의 산출물을
검토하게 만드는 데서 나옵니다.

기본값은 Single Agent 입니다. `--agent-mode parallel` 은 plan 이 이미 독립 lane 으로 나뉘고,
각 lane 의 files_scope 가 겹치지 않으며, lane 별 commit message 를 한 문장으로 말할 수 있을 때만
사용합니다. 그 문장을 못 쓰면 아직 나눌 준비가 안 된 것입니다.

그 commit message 는 사용자의 native 언어 또는 workspace 언어로 써야 합니다. 한국어 사용자의
작업이면 lane 이름과 커밋 메시지도 한국어로 읽혀야 하며, 영어 커밋은 repo 규칙이나 사용자의
native 언어가 영어일 때만 기본값입니다.

```text
fixed plan
→ commit-unit lanes
→ disjoint files_scope
→ lane verification
→ agent cross review
→ Gate 6 review
```

이 구조가 있으면 Codex, Claude, Gemini 를 동시에 써도 작업 속도와 품질 체크가 같이 올라갑니다.
구조가 없으면 병렬성은 충돌과 중복 review 만 늘립니다.

## Token Diet 10x 루프

AI agent 를 오래 쓰면 비용보다 먼저 맥락 품질이 흔들립니다. 짧은 답변이 도움이 되는 이유는
단어 수 자체가 아니라, 사용자가 볼 필요 없는 장식을 줄이고 판단에 필요한 trace 를 더 빨리 찾게
하기 때문입니다.

| Token Diet practice | Solon 의미 | 10x 효과 |
|---|---|---|
| Professional compact output | routine status/start/report 를 한 줄 필드로 출력 | 기다리는 시간과 읽는 비용을 줄임 |
| Evidence-preserving floor | warning, decision, evidence, source trace, verification 은 유지 | 짧아져도 review 품질이 무너지지 않음 |
| Raw-text fallback | compact 판단이 애매하면 원문/경로를 다시 확인 | 잘못 요약한 상태로 구현하지 않음 |
| Context Diet | routed context, stable search vocabulary, concept-grained artifact 우선 | 입력 토큰을 broad read 로 태우지 않음 |
| Quiet release verifier | 성공한 install/upgrade smoke 로그는 접고 실패 stdout/stderr 는 replay | 배포 로그는 짧고 실패 원인은 추적 가능 |
| Persona opt-in | Caveman/persona 말투는 기본값이 아님 | 제품 출력 톤을 장난으로 만들지 않음 |

Token Diet 의 성공 조건은 "짧아짐"이 아닙니다. 짧아져도 evidence/risk/raw traceability 가 살아 있어야
성공입니다. 그 조건이 흔들리면 Solon 은 full clarity 로 돌아갑니다.

## 모델 라우팅 10x 루프

Solon 의 모델 라우팅은 "비싼 모델을 항상 쓰자"가 아니라 "판단의 무게와 모델의 책임을 맞추자"는
운영 원칙입니다. 빠른 helper 는 빠르게 쓰고, 제품 정체성, architecture, acceptance criteria,
review 처럼 되돌리기 비싼 판단은 최상위 advisor 로 올립니다.

| 역할 | Solon 기준 | 10x 효과 |
|---|---|---|
| Helper-grade intake | 단순 relay, 누락 인자 질문, 낮은 위험의 짧은 요약 | 사용자가 기다리는 시간을 줄임 |
| Facilitator / question | brainstorm 질문 생성, 선택지 framing, 답변 요약 | 좋은 질문으로 scope 를 빠르게 선명하게 함 |
| C-Level / review | 의도, 구조, AC, 검토, 승격 판단 | 되돌리기 비싼 결정을 더 깊게 봄 |
| Worker | plan 과 files_scope 가 고정된 구현 slice | 실행과 판단 책임을 섞지 않음 |
| Bounded helper | grep, 포맷, 동기화 같은 기계적 보조 작업 | 고급 모델 시간을 반복 작업에 태우지 않음 |

이 라우팅은 기본값입니다. 사용자가 따로 설정하지 않아도 적용되고, `current_model` 은 명시적으로
역할 분리를 끄고 현재 선택 모델을 그대로 쓰고 싶을 때만 선택합니다. 모델명은 SFS 의
role/profile contract 이며 모든 CLI 가 `--model` 같은 옵션을 지원한다고 가정하지 않습니다.
기본 bridge 는 prompt 와 host/runtime 설정으로 해당 역할을 요청하고, 명시 override 가 필요할 때만
`SFS_REVIEW_<EXECUTOR>_CMD` 로 검증된 명령을 둡니다.

Codex 기준으로 helper-grade intake 와 non-coding helper 는 `gpt-5.4-mini`, 질문 생성/facilitator 와
일반 worker 는 `gpt-5.4`, advisor/review 는 `gpt-5.5` xhigh, bounded repo-aware coding helper 는
`gpt-5.3-codex`, 무판단 mechanical implementation helper 는 `gpt-5.3-codex-spark` 를 기본 계약으로
봅니다. Claude 는 Opus/Sonnet 4.6/Haiku 책임 분리를 따릅니다. Claude 에서 코딩 가능한
worker/helper 는 Sonnet 4.6이고, Haiku 는 코딩 금지 helper-grade relay/요약/read-only 보조 전용입니다.
Gemini 는 모든 role 을 `gemini-3-pro-auto` 로 두며 Flash/2.5 fallback 이름은 쓰지 않습니다.
실질 research 는 가능하면 Gemini 3 Pro auto researcher 로 보냅니다.

Helper-grade 단순 I/O 는 advisor 검토를 생략할 수 있습니다. 하지만 하위모델 출력이 질문/선택지를
설계하거나 사용자 답변을 해석하거나 product identity, architecture, gate, AC, files_scope 에
영향을 주면 최상위 advisor 검토가 필수입니다.

advisor 호출은 self-CPO PASS 를 대체하지 않습니다. external/cross review 전에 작성자는
self-CPO mini-check 를 남깁니다: 요구사항 -> AC -> 구현 slice -> ADR/decision id 추적, 각 AC 의
file/artifact/evidence 매핑, SEED/placeholder/mock/fallback 이 실제 산출물 전에는
non-acceptance 로 남는지 확인합니다.

`gpt-5.3-codex` 는 일반 worker 가 아니라 좁은 code helper 입니다.
`gpt-5.3-codex-spark` 는 더 좁은 mechanical implementation helper 입니다. 이미 결정된 사항에 대해
판단이 필요 없고 scope, files_scope, AC, 정확한 수정 의도가 잠긴 file move, import/path rewrite,
generated index sync, deterministic test expectation update 같은 작업에만 씁니다. architecture,
public contract, security, privacy, data-loss, release gate, 같은 실패 반복이 있으면 worker 도 high
reasoning 으로 승격합니다.

## 디자인 시스템 10x 루프

AI 시대에는 코드 작성 능력보다 화면의 일관성과 감도가 더 빨리 드러납니다. 사용자는 코드를
보지 않아도 화면은 봅니다. 그래서 디자인본부의 10x 는 pixel 을 더 많이 그리는 것이 아니라,
AI 가 따라야 할 디자인 시스템을 만들고 AI output 이 평균값으로 회귀하는 것을 잡아내는 데서
나옵니다.

Solon 은 visible UI 작업에서 `design.md` 또는 `docs/solon/design.md` 를 디자인 계약으로 봅니다.
이 파일에는 색, 폰트, type scale, spacing, radius, shadow, component variant, icon style,
금지값과 rationale 이 있어야 합니다. UI 를 구현할 때 AI 는 이 계약을 먼저 읽고, review 는
계약 밖 token drift 를 찾습니다.

| Design practice | Solon meaning | Why it matters for AI |
|---|---|---|
| `design.md` | AI 가 읽는 디자인 시스템 계약 | 매 화면마다 색, 간격, radius 를 새로 invent 하지 않음 |
| Token drift check | 임의 hex, font-size, spacing, icon style 검사 | AI 슬롭 신호를 review finding 으로 잡음 |
| Korean typography | 한글 font, line-height, 긴 label fit 검증 | 한국어 UI 가 영어 기준 레이아웃에 눌리지 않음 |
| Coherent icon family | 하나의 icon system 또는 기존 product icon 유지 | 화면 톤이 섞이지 않음 |
| Screenshot evidence | desktop/mobile 에서 실제 fit 확인 | "그럴듯함"이 아니라 사용 경험을 검증함 |

원티드 몽타주식 컴포넌트, Coolicons 같은 단일 icon family, Pretendard 같은 Korean-capable font 는
좋은 starter set 이 될 수 있습니다. 하지만 핵심은 vendor 가 아니라 시스템입니다. 기존 제품
design system 이 있으면 그것이 우선이고, 없다면 작은 `design.md` seed 부터 만드는 것이 Solon 의
권장 출발점입니다.

## 벤치마크 흡수 10x 루프

agent-skills 류 repo 의 좋은 점은 "새 버튼"이 아니라 AI 가 반복해서 놓치는 판단을 짧은
practice 로 고정한다는 데 있습니다. Solon 은 이것을 새 lifecycle command 로 복제하지 않고,
기존 루프 안의 기준으로 흡수합니다.

| Practice | Solon 흡수 위치 | 10x 효과 |
|---|---|---|
| Source-driven implementation | `implement`, `source-docs` review lens | framework/API 추측을 공식 근거로 줄임 |
| Stop-the-line debugging | `implement` debugging policy | 같은 실패를 반복하지 않고 원인/evidence 로 전환 |
| Deprecation/migration cleanup | `adopt`, `tidy` | 남길 이유 없는 로그/히스토리 파일을 visible state 에 두지 않음 |
| Shipping discipline | `release` | version/channel/install 검증과 rollback 감각을 배포 전 확인 |
| Focused review lenses | `review` | 보안, 성능, API contract 같은 위험을 코드리뷰 한 단어에 묻지 않음 |

## Solon 이 약속하지 않는 것

- 나쁜 코드베이스를 마법처럼 싸게 만들지 않습니다.
- 사람의 product judgment 를 제거하지 않습니다.
- 컴파일되었다는 이유로 AI output 을 정답으로 취급하지 않습니다.
- TDD/DDD 를 무겁게 강제하지 않습니다.

Solon 은 루프를 실행 가능한 만큼 작게 유지하되, 코드베이스와 제품 판단을 보호할 만큼은
구조화합니다.

## 제품 약속

Solon 은 비개발자가 흐릿한 의도를 검증 가능한 작업으로 바꾸게 돕고, 개발자가 AI 를 쓰면서도
코드베이스와 문서베이스의 설계 표면을 망가뜨리지 않게 돕습니다.

결과는 단순히 더 빠른 output 이 아닙니다. 더 안전한 iteration 입니다.
