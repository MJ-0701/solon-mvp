---
doc_id: sfs-current-product-shape-ko-22
title: "Project Harness Map"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-28
parent: docs/ko/current-product-shape.md
summary: "Project Harness Map"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Project Harness Map

하네스 엔지니어링은 모델 주변 환경이 보이고 검증 가능할 때 힘이 납니다. SFS 는 이제 그 환경을 직접 점검합니다.

- `sfs harness doctor` 는 현재 프로젝트에 얇은 진입 문서, routed context, 활성 6본부 council,
  artifact/memory 표면, wiki 또는 bug recurrence memory, test, release/check rail 이 있는지 확인한다.
- `sfs harness map` 은 agent, skill/policy, orchestrator rail, artifact, memory, test, release loop,
  human-owned boundary 를 프로젝트 하네스 설계도로 출력한다.
- `sfs harness map --write` 는 `.sfs-local/harness/harness-map.md` 를 작성해 긴 자율 작업이나
  선택적 parallel-agent 작업 전에 운영 설계를 눈으로 확인할 수 있게 한다.

map 은 하네스 자체의 설계 evidence 도 남긴다.

- generated-harness audit: 선언된 agent, skill, orchestrator pointer, change
  history 가 파일시스템과 맞는지 먼저 대조한다.
- optional team architecture: pipeline, fan-out/fan-in, expert pool,
  producer-reviewer, supervisor, hierarchical delegation 중 선택된 패턴을 이름 붙인다.
- advisor-Code file bus: reviewer 는 긴 chat transcript 대신 rule, evidence,
  finding, uncertainty, requested action 을 담은 artifact capsule 을 남긴다.
- fan-out/synthesize barrier: 여러 verifier 가 병렬로 본 경우 lead 는 모든
  capsule 이 생긴 뒤 source evidence 기준으로 synthesize 한다.
- harness evolution: initial design vs shipped design, feedback source, 반복
  delta 에서 승격한 test/policy/skill/scaffold default 를 기록한다.
- concrete ledger: `sfs harness map --write` 는 없을 때
  `.sfs-local/harness/evolution-ledger.md` 도 만든다. source, baseline,
  shipped delta, hypothesis, acceptance signal, promotion target, decision,
  evidence path, next check 를 기록한다.

이 명령은 worker 를 실행하지 않습니다. AI 가 빠르게 움직이기 전에 project-as-prompt 구조가 충분히 좋은지 먼저 보이게 합니다.
