---
doc_id: sfs-current-product-shape-domain-knowledge-assets-ko
title: "도메인 지식 자산"
visibility: oss-public
doc_type: product-reference-section
language: ko
updated: 2026-08-27
summary: "전문가 노하우는 AI 가 재사용할 수 있는 자산으로 컴파일될 때 해자가 된다."
load_when: "도메인 전문성, 반복 설명, craft rule 을 SFS 기억으로 만들 때 읽는다."
---
# 도메인 지식 자산

AI 시대에는 일반적인 코딩 실력만으로 만든 해자가 얕아집니다. 비슷한 코드 생성기를 쓰면
비슷한 scaffold 와 구현이 나올 수 있기 때문입니다. 더 복제하기 어려운 경쟁력은 실무자가
머릿속에 쌓아둔 도메인 지식입니다. 용어, 예외, taste, 예시, 반례, "여기서는 이렇게 한다"는
규칙이 여기에 들어갑니다.

Solon 은 그 지식을 agent 가 재사용할 수 있게 되었을 때 자산으로 봅니다. 형태는 glossary,
domain map, playbook, checklist, knowledge pack, review lens, skill, fixture, test,
wiki TopicHub 중 하나일 수 있습니다. 중요한 것은 다음 sprint 의 AI 행동이 실제로 좋아지는지입니다.

5개 조직 본부와 foundational cross-cutting product function/lens인 taxonomy로 이루어진
6개 필수 council role은 이 자산을 모으는 기본 수집 장치입니다. 전략/PM 은 포지셔닝과 우선순위 판단을,
taxonomy 는 명명과 분류를, design 은 workflow/copy/taste 를, dev 는 구조와 invariant 를, QA 는
risk 와 acceptance edge case 를, infra 는 reliability/security/deploy/rollback 지식을 잡습니다.
관련 council role row 는 `asset_candidate` 를 남겨야 합니다. 그래야 한 번 나온 실무 노하우가 다음 작업의
durable SFS memory 로 승격될 경로를 갖습니다.

이 경로는 sprint artifact 에서 실행됩니다. plan 은 `Domain Asset Promotion Ledger` 를 남기고,
implement 는 artifact path 와 verification 을 남기며, review 는 source/owner/confidence/gaps 를
확인한 뒤에야 해당 자산을 재사용 가능하거나 공개 가능하다고 봅니다.

원칙은 source first 입니다. 원문 note, interview, review comment, meeting note, support example 은
원래 위치에 둡니다. 그런 다음 오래 남는 의미만 컴파일합니다. canonical term, decision rule,
위험 신호, 예시, 반례, owner, confidence, gap, 그리고 이 지식이 행동을 바꾸었는지 확인하는
check 를 남깁니다.

skill 은 가능한 산출물 형태 중 하나이지 기본 새 명령이 아닙니다. 카메라 감독, 마케터, 회계 담당자,
디자이너, 고객지원 리드, 엔지니어에게 반복 가능한 판단 패턴이 있다면 SFS 는 먼저 그 판단을
가장 작고 검토 가능한 artifact 로 만드는 방법을 찾습니다. 공개 공유, 유료 배포, attribution,
private note, IP 경계는 계속 사람이 소유하는 결정입니다.
