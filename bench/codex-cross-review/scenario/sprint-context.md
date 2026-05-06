# Sprint Context — DigestKit Sprint 1

> 본 파일은 Solon 가 native 로 들고 있는 sprint contract 의 요약.
> 공정한 비교를 위해 공식 `/codex:review` 호출 시에도 plan.md 와 함께 동일하게 input 으로 제공한다.

## CEO 요구사항 (Gate 2 Brainstorm 결과)

> "내 노트가 옵시디언/iA Writer/Apple Notes 에 흩어져 있는데, 매주 일요일에 한 번 자동으로 정리된 digest 를 받고 싶다. 처음엔 나만 쓸 거고, 잘 되면 사이드 프로젝트로 공개할까 싶다."

## CEO plan (Gate 3 출력 = `plan.md` 이 본 review 의 대상)

## Sprint contract

- **Generator**: CTO (구현 담당)
- **Evaluator**: CPO (review 담당)
- **Sprint length**: 1 주 (Day 1~7)
- **Definition of Done**: P0 user stories 가 dogfooding 환경에서 실행되고, 결과 digest 를 사용자가 1주 사용했을 때 사용 지속 의향이 있음.

## Review lens

본 review 는 **artifact acceptance review** (코드 review 아님). plan 자체의 완전성 / 일관성 / 위험 식별 능력을 본다.

체크리스트:
- 성공 기준이 측정 가능한가
- P0 범위가 sprint 길이와 일치하는가
- 비범위 / P0 / P1 사이에 모순이 없는가
- 기술 선택의 근거가 명시되는가
- 데이터 / 보안 / privacy 처리가 식별되는가
- 배포 / 롤백 / 모니터링 / 비용 대비책이 있는가 (Release Readiness)
- 리스크 식별이 LLM 비용 외에 충분한가
- 테스트 전략이 구체적인가

## 환경

- 사용자: 1인 사이드 프로젝트
- 노트 데이터: 로컬, 일부 개인 정보 / 회사 메모 가능성 있음
- LLM: OpenAI API (사용자 키)
- 배포: npm + GitHub public 예정
