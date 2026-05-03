---
phase: plan
gate_id: G1
sprint_id: "0-6-0-product-spec"
goal: "0.6.0-product spec — storage architecture redesign + SFS identity codification + Deep Module 설계 framework"
visibility: raw-internal
created_at: 2026-05-03T19:55:00+09:00
last_touched_at: 2026-05-03T21:55:00+09:00
status: ready-for-implement   # Codex Round 4 PASS LOCKED 2026-05-03T21:10 KST. G2 implement 진입 = user 명시 명령 후 (no-auto-advance, CLAUDE.md §1.3). G2 EXECUTED 21:30 / G6 PASS LOCKED 21:55 (Stage 1 claude PASS-with-flags + Stage 2 codex PASS 정정 + Stage 3 gemini ALL PASS + user CEO ruling).
ac6_contract_backstamp:
  date: 2026-05-03T21:55:00+09:00
  trigger: "Codex Stage 2 G6 PARTIAL → user CEO ruling: '비지니스 모델 = later track, 비지니스 기능 얘기 꺼내기 전까지 공식적으로 OSS-PUBLIC' → AC6 contract clarification."
  resolution: "AC6 verify scope = frontmatter/classification 기준만. spec body 의 user-explicit restricted visibility 옵션 설명 (business-only literal 등장) 은 허용. business-only 운영 정책 = later track."
  rationale: "현재 product 우선순위 = 기능 + 아키텍쳐 + 제품 안정성. 비지니스 모델 / business-only visibility 운영 정책 = user 가 명시적으로 꺼내기 전까지 default = oss-public 으로 고정."
input_brainstorm: "sprints/0-6-0-product-spec/brainstorm.md (G0, ready-for-plan, 7/7 axes locked)"
release_split:
  proposal: "soft split — R1~R5 모두 0.6.0 spec 에 포함, implement sprint 만 0.6.0/0.6.1 으로 분할"
  user_final_decision: "soft split APPROVED 2026-05-03 KST"
visibility_default: "oss-public (4 신규 spec 모두). business-only 은 user 가 명시적으로 지정할 때만."
runtime_split:
  default: "current runtime (single-runtime)"
  rationale: "보통 사용자는 claude OR codex OR gemini 단일 사용. 3-runtime 병렬은 outlier. 따라서 spec 산출물은 runtime-agnostic."
  self_validation_prevention: "다른 instance/conversation/session 으로 충분 (반드시 cross-runtime 필수 X)"
  cross_runtime_override: "user-explicit only (e.g. '이번엔 codex 로 evaluate')"
harness_reference:
  url: "https://claude.com/ko-kr/blog/harnessing-claudes-intelligence"
  summary_blog_attribution: "Anthropic harness-assumption reference: '하네스 = 모델이 혼자 할 수 없는 것을 가정' 메타 철학. 모델 발전 시 가정이 낡아져 재점검 필요. (정확 인용 ≤15 단어 가드, 직접 인용 X)"
  summary_sfs_local_analogy: "SFS 의 CEO (brainstorm/plan) / CTO (generator) / CPO (evaluator) 3-role 구조는 SFS 자체의 design 이며, 위 harness-assumption 메타 철학과 정합한다는 SFS-local analogy. 본 mapping 자체를 blog 출처로 attribute 하지 않음."
  use: "R1 SFS-PHILOSOPHY.md 의 6 철학 codification 시 (a) blog harness-assumption 메타 철학 cross-ref + URL 명시, (b) SFS 3-role 매핑은 'SFS-local analogy' 로 명시 분리. 직접 인용 X (저작권 ≤15 단어 가드)."
session: "claude-cowork:elegant-hopeful-maxwell"
codex_cross_instance_verdict_received:
  round_2: "2026-05-03T20:30+09:00 KST — PARTIAL (3 fix: AC8 inclusion, AC7 relabel, attribution split). fixes applied 20:35."
  round_3: "2026-05-03T20:50+09:00 KST — PARTIAL (3 follow-up: §4 stale self-check, §5 fail criteria AC8 hard fail, §6 historical literal phrase). fixes applied 20:55."
  round_4: "2026-05-03T21:10+09:00 KST — **PASS LOCKED**. Round 3 fixes 정합성 확인 + Round 2 잔존 inconsistency 부재 + AC7 sub-check ↔ §4 self-check contract 정합. Gate 3 (Plan) ready for G2 implement subject to no-auto-advance rule."
---

# Plan — 0.6.0-product spec

> Sprint **G1 — Plan Gate** 산출물. brainstorm.md (G0) 의 7/7 lock 결정을 입력으로 받아 측정 가능한 sprint contract 를 정의한다.
> 입력 기준: `sprints/0-6-0-product-spec/brainstorm.md` (G0, status=ready-for-plan).
> SSoT: `05-gate-framework.md §5.1` Gate 매트릭스.

---

## §1. 요구사항 (Requirements)

본 sprint 는 **docset-design sprint**. 산출물 = 5 spec 문서 + (선택) 0.6.0/0.6.1 release split 결정. 실 코드 / script 는 **plan 산출물이 아님** (별도 implement sprint 에서 처리).

- [ ] **R1 — SFS-PHILOSOPHY.md SSoT 작성**: 6 철학 (Grill Me / Ubiquitous Language / TDD-no-overtake / Deep Module / Gray Box / Daily System Design) 을 one-screen 으로 codify. visibility=oss-public, project root, ≤200 line.
- [ ] **R2 — storage-architecture-spec.md 작성**: Layer 1 영구 (`docs/<domain>/<sub>/<feat>/`) + Layer 2 작업 히스토리 (`.solon/sprints/<S-id>/<feat>/`) hybrid co-location, archive 브랜치 + 미래 S3, N:M sprint × feature mapping, 폴더 격리 + `sprint.yml` shared file + pre-merge hook (lock layer **명시적 reject** 포함). file path schema 명시.
- [ ] **R3 — migrate-artifacts-spec.md 작성**: `sfs migrate-artifacts --apply` 의 2-pass propose-accept flow. pass 1 default action 알고리즘 (`report.md` 존재→archive auto, 부재→AI 가 user 암묵지 (decisions / events.jsonl / raw 메모) 꺼내 질문). reject = 파일 단위 (sprint 전체 영향 시 sprint escalate). rollback = git revert (pre-push local revert).
- [ ] **R4 — improve-codebase-architecture-spec.md 작성**: Deep Module 정제의 정적 + AI + interactive 3-pass flow. **두 surface 동시 명세**: (a) `sfs implement --change-deep` 옵션 (implement gate 안 자동 감지 + 반자동 승인, force-on power-user flag), (b) `sfs improve-deep-modules` standalone subcommand (legacy 정제 trigger). 도메인 사이즈 자동 감지 algo 의 input/output 계약.
- [ ] **R5 — model-profiles.yaml ↔ SFS-PHILOSOPHY.md cross-ref 정의**: SFS-PHILOSOPHY.md "Deep Module" 섹션이 의미 layer 만 (interface = C-Level / 구현 = worker / 검증 = evaluator) 명시. 실 tier mapping SSoT = `model-profiles.yaml` (G-ref-γ). validator 도메인 escalation depth = `divisions.yaml` 위임 (G-β). model-profiles.yaml schema bump 없음.
- [x] **R6 — release split 결정 (CEO call)** ✅ **soft split APPROVED** (2026-05-03 KST). R1~R5 모두 0.6.0 spec 에 포함. implement sprint 만 0.6.0 (R1+R2+R3+R5 ship) / 0.6.1 (R4 ship) 으로 분리 가능. spec 자체는 본 sprint 에 통합.

- [ ] **R7 — Harness-assumption reference + SFS-local CEO/CTO/CPO analogy**: R1 SFS-PHILOSOPHY.md 작성 시 (a) Anthropic blog (`https://claude.com/ko-kr/blog/harnessing-claudes-intelligence`) 의 **harness-assumption 메타 철학** ("하네스 = 모델이 혼자 할 수 없는 것을 가정", 모델 발전 시 가정 재점검 필요) 을 cross-ref. URL 명시 + 직접 인용 ≤15 단어 가드. (b) **SFS-local analogy** 로서 CEO (brainstorm/plan) + CTO (generator) + CPO (evaluator) 3-role 구조가 위 메타 철학과 정합함을 명시. **단 mapping 자체를 blog 출처로 attribute 금지** — SFS 자체의 design 임을 분명히 표기. 메타 철학을 6 철학 6번 ("매일 system 설계") 의 sub-context 로 통합.

## §2. Acceptance Criteria (AC, 측정 가능, binary)

각 R 에 대응하는 binary AC + verify-by 명시. "되면 안 되는 것" (anti-AC) 도 포함.

- [ ] **AC1**: `SFS-PHILOSOPHY.md` 가 project root 에 신설되고 6 철학 6 항목 모두 (Grill Me / Ubiquitous Language / TDD-no-overtake / Deep Module / Gray Box / Daily System Design) 가 명시됨. — verify by `grep -c "^## §" SFS-PHILOSOPHY.md` ≥ 6 + line count ≤ 200 + visibility frontmatter `oss-public`.
  - **anti-AC1**: SSoT 이중화 (CLAUDE.md §1.x 에 6 철학 본문 복제 금지 — link 만 허용). verify by `grep "Grill Me" CLAUDE.md` 결과가 1-line summary 형식이고 본문 inline 아님.
- [ ] **AC2**: `storage-architecture-spec.md` 가 다음 7 요소 모두 file path schema 로 명시함 — Layer 1 / Layer 2 / archive branch / co-location pattern / N:M mapping example / `sprint.yml` shared file scope / pre-merge hook 검증 대상 list. **lock layer 명시적 reject 문구 포함** (사용자 round 1 결정 trace). — verify by 7-item checklist grep PASS.
  - **anti-AC2**: 도메인 특화 path (`admin-page` / `saas` 등) hardcoding 금지. verify by `grep -E "(admin|saas|customer-portal)" storage-architecture-spec.md` empty.
- [ ] **AC3**: `migrate-artifacts-spec.md` 가 pass 1 default action 알고리즘 + pass 2 file-level review + reject granularity (file / sprint-escalate) + rollback (git revert) 4 항목 step-by-step 명세. — verify by 4-item checklist grep PASS + algorithm pseudo-code block 존재 (` ```pseudo` or ` ```python` fenced).
- [ ] **AC4**: `improve-codebase-architecture-spec.md` 가 (a) implement gate 자동 감지 flow + (b) `sfs implement --change-deep` force-on flag + (c) `sfs improve-deep-modules` standalone subcommand 3 surface 모두 명세. 정적 분석 input/output contract 명시 (정적 분석 언어 scope = bash + markdown + YAML 우선, 추가 언어는 0.6.x patch). — verify by 3-surface checklist + I/O contract block 존재.
- [ ] **AC5**: `SFS-PHILOSOPHY.md` 의 "Deep Module" 섹션이 1-line "구현 = `execution_standard` tier, 정확 mapping 은 `model-profiles.yaml`" 만 cross-ref. tier mapping 표 본문 복제 금지. validator 도메인 escalation 은 `divisions.yaml` 위임 명시. — verify by SFS-PHILOSOPHY.md grep `model-profiles.yaml` ≥1 + tier 표 grep 결과 0 + `divisions.yaml` reference 1+.
- [ ] **AC6**: 4 신규 spec 문서 모두 frontmatter `visibility: oss-public` (default APPROVED). business-only override 는 user 가 명시적으로 지정할 때만. — **verify scope (post-Codex Stage 2 + CEO ruling backstamp 2026-05-03T21:55 KST)**: (a) 각 파일 frontmatter `visibility: oss-public` 존재 + (b) `.visibility-rules.yaml` 충돌 없음. **본문 grep 은 검증 대상 아님** — spec body 가 user-explicit restricted visibility 옵션을 *설명* 하는 맥락에서 `business-only` literal 이 등장하는 것은 허용한다 (예: storage-architecture-spec.md L44 / migrate-artifacts-spec.md L118 의 override 옵션 설명). business-only 운영 정책 자체는 later track (CEO ruling: "비지니스 기능 얘기 꺼내기 전까지 공식적으로 OSS-PUBLIC").
- [ ] **AC8 (R7 추가, post-Codex reword)**: R1 SFS-PHILOSOPHY.md 가 (a) Anthropic harness blog URL (`https://claude.com/ko-kr/blog/harnessing-claudes-intelligence`) 을 **harness-assumption 메타 철학 출처** 로 명시 + (b) SFS 의 CEO/CTO/CPO 3-role 구조가 그 메타 철학과 정합함을 **SFS-local analogy** 로 별도 표기 (mapping 을 blog 출처로 attribute 금지) + (c) 직접 인용 ≤ 15 단어 가드. — verify by `grep "harnessing-claudes-intelligence" SFS-PHILOSOPHY.md` ≥1 + `grep -E "(SFS-local analogy|SFS 자체)" SFS-PHILOSOPHY.md` ≥1 + 인용 길이 ≤ 15 단어.
- [ ] **AC7 — 6 철학 self-application (review_high judgment, post-Codex split into 6 sub-checks)**: 본 sprint 산출물 자체가 6 철학을 위반하지 않음. **deterministic grep 안 됨 — review_high reasoning_tier 가 review.md 에서 binary 판정**. 6 sub-check (각각 review_high 1-pass binary):
    - **AC7.1 Grill Me**: brainstorm hard 모드 grill 라운드 evidence + plan G1 추가 grill evidence 명시. — verify by review.md 에서 binary.
    - **AC7.2 Ubiquitous Language**: 핵심 용어 (Layer 1/2 / archive branch / sprint.yml / runtime-agnostic / harness-assumption / SFS-local analogy) 가 plan + brainstorm 일관 사용. — verify by review.md grep + binary.
    - **AC7.3 TDD-no-overtake**: AC8 binary + R1~R7 measurable verify 시그널이 implement 전에 명시. — verify by review.md binary.
    - **AC7.4 Deep Module**: 4 신규 markdown 이 각각 deep module 단위 (shallow split 금지). R5/R7 inline → R1 wider scope yellow-flag 기록. — verify by review.md binary.
    - **AC7.5 Gray Box**: interface 결정 = user lock (brainstorm 7/7 + plan 3 + R7 reword). 구현 detail 은 generator/strategic_high 위임. — verify by review.md binary.
    - **AC7.6 Daily System Design**: 본 sprint 자체 + harness-assumption 메타 철학 cross-ref 가 6번 철학 sub-context 로 통합. — verify by review.md binary.

## §3. 범위 (Scope)

- **In scope (본 sprint = G1 plan + G2~G7 implement/review/retro)**:
  - 5 spec 문서 작성 (R1~R5). 실 markdown file 4 개 (R5 는 R1 inline).
  - R6 release split = **soft split** lock (CEO approved).
  - R7 harness blog cross-ref in R1 SFS-PHILOSOPHY.md.
  - SFS-PHILOSOPHY.md 신설 → CLAUDE.md §1.x link 1 줄 추가.
  - .visibility-rules.yaml 갱신 (4 신규 spec 파일 visibility=oss-public 매핑).
- **Out of scope (다음 sprint / 별도 release)**:
  - 실 storage 마이그레이션 script (= 별 implement sprint, 0.6.0-product release 시 동행).
  - 실 `sfs migrate-artifacts` script 구현.
  - 실 `sfs improve-deep-modules` / `sfs implement --change-deep` script 구현.
  - .solon/ runtime 구조 실제 마이그레이션 (현재 진행 중 sprint 들 보존 위해 spec 만 ship → 다음 release 에서 실행).
  - 0.5.97 dashboard (서스테이닝).
  - MD split queue (§4.B, 우선순위 낮음).
  - release-tooling polish (§4.C).
- **Dependencies**:
  - brainstorm.md 7/7 axes locked (✅ 충족).
  - `model-profiles.yaml` v1.1 (study-note 0.5.88-product) 첨부 검증 완료 (✅ 충족).
  - `divisions.yaml` 가 도메인 단위 SSoT 로 이미 존재 (✅ 충족, project_root/.sfs-local/divisions.yaml).
  - 결정 대기: **R6 release split 0.6.0 vs 0.6.1 비율** = user 최종 콜.

## §4. G1 Gate 자기 점검 (post-Round 3 갱신, 2026-05-03)

- [x] R/AC 가 측정 가능: **AC1~AC6 + AC8 = deterministic** (grep / line-count / frontmatter / fenced-block grep 자동 가능, binary). **AC7 = review_high sub-check judgment** (AC7.1~AC7.6 6 sub-check, deterministic grep 안 됨, evaluator binary 평가).
- [x] 범위가 sprint 1 개 안에서 닫힘: **4 신규 markdown spec** (R5 inline → R1 SFS-PHILOSOPHY.md) + 2 modified file (CLAUDE.md §1.x / .visibility-rules.yaml). 코드 / script 는 out-of-scope.
- [x] 의존성 / 결정 대기 항목이 명시됨: brainstorm 7/7 lock + model-profiles.yaml v1.1 첨부 + divisions.yaml 존재 + R6 release split soft-split lock + R7 harness reference lock — 모두 충족.

> 본 체크리스트 통과 = `/sfs review --gate G1` 진입 조건. user 가 R6 release split 결정 + plan AC 검토 → review.md 에 verdict (pass / partial / fail) 기록 후 G2 implement 진입.

## §5. Sprint Contract (Generator ↔ Evaluator)

역할 흐름: **CEO (= user) → CTO Generator → CPO Evaluator → CTO 구현 → CPO 리뷰 → CTO rework/final confirm → retro**.

- **CEO (user) 요구사항/plan 결정**:
  - **문제 정의**: SFS 6 철학 / Deep Module 설계 / storage architecture / N:M sprint×feature mapping 이 implicit 으로 흩어져 있음. SSoT 화 + spec codify 필요.
  - **최종 목표**: 0.6.0-product release 가능한 5 spec 문서 + (선택) 0.6.1 follow-up 분리.
  - **이번 sprint 에서 버릴 것**: 실 코드 / script 구현. dashboard / MD split / release-tooling polish.

- **CTO Generator 가 만들 것**:
  - **persona**: `.sfs-local/personas/cto-generator.md`
  - **reasoning_tier**: `strategic_high` (architecture / public contract — model-profiles.yaml 정합)
  - **runtime**: **default = current runtime** (single-runtime). 보통 사용자는 claude OR codex OR gemini 단일 사용 — 본 spec 산출물은 **runtime-agnostic** 으로 작성 (특정 runtime 가정 금지). model profile source = consumer project 의 `.sfs-local/model-profiles.yaml`.
  - **본 cowork 세션 fact-only**: claude (단 spec 본문에 leak 금지)
  - **policy fallback**: current_model (user 가 model 설정 안 했을 때) → solon_recommended (user explicit 후)
  - **implementation worker persona**: `.sfs-local/personas/implementation-worker.md` (본 sprint 는 architecture-grade — strategic_high 가 직접 작성, worker 위임 X)
  - **harness 메타 철학 정합**: 본 generator 자체가 "모델이 혼자 할 수 없는 것을 가정" 의 instance — Opus 4.7 / GPT-5.5 / Gemini-high 시대에는 sprint 분해 강도 약화 가능 (Anthropic blog: Opus 4.6 출시 후 sprint 구조 제거 사례). 단 본 sprint = docset-design 으로 evaluator 검증이 여전히 유효 (모델 단독 self-validation 회피).
  - **산출물 (5 markdown 파일)**:
    1. `SFS-PHILOSOPHY.md` (project root, oss-public, ≤200 line)
    2. `2026-04-19-sfs-v0.4/storage-architecture-spec.md` (visibility = oss-public 권장, line cap soft 400)
    3. `2026-04-19-sfs-v0.4/migrate-artifacts-spec.md` (visibility = oss-public 권장, line cap soft 300)
    4. `2026-04-19-sfs-v0.4/improve-codebase-architecture-spec.md` (visibility = oss-public 권장, line cap soft 400)
    5. (model-profiles cross-ref 는 R1 안에 inline + `divisions.yaml` reference 만 — 별도 파일 안 만듦)
  - **변경 파일/모듈**:
    - 신규: 위 4 markdown.
    - 수정: `2026-04-19-sfs-v0.4/CLAUDE.md` §1.x 1-line link 추가 (≤200 line cap 유지). `.visibility-rules.yaml` 4 신규 파일 매핑 추가.
  - **구현하지 않을 것**: 실 script / hook / runtime 마이그레이션. 0.6.0 release cut 자체.

- **CPO Evaluator 가 검증할 것**:
  - **persona**: `.sfs-local/personas/cpo-evaluator.md`
  - **reasoning_tier**: `review_high`
  - **runtime**: **default = current runtime** (single-runtime 정합). cross-runtime evaluator 는 user-explicit override only (e.g. user 가 "이번엔 codex 로 evaluate" 발화 시).
  - **self-validation 방지 mechanism**: 다른 instance / conversation / session 으로 충분 — 반드시 cross-runtime 필수 X. (claude generator → claude evaluator 도 OK, 단 별 instance/conversation 이어야 model-profiles.yaml `cannot: approve own work` 정합).
  - **AC 검증 방법** (post-Codex reorder, AC1~AC8 모두 명시):
    - **AC1~AC6 + AC8**: deterministic grep / line-count / frontmatter / fenced-block grep 자동 가능 (binary).
    - **AC7 (6 철학 self-application, 6 sub-checks)**: review_high reasoning_tier 가 review.md 에서 1-pass 판정 — **deterministic grep 안 됨**. AC7.1~AC7.6 sub-check 별 binary 판정 (review_high judgment).
  - **회귀/위험 체크**:
    - 기존 sprint workbench 진행 중인 것 (즉 본 sprint 자체) 의 .sfs-local/sprints/<S-id>/ 가 새 storage spec 으로 깨지지 않음 — out-of-scope (실 마이그 다음 sprint).
    - CLAUDE.md ≤200 line cap 유지 (§1.14).
    - oss-public 산출물에 사용자 raw 메모 / 도메인 특화 키워드 누출 없음.
  - **통과/부분통과/실패 기준** (post-Round 3 AC8 hard failure 추가):
    - **pass**: AC1~AC8 모두 PASS (AC7 = AC7.1~AC7.6 6 sub-check 전부 PASS).
    - **partial**: AC7 sub-check 단일 fail (1 cycle CTO 부분 rework) OR AC8 minor wording fix (저작권 가드 ≤15 단어 인용 위반 시 reword 등).
    - **fail**: AC1~AC6 중 하나라도 fail OR **AC8 hard failure** (예: blog attribution 잔존 위반 / 직접 인용 >15 단어 / SSoT 이중화) OR plan §3 scope 위반 OR AC7 multiple sub-checks fail.

- **CTO ↔ CPO 재작업 계약**:
  - CPO `pass`: 최종 통과 + retro 진입 (G7).
  - CPO `partial`: 지정된 spec 문서만 CTO 재작성 후 재리뷰 (1 cycle 만 허용 — 2 회 partial 시 plan 으로 escalate, CLAUDE.md §1.7 + model-profiles.yaml execution_standard.escalate_when "same test/review finding fails twice").
  - CPO `fail`: brainstorm 으로 escalate (R 정의 자체 재검토) 또는 plan §3 scope 재조정.

- **사용자 최종 결정 (모두 LOCKED 2026-05-03 KST)**:
  - ✅ **R6 release split**: **soft split APPROVED**. R1~R5 spec 통합 0.6.0 sprint. implement sprint 만 0.6.0 (R1+R2+R3+R5+R7) / 0.6.1 (R4) 으로 분리 가능.
  - ✅ **4 신규 spec visibility**: **oss-public default APPROVED**. business-only 은 user 가 명시적으로 지정할 때만 (당분간 없음).
  - ✅ **runtime split**: **default = current runtime** (single-runtime). spec 산출물 runtime-agnostic. self-validation 방지는 instance/conversation 분리로 충분. cross-runtime evaluator 는 user-explicit override only.

---

## §6. Plan Self-Note (CTO 메모) + Harness Engineering Reference

본 plan 은 brainstorm.md §6 Plan Seed (Locked input 7 항목) 의 직접 expansion. 새로운 결정 추가 없음 — brainstorm 단계에서 7/7 lock 된 것을 R/AC/Contract 형태로 변환했다. plan G1 단계에서 user 가 추가 결정 3 건 (R6 soft split / visibility oss-public default / runtime current-runtime default) + 1 신규 R (R7 harness blog cross-ref in R1) lock.

### Harness-Assumption Reference + SFS-Local Analogy (post-Round 3 neutralized, 2026-05-03)

> 본 섹션은 두 layer 로 분리되어 있다 (Codex round 2 + 3 verdict 정합):
> (a) **blog 출처** = harness-assumption 메타 철학만 (직접 인용 ≤15 단어 가드).
> (b) **SFS-local analogy** = CEO/CTO/CPO 3-role 매핑은 SFS 자체의 design.
>
> **Round 2/3 verdict 의 historical detail (rationale + 원본 wording 이 왜 reword 됐는가)** 는 본 plan.md 에 보존하지 않는다 — `review.md §5.2 (Round 2)` + `§7.2 (CTO 응답)` 의 review trace 가 SSoT.

**(a) Anthropic harness-assumption reference (blog 출처)**

source: <https://claude.com/ko-kr/blog/harnessing-claudes-intelligence>

의미 layer paraphrase (저작권 가드 — 직접 인용 ≤15 단어):

- 하네스의 모든 구성 요소는 "모델이 혼자 할 수 없는 것" 을 가정한 협업 구조라는 메타 철학.
- 모델 발전 시 그 가정이 낡아지므로 **모델 업데이트마다 하네스를 재점검** 해야 한다.
- 모델 강화 시 sprint 분해 강도 약화 가능 (Opus 4.6 사례 등 — blog 본문 참조).
- "하네스 조합 공간이 이동" — AI 엔지니어 역할 = 다음 noble combination 탐색.

위 paraphrase 는 blog 의 메타 철학 만 의미 layer 로 옮긴 것. 본 plan 은 어떤 specific 3-role / agent terminology 도 blog 출처로 attribute 하지 않는다 (Codex round 2 + 3 finding 정합).

**(b) SFS-local analogy — CEO/CTO/CPO 3-role 구조와의 정합**

본 매핑은 **SFS 자체의 design** 이며, 위 (a) harness-assumption 메타 철학과 정합 / 영감 받음 — 단 blog 의 어떤 specific term 의 1:1 paraphrase 가 아님:

| SFS-Local 3-Role (SFS 자체 design) | 책임 |
|---|---|
| CEO | brainstorm G0 + plan G1 (interface 결정 = user) |
| CTO Generator | implement G2~G4 (구현 = AI worker, model-profiles.yaml `execution_standard` tier) |
| CPO Evaluator | review G5~G6 (검증 = `review_high` tier, `cannot: approve own work`) |
| Sprint Contract | Plan §5 (Generator ↔ Evaluator 선 협상) |
| 6 철학 6번 ("매일 system 설계") | 모델 발전 시 SFS 자체 재점검 cycle (= harness-assumption 정합) |

**R1 SFS-PHILOSOPHY.md 작성 시 사용**: 6 철학 codification 후 1 섹션 "External References" 추가. (a) URL + harness-assumption 메타 철학 1-line summary (blog 출처) + (b) "SFS 의 CEO/CTO/CPO 3-role 구조는 SFS 자체 design 이며 위 메타 철학과 정합 (SFS-local analogy)" 명시. **Mapping 자체를 blog 출처로 attribute 금지**. 직접 인용 ≤ 15 단어 가드.

### G1 Self-Check Recap (§4 final state, post-Round 3)

- [x] R/AC measurable: AC1~AC6 + AC8 deterministic; AC7 review_high sub-check judgment (AC7.1~AC7.6).
- [x] Sprint 1 안에서 닫힘: 4 신규 markdown + 2 수정 (CLAUDE.md §1.x / .visibility-rules.yaml).
- [x] Dependency / 결정 대기 모두 명시 + lock 완료 (3 user decisions all approved + R6 + R7).

**status: ready-for-implement** ✅ (Codex Round 4 PASS LOCKED 2026-05-03T21:10 KST). **다음 1 step** = user 명시 G2 implement 명령 (예: "implement 가자" / "G2"). 자동 G2 승급 금지 (CLAUDE.md §1.3 + harness 메타 철학 + Codex Round 4 verdict "subject to no-auto-advance rule" 명시).
