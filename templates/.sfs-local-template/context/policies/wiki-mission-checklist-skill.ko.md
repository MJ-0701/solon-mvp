---
id: sfs-policy-wiki-mission-checklist-skill-ko
summary: 긴 컨텍스트 작업에서 사용자 지적사항이 흐려지지 않게 하는 wiki checklist skill.
language: ko
load_when:
  - checklist
  - wiki checklist
  - long context
  - context heavy
  - multi-step
  - follow-through
  - 흐려짐
  - 체크리스트
status: filled-v1
content_policy: "여러 단계/반복 결함/멀티 repo/release/monitoring/긴 컨텍스트 때 로드"
---

# Wiki Mission Checklist Skill

컨텍스트가 무거우면 계속 진행하기 전에 임무를 durable 하게 만든다. 체크리스트는
plan/review 대체물이 아니라, 사용자 지적사항을 놓치지 않게 하는 짧은 live control
surface 다.

## 활성 조건

다음 중 하나면 체크리스트를 만들거나 갱신한다.

- 사용자가 문제점이 흐려질까 봐 우려한다.
- 작업이 여러 제품버그, 도구, agent, repo, release 를 걸친다.
- 여러 검증 loop 또는 다음 세션까지 이어질 수 있다.
- monitor/heartbeat, 긴 PR loop, cross-agent handoff 가 있다.
- SFS 자체 또는 project-wide policy 를 바꾼다.

## 위치

- 현재 프로젝트에 `llm-wiki/` 가 있고 durable product knowledge 라면 작업 중에는
  `llm-wiki/tmp-<slug>-checklist.md` 를 쓰고, 완료 후 관련 wiki map 으로 접는다.
- 해당 프로젝트 wiki 를 건드리면 안 되면 사용자가 지정한 SFS product-management
  wiki 또는 현재 sprint artifact 를 쓴다.
- wiki 가 없으면 현재 sprint workbench artifact 를 쓴다.

## 체크리스트 규칙

- 각 item 은 `[ ]` 로 시작하고, 처리 중 `[~]`, evidence 연결 후 `[x]` 로 바꾼다.
- audit 후, edit 전, test 후, review 후, release 후, final 전 같은 자연 경계에서
  상태를 갱신한다.
- transcript 나 raw secret 이 아니라 evidence path/command 를 남긴다.
- 새 defect 를 발견하면 chat memory 에 맡기지 말고 즉시 item 으로 추가한다.

긴 컨텍스트 sprint 가 checklist 를 썼는데 open item 을 최종 evidence 와 reconcile 하지
못하면 Gate 6 는 partial 이다.
