---
doc_id: solon-product-policy-six-division-council
title: "6본부 council always-on — 운영 원칙 / cross-link"
visibility: oss-public
doc_type: maintenance-policy
language: ko
updated: 2026-05-28
summary: "Pointer doc for the always-on 6-division council. The actual SSoT is the routed context policies; this file is just maintainer-side documentation of the principle."
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

1. **`plan.md` 템플릿 구조** — `templates/.sfs-local-template/sprint-templates/plan.md`
   가 §7 (Division Sub-agent Ledger 6행), §7.1 (Domain Asset Promotion
   Ledger), §8 (Enterprise Plan Council 6행 + risk_flag) 세 개 테이블을
   자동 scaffold 한다. LLM 이 이걸 비우면 §12 리뷰 체크리스트가 실패
   신호를 낸다.
2. **`enterprise-plan-council-pack.md` 정책** — "Empty six-division
   ceremony is not PASS; each row needs a finding, evidence,
   asset_candidate, waiver, or concrete N/A reason."
3. **0.6.138 enhancement (asset_candidate + domain-knowledge-assets)** —
   council 결과가 재사용 가능한 도메인 자산 후보까지 끌어올리는 단계.
   회의 결과 = 자산 promotion 후보 명세.
4. **회귀 잠금 contract test 3개**:
   - `tests/test-domain-knowledge-assets.sh`
   - `tests/test-enterprise-agent-team-knowledge-packs.sh`
   - `tests/test-division-subagent-continuation-guard.sh`

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
