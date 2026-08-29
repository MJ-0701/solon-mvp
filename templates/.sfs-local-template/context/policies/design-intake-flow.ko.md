---
id: sfs-policy-design-intake-flow-ko
summary: 넓은 UI 작업 전에 확인 또는 미확인 seed를 남기는 조건부 초심자 디자인 intake.
language: ko
load_when:
  - 디자인 인테이크
  - 디자인 브리프
  - Figma
  - design.md 없는 visible UI
  - docs/solon/design.md
six_question_keys: "user-job, first-flow, viewport, constraints, direction, evidence"
intake_states: "CONFIRMED, UNVERIFIED"
content_policy: "조건부 초심자 intake; 기본안을 제안하고 대화형에서는 한 번 확인하되, 확인할 수 없으면 UNVERIFIED 증거를 남긴다"
---

# 초심자 디자인 인테이크 흐름

이 다섯 단계는 인테이크 조건이 맞을 때만 사용한다. 작은 기존 UI 수정이나
noninteractive 실행을 blocker로 만들지 않으면서 초심자 brief의 불확실성을 줄인다.

## 콘텐츠 정책

이 문서는 intake route이지 두 번째 design-system 명세가 아니다. token, AI-slop review,
browser QA는 기존 design knowledge pack을 그대로 재사용한다.

## DES-INTAKE-01 - 인테이크 대상 판단

확인된 seed가 없고, 요청자가 디자인 도움이 필요하다고 하거나 디자인 경험이 없다고
밝힌 경우, 또는 넓은 새 화면·흐름·리디자인을 만드는 경우에만 여섯 문항 brief를
실행한다. 확인된 `design.md` 또는 `docs/solon/design.md`가 있으면 바로 구현으로 간다.

seed 파일이 없다는 이유만으로 기존 visible UI의 작은 수정을 여섯 문항으로 늘리지
않는다. 기존 화면에서 확인되는 token과 component를 보존하고, 나중 review에 보여야
하면 좁은 missing-seed gap을 `UNVERIFIED`로 기록한다.

## DES-INTAKE-02 - 여섯 문항 brief

target user와 primary job, 첫 workflow 또는 screen, desktop/mobile 우선순위, 기존
brand/product 제약, 유용한 reference 또는 선호 방향, delivery/evidence 제약의 여섯
질문을 한 번에 묻는다. 답이 비어 있으면 명확한 기본안을 제안하고 계속 진행하며,
brief를 막거나 기본안별 확인을 따로 받지 않는다.

## DES-INTAKE-03 - reference 또는 안전한 출발점

Figma 파일이 있으면 먼저 살핀다. 없으면 screenshot 또는 reference page를 fallback으로
쓴다. 복제품이 아니라 쓸 수 있는 원리를 추출하며, protected asset이나 고유 trade dress를
복사하지 않는다.

Figma, screenshot, reference가 모두 없다면 안전한 starter direction을 제안한다. 기존
product system이 있으면 그것을 따르고, 없으면 차분한 task-first layout, 읽기 쉬운 type,
단일 icon family, neutral surface와 절제된 accent 하나, 일정한 spacing, 과하지 않은
radius를 쓴다. generic gradient와 남의 brand treatment는 쓰지 않으며 seed에
`reference: none`을 기록한다.

## DES-INTAKE-04 - seed 상태와 한 번의 확인

brief, token value, component/icon rule, prohibited value, 짧은 reference rationale을 담은
`docs/solon/design.md`를 만든다. 위쪽에는 `intake_status: CONFIRMED` 또는
`intake_status: UNVERIFIED`를 기록한다. 대화가 가능하면 사람 확인은 한 번만 묻고,
그 응답에서 제안 기본안을 수락하거나 수정한다.

사람이 확인하지 않으면 제안 seed를 `UNVERIFIED`로 남긴다. seed를 만들 이유가 없는
작은 수정이면 implementation 또는 review evidence에 `UNVERIFIED` design-intake gap과
사유를 기록한다. noninteractive 또는 CI에서는 기다리지 않고 같은 방식으로 proposed
seed 또는 gap을 `UNVERIFIED`로 기록하며, 절대 `Ready`라고 쓰지 않는다. 이는
evidence 상태이지 새 hard implementation block이 아니다.

## DES-INTAKE-05 - 구현, review, Ready 상태

확인된 seed가 있으면 그 seed에 구현을 binding한다. CI를 포함한 scoped change는
`UNVERIFIED` proposed seed 또는 기록된 gap에서도 계속할 수 있지만, seed 또는 기존
화면에 있는 값만 쓰고 prohibited value나 새로 만든 임의 값은 거부한다. 새로 승인된
값을 넣기 전에는 seed를 먼저 갱신한다.

사람 확인, 기존 token-drift check 통과, desktop viewport 하나와 mobile viewport 하나의
기존 browser-QA evidence가 모두 있을 때만 design route를 `Ready`로 표시한다. 이
intake가 필요했는데 건너뛰었거나 아직 확인되지 않았다면 review는 조용히 `Ready`로
부르지 않고 `UNVERIFIED`로 기록한다. 이는 새 gate가 아니며 기존 review/waiver 규칙을
대체하지 않는다.
