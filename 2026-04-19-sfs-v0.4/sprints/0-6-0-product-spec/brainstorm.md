---
phase: brainstorm
gate_id: G0
sprint_id: "0-6-0-product-spec"
goal: "0.6.0-product spec — storage architecture redesign + SFS identity codification + Deep Module 설계 framework"
visibility: raw-internal
created_at: 2026-05-03T18:55:00+09:00
last_touched_at: 2026-05-03T19:50:00+09:00
status: ready-for-plan
brainstorm_depth: hard
brainstorm_depth_source: explicit
inherited_from: "claude-cowork:determined-focused-galileo (HANDOFF §4.D)"
prior_decisions_resolved: 7   # AS-D1~D6 + AS-Migration (HANDOFF §4.D.1)
deferred_sub_questions: 7     # HANDOFF §4.D.2
grill_round_1_resolved: 4     # Q1, Q2, Q3, Q4
grill_round_2_resolved: 3     # Q5, Q6, Q7 (Q7 = a + b)
all_axes_locked: true
attached_artifacts:
  - "uploaded/model-profiles.yaml (study-note 0.5.88-product, version 1.1, 2026-05-03)"
plan_gate_entry: "user-explicit-only"   # G1 진입은 user 발화 후 (CLAUDE.md §1.3)
---

# Brainstorm — 0.6.0-product spec

> Sprint **G0 — Brainstorm Gate** 산출물 (depth=**hard**).
> 본 sprint 는 docset-design sprint. 산출물은 product code 가 아니라 **spec 문서 묶음** (SFS-PHILOSOPHY.md or CLAUDE.md §1.x 추가 / storage architecture 명세 / Deep Module framework 명세 / `sfs migrate-artifacts` flow / `sfs improve-codebase-architecture` subcommand spec).
> Hard 모드: status=draft 유지. 사용자가 owner 결정을 내려야 plan 으로 넘어간다.

---

## §0. 인계 요약 (이전 세션 → 본 세션)

이전 세션 (`determined-focused-galileo`, 2026-05-03 KST) 에서 user mid-session brain-dump (mobile, afk) 를 통해 **7 결정** 이 일괄 해소되었고, **7 sub-question** 이 본 brainstorm gate 로 위임되었다. 본 §0~§7 은 그 인계 상태를 G0 산출물 형식으로 재구성한다. raw 발화는 §8 Append Log 에 보존.

**해소된 결정 (HANDOFF §4.D.1)** — 재오픈 금지:

| ID | 확정 |
|---|---|
| AS-D1 | (b) Feature 단위 7-Gate cycle |
| AS-D2 | (b) Sprint 단위 retro/report only ("남겨야 될 것만 남긴다") |
| AS-D3 | (C) Hybrid co-location (Google + ADR + 별도 `.solon/` 트랙) |
| AS-D4 | (a) archive 브랜치 + (d) 미래 S3 graduate hybrid |
| AS-D5 | (b) Feature 폴더가 sprint 들 누적 + 병렬 conflict-free 보장 hard requirement |
| AS-D6 | (b) Gate 7 정제 = 반자동 (AI 초안 + user 검토) |
| AS-Migration | 반자동 (AI propose + user accept-per-item) |

---

## §1. Raw Brief / Conversation Notes

**원래 frame** (이전 이전 세션): "0.6.0-product = storage architecture redesign". Layer 1 영구 (`docs/<domain>/<sub>/<feat>/`) + Layer 2 작업 히스토리 (feature branch only, `.solon/sprints/<S-id>/<feat>/`). 머지 시점 제거 + archive 브랜치 보관. 핵심 철학 = "히스토리는 정제되어 영구 문서가 된다" (Gate 7 = 정제 단계).

**user 가 mid-session 으로 발본** (2026-05-03 evening, AS-D1 답변 중에 드러남): 진짜 axis 는 storage 만이 아니다. **SFS 6 철학의 명시적 codification + Deep Module 설계 framework + storage redesign + N:M sprint × feature 매핑 + 신규 subcommand `improve-codebase-architecture-to-deep-modules`** — 이 5 axis 의 통합 release.

**SFS 6 철학 (raw verbatim 발췌)**:

1. 의도가 안맞으면 → **Grill Me** (brainstorm `--hard` / `--normal` 둘 다 의도 안맞으면 계속 심문; `--hard` 는 user 가 놓치고 있는 부분까지 생각하게 만드는 게 핵심).
2. AI 가 장황하면 → **Ubiquitous Language** (Taxonomy 본부 활성화 OR Taxonomy 미활성화 시 DDD/TDD 가 들어가야 하는 이유).
3. 안돌아가면 → **TDD 헤드라이트 추월 X** (안돌아가면 돌아가게 하는 게 먼저, 그러기 위한 TDD).
4. 테스트가 어려우면 → **Deep Module 구조 개선** (shallow 가 아니라 deep 으로).
5. 뇌가 못 따라가면 → **Gray Box 위임**.
6. 매일 system 설계에 투자.

**Deep Module 설계 framework (raw verbatim)**:
- 인터페이스 = 사람이 직접 설계 (`sfs brainstorm` 에서 user 한테 계속 생각하게 하는 이유).
- 구현 = AI 통으로 (구현 agent 모델 따로 설정하는 이유 — 설계가 이미 user + 상위모델로 끝나서 구현 시점 상위모델 불필요).
- 검증 = interface 단위 (단, 도메인에 따라 — 보험/금융/보안 critical 모듈은 안쪽까지 다 검증).
- Shallow module = 복잡성 증가 + AI agent 가 스스로 갇힘 (작은 모듈만 잔뜩 → 탐색 시간 ↑ → context overflow → context rot → 무엇을 하려 했는지 망각).
- Deep module = code 탐색 → 관련 코드 묶기 → testable + 경계 단순.

---

## §2. Problem Space

- **누가 이 문제를 겪는가**:
  - SFS 를 docset 으로 운영하는 본인 (raw 데이터 owner) — 매 sprint 마다 .solon/ tmp 가 누적되고, sprint 간 정제/archive 규율이 implicit.
  - SFS 를 OSS 로 도입하는 신규 사용자 — "SFS 가 뭘 하는 건지" 6 철학이 흩어져 있어 entry barrier 큼.
  - SFS 를 legacy 코드베이스에 도입하려는 사용자 — Deep Module 로 점진 정제할 mechanism 부재.
- **왜 지금 풀어야 하는가**:
  - 0.5.96-product 까지 surface (CLI discovery / 3-CLI 통합) 는 안정. 다음 axis 는 **identity 와 storage 의 정합** — 정체성 명문화 없이 더 쌓으면 SFS 자체가 shallow module 들의 집합으로 부패한다 (철학 4번 자기적용).
  - 7 결정 이미 user 손에서 해소됨 — 추가로 7 sub-question 만 정제하면 spec 가능.
- **기존 방식의 불편함**:
  - SFS 6 철학이 conversation log / sprint retro / cross-ref-audit 에 산재. CLAUDE.md / SFS-PHILOSOPHY.md / user-facing docs 에 single source 없음.
  - storage 가 "everything in `.sfs-local/` + ad-hoc archives/" — sprint × feature N:M 자연 표현 안 됨. 병렬 작업 시 충돌 mechanism 명시 안 됨.
  - Deep Module 은 사용자 머릿속 dogma — 코드 / docset 어디에도 framework 화되지 않음. 신규 사용자 / 신규 agent 가 shallow module 트랩 못 피함.
- **성공하면 어떤 상태가 되는가**:
  - SFS 6 철학이 one-screen 으로 읽히는 SSoT 가 존재 (위치 = §4.D.2 sub-question #6 결정).
  - Storage 가 Layer 1/2 + co-location + .solon/ 트랙 hybrid 로 분리 + N:M 자연 표현 + 병렬 conflict-free.
  - `sfs migrate-artifacts --apply` 가 반자동으로 sprint 자료를 Layer 2 → archive 또는 Layer 1 영구 promote 한다 (AI propose + user accept-per-item).
  - `sfs improve-codebase-architecture --to-deep-modules` 가 신규 / legacy project 양쪽에서 정적 분석 + AI 의견 결합으로 deep module 후보를 제안한다.
  - Interface = user, 구현 = AI, 검증 = interface 단위 — 가 model-profiles.yaml 과 명시적으로 link.

## §3. Constraints / Context

- **기술 제약**:
  - bash 3.2 호환 유지 (기존 .sfs-local/scripts/* 정합).
  - File-backed (DB 없음) — queue / events.jsonl 정합.
  - dev (`solon-mvp-dist/`) → stable cut → Homebrew + Scoop 양채널 (CLAUDE.md §1.13, §1.24).
  - archive 브랜치 = git native (LFS 도입은 D4 sub-question 의 trigger 조건 결정 후).
- **배포/운영 제약**:
  - Visibility tier 3 종 유지 (oss-public / business-only / raw-internal). SFS-PHILOSOPHY.md 는 oss-public 후보, raw .solon/ history 는 raw-internal.
  - Brew + Scoop 양채널 동일 `v<VERSION>` 동시 갱신 의무 (§1.24).
  - 0.6.0 = multi-sprint 가능. 0.6.0 (storage + philosophy + migrate-artifacts) + 0.6.1 (Deep Module subcommand + agent split) 분할 가능 (§4.D.4).
- **시간/비용 제약**:
  - Phase 1 MVP 진행 중 — 본 sprint 가 그 위에 얹혀 진행. release timing 은 user 결정.
  - 매일 system 설계 투자 (철학 6번) — 본 sprint 자체가 그 실천.
- **사용자 역량/학습 맥락**:
  - User 가 owner 인 raw 데이터 docset. user 가 결정하지 않으면 plan 진행 금지 (CLAUDE.md §1.3).
- **아직 모르는 것** (= §4.D.2 sub-question 7 종, §6 으로 escalate).

## §4. Options (axis 별)

각 axis 에 최소 2 옵션. 본 §4 는 §4.D.2 의 7 sub-question 을 옵션화한 것. **결정은 §6/§7 user grill 라운드 후**.

> **Lock 완료 (grill round 1+2, 2026-05-03T19:50 KST)** — 7/7 axes ✅:
> A4 / B3 (default 500 MB warn) / C4 (`sprint.yml` shared, **lock layer 명시적 reject**) / D4 (pass 1 algo + file-level reject sprint-escalate exception) / **E-cmd-γ 둘 다** / **F4-γ defer + future scope = KO+EN bilingual only** / **G-β (validator depth = `divisions.yaml` 위임) + G-ref-γ (의미 layer cross-ref, 실 mapping = model-profiles.yaml SSoT)**.

### Axis A — Feature retro 가 sprint retro 로 흡수되는 mechanism (sub-Q1) ✅ LOCKED → A4

- **A1 자동 압축** at feature close: feature retro.md → sprint retro.md 의 `<feature-name>` 섹션으로 AI 자동 머지. 단점: AS-D2 "남겨야 될 것만 남긴다" 위배 가능 (자동 = 필터 약함).
- **A2 user-confirmed 압축** at feature close: AI propose + user accept (AS-D6 정합). 단점: feature 종료 마다 1 가벼운 결정 1 회.
- **A3 sprint 종료 시점 batch 처리**: feature retro 들은 .solon/ 에 그대로 두고, sprint close 때 한 번에 흡수 + accept. 단점: feature retro 가 누적 시 머지 batch 가 무거움.
- **A4 (β default) hybrid**: feature 마다 AI 가 1-line summary 만 sprint retro 에 append (자동) + sprint close 때 user 가 final accept (반자동). AS-D2 + AS-D6 정합.

### Axis B — Archive 브랜치 비대 임계점 + LFS trigger (sub-Q2) ✅ LOCKED → B3 (default 500 MB warn, 정확 임계점 0.6.x patch 시 재조정)

- **B1 release 별 amend (squash)** 만 사용: 매 release 마다 오래된 sprint 들 squash. trigger 자동 alert = repo size > N MB.
- **B2 git LFS 도입** at threshold: archive branch 에 LFS attribute 적용. trigger = single sprint 단위 > M MB OR 누적 > N GB.
- **B3 (β default) 단계적**: 0.6.0 → B1 only + size monitor (`sfs archive doctor` 가 size warn). LFS 는 실제 limit 도달 시 0.6.x patch 로 도입. AS-D4 "일단 archive 브랜치, 사이즈 봐서 S3 연동" 정합.
- **B4 처음부터 S3 graduate target**: skip LFS, archive 브랜치 → S3 (gzip + manifest) 직행. 단점: 인프라 복잡도 ↑.

### Axis C — N feature 동시 작업 + 동시 머지 conflict 회피 (sub-Q3, **strong** user 요구) ✅ LOCKED → C4 / shared file = `sprint.yml` / **C2 lock layer = REJECTED (금지)**

- **C1 폴더 격리** (β default): `.solon/sprints/<S-id>/<feature>/` 모든 산출물이 feature 폴더 내부 → file path 충돌 0. 단점: 공유 메타 파일 (sprint-level retro / index) 은 별도 합의 필요.
- **C2 lock-based**: file lock 또는 `.solon/locks/<feature>.lock` mutex. 단점: bash 3.2 cross-platform lock 복잡.
- **C3 merge-commit time enforcement**: pre-merge hook 이 N feature 의 file overlap 검사. 단점: hook bypass 가능.
- **C4 hybrid (C1 + C3)**: 폴더 격리로 95% 회피 + sprint-level shared file (e.g. `sprint.yaml`) 은 pre-merge hook 으로 detect.

### Axis D — `sfs migrate-artifacts` 반자동 정확한 spec (sub-Q4) ✅ LOCKED → D4 + 정제

**Pass 1 default action 알고리즘** (user 발본):
- sprint 에 `report.md` **존재** → archive default 자동
- sprint 에 `report.md` **부재** → 사용자 암묵지 데이터 (raw 메모 / decisions / events.jsonl 등) 를 꺼내 AI 가 질문 → user 답변으로 archive vs promote vs skip 결정.

**Reject granularity** (user 발본):
- 기본 = **파일 단위** reject.
- 단 reject 가 sprint 전체에 영향 (cross-file dependency / sprint contract 무효화) 시 → **sprint 단위 reject** 로 escalate.

**Rollback** = git revert (archive 브랜치 push 전이면 local revert).

- **D1 sprint 별 propose**: AI 가 sprint 1 단위로 "이 sprint 자료를 archive/promote 하시겠습니까?" propose. user accept granularity = sprint.
- **D2 feature 별 propose**: feature 단위로 propose. 단점: feature 가 많으면 user 부담.
- **D3 file 별 propose**: 가장 fine-grained. 단점: 압도.
- **D4 (β default) hybrid 2-pass**: pass 1 = sprint 단위 default action (archive / promote / skip) propose, user `--accept-defaults` 또는 per-sprint override. pass 2 = sprint 안에서 promote 결정된 것만 file 별 review. AS-D6 + AS-Migration "AI propose + user accept-per-item" 정합.
- **D-rollback**: reject 시 rollback = git revert. archive 브랜치 push 전이면 local revert 만으로 안전.

### Axis E — Deep Module subcommand spec (sub-Q5) ✅ LOCKED → E3 3-pass + **E-cmd-γ 둘 다**

**User 발본 (2026-05-03 grill round 1)**:
- 명령어가 너무 길어서 user 가 직접 manual 호출하는 surface 는 **bad UX**.
- **Implement gate 안에 자동 적용** = 기본 동작.
- 단, legacy = 시간 흐르며 deep → shallow 로 부패할 수 있음 → **수동 trigger 도 필요**.
- 도메인 사이즈 **자동 감지** → 안내 → 사용자 승인 → 진행 (반자동).
- 명령어 surface 후보:
  - (a) `sfs implement --change-deep` (implement 에 옵션 추가)
  - (b) `sfs improve-deep-modules` (별도 subcommand)
- user 가 둘 중 어느 쪽이 나을지 결정 필요.

**E3 정적 + AI + interactive 3-pass 는 base 채택**. surface 결정만 sub-grill 잔존.

- **E1 정적 분석 only**: AST 기반 module 경계 / 의존성 그래프 → shallow module 후보 list. 단점: 의도 모름.
- **E2 AI only**: AI 가 codebase 통째로 읽고 deep module 후보 제안. 단점: 일관성 편차.
- **E3 (β default) 정적 + AI 결합**: pass 1 = 정적 분석으로 shallow module 후보 (low cohesion + small surface) 추출 → pass 2 = AI 가 제안된 후보들에 대해 deep module 묶음 + interface 초안 작성 → pass 3 = user interactive review (per-cluster accept/reject/modify). AS-D6 정합.
- **E4 interactive only**: 모든 cluster 결정을 user 가 driving. AI 는 옵션만 제시.

### Axis F — SFS 6 철학 codification 위치 (sub-Q6) ✅ LOCKED → SSoT `SFS-PHILOSOPHY.md` + 3-곳 hybrid + **F4-γ defer (future scope = KO+EN bilingual only)**

**파일 이름 = `SFS-PHILOSOPHY.md`** ✅ LOCKED.

**User 이해 확인 요청**: "3 곳에 다 하이브리드 = MD 파일 따로 생성하고 3 곳에는 다 link 만 걸어서 실제 파일 확인" — 사용자 이해는 **거의 맞음**. 정확한 그림:

1. **SSoT 1 파일** = `SFS-PHILOSOPHY.md` (project root, oss-public). **실제 본문**.
2. `CLAUDE.md §1.x` 추가 = 1-line summary + **link 만** → SFS-PHILOSOPHY.md.
3. `solon-mvp-dist/docs/<lang>/philosophy.md` = ?? — sub-grill (round 2 Q6).

**Multilingual sub-question**: docs/<lang>/philosophy.md 가
- (F4-α) **link only** (영어/한국어 무관, SSoT 한 lang 만 — 사용자 발화 정합) → simple, but multilingual user disservice.
- (F4-β) **lang 별 번역본 + 원본 link** (SSoT 영어 또는 한국어 1 본 + 다른 lang 번역 + cross-link) → multilingual OK, but stale risk + 2x maintenance.
- (F4-γ) **현재는 link only, multilingual 요구 발생 시 0.6.x patch 로 번역본 추가** → simplest now, defer.

→ 사용자 결정: F4-α / F4-β / F4-γ 중 어느 것?

- **F1 CLAUDE.md §1.x 추가**: 가장 가까운 SSoT. 단점: §1.14 ≤200 line 위배 위험. 별도 §1 sub-section 으로 분할 가능.
- **F2 별도 `SFS-PHILOSOPHY.md` (oss-public, project root)**: 단일 화면. CLAUDE.md 는 link 1 줄로 reference. 단점: 또 하나의 root file.
- **F3 user-facing `solon-mvp-dist/docs/<lang>/philosophy.md`**: OSS user 가 직접 보는 위치. 단점: dev/internal 에서 reference 시 1-step 더 멀음.
- **F4 (β default) 3 곳 동시 + 단일 SSoT**: SSoT = `SFS-PHILOSOPHY.md` (project root, oss-public). CLAUDE.md §1.x 에 1-line summary + link, `solon-mvp-dist/docs/<lang>/philosophy.md` 에 user-facing 번역 + same link. F1+F2+F3 hybrid.

### Axis G — Interface vs 구현 agent 분리 mechanism (sub-Q7) ✅ LOCKED → G2 신규 필드 거부 (이미 분리) + **G-β (validator depth → `divisions.yaml`)** + **G-ref-γ (의미 layer cross-ref만, 실 mapping SSoT = model-profiles.yaml)**

**User 발본 (correct)**: "이건 현재 분리가 돼 있을 텐데?? model-profiles.yaml 인터페이스 설계는 C 레벨이고 구현은 implementation worker, helper 이런 식으로 구현돼 있잖아??" → **✅ 확인됨**.

**첨부 model-profiles.yaml v1.1 (study-note 0.5.88-product) 분석**:

| Tier | Roles | Cost/Latency | 의미 |
|---|---|---|---|
| `strategic_high` | `ceo`, `cto-generator` | highest | **Interface designer** = C-Level (CLAUDE.md §1.3 self-validation-forbidden 정합) |
| `review_high` | `cpo-evaluator`, `external-reviewer` | high | **Validator (interface 단)** |
| `execution_standard` | `implementation-worker`, `division-worker` | standard | **Implementer**. `escalate_to: strategic_high`, `cannot: approve own work` 명시. |
| `helper_economy` | `parser`, `formatter`, `sync-helper` | lowest | Deterministic helpers |

→ **G2 신규 필드 (`role: interface_designer | implementer | validator`) 추가 = redundant**. 이미 4 tier 가 같은 의미.

**남은 sub-decisions** (round 2 Q7):
1. **Validator 의 도메인별 escalation depth** (보험/금융/보안 critical = 안쪽까지 검증) — 현 model-profiles 에 표현 없음. 추가 방법 후보:
   - (G-α) model-profiles.yaml 에 `validation_depth: interface | full` per-domain 신규 필드 추가.
   - (G-β) model-profiles.yaml 은 그대로 두고, **SFS-PHILOSOPHY.md "Deep Module" 섹션이 이 dogma 를 user-policy 로 명시** + division 별 override 는 별도 `divisions.yaml` 에 (이미 존재).
   - (G-γ) skip — 0.6.0 spec 에 명시 안 하고 사용자 division 정책에 위임.
2. **SFS-PHILOSOPHY.md "Deep Module" 섹션이 model-profiles.yaml 을 cross-ref 하는 정도**:
   - (G-ref-α) 1-line "구현 = AI = `execution_standard` tier" 만 link.
   - (G-ref-β) 4 tier mapping 표 자체를 SFS-PHILOSOPHY.md 에 복제 (SSoT 이중화 risk).
   - (G-ref-γ) tier mapping 은 model-profiles.yaml SSoT 유지 + SFS-PHILOSOPHY.md 는 의미 layer 만 (interface=C-Level, 구현=worker, 검증=evaluator) → user 가 model-profiles 에서 실 매핑 확인.

→ 사용자 결정: G-α/β/γ × G-ref-α/β/γ.

- **G1 model-profiles.yaml 만 수정**: 기존 구조에 brainstorm/plan agent = high-tier model, generator agent = mid-tier model. 단점: philosophy 와의 link 가 implicit.
- **G2 (β default) model-profiles.yaml + SFS-PHILOSOPHY.md cross-ref**: model-profiles 에 `role: interface_designer | implementer | validator` 명시 + SFS-PHILOSOPHY.md §"Deep Module" 섹션이 model-profiles 를 reference. F4 정합.
- **G3 신규 agent 분류 도입**: division 별 (engineering / business / ops) interface vs implementation agent split. 단점: 현 분류 체계와 충돌 위험.

## §5. Scope Seed

- **이번 sprint (0-6-0-product-spec) 에 넣을 것**:
  - 7 sub-question 결정 (Axis A~G).
  - 결정 결과를 spec 문서로 codify (SFS-PHILOSOPHY.md 초안 / storage-architecture-spec.md 초안 / migrate-artifacts-spec.md 초안 / improve-codebase-architecture-spec.md 초안 / model-profiles cross-ref 초안).
  - **plan gate (G1) 으로 넘어가는 ready-for-plan 조건** = §7 모든 항목 ✓.
- **이번 sprint 에서 뺄 것**:
  - 실 구현 (script 추가 / archive 브랜치 생성 / migrate-artifacts 동작) — plan + implement gate 에서.
  - 0.5.97 dashboard (D1' deferred, 서스테이닝).
  - MD split queue (§4.B, 우선순위 낮음 + spec 결정 후 split 시 충돌 가능).
- **다음 sprint 후보**:
  - **0.6.0-product implement** sprint = storage migration + SFS-PHILOSOPHY.md ship + migrate-artifacts script.
  - **0.6.1-product** sprint = Deep Module subcommand + agent role split.
  - **0.5.97-product** sprint = dashboard surface (서스테이닝, user timing 콜).

## §6. Plan Seed

> Plan gate (G1) 으로 넘어갈 때 필요한 최소 재료. **현재는 7 grill question 미해소 → ready-for-plan 불가**.

- **Goal**: 0.6.0-product spec 5 문서 (philosophy / storage-architecture / migrate-artifacts / improve-codebase-architecture / model-profiles cross-ref) 초안 + AC + risk 식별.
- **Locked input (round 1+2 통합 결과, 7/7 axes)**:
  - **A4** hybrid (feature 1-line auto-append + sprint close user accept)
  - **B3** 단계적 + 임계점 default 500 MB warn (정확치 추후 patch)
  - **C4** 폴더 격리 + pre-merge hook · shared file = `sprint.yml` · **lock layer REJECTED**
  - **D4** hybrid 2-pass · pass 1 algo: report 존재→archive auto, 부재→AI 가 user 암묵지 질문 · reject = file 단위 (sprint 영향 시 sprint escalate) · rollback = git revert
  - **E3 + E-cmd-γ** (3-pass 정적+AI+interactive · `sfs implement` 자동 감지 + 반자동 승인 · `sfs implement --change-deep` 옵션 + `sfs improve-deep-modules` standalone subcommand 둘 다 제공)
  - **F4 + F4-γ** (SSoT `SFS-PHILOSOPHY.md` project root oss-public + CLAUDE.md §1.x 1-line link + `solon-mvp-dist/docs/<lang>/philosophy.md` link only · multilingual 번역본은 0.6.x patch 로 defer · future scope = **KO+EN bilingual only**)
  - **G-β + G-ref-γ** (G2 신규 필드 거부 / validator 도메인 escalation depth = `divisions.yaml` 위임 / SFS-PHILOSOPHY.md ↔ model-profiles.yaml cross-ref = 의미 layer 만, 실 tier mapping SSoT = model-profiles.yaml)
- **Acceptance Criteria 후보**:
  - SFS-PHILOSOPHY.md 가 6 철학 + Deep Module dogma 를 one-screen 으로 표현 (≤200 line).
  - storage-architecture-spec.md 가 Layer 1/2 + co-location + .solon/ 트랙 + N:M mapping + parallel conflict-free 를 file path schema 로 명시.
  - migrate-artifacts-spec.md 가 2-pass propose-accept flow 를 step-by-step 명세.
  - improve-codebase-architecture-spec.md 가 정적 + AI + interactive 3-pass flow + input/output contract 명세.
  - model-profiles cross-ref 가 role=interface_designer/implementer/validator 명시 + philosophy link.
- **주요 risk**:
  - SFS-PHILOSOPHY.md 가 너무 길어지면 ubiquitous language 자체가 흐려짐 (철학 2번 위배 risk).
  - storage redesign 이 기존 .sfs-local/ runtime 과 호환 안 되면 in-flight sprint 깨짐.
  - migrate-artifacts 가 user 부담 ↑ 시 채택 안 됨 (AS-D6 반자동 의도 무효화).
- **generator agent 가 만들 산출물**: 5 spec 문서 초안 (markdown).
- **evaluator agent 가 검증할 기준**: AC 5 항 + 6 철학 self-application (philosophy 자체가 6 철학 위반 안 함) + visibility tier 정합 + bash 3.2 호환.

## §7. G0 Checklist (현재 status, 2026-05-03T19:50 KST)

- [x] raw brief / 대화 메모가 남아 있다 (§1 + §0 + §8 round 1+2 verbatim)
- [x] 문제와 성공 상태가 한 줄로 설명된다 (§2)
- [x] 대안 2 개 이상을 비교했다 (§4 Axis A~G 각 ≥3 옵션, 7/7 lock)
- [x] in/out scope seed 가 있다 (§5)
- [x] **generator/evaluator 계약에 넘길 재료가 충분하다** ← 7 sub-question 7/7 lock
- [x] **6 철학 self-application 확인**:
    - **Grill Me** ✓ (hard 모드 2 round 진행, "ㄱㄱ" 로 plan 승급 안 함)
    - **Ubiquitous Language** ✓ (Layer 1/2, archive branch, sprint.yml, KO+EN bilingual, validator depth, cross-ref scope — 모든 핵심 용어 확정)
    - **TDD 헤드라이트 추월 X** ✓ (plan/implement 전 brainstorm gate close, AC 5 항 + risk 식별)
    - **Deep Module** ✓ (E3 3-pass + 둘 다 surface · interface = user, 구현 = AI = `execution_standard`, 검증 = `review_high` + 도메인별 escalation)
    - **Gray Box** ✓ (interface 7/7 user 가 직접 결정, 구현 detail 은 plan/implement gate 위임)
    - **매일 system 설계** ✓ (본 sprint 자체)

> **status: ready-for-plan ✅** (frontmatter 갱신 완료). plan gate (G1) 진입 = **user 명시 명령 후** (CLAUDE.md §1.3 self-validation-forbidden + brainstorm.md hard 모드 spec — 자동 승급 금지). user 발화 예시: "plan 가자" / "G1 진입" / `sfs plan`.

## §8. Append Log (Grill Round — hard mode, 7 questions)

다음 7 질문은 HANDOFF §4.D.2 의 sub-question 을 hard-mode 형식 (4-7 demanding questions, 답을 미루지 말 것) 으로 정제한 것. **답변은 별도 turn 에서 한 번에 / 부분으로 / 추가 질문 + 발본 OK**. β default 가 있는 것은 그대로 채택해도 되고, 명시적 reject 도 OK.

### Q1 (Axis A) — Feature retro → Sprint retro 흡수
β default = **A4 hybrid** (feature 마다 AI 1-line auto-append + sprint close 때 user final accept). AS-D2 "남겨야 될 것만 남긴다" + AS-D6 반자동 정합.
- 이대로 OK?
- 아니면 (A1 자동 / A2 per-feature accept / A3 batch at sprint close) 중 어디?
- "1-line summary" 의 information shape (헤딩 / bullet 1 줄 / kv) 까지 지정?

### Q2 (Axis B) — Archive 브랜치 비대 + LFS trigger
β default = **B3 단계적** (0.6.0 → release amend + size monitor / `sfs archive doctor` warn / LFS 는 실 limit 도달 시 0.6.x patch).
- 이대로 OK?
- size monitor 의 **임계점 숫자** = ? (ex. archive branch repo size > 500 MB warn / > 2 GB error / single sprint > 100 MB warn — 자유 입력).
- S3 graduate trigger 도 동일 시점 (LFS 와 동시) 또는 별도?

### Q3 (Axis C) — N feature 병렬 conflict-free (**strong** 요구)
β default = **C4 hybrid** (폴더 격리 95% + sprint-level shared file 은 pre-merge hook 검사).
- 이대로 OK?
- sprint-level shared file 의 list 명시 = ? (ex. `sprint.yaml` / `retro.md` / `report.md` / `_INDEX.md` — 어디까지 hook 으로 보호?)
- C2 lock-based 를 **추가** layer 로 (defense in depth) 도 가능 — 채택?

### Q4 (Axis D) — migrate-artifacts 정확한 spec
β default = **D4 hybrid 2-pass** (sprint 단위 default + user override → file 단위 review).
- 이대로 OK?
- pass 1 default action 의 **결정 알고리즘** 은? (ex. sprint 가 N month 이상 dormant + report.md 존재 → archive default / report.md 부재 → skip default — 자유 입력)
- reject 시 rollback granularity = sprint 단위 git revert OR file 단위 selective revert?

### Q5 (Axis E) — Deep Module subcommand `improve-codebase-architecture` spec
β default = **E3 3-pass** (정적 + AI + interactive).
- 이대로 OK?
- 정적 분석 pass 의 **언어 scope** = ? (ex. bash + markdown + YAML 만 / Python 추가 / TypeScript 추가 / 모든 언어).
- input contract = directory path? git ref? 둘 다? `--baseline <ref>` 같은 flag 가 필요?

### Q6 (Axis F) — SFS 6 철학 codification 위치
β default = **F4 3-곳 hybrid** (SSoT = `SFS-PHILOSOPHY.md` project root oss-public + CLAUDE.md §1.x summary + link + `solon-mvp-dist/docs/<lang>/philosophy.md` user-facing 번역).
- 이대로 OK?
- SSoT 파일 이름 = `SFS-PHILOSOPHY.md` OR 다른 이름 (`PHILOSOPHY.md` / `IDENTITY.md` / `SFS-IDENTITY.md`)?
- 6 철학을 ordered list (1~6) OR named principles (Grill Me / Ubiquitous Language / TDD-no-overtake / Deep Module / Gray Box / Daily System Design) 둘 다 보존?

### Q7 (Axis G) — Interface vs 구현 agent 분리 mechanism
β default = **G2** (model-profiles.yaml 에 `role: interface_designer | implementer | validator` 추가 + SFS-PHILOSOPHY.md cross-ref).
- 이대로 OK?
- 현 model-profiles 의 어떤 entry 들이 어느 role 에 매핑되는가? (사용자 검토 필요 — 본 grill 후 별도 listing pass 요청 가능)
- validator 의 도메인별 escalation (보험/금융/보안 critical = 안쪽까지) 을 model-profiles 에 어떻게 표현? (e.g. `role: validator, depth: interface | full` 추가?)

---

---

### Grill Round 1 — User 답변 verbatim 기록 (2026-05-03 KST, 본 turn)

- **Q1 (Axis A)**: "Approve" → A4 hybrid lock.
- **Q2 (Axis B)**: "Approve인데 사이즈는 용량 결정은 일단 추 후 (default 500mb -> 문서라서 500mb면 충분하단 판단)" → B3 lock + threshold default 500 MB warn (patch 시 재조정).
- **Q3 (Axis C)**: "Approve, sprint.yml, lock채택 ㄴㄴ 채택안함 (금지)" → C4 lock + shared file `sprint.yml` + **lock layer 명시적 REJECT**.
- **Q4 (Axis D)**: "Approve, pass1 -> 케이스가 부족해서 일단 기본은 report가 존재하면 자동으로 archive하되, report 없으면 사용자 암묵지 데이터를 꺼내서 판단하게 질문, 파일단위 reject (단, 스프린트 전체에 영향 줄 경우 sprint reject)" → D4 lock + pass 1 algo 명세 + file-level reject (sprint escalate exception).
- **Q5 (Axis E)**: "명령어가 너무 길어서 사용자가 직접 수동으로 사용하게 하는건 별로 안좋고, 구현 단계(implement)에서 자동 적용하는쪽이 맞고 근데 legacy가 되면 초기엔 deep module이었던게 나중엔 shallow가 될 수 있잖아?? 그때는 당연히 수동으로 사용할 수 있어야되고, 도메인 사이즈에 따라 자동감지가 좀 됐으면 좋겠어 그래서 안내하고 승인하면 진행되도록(반자동) + 수동으로 사용할때 명령어도 sfs implement --change-deep 이런식으로 옵션을 주던가 아니면 sfs improve-deep-modules 이게 나을듯??" → 자동 감지 + 반자동 승인 + manual fallback. Surface 결정 sub-grill 잔존 (round 2 Q5).
- **Q6 (Axis F)**: "이거는 내가 지금 이해한게 맞는지 확인좀 해주고 나랑 다시 얘기 -> 3곳에 다 하이브리드로 둔다는게 md파일을 따로 생성하고 3곳에는 다 link만 걸어서 실제 파일을 확인하게 한다는게 맞는지?? 파일 이름 : SFS-PHILOSOPHY.md 이거는 승인" → 사용자 이해 거의 맞음 (정확 confirm = §4 Axis F 본문). 파일 이름 lock. Multilingual sub-grill 잔존 (round 2 Q6).
- **Q7 (Axis G)**: "이건 현재 분리가 돼 있을텐데?? model-profiles.yaml 인터페이스 설계는 C레벨이고 구현은 implementation worker, helper 이런식으로 구현 돼 있잖아??" → 사용자 fact-check **정확** (model-profiles.yaml 첨부 검증 결과 §4 Axis G 본문). 신규 필드 추가 redundant. Validator depth + cross-ref 정도 sub-grill 잔존 (round 2 Q7).

---

### Grill Round 2 — Sub-question (3 종)

#### Round 2 Q5 — Deep Module subcommand surface

자동 감지 + 반자동 승인 = `sfs implement` 흐름 안에서 자동으로 작동 (별 명령어 호출 없이). manual fallback 명령어를 어떻게 노출할지가 sub-decision.

- **(E-cmd-α) `sfs implement --change-deep`** — 기존 implement subcommand 의 옵션 형태.
  - 장점: surface 1 개로 통합. 명령어 수 ↑ 안 함.
  - 단점: implement = "build now", deep refactor 와 의미가 섞임. legacy 정제는 implement 의 책임 범위 밖이라는 인상.
- **(E-cmd-β) `sfs improve-deep-modules`** — 별 standalone subcommand.
  - 장점: 의미 분리 명확. legacy 정제가 implement context 밖에서도 trigger 가능.
  - 단점: 명령어 surface 추가 1 개.
- **(E-cmd-γ) 둘 다** — `sfs implement` 내부 자동 감지 시 옵션 노출 OR power-user 가 `sfs implement --change-deep` 으로 force-on, 별도 standalone trigger 는 `sfs improve-deep-modules`.
  - 장점: 두 use-case 자연스럽게 분리. implement gate 의 자동 감지는 옵션 명령어 없이 prompt 만 띄우면 됨, `--change-deep` 은 자동 감지 skip force-on, `sfs improve-deep-modules` 는 implement 와 무관한 standalone refactor sprint.
  - 단점: surface 약간 ↑ (옵션 1 + subcommand 1).

→ **β default 추천 = (E-cmd-γ) 둘 다**. 의미 분리 + 자연 use-case 매핑 + 자동 감지 prompt 는 어느 쪽이든 유효. 어느 것 채택?

#### Round 2 Q6 — `solon-mvp-dist/docs/<lang>/philosophy.md` multilingual 처리

(SSoT 1 파일 = `SFS-PHILOSOPHY.md` project root + CLAUDE.md §1.x 1-line link 는 confirm 됨. 남은 결정은 docs/<lang>/ 처리만.)

- **(F4-α) link only** — docs/<lang>/philosophy.md 가 단순 link → SFS-PHILOSOPHY.md.
  - 장점: stale 0, maintenance 0.
  - 단점: SSoT 1 lang 만 (영어 OR 한국어 1 본). multilingual user 에게 disservice.
- **(F4-β) lang 별 번역본 + 원본 link**.
  - 장점: 다국어 사용자 UX OK.
  - 단점: SSoT 가 사실상 multilingual SSoT 가 됨. 본 docset Phase 1 MVP 단계에서 번역 maintenance 부담 ↑. stale risk.
- **(F4-γ) 0.6.0 = link only, multilingual 발생 시 0.6.x patch 로 번역본 추가**.
  - 장점: 지금은 simple, 미래 확장 가능.
  - 단점: 사용자 발생 전엔 disservice 잔존.

→ **β default 추천 = (F4-γ) defer**. Phase 1 OSS user 발생 sample 부족 + 1 lang SSoT 가 가장 단순. 어느 것 채택?

#### Round 2 Q7 — Validator depth + SFS-PHILOSOPHY.md ↔ model-profiles.yaml cross-ref 정도

**Q7-a Validator 도메인별 escalation depth** (보험/금융/보안 critical = 안쪽까지 검증):
- (G-α) model-profiles.yaml 에 신규 필드 `validation_depth: interface | full` per-domain 추가.
  - 장점: machine-readable, runtime 이 직접 참조 가능.
  - 단점: model-profiles.yaml schema bump (v1.2 → v1.3 호환 처리).
- (G-β) model-profiles 그대로, SFS-PHILOSOPHY.md "Deep Module" 섹션이 user-policy 로 명시 + 도메인 override 는 기존 `divisions.yaml` 에서 처리.
  - 장점: schema 안 건드림. divisions.yaml 이 이미 도메인 단위 SSoT 인 점과 정합.
  - 단점: validator runtime 이 divisions.yaml 도 읽어야 함 (1-step 더).
- (G-γ) 0.6.0 spec 에 명시 안 함, division 정책에 위임.
  - 장점: simple now.
  - 단점: 사용자가 critical 도메인 운영 시 spec 결락 발견 가능.

→ **β default 추천 = (G-β)**. 기존 divisions.yaml 활용. 어느 것 채택?

**Q7-b SFS-PHILOSOPHY.md ↔ model-profiles.yaml cross-ref 정도**:
- (G-ref-α) 1-line cross-ref ("구현 = `execution_standard` tier, 정확 mapping 은 `model-profiles.yaml`").
- (G-ref-β) 4 tier mapping 표 SFS-PHILOSOPHY.md 에 복제.
- (G-ref-γ) 의미 layer 만 명시 (interface=C-Level / 구현=worker / 검증=evaluator), 실 mapping 은 model-profiles.yaml SSoT.

→ **β default 추천 = (G-ref-γ)**. SSoT 이중화 (CLAUDE.md §13 R-D1 정합) 회피. 어느 것 채택?

---

---

### Grill Round 2 — User 답변 verbatim 기록 (2026-05-03 KST, 본 turn)

- **Round 2 Q5 (Axis E)**: "둘 다" → **E-cmd-γ** lock (`sfs implement --change-deep` 옵션 + `sfs improve-deep-modules` standalone 둘 다 제공).
- **Round 2 Q6 (Axis F)**: "F4-γ (다국어 지원 물어보는거 맞지?? 지원 해봣자 일단은 영어정도만 같이 해주면 될 거 같은데??)" → **F4-γ** lock + future patch 시 scope = **KO+EN bilingual only** (모든 언어 X). AI 답변: 맞아 — Q6 sub-grill 은 정확히 multilingual 처리 방식을 묻는 거였음.
- **Round 2 Q7-a (validator depth)**: "(G-β) model-profiles 그대로" → **G-β** lock (validator 도메인 escalation depth 는 model-profiles.yaml schema 안 건드리고 `divisions.yaml` 위임).
- **Round 2 Q7-b (cross-ref scope)**: "G-ref-γ" → **G-ref-γ** lock (SFS-PHILOSOPHY.md 는 의미 layer 만 명시, 실 tier mapping SSoT = model-profiles.yaml).

---

### Brainstorm Gate Close (G0 → ready-for-plan)

**7/7 axes locked, 7 sub-Q (round 1: 4, round 2: 3) all resolved**. status: draft → **ready-for-plan**. §6 Plan Seed 'Pending input' 섹션 제거됨 (모두 'Locked input' 으로 합류).

**다음 1 step (Sequential Disclosure, CLAUDE.md §1.20)**: user 가 plan gate (G1) 진입 명시 명령 → `/sfs plan` 또는 본 docset workbench 에서 `plan.md` 생성. AI 자동 승급 금지 (CLAUDE.md §1.3 + brainstorm hard 모드 spec).
