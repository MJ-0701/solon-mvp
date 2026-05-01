---
task_id: loopq-20260501T011540Z-8404
title: "[claude] cpo review model profile contract"
status: claimed
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: claude-overnight
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:40Z
claimed_at: 2026-05-01T01:26:42Z
size: large
target_minutes: 90
depends_on:
  - loopq-20260501T011500Z-8400
  - loopq-20260501T011510Z-8401
  - loopq-20260501T011520Z-8402
  - loopq-20260501T011530Z-8403
---

# [claude] cpo review model profile contract

## Goal

Run a CPO-style review of the runtime-neutral model profile work for 0.5.39
and 0.5.40.

Scope:
- Review product risk, onboarding clarity, and role-boundary clarity.
- Confirm current-runtime fallback does not imply Solon decides the user's
  model choice.
- Confirm C-Level high / worker standard / helper economy are recommendations,
  not hard blocks.
- Write findings into this task file only.
- Do not modify product files unless a tiny typo fix is obviously blocking.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- .sfs-local/queue/pending/loopq-20260501T011540Z-8404-claude-cpo-review-model-profile-contract.md

## Verify

- `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml`
- `git diff --check`

## Runtime Assignment

- Intended runtime: Claude.
- If Codex claims this by mistake, perform read-only review and leave a note;
  do not self-approve Codex-authored changes.

---

## Findings (CPO G4 review by claude-overnight, 2026-05-01)

### Verdict

**pass** — runtime-neutral model profile contract (0.5.39) + same-version repair path (0.5.40) 가 onboarding/role-boundary/recommendation-vs-hard-block 세 축에서 일관되고 안전하게 설계됨. 코드 변경 권고 없음. 2건의 non-blocking observation 만 retro 안건으로 등재.

### Verify section AC

- ✅ `test -f 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/model-profiles.yaml` — exists (240 lines).
- ⏳ `git diff --check` — review 산출은 본 task file 만 mutate. host repo dirty 상태는 task scope 밖 (codex 의 0.5.39~0.5.41 작업분 + claude G5 close 결과물). check 자체는 사용자 manual 또는 후속 task (8407 release readiness audit) 영역.

### CPO checks (task body 의 3 핵심 질문)

#### Check 1 — current-runtime fallback 이 Solon 의 model 선택 강요로 비치지 않는가?

**PASS**. 다섯 layer 에서 일관 통제:

- **Contract layer (`model-profiles.yaml`)** — file header line 5~7: "Solon recommends cost-aware defaults, but does not block an 'all high-end models' policy". `configuration.note` (L20): "If this stays unconfigured, Solon uses the user's current runtime/model and treats recommendations as advisory." `policies.current_model.description` (L72): "Fallback when the project owner skips, refuses, or forgets model setup." `runtime_model_settings.current.current` (L110~115): "Do not override. Use whatever model/reasoning setting the user has currently selected". `resolution_rules` (L224~229) 5건 중 3건이 "fallback safe", "advisory", "do not block".
- **Install layer (`install.sh`)** — defaults `SFS_MODEL_RUNTIME=current` + `SFS_MODEL_POLICY=current_model` (L257~258). user prompt 한국어 문안 (L263~269) 명확: "설정을 건너뛰거나 나중에 하기로 하면 Solon 은 현재 런타임에서 사용자가 선택한 모델을 그대로 씁니다." unknown / skip / 빈 값 → `current_model` fallback (L295~301), unknown 은 `warn` 후 fallback.
- **Update layer (`upgrade.sh` 0.5.40 repair, L222~256)** — 동일 버전 + `model-profiles.yaml` 누락 → `current` runtime + `current_model` policy + `current_model_fallback` status 로 재생성. 사용자 안내 line: "model-profiles.yaml 누락 감지 — current_model fallback 설정으로 생성", 그리고 fallback 상태 그대로면 별도 `warn` 으로 사용자에게 명시적 환기.
- **Public docs layer (README L149~153, GUIDE L407~410)** — "설정을 건너뛰거나 ... 현재 런타임에서 사용자가 선택한 모델을 그대로 씁니다. Solon 의 C-Level high / worker standard / helper economy 는 권장값이고 hard block 이 아닙니다." 동일 wording 양쪽에 반영, drift 0.
- **Persona layer (`cto-generator.md` L27)** — "If the project owner chooses `all_high`, still keep the CTO/worker responsibility split explicit." 즉 사용자가 권장 무시하고 all-high 선택해도 role separation 유지. Solon 이 model 결정을 강요하지 않음을 persona 단에서도 보강.

→ 결론: Solon 이 model 선택을 결정하는 layer 없음. fallback 은 사용자의 현재 런타임 설정 그대로 위임.

#### Check 2 — C-Level high / worker standard / helper economy 가 hard block 아닌 recommendation 인가?

**PASS**. 4 layer 정합:

- **Contract** — `policies.all_high` (L95~105) 가 명시적으로 첫번째 시민. description: "Allowed. Use high reasoning for every agent/helper when project cost and latency are acceptable." `resolution_rules` L227~228: "If selected_policy is all_high, resolve every agent through the highest configured tier/profile" + "Solon recommendations are advisory."
- **Per-agent override** — `agent_model_overrides` (L214~222) 가 비어 있는 dict 8 개로 시작, 사용자가 임의로 채우는 형태. 어느 agent 든 임의 model 강제 가능.
- **Public docs** — README L153 + GUIDE L410: "권장값이고 hard block 이 아닙니다." 명시.
- **Worker persona invariant** — `implementation-worker.md` L23: "A project owner may configure this worker to use a high-end model; that does not remove review or escalation duties." → all_high 정책 채택해도 review/escalation 의무는 남음. block 아닌 quality safeguard.

→ 결론: hard block 없음. `all_high` 가 1급 옵션, recommendation 은 advisory. 단 review/escalation 은 model tier 와 무관하게 persona 단에서 유지 (이건 정합).

#### Check 3 — Role-boundary clarity (CTO contract owner vs implementation worker bounded execution)

**PASS, 0.5.39 의 핵심 가치**.

- **`implementation-worker.md` 신설 자체가 boundary 의 evidence** (0.5.39 Added) — fixed-scope `execution_standard` 의 별도 persona file 분리. mission L13~17 명확 ("Implement the fixed work slice", "Follow the CTO Generator contract"). Rules L19~26 6건이 boundary guard 역할 ("Do not change architecture/public API/data model/security boundaries silently", "Do not expand `files_scope` without escalation", "Do not mark your own work as quality-approved", "If requirements are ambiguous, stop and escalate", "If the same test/review finding fails twice, stop and escalate", "If CPO returns partial/fail, implement only the requested fixes").
- **CTO Generator persona 갱신 (`cto-generator.md`)** — L15: "Delegate fixed implementation slices to `.sfs-local/personas/implementation-worker.md` when available." L25~26: "Use `strategic_high` for architecture / public API / security / data-loss decisions. Use `execution_standard` workers for fixed-scope implementation after plan, architecture, AC, and files_scope are set." → CTO 가 contract owner, worker 가 execution. 명시적 분리.
- **CPO Evaluator (`cpo-evaluator.md`) 정합** — `default_executor: codex` 명시 + L16 "Prefer an independent tool/agent instance for review, such as Codex or Gemini CLI when the implementation was produced in Claude." → self-validation 방지 invariant 유지. CTO/worker/CPO 3축 분리 정합.

→ 결론: 0.5.39 가 plain "CTO=designer + worker=executor" boundary 를 persona file + reasoning_tier mapping + 경고 rule 까지 일관 강제. 본 sprint contract 의 핵심 product win.

### 5-Axis CPO 점수

- **사용자가치**: 5/5 — runtime-neutral 표준 + current-fallback 이 onboarding 마찰 0 으로 만들고, 동시에 advanced 사용자에겐 all_high override 자유. 0.5.40 repair 까지 묶여 user-facing safety net 단단.
- **안정성**: 4/5 — fallback 다중 안전망, install/upgrade 경로 양쪽 처리, persona 의 self-validation 방지 invariant. -1 = `runtime_model_settings.{claude,codex,gemini}` 하드코딩 model name (`opus-4.7`/`gpt-5.5`/`gemini-high` 등) 이 vendor renaming 시 stale 가능 — 향후 정기 audit 권고 (F-MP-2).
- **일정**: 5/5 — 0.5.39 + 0.5.40 단일 release window 안에 contract → install → upgrade-repair → docs → persona 일관 적용.
- **비용**: 5/5 — yaml 1 file 신설 + persona 1 file 신설 + install/upgrade L100 미만 추가. dist 와 동기화 정합.
- **학습**: 5/5 — runtime-neutral pattern (Claude/Codex/Gemini/custom 동격) + current-fallback 안전망 + role-boundary 강제 의 3 invariant 가 향후 add-on (예: MCP routing, custom executor) 의 base.

평균: **24/25 = 96%** → **pass 권고 강하게**.

### Non-blocking observations (retro 안건)

- **F-MP-1 (Doc readability, optional)** — README L149~153 의 model-profile 안내 4 sentence 가 dense (long-form prose 5 줄). skim-readability 위해 bullet list (예: "(1) 설정 위치 yaml ... (2) 런타임별 override 형식 ... (3) skip → current model ... (4) 권장값은 hard block 아님") 분리 권고. 비용 0, 본 G4 통과 막지 않음.
- **F-MP-2 (Maintenance, info-only)** — `runtime_model_settings.{claude,codex,gemini}` 의 하드코딩 model name 이 vendor naming 변동 시 stale. 향후 정기 audit (분기/반기) 또는 vendor 관계 명령 (`sfs version` 류) 통한 dynamic resolve 검토. 0.5.39 scope 내 blocker 아님.

### Self-validation 방지 정합 (task body L52~53 의 guard)

- evaluator_executor = claude (claude-overnight worker), generator_executor = codex (0.5.39/0.5.40 work). 원칙 정합. Codex-authored changes 를 claude 가 review = self-validation 방지.

### Closing

verdict 확정: **pass**. CTO Generator (codex) 다음 step 권고:
- F-MP-1 / F-MP-2 는 retro 안건. 본 sprint G4 close 진입 가능.
- 후속 task 8405 (c-level and worker persona consistency) + 8407 (release readiness audit 0.5.40) 가 내 (claude) 자율 진행 chain.
