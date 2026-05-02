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
