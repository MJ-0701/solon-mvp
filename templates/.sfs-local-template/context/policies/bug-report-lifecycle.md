---
id: sfs-policy-bug-report-lifecycle
summary: Official SFS-product bug lifecycle — channel, report template, user confirm gate, dev-first|hotfix fix routing.
load_when: ["bug-report", "bug lifecycle", "버그 lifecycle", "issue triage", "bug fix flow", "report-bug"]
---

# Bug-Report Lifecycle (SFS-product)

`commands/report-bug.md` 보고 primitive 를 받쳐주는 lifecycle SSoT.

## 공식 채널
GitHub Issues `MJ-0701/solon-product` + label `bug`. consumer 가 누구든 SFS 제품 결함은 여기로만.

## lifecycle states
detected → filed(gh,`bug`) → confirmed(user gate) → in-fix(dev-first|hotfix) → shipped(close w/ version).

## 보고 템플릿 (이슈 본문)
- **증상** — 무엇이 어떻게 잘못되나, 1~3줄.
- **실제 사례** — consumer/sfs version/runtime + 충돌·오작동 구체 인용(파일·라인).
- **근본 원인** — 어느 context/CLI/config 의 규칙 부재/모순인가.
- **제안** — 택1 가능한 fix 방향.
- **환경** — sfs version, model-profiles version, runtime, consumer repo 이름.
(private docset 경로/파일명/내용 유출 금지 — repo 이름·changelog 최소맥락만.)

## confirm gate (필수)
- 제출 직후 agent 가 이슈 URL+요약 제시 → 사용자 확정. 확정 전 fix 진입 금지(#3 정신).

## fix routing (둘 다 명시)
1. 기본 = dev-first(R-D1): dev staging 수정 → release-cut → stable. CHANGELOG/RELEASE-NOTES 이슈 참조, `Fixes #N` close.
2. 예외 = critical stable hotfix: stable 발견 critical 만 stable 직접 + 같은 사이클 dev back-port(`sync(stable): <sha>`). 그 외 전부 1번.
- fix 본체 = 정규 lifecycle + worker-tiering 기본 + #3 guard.

## conflict-surface 상속
보고/수정 중 project-local 정책 ↔ SFS default 충돌이 드러나면 진입 전 surface(#3,
`policies/user-override-precedence.md`). silent 금지.

## 능동 탐지 연결
탐지층 flowcheck(`policies/flow-conformance-postflight.md`)이 divergence 를 제품버그로 판정하면
report-bug 본문을 prefill 하고 confirm gate 로 자동 연결한다(detection → report → confirm → fix).

## 비목표
- consumer 자기 코드 버그는 대상 아님(각 프로젝트 트래커).
- 기능 제안/RFC 는 `bug` 아님 — 별도 라벨/discussion.
