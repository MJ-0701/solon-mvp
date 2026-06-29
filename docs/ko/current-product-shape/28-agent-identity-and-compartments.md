---
doc_id: sfs-current-product-shape-ko-28
title: "에이전트 신원과 구획(compartment)"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-06-28
parent: docs/ko/current-product-shape.md
summary: "자율 에이전트의 접근 모델: 에이전트가 자기 신원(service account)으로 행동하고 신원으로 접근을 폐기, 권한은 사용자 아닌 compartment(작업 경계)에 귀속, grant 는 추측 아닌 감사로 확장."
load_when: "에이전트가 크리덴셜/접근이 필요할 때, 개인-학습 경계와 회사 프로젝트를 분리할 때, 에이전트 권한을 넓히는 방법을 정할 때 읽는다."
---
## 에이전트 신원과 구획(compartment)

에이전트가 자율성을 얻을수록 예전의 "사용자 대행" 지름길 — 에이전트가 네
크리덴셜·권한을 빌려 쓰는 것 — 은 안전하지 않게 된다: 그 행위가 네 것과
구분이 안 되고, 에이전트만 깔끔히 폐기할 방법도 없다. durable 모델은 3부분이다
(근거: 에이전트 신원 접근 모델에 관한 Claude 블로그 2026-06-24, by-reference —
일반화; 벤더 채널 UI·Enterprise RBAC·JIT 크리덴셜 로드맵은 보류).

### 1. 에이전트가 자기 자신으로 행동

에이전트는 **자기 신원**(전용 service account)을 가진다 — 어떤 운영자와도
구분된다. 접근은 그 신원에 부여되고 그 신원으로 감사되므로 **신원을 폐기하면
그 신원이 가진 모든 접근이 한 번에 종료** — 빌린 사용자 크리덴셜은 줄 수 없는
단일·깔끔한 kill switch. 크리덴셜 경계 규칙의 access-control 쌍둥이다: 키는 한
store, 경계에서 주입, consumer 단위 스코프 — 이제 consumer 가 에이전트 자기
신원 (`policies/credential-hygiene.md` AGENT_IDENTITY;
`policies/runtime-token-firewall.md` 와 동일 per-consumer 격리).

### 2. 권한은 사용자 아닌 구획에 귀속

접근과 메모리를 **compartment** — 작업 경계(프로젝트/repo/채널) — 에
스코핑한다, 누가 있느냐가 아니라. 워크스페이스 baseline 이 전역 적용되고,
compartment 가 자기 scope 로 좁히거나 override 하며, **한 compartment 안에서
배운 것이 다른 곳으로 새지 않는다** (`policies/user-context-separation.md`
COMPARTMENT_SCOPING).

1인 운영자에게 이건 멀티테넌트 오버헤드가 아니다 — 살아있는 경계가 네 것이다:
개인-학습 도셋 vs 회사 프로젝트. 이 규칙이 개인-도셋 학습이 회사-프로젝트
산출물로 스며드는 걸 막는다 (배포본이 이미 테스트로 지키는 product-leak 경계).

### 3. Grant 는 추측 아닌 감사로 넓힌다

권한은 단일 광범위 grant 가 아니라 라이프사이클로 자란다:

1. **baseline profile 에서 시작** — 작업을 시작할 수 있는 최소 집합으로 스코핑.
2. **감사 추적을 읽는다** — 신원이 실제로 무엇을 건드렸는지. solon 의
   `events.jsonl` 과 `tool_call` 텔레메트리가 그 source.
3. **정당한 grant 한 개씩 좁힌다.** 막힘 해소를 위해 넓게 시작해야 할 땐
   broad-then-narrow 를 의무로 본다: 이후 각 grant 는 추적으로 정당화되고,
   안 쓰는 scope 는 제거한다 (`policies/credential-hygiene.md` GRANT_LIFECYCLE).

오케스트레이터의 read → propose → bounded-write 단계 확장을 미러한다
(`policies/external-orchestrator-entry.md`).

### Solon 워크플로와 만나는 지점

- 실 키는 에이전트-가시 표면에 절대 안 나타난다 — placeholder 와 env-var
  이름만 (`policies/credential-hygiene.md` PLACEHOLDER_ONLY_SURFACES).
- grant 결정의 감사 source 는 flowcheck 가 읽는 같은 이벤트 원장
  (`policies/flow-conformance-postflight.md`).
- 접근을 스코핑하는 에이전트들은 팀 로스터에 있는 그들이다
  (`current-product-shape/27-human-agent-teams.md`).
