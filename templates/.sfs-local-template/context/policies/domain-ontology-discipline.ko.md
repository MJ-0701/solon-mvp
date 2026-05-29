---
id: sfs-policy-domain-ontology-discipline-ko
summary: 도메인 엔티티·관계·암묵적 업무지식이 바뀔 때 컴파일·재정합 상태를 유지한다.
load_when:
  - ontology
  - domain ontology
  - entity
  - entity relationship
  - relationship
  - domain knowledge asset
  - ubiquitous language
  - 온톨로지
  - 도메인 지식
status: filled-v1
content_policy: "도메인 엔티티/관계나 domain-knowledge 자산이 바뀔 때, 또는 ontology / entity-change review lens 가 활성일 때 읽는다"
---

# 도메인 온톨로지 규율

제품의 온톨로지는 엔티티, 엔티티 사이의 관계, 그 관계에 걸리는 불변식, 그리고
그것들이 왜 존재하는지를 설명하는 암묵적 업무지식이다. Solon 은 이미 이를 자산으로
보관한다 (`domain-knowledge-assets.md` 의 glossary/playbook/fixture/wiki TopicHub,
DDD/TDD knowledge pack 의 aggregate/event/invariant, `llm-wiki/ddd/` context map).
본 pack 은 도메인 언어나 관계가 바뀔 때 그 표면이 조용히 어긋나는 것을 막는다.

본 pack 은 새 lifecycle command 가 아니다. `ontology` review lens 뒤의 규율이며
`review-lens-routing.md` 를 통해 로드된다.

## 적용 시점

도메인 엔티티를 생성·rename·삭제·재관계화하는 작업, 또는 `domain-knowledge-assets`,
`llm-wiki/ddd/`, glossary, ubiquitous-language 자산을 편집하는 작업에 적용한다.
의미를 바꾸지 않는 사소한 표기 수정은 전체 체크리스트가 필요 없다.

## 엔티티 변경 체크리스트

- 신규/rename 엔티티는 프로젝트 ubiquitous language 와 glossary 를 따른다. 새 용어는
  임의로 만들지 말고 glossary 에 등록한다.
- 각 엔티티의 관계 (owns, references, is-part-of, depends-on) 를 흩어진 playbook·
  fixture 에 암묵적으로 두지 말고 명시한다.
- rename/삭제된 엔티티·관계는 backward-compatibility 를 기록한다: migration, alias,
  deprecation note, 또는 사용자 승인된 명시적 break.
- 불변식을 가진 관계가 바뀌면 그 불변식에 대한 test 나 bounded proof, 또는 명시적
  N/A waiver 가 있어야 한다.
- 변경 뒤의 암묵적 업무지식 (관계가 존재하는 이유, owner, 알려진 gap) 을 owner·
  confidence 와 함께 자산으로 남기고 대화 속에서 흘려보내지 않는다.

## 재정합 게이트

도메인 언어나 관계가 바뀌면, 의존 표면이 같은 작업 단위 안에서 재정합될 때까지 변경은
미완이다:

- 엔티티를 명명하는 `domain-knowledge-assets` 항목.
- `llm-wiki/ddd/` context map 링크.
- 옛 이름/관계를 인코딩한 test 나 fixture.

이 표면 중 하나만 갱신한 엔티티/관계 변경은 완료가 아니라 review finding 으로 본다.
재정합을 미루면 silent drift 가 아니라 owner 있는 명시적 follow-up 으로 기록한다.
