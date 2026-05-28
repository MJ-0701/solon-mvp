---
doc_id: solon-product-methodology-7-step
title: "Methodology — 7-step flow + Gate 1~7 표기"
visibility: oss-public
doc_type: maintenance-doc
language: ko
updated: 2026-05-28
summary: "7-step flow summary applied even to this repo's own development. Gate display labels are 1~7; new CLI examples use --gate 6 style."
load_when: "Read for a quick refresher on the 7-step / Gate label convention. Deeper policy lives in routed context (kernel.md, commands/*.md, policies/*.md)."
---

# Methodology — 7-step flow

본 문서는 0.7.2 이전 CLAUDE.md 의 § 7-step flow 요약 섹션을 떼어내 분리한
maintenance doc 이다. 본 repo 자체 개발에도 동일 7-step 이 적용된다. routed
context 가 SSoT 이고 (`kernel.md`, `commands/*.md`, `policies/*.md`), 본
문서는 빠른 참조용 요약이다.

## 7-step 요약

1. **CEO 요구사항 정리** — Gate 2 (Brainstorm)
2. **CEO plan** — Gate 3 (Plan)
3. **CTO Generator ↔ CPO Evaluator sprint contract**
4. **`/sfs implement` 로 CTO 구현** — Gate 4 (Design/Entry) — 실제 코드 +
   `implement.md` / `log.md` evidence
5. **CPO review** — Gate 6 (Review)
6. **CTO review 확인 + 사용자 최종 통과**
7. **회고 / 문서화**

## Gate 표기 규약

- Solon report 에서는 **Gate 1~7 표시**를 쓴다 (Intake / Brainstorm / Plan /
  Design / Handoff / Review / Retro).
- 새 CLI 예시는 **`--gate 6`** 처럼 1~7 숫자를 쓴다.
- 내부 id 는 `G-1 / G0 / G1 / G2 / G3 / G4 / G5` 로 7-display 와 매핑되어
  있다 (`templates/.sfs-local-template/scripts/sfs-common.sh` 의
  `sfs_gate_display_label`).

## Signal vs hard block

Gate 는 all signal-only (ALT-INV-3 never-hard-block). 단 CPO review 자체는
sprint flow 의 필수 단계이며, review executor / tool 은 Codex / Gemini /
Claude / custom 중 선택 가능하다. `/sfs review` 는 artifact acceptance
review 이고, code review 는 자동 또는 명시 `code` lens 일 때만 적용한다.
Production open 을 수반하면 Release Readiness evidence (secret / auth /
data / monitoring / rollback / cost) 를 review 또는 retro-light 에 남긴다.

## 6본부 always-on

7-step 과 직교하는 축으로, 6 division (strategy-pm / dev / QA / design /
infra / taxonomy) 이 brainstorm 부터 Gate 6 까지 *항상* 개념적 sub-agent 로
개입한다. `.sfs-local/divisions.yaml` 의 `activation_state` 는 *깊이* 만
제어하지 참여 여부를 제어하지 않는다.

상세 규약: [`policies/six-division-council.md`](policies/six-division-council.md).

## Routed context SSoT

본 문서는 빠른 참조이고, 실제 SSoT 는 routed context 다:

- `sfs context cat kernel`
- `sfs context cat index`
- `sfs context cat commands/<name>`
- `sfs context cat policies/<name>`
- `sfs context list` (0.7.1+) — slug 색인 출력
