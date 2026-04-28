---
doc_id: sfs-v0.4-review-2026-04-28-foundation-structural-defects
title: "2026-04-28 Review — 기초공사 구조 결함 정리"
status: draft
created: 2026-04-28
visibility: raw-internal
source_thread: "Codex user-active conversation"
related_docs:
  - "../../AGENTS.md"
  - "../../README.md"
  - "../../10-phase1-implementation.md"
  - "../../04-pdca-redef.md"
  - "../../05-gate-framework.md"
  - "../templates/plan.md"
  - "../templates/design.md"
  - "../templates/analysis.md"
  - "../templates/report.md"
  - "../schemas/gate-report.schema.yaml"
  - "../schemas/l1-log-event.schema.yaml"
---

# 2026-04-28 Review — 기초공사 구조 결함 정리

## 1. 목적

사용자는 Claude 한도 복구 전까지 "기존 세션 이어달리기"보다 구조적으로 결함이 있는 부분을 찾아 기초 설계를 탄탄하게 하라고 지시했다. 본 리뷰는 그 지시에 따라 확인한 foundation-level 결함과 수정 내용을 기록한다.

## 2. 결함 A — docset AGENTS.md target missing

### 발견

루트 `AGENTS.md` 는 `2026-04-19-sfs-v0.4/AGENTS.md` 를 즉시 읽으라고 지시한다. 하지만 실제 파일은 없고 `CLAUDE.md` 만 존재했다.

### 왜 구조 결함인가

- Codex/Cowork auto-load 는 root `AGENTS.md` 를 신뢰한다.
- target 파일이 없으면 agent 는 첫 진입에서 규칙 읽기 실패를 경험한다.
- 실패 후 임의로 `CLAUDE.md` 를 찾아 읽는 것은 사람/agent 의 추론에 의존하므로 bootstrap 이 아니다.

### 수정

`2026-04-19-sfs-v0.4/AGENTS.md` 를 신설했다. 이 파일은 규칙을 복제하지 않고 `CLAUDE.md` 로 redirect 하는 tiny shim 이다. 루트 `AGENTS.md` 도 같은 구조에 맞춰 "docset shim = AGENTS, 실제 SSoT = CLAUDE" 로 문구를 정정했다.

### 왜 합리적인가

- root stub 의 기존 계약을 깨지 않는다.
- `CLAUDE.md` 를 계속 실제 SSoT 로 유지한다.
- AGENTS/CLAUDE 이중 SSoT 를 만들지 않는다.
- 다음 Codex/Cowork 세션의 entry failure 를 제거한다.

## 3. 결함 B — outline 과 본문 SSoT 의 gate/artifact drift

### 발견

2026-04-28 startup team-agent flow 리뷰 후 v0.4 outline 은 다음 개념을 갖게 됐다.

- 13-step full form
- Artifact Contract First
- G0 Brainstorm
- Release Readiness Gate
- Continuous Documentation Ledger

하지만 본문 SSoT 인 `04-pdca-redef.md` 와 `05-gate-framework.md` 는 이 중 일부를 암시만 하거나, `G-1 + G1~G5` 중심으로만 제목/스키마가 고정돼 있었다.

### 왜 구조 결함인가

- Claude agent 는 outline 보다 본문 SSoT 를 우선 읽을 가능성이 높다.
- outline 과 본문이 다르면 agent 는 "어느 쪽이 진짜냐"를 스스로 결정하려 한다.
- 스키마 enum 이 gate vocabulary 를 따라가지 못하면 나중에 로그/validator 구현에서 `RELEASE` 같은 값이 invalid 가 된다.

### 수정

다음을 수정했다.

- `04-pdca-redef.md`: 4.0 Startup Team-Agent Flow + Artifact Contract addendum 추가
- `05-gate-framework.md`: 제목/TOC/gate matrix/evaluator matrix/failure matrix 에 G0 + Release Readiness 반영
- `05-gate-framework.md`: §5.12 Release Readiness Gate 신설
- `appendix/schemas/gate-report.schema.yaml`: `gate_id` enum 에 `G-1`, `G0`, `RELEASE` 추가
- `appendix/schemas/l1-log-event.schema.yaml`: `gate_id` enum 에 `RELEASE` 추가

### 왜 합리적인가

- "기획상 좋은 아이디어"를 outline 에만 두지 않고 실행 SSoT 로 승격했다.
- Release Readiness 를 G4 안에 숨기지 않아 QA 품질과 production 운영 준비성을 분리했다.
- schema 가 문서 vocabulary 를 따라가므로 후속 구현에서 false invalid 를 줄인다.
- Phase 1 에서는 heavy command 추가 없이 checklist 로 시작할 수 있어 과투자를 막는다.

## 4. 결함 C — entry README / Phase 1 plan 의 r3 drift

### 발견

`README.md` 는 docset version 을 `v0.4-r3` 로 유지하고 있었고, gate 집합도 `G-1 + G1~G5` 중심으로 설명했다. `10-phase1-implementation.md` 는 L3 notion default, Phase 1 필수 조건 5개/6개 표현 불일치, Release Readiness 부재가 남아 있었다.

### 왜 구조 결함인가

- README 는 Claude/Codex 가 가장 먼저 읽는 제품 overview 다.
- §10 은 구현 계획 SSoT 역할을 하므로, 여기서 Release Readiness 와 L3 default 가 어긋나면 실제 구현 agent 가 오래된 계약을 따른다.
- "필수 조건 5개"라고 말하면서 표에는 6개가 있으면 evaluator 가 성공 기준을 임의 해석한다.

### 수정

- `README.md`: v0.4-r4 로 갱신, Foundation Invariants 요약 추가, Gate vocabulary 를 `G-1/G0/G1~G5/RELEASE` 로 정합화, command count 를 13개로 정리.
- `10-phase1-implementation.md`: v0.4-r4 로 갱신, G0/Release Readiness/Artifact Contract references 추가, L3 default 를 `none` 으로 정정, Phase 1 성공 기준을 1~6 필수 + production 시 7 Release Readiness 조건부로 정리.

### 왜 합리적인가

entry 문서와 구현 계획이 같은 vocabulary 를 쓰게 되므로, 후속 agent 가 "README는 r3, 본문은 r4" 같은 충돌을 해석할 필요가 없다. Release Readiness 를 조건부로 둔 것도 합리적이다. Phase 1 dogfooding 자체가 production open 을 항상 의미하지 않기 때문이다.

## 5. 결함 D — MVP 7-step 이 full 설계로 오해될 위험

### 발견

`phase1-mvp-templates/` 는 이미 보정했지만, 실제 배포판 역할의 `solon-mvp-dist/` 는 여전히 "7-step + 4 Gate" 를 전체 방법론처럼 읽힐 수 있었다.

### 왜 구조 결함인가

- MVP dist 는 consumer project 에 설치되는 파일이다.
- 설치된 agent 는 full docset 을 항상 읽지 않는다.
- 따라서 `SFS.md.template` 만 읽고 "Taxonomy/Discovery/Release Readiness 는 없는 설계"라고 해석할 수 있다.

### 수정

`solon-mvp-dist/README.md`, `templates/SFS.md.template`, `CLAUDE.md`, `install.sh`, `CHANGELOG.md` 에 7-step 이 full startup team-agent artifact chain 의 lightweight projection 임을 명시했다. Production open 전 Release Readiness evidence 는 review 또는 retro-light 에 남기도록 보강했다.

### 왜 합리적인가

MVP 의 장점인 속도는 유지하되, 설계의 뼈대를 삭제하지 않는다. "빠르게 굴린다"와 "검증/택소노미/배포 준비를 생략한다"를 분리한 수정이다.

## 6. 결함 E — template 의 artifact contract 부족

### 발견

`appendix/templates/plan.md` 와 `design.md` 는 AC/설계 중심이었고, taxonomy root 를 강제하는 필드가 없었다. `analysis.md` 와 `report.md` 에는 production 전 Release Readiness evidence 를 남길 위치가 없었다.

### 왜 구조 결함인가

- Agent system 에서 문서 template 은 실제 실행의 레일이다.
- 원칙/본문에만 "Taxonomy Is Root" 를 써두고 template 에 필드가 없으면 agent 는 실무 산출물에서 생략한다.
- Release Readiness 도 별도 command 미정 상태라면, 최소한 analysis/report 에 evidence 슬롯이 있어야 한다.

### 수정

- `plan.md`: `artifact_contract` 와 `taxonomy_contract` 섹션 추가, `strategy-pm` 명칭 정합화, G1 checklist 에 taxonomy/infra/security/cost early risk 추가.
- `design.md`: Taxonomy-first rule 추가, taxonomy 본부를 디자인 본부보다 먼저 배치, infra preliminary checklist 추가.
- `analysis.md`: Release Readiness pre-check 섹션 추가.
- `report.md`: Release Readiness 결과 필드/섹션 추가.

### 왜 합리적인가

원칙이 아니라 산출물 칸으로 강제해야 agent 가 빼먹지 않는다. 이 수정은 새 ceremony 를 만들지 않고 기존 artifact 안에 evidence slot 만 추가하므로 MVP 부담도 낮다.

## 7. 남은 구조 리스크

이번 수정은 foundation drift 를 줄였다. 이후 같은 세션에서 추가로 `02-design-principles.md` 와 `phase1-mvp-templates/` 에도 보강을 반영했다. 남은 리스크는 다음과 같다.

1. `/sfs check --release-readiness` 로 흡수할지, `/sfs release` command 를 만들지 아직 결정되지 않았다.
2. GateReport schema 에 release-blocker 전용 필드를 추가할지 아직 결정되지 않았다.
3. `02-design-principles.md` 의 Foundation Invariants 는 아직 비번호 규칙이다. numbered principle 로 승급하려면 INDEX/README/affects 전체 갱신이 필요하다.
4. command registry 는 13 slash commands 로 정합화했지만, Release Readiness 는 아직 command 가 아닌 gate vocabulary 로만 존재한다.

## 8. 다음 권장 작업

1. Release Readiness 를 command 로 노출하는 방식을 결정한다.
2. GateReport schema 에 release-blocker 전용 필드를 추가할지 검토한다.
3. Foundation Invariants 를 numbered principles 로 승급할지 1~2 cycle dogfooding 후 결정한다.

## 9. Claude agent 에게 주는 판단 기준

반박하려면 "문서가 늘어났다"가 아니라 아래 중 어느 계약이 불필요한지 지적해야 한다.

- docset AGENTS redirect 가 불필요한가?
- outline 과 본문 SSoT drift 를 허용해도 되는가?
- G4 와 Release Readiness 를 합쳐도 책임 경계가 흐려지지 않는가?
- schema enum 이 gate vocabulary 를 따라가지 않아도 되는가?
- README/§10 이 오래된 r3 표현을 유지해도 agent onboarding 이 안전한가?
- MVP 7-step 을 full 설계로 오해해도 Taxonomy/Release Readiness 누락이 발생하지 않는가?
- template 에 taxonomy/release evidence 슬롯이 없어도 실제 agent 가 매번 기억으로 보완할 수 있는가?

이 질문에 답하지 않고 "너무 무겁다"는 반박은 기초공사 관점에서는 충분하지 않다.
