---
doc_id: solon-product-policy-six-division-council
title: "6본부 council always-on — 운영 원칙 / cross-link"
visibility: oss-public
doc_type: maintenance-policy
language: ko
updated: 2026-08-26
summary: "Pointer doc for the always-on 6-division council, including the current Tier-B ledger-completeness advisory. The actual SSoT remains the routed context policies."
load_when: "Read when discussing why divisions.yaml activation_state only controls depth, not participation. For the actual prompt-driven contract, load policies/division-subagent-council.md from routed context."
---

# 6본부 council always-on

본 문서는 0.7.2 이전 CLAUDE.md § 배포 원칙 7 의 요약을 떼어내 분리한
maintenance policy doc 이다. **실제 SSoT 는 routed context** 의 다음 두
정책이고, 본 문서는 maintainer-facing 요약 + cross-link 다:

- `templates/.sfs-local-template/context/policies/division-subagent-council.md`
- `templates/.sfs-local-template/context/policies/enterprise-plan-council-pack.md`
  (+ `.ko.md`)

routed 라 consumer agent 가 `sfs context cat policies/division-subagent-council`
로 직접 읽는다.

## 원칙 한 줄

**6 division (strategy-pm / dev / QA / design / infra / taxonomy) 은
brainstorm 부터 Gate 6 까지 *항상* 개념적 sub-agent 로 개입한다.**

`.sfs-local/divisions.yaml` 의 `activation_state` (active / abstract) 는
**깊이** 만 제어한다. 참여 여부를 제어하지 않는다 — abstract 상태도 lens
는 켜져 있어야 한다.

## 어디서 강제되나

1. **템플릿 scaffold** — `templates/.sfs-local-template/sprint-templates/plan.md`
   의 §7과 `review.md`의 §5가 각각 6행 Division Sub-agent Ledger를 만든다.
   plan §7.1/§8의 자산·enterprise council 표도 별도 scaffold 이다. 템플릿의
   리뷰 체크리스트는 사람/agent 검토 계약이며, 그 자체가 기계적 실패는 아니다.
2. **Tier-B healthcheck lint (현재 release 는 advisory)** — active sprint에서
   `implement.md`가 생긴 뒤 `plan.md` §7을, 실제 `result_verdict`가 기록된 뒤
   `review.md` §5를 검사한다. division 이름 뒤의 모든 substantive cell이 빈
   6본부 row를 `sfs healthcheck`가 WARN으로 보고한다. `finding`, `evidence`,
   `asset_candidate`, 명시적 N/A 또는 waiver 중 하나가 있으면 통과한다. 이 lint는
   `say_warn` 전용이라 issue count/exit code를 바꾸지 않으며, relevance나 Gate
   PASS 판단까지 대신하지 않는다.
3. **`enterprise-plan-council-pack.md` 정책** — "Empty six-division
   ceremony is not PASS; each row needs a finding, evidence,
   asset_candidate, waiver, or concrete N/A reason."
4. **0.6.138 enhancement (asset_candidate + domain-knowledge-assets)** —
   council 결과가 재사용 가능한 도메인 자산 후보까지 끌어올리는 단계.
   회의 결과 = 자산 promotion 후보 명세.
5. **회귀 잠금 contract test**:
   - `tests/test-domain-knowledge-assets.sh`
   - `tests/test-enterprise-agent-team-knowledge-packs.sh`
   - `tests/test-division-subagent-continuation-guard.sh`
   - `tests/test-sfs-healthcheck-division-ledger-advisory.sh`

## 6본부 vs parallel worker

6본부 council 은 **개념적 sub-agent** — LLM 의 prompt-driven 행동이지
bash subprocess fork 가 아니다. *실제* parallel worker spawn 은 별도
opt-in (`sfs loop`, sprint-level parallel lane). 둘이 헷갈리지 않게 하는
게 회귀 방지의 핵심.

## 관련 산출물

- `templates/.sfs-local-template/scripts/sfs-division.sh` — `sfs division`
  command (activate/deactivate, activation_state 조정).
- `templates/.sfs-local-template/divisions.yaml` — consumer 측 activation
  state 기본값.
- `templates/.sfs-local-template/sprint-templates/plan.md` — 3개 council
  ledger 테이블 scaffold.
- 본 repo `INTEGRATION-VERIFY-2026-05-28.md` §2 — 0.7.0 시점에 6본부
  council 메커니즘이 실제로 어떻게 작동하는지 sandbox 검증한 결과.
