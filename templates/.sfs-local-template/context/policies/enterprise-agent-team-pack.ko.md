---
id: sfs-policy-enterprise-agent-team-pack-ko
summary: SFS 계획/리뷰용 엔터프라이즈 6본부 agent team 운영 팩.
language: ko
load_when:
  - enterprise
  - agent team
  - 6본부
  - sub-agent
  - plan council
  - 대기업급
status: filled-v1
content_policy: "상위 팩. 활성 트리거가 있을 때만 child pack 을 연다."
split_children:
  - enterprise-plan-council-pack.ko.md
  - enterprise-evidence-pack.ko.md
  - enterprise-performance-review-pack.ko.md
---

# Enterprise Agent Team Pack

이 팩은 SFS 의 6본부를 장식용 표가 아니라 실제 계획/검수에 참여하는
개념적 sub-agent 팀으로 만든다. FE/BE 가 아니라 모든 product-bearing
entrypoint 에 적용한다.

## 원칙

- strategy-pm, dev, QA, design, infra, taxonomy 는 brainstorm 부터 Gate 6 까지
  항상 참여한다.
- plan 은 brainstorm 직후 계약서가 아니라 설계 단계다. 코딩 전 위험,
  증거, 파일/산출물 경계를 드러내야 한다.
- 모든 본부가 참여하지만 deep pack 은 AC/risk/artifact 가 닿을 때만 연다.
- 체크리스트보다 실행 증거가 우선이다. command, artifact, diff, test,
  trace, screenshot, waiver 없이 PASS 라고 하지 않는다.
- 최신 제품팀 방식에 맞춘다: 작은 slice, trunk 친화 commit, 관측 가능한
  release, 안정적인 domain language, 빠른 feedback loop.

## 흡수한 기준

- DORA: lead time, deployment frequency, change failure rate, recovery time.
- Google SRE: SLO/error budget, monitoring, incident learning.
- AWS Well-Architected: 운영, 보안, 신뢰성, 성능, 비용 의식.
- OWASP ASVS: auth/session/access-control/validation/secrets.
- WCAG/Core Web Vitals: 접근성과 사용자 체감 성능.
- Google engineering practice: 작은 변경, 유지보수성, reviewer 책임.

## 버릴 것

- 모든 작업에 SAFe/CAB/BDUF/수동 trace matrix 를 강제하지 않는다.
- 모든 작은 변경에 mutation threshold, PR/FAQ, RFC, ADR, diagram 을 강제하지
  않는다.
- stateless utility/glue/adapter 에 엄격한 DDD 를 강제하지 않는다. 이름 붙은
  boundary 와 evidence 면 충분할 수 있다.
- 모든 pack 을 전부 읽지 않는다. 그건 context pollution 과 얕은 compliance 를
  만든다.

## Child Pack

- Gate 3 plan 생성/수정: `enterprise-plan-council-pack.ko.md`
- QA/QC, release, monitor, wiki evidence: `enterprise-evidence-pack.ko.md`
- algorithm/query/UI runtime/batch/network/storage/performance:
  `enterprise-performance-review-pack.ko.md`

## PASS 모양

- 관련 본부마다 finding/evidence/waiver 가 있다.
- AC 가 file/artifact/evidence 에 연결된다.
- hot path 는 측정 또는 bounded proof 가 있다.
- SFS 제품 정책이면 실제 프로젝트 적용 QA/QC 를 남긴다.
- 사용자는 진짜 제품 판단에만 호출한다.
