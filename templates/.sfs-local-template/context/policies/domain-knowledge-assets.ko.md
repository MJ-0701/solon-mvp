---
id: sfs-policy-domain-knowledge-assets-ko
summary: 전문가 도메인 노하우를 AI 가 재사용할 수 있는 자산으로 컴파일하는 기준.
language: ko
load_when:
  - 도메인 지식
  - 도메인 전문성
  - 전문가 노하우
  - 노하우
  - 스킬화
  - 플레이북
  - 휴리스틱
  - 업무 규칙
  - 지식 자산
  - 해자
status: filled-v1
content_policy: "전문가 판단을 작고 검토 가능한 자산으로 컴파일한다; private 노하우의 공유/공개는 사람 승인 없이는 하지 않는다"
---

# Domain Knowledge Assets Policy

AI 가 일반 코딩과 scaffold 를 평준화할수록 오래 남는 해자는 전문가의 도메인 판단이다.
SFS 는 그 판단을 AI 가 다시 쓸 수 있는 용어, 규칙, 휴리스틱, 예시, 반례, check, taste boundary 로
컴파일한다.

## Activation Rules

- 사용자가 현장 메모, 전문가 critique, craft vocabulary, 업무 규칙, "여기서는 항상 이렇게 한다"
  같은 지침을 준다.
- 같은 설명이 sprint, review, agent 사이에서 반복된다.
- plan 이 재무, 운영, 의료, 법무, 디자인, 영상, 음악, 마케팅, 고객지원, 내부 업무 프로세스 같은
  암묵지를 필요로 한다.
- 사용자가 노트를 skill, playbook, knowledge pack, checklist, wiki page, fixture, test, agent prompt 로
  바꾸자고 한다.
- review 가 generic AI output 이 도메인 판단을 놓쳤다고 판정한다.

## Asset Shapes

- Raw source: 원문 note, capture, interview, example, support ticket, PR comment,
  meeting note, expert review. 원문은 by-reference 로 보존한다.
- Ubiquitous language: canonical term, forbidden alias, actor/state 이름,
  domain boundary, source link.
- Playbook/checklist: when-to-use, 단계 순서, 위험 신호, 복구 절차, 금지 constraint.
- Skill/knowledge pack/review lens: 반복되는 도메인 또는 craft 판단을 agent 가 로드할 수 있는 compact 지침.
- Fixture/test/smoke: 지침이 장식이 아니라 실행 가능하다는 것을 보여주는 예시/반례 쌍.
- Wiki TopicHub/index: source truth 와 compiled asset 을 연결하는 retrieval map.

## Six-Division Asset Loop

6본부 council 은 도메인 자산을 수집하는 기본 장치다. 각 row 는 다음에도 재사용할 사람 노하우가
무엇인지 묻는다.

- Strategy-PM: 시장, 포지셔닝, 우선순위, rollout, decision-boundary 판단을 roadmap/playbook/AC 지침으로 만든다.
- Taxonomy: vocabulary, state, event, alias, classification 판단을 glossary, domain map, naming rule, review lens 로 만든다.
- Design: workflow, taste, interaction, accessibility, copy, visible craft 판단을 `design.md`, checklist, 예시/반례, screenshot, browser-review 휴리스틱으로 만든다.
- Dev: architecture, runtime, invariant, API, migration, implementation 판단을 boundary note, interface contract, fixture, test, source-driven 구현 지침으로 만든다.
- QA: defect, risk, regression, edge-case, acceptance 판단을 fixture set, smoke check, acceptance ledger, review question 으로 만든다.
- Infra: deploy, observability, security, reliability, rollback, cost 판단을 runbook, monitor, shipping check, operations evidence 로 만든다.

각 division ledger row 는 `asset_candidate` 를 기록한다. 기존 asset 재사용, 신규 asset 생성,
구체적 gap/waiver 중 하나가 있어야 한다.

## Compile Flow

1. Raw source 는 원래 위치에 둔다. 큰 private note 를 core context 에 붙여넣지 않는다.
2. 재사용 가능한 최소 단위만 뽑는다: 용어, 휴리스틱, decision rule, 예시, 반례, review question.
3. 가장 좁은 asset shape 를 고른다. 새 command/tool 보다 `docs/solon`, `llm-wiki`, checklist,
   fixture, review lens 를 먼저 선호한다.
4. source, owner/expert, confidence, gap, promotion status 를 기록한다.
5. feedback check 를 붙인다: review question, test, fixture assertion, smoke run, dry-run prompt.
6. private 프로젝트 밖으로 공유하거나 판매할 asset 은 IP, privacy, attribution, commercial boundary 에
   대해 명시적 사람 승인을 받는다.

## Boundaries

- craft 를 generic advice 로 납작하게 만들지 않는다. 도메인 단어와 그 규칙이 중요한 이유를 보존한다.
- AI confidence 를 전문가 권위로 취급하지 않는다. AI 는 포장, 비교, 테스트를 돕고 의미, taste,
  public contract, 공유/공개 결정은 사람이 소유한다.
- 한 전문가의 선호를 scope, 반례, review 없이 universal product law 로 고정하지 않는다.
- "skill" 은 산출물 형태이지 필수 lifecycle command 가 아니다. 실제 tool boundary 가 필요할 때만 새
  command/tool 을 만든다.

## Review Questions

- 어떤 raw source 또는 expert signal 에서 자산이 나왔는가?
- 어떤 용어, 휴리스틱, 예시, 반례가 재사용 가능해졌는가?
- agent 가 필요한 순간에 로드할 만큼 작고 선명한가?
- 그 지식이 실제 행동을 바꾸는지 확인하는 check 가 있는가?
- privacy, IP, attribution, publication status 가 명시됐는가?
- private note 나 host-local skill bundle 을 승인 없이 project SSoT 로 승격하지 않았는가?
- product behavior 에 영향을 주는 지식이면 AC, file, docs, tests, wiki, review evidence 와 연결됐는가?

## Evidence

- Source link, capture id, interview/note path, expert review reference.
- 컴파일된 glossary/domain-map/playbook/skill/knowledge-pack/checklist/wiki path.
- 규칙을 실행하는 example/counterexample fixture 또는 review prompt.
- Verification command/result, dry-run transcript excerpt, reviewer verdict.
- shared-public, paid, cross-team publication 에 대한 human approval/waiver.

## AI 시대 해자 노트 (AI-Era Moat Notes)

2026-05 실무 강연에서 추린 review-lens 프롬프트. hard rule 이 아닌 토의용
체크이며, 인용 주장은 강연 시점 주장이다.

- "도메인 지식 > 코딩": AI 가 generic 구현을 평준화할수록 희소한 입력은
  *무엇을* *왜* 만드는지 아는 것이다. plan 이 AI 코드작성에 기댈 때, 그 뒤의
  도메인 판단이 암묵으로 남지 않고 재사용 asset 으로 포착됐는지 점검한다.
- 공개정보 천장 = 비공개 데이터 가치: 공개정보로 학습한 AI 는 운영자의 고유·
  비공개 데이터나 어렵게 얻은 알파에 닿지 못한다. 사용자 고유의 사적 지식·
  데이터를 컴파일·보호할 asset 으로 취급한다.
- 노하우 자산화: 반복 작업과 craft 판단을 재사용 가능한 skill·프롬프트 팩·
  checklist·review lens 로 묶어, 공유 전문성을 일회성 chat 이 아니라 지속
  레버리지(및 평판)로 전환한다.
- 신뢰·관계·희소성이 AI 시대 해자: 베끼기와 옵션 폭증으로 raw skill 이 평준화될
  수록 신뢰가 차별점이 된다. 쌓은 신뢰·관계·희소한 판단을 1인 운영자의 부가가
  아니라 포지셔닝 asset 으로 다루고 있는지 묻는다.
- AI 리터러시는 옵션이 아니라 baseline 전제: AI 활용은 기본 역량이 됐다(거부=
  불리). 온보딩·pack 이 운영자가 이미 AI 를 레버리지한다는 전제로 짜였는지, 그
  위에 어떤 희소한 가치를 포착하는지 묻는다.
