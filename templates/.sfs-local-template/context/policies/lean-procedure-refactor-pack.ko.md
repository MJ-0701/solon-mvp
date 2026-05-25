---
id: sfs-policy-lean-procedure-refactor-pack-ko
summary: 품질 gate 는 유지하면서 절차 병목과 비효율 의식을 제거하거나 자동화한다.
load_when:
  - 절차 병목
  - 절차 리팩토링
  - ceremony
  - lean gate
  - slow review loop
  - 불필요한 절차
language: ko
status: filled-v1
---

# Lean Procedure Refactor Pack

SFS 자체나 SFS 로 관리되는 프로젝트가 품질 향상 없이 절차 때문에 느려질 때
사용한다.

## Keep / Shrink / Remove

- 보안, 데이터 손실, 공개 contract, 회귀, release, user judgment 실패를 막고
  테스트로 싸게 대체하기 어려운 step 은 유지한다.
- 가치가 있지만 사용자 눈에 보이는 의식일 필요가 없으면 auto-lens, checklist row,
  template field, post-run assertion 으로 축소한다.
- stronger evidence 를 중복하거나, user 에게 runnable work 를 맡기거나,
  mainline 을 반복해서 막는 ceremony 는 제거하거나 downgrade 한다.
- invariant 는 제거하지 않는다. evidence path 를 자동화, 축소, 인접 gate 통합,
  waiver 로 바꾼다.

## Bottleneck Ledger

의미 있는 signal 만 기록한다.

- user-call count, runnable-step delegation count, review loop count.
- auth/tool setup 에 막힌 시간과 main objective 진행 시간의 차이.
- 반복 finding category 와 더 이른 guard/test 로 잡을 수 있는지.
- token/context growth, stale artifact, manual copy-paste handoff.
- command/test/runtime wait 를 parallel, cache, targeted 로 바꿀 수 있는지.

## Refactor Rule

결과는 절차는 줄고 품질은 같거나 강해야 한다.

- manual prompt 와 반복 review 감소.
- trigger condition 명확화와 context load 축소.
- test, smoke, ledger, release verifier evidence 는 같거나 강함.
- security, data validation, DDD/TDD, user approval safety 는 약화 금지.
