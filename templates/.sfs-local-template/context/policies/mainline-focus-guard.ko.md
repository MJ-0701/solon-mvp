---
id: sfs-policy-mainline-focus-guard-ko
summary: 보조 도구/인증/설정 작업이 사용자 본론을 잡아먹지 못하게 막는 가드.
language: ko
load_when:
  - mainline
  - focus
  - tool setup
  - auth setup
  - drift
  - 삼천포
  - 본론
  - 보조도구
status: filled-v1
content_policy: "보조 도구 설정이 본 작업을 끊을 위험이 있을 때만 로드"
---

# Mainline Focus Guard

이 팩은 눈앞의 도구 문제가 실제 sprint 목표를 잡아먹는 일을 막는다. 도구,
인증, 모델, connector, bridge probe 는 사용자 본론을 돕는 수단이지, 사용자가
명시하지 않은 한 본론 자체가 아니다.

## 보조 작업 분류

설정/도구 작업에 시간을 쓰기 전에 다음 중 하나로 분류한다.

- `mainline`: 사용자가 그 제품/도구 동작 자체를 고치라고 했다.
- `unblocker`: 본 작업을 진행하려면 최소 설정이 반드시 필요하다.
- `deferred_followup`: 유용하지만 본 작업은 진행 가능하다.
- `blocked`: 인증/도구/runtime/sandbox 승인 부재로 본 작업이 막혔다.
- `out_of_scope`: 흥미롭지만 현재 AC 와 연결되지 않는다.

현재 sprint 를 끊을 수 있는 것은 `mainline` 또는 진짜 `unblocker` 뿐이다.
`unblocker` 라면 최소 설정만 끝내고 증거를 남긴 뒤 즉시 본론으로 복귀한다.

## 드리프트 규칙

- 비자명한 변경 전에는 main objective 를 다시 적는다.
- 사용자가 본론을 다시 짚으면 side work 를 멈추고, 그 드리프트를 허용한
  SFS artifact/check 를 제품버그로 고친다.
- helper model 설정 자체가 산출물이 아닌데 helper 설정 sprint 로 바꾸지 않는다.
- 본 작업 중 발견한 도구 설정 버그는 acceptance 를 막는 경우만 즉시 처리하고,
  나머지는 본론 종료 후 product defect/follow-up 으로 남긴다.

## Mainline Ledger

plan/review/긴 작업에는 다음을 남긴다.

| field | meaning |
|---|---|
| main objective | 전달할 product behavior 또는 SFS policy |
| current step | 지금 하는 일이 objective 를 어떻게 돕는지 |
| side-work classification | mainline / unblocker / deferred_followup / blocked / out_of_scope |
| return condition | 본론으로 돌아가도 되는 증거 |
| evidence | command, artifact, waiver |

helper 설정이 sprint 를 소비했는데 본 objective 가 검증되지 않았다면 Gate 6 는 partial 이다.
