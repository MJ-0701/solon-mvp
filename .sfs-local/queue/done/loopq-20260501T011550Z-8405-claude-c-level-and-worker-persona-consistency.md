---
task_id: loopq-20260501T011550Z-8405
title: "[claude] c-level and worker persona consistency"
status: claimed
priority: 3
mode: user-active-deferred
sprint_id: "solon-loop-queue-mvp"
owner: claude-overnight
attempts: 0
max_attempts: 3
created_at: 2026-05-01T01:15:50Z
claimed_at: 2026-05-01T01:36:00Z
size: medium
target_minutes: 75
---

# [claude] c-level and worker persona consistency

## Goal

Review and lightly correct the docs/personas that explain C-Level strategic
roles versus implementation worker execution roles.

Scope:
- Keep the distinction sharp: CTO owns sprint contract; implementation worker
  owns bounded execution slices.
- Avoid wording that makes Claude the canonical model provider.
- Keep docs runtime-neutral across Claude, Codex, Gemini, and current-runtime
  fallback.
- Do not edit scripts or packaging files.
- Do not implement Windows/Scoop packaging.
- Do not run `git add`, `git commit`, `git push`, or release apply.

## Files Scope

- 2026-04-19-sfs-v0.4/02-design-principles.md
- 2026-04-19-sfs-v0.4/03-c-level-matrix.md
- 2026-04-19-sfs-v0.4/RUNTIME-ABSTRACTION.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/personas/ceo.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/personas/cto-generator.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/personas/cpo-evaluator.md
- 2026-04-19-sfs-v0.4/solon-mvp-dist/templates/.sfs-local-template/personas/implementation-worker.md

## Verify

- `git diff --check`

## Runtime Assignment

- Intended runtime: Claude.
- Keep changes minimal and wording-focused.

---

## Findings (claude-overnight, 2026-05-01)

### Verdict

**pass with 2 minimal wording fixes applied** — 0.5.39 model profile work + RUNTIME-ABSTRACTION §5.4 가 이미 C-Level 전략 vs Implementation Worker 실행 boundary 와 runtime-neutral wording 을 잘 enforce. 잔여 stale wording 2 건만 (Claude-시절 historical reference) light fix 적용. 코드/스크립트/패키징 변경 0.

### 검증 통과

- `git diff --check` exit=0 ✅ (양쪽 수정 모두 whitespace clean).

### 7 file scope 검토 결과

#### File 1 — `02-design-principles.md`

- **§2.2 자기검증 금지 (3-Tier Separation)** ✅ — Tier 1/2/3 분리 명확. CTO=designer, Worker=executor, Evaluator=independent reviewer.
- **§2.4 모델 할당 규칙** ✅ — 2026-05-01 migration note (L176) 가 "Opus/Sonnet/Haiku 는 Claude runtime baseline 예시일 뿐, RUNTIME-ABSTRACTION.md §5.4 가 SSoT" 로 명시. 사용자 권장값 vs override (`current_model` fallback).
- **L181 표** ✅ — C-Level=`strategic_high`, Worker=`execution_standard`, Evaluator=`review_high`, Helper=`helper_economy`. Claude-canonical wording 없음.
- **L136 stale historical wording**: ⚠️ "v0.3 §2.2 'Sonnet 실행자 + Opus 판단자 쌍'을 더 엄격하게 명문화한 것" — Claude 시절 짝 표현이 무 scaffolding. **Light fix 적용** → tier 추상화 명시 + RUNTIME-ABSTRACTION §5.4 SSoT 정합 wrap.

#### File 2 — `03-c-level-matrix.md`

- **§3.1 mermaid 조직도** ✅ — C-Level=strategic_high label, role separation 명확.
- **§3.4 본부장 = Gate Operator** ✅ — Gate 직접 판단 안 함, evaluator 호출 + routing.
- **§3.4.2 본부장이 하지 않는 일** ✅ — "Worker가 만든 산출물의 직접 작성/수정 — Worker 영역" 등 boundary 강제.
- **§3.6 모델 할당 최종 표** ✅ — 2026-05-01 보정 note (L460) Codex/Gemini/current peer 명시 + audit fields 6 종.
- **L366 sample yaml `model: claude-opus-4-6`**: ⚠️ 본부장 prompt 예시에서 concrete Claude model 명. **Light fix 적용** → `reasoning_tier: execution_standard   # escalates to strategic_high on architecture/public-contract decisions; concrete model resolved per .sfs-local/model-profiles.yaml (Claude/Codex/Gemini/current)` 로 교체.

#### File 3 — `RUNTIME-ABSTRACTION.md`

- **§5.4 Reasoning Tier Contract** ✅ — 4-tier + runtime별 비규범 예시 (Claude/Codex/Gemini 동격).
- **§5.4 Project model profile / current fallback** ✅ — `.sfs-local/model-profiles.yaml` SSoT, `current_model` fallback default, hard block 아님.
- **§5.4 Worker boundary 3 조건** ✅ — plan/architecture/AC/files_scope 고정 + 임무=구현/테스트/리팩터 + CPO 별도 instance.
- **§5.4 즉시 escalate 트리거 5 종** + **Audit fields 6 필드** ✅.
- **§6 Runtime Adapter 슬롯** ✅ — Claude/Codex/Gemini peer adapter.

#### File 4 — `personas/ceo.md`

- ✅ Mission 4 + Rules 4. phase=`brainstorm-plan`, reasoning_tier=`strategic_high`. 변경 권고 없음.

#### File 5 — `personas/cto-generator.md`

- ✅ L15: implementation-worker 위임 명시. L25~26: tier 별 책임. L27: all_high 시도 role separation 유지. 변경 권고 없음.

#### File 6 — `personas/cpo-evaluator.md`

- ✅ self-validation 방지, "Codex/Gemini CLI for review" runtime-neutral, `default_executor: codex`. 변경 권고 없음.

#### File 7 — `personas/implementation-worker.md`

- ✅ 0.5.39 신설 자체가 boundary evidence. 6 종 boundary rule. L23 all_high 시 review/escalation invariant. 변경 권고 없음.

### CTO contract owner vs implementation worker boundary 검증 (task body 핵심 질문)

**SHARP** ✅ — CTO Generator (cto-generator.md L15) **delegates** fixed slices to implementation-worker; Implementation Worker (implementation-worker.md L13~26) **execution-only** with 6 boundary rules. 02 §2.2 + 02 §2.4 + 03 §3.6 + RUNTIME-ABSTRACTION §5.4 4 layer 가 boundary 일관 강제. Persona reasoning_tier frontmatter 4 종 (`ceo: strategic_high`, `cto-generator: strategic_high`, `cpo-evaluator: review_high`, `implementation-worker: execution_standard`) 도 evidence.

### Runtime-neutral wording 검증 (task body 핵심 질문)

**PASS with 2 light fix** ✅ — 02 §2.4 + 03 §3.6 migration note + RUNTIME-ABSTRACTION §5.4/§6 가 Claude/Codex/Gemini peer + current fallback 명시. 위 2 light fix 로 stale historical wording / hardcoded model 제거.

### "Claude as canonical" 잔여 wording 검토

- 전수 grep — `canonical model` / `Claude (canonical` / `Claude only` / `Claude 만` 직접적 canonical wording 없음.
- Claude 모델명 (Opus/Sonnet/Haiku) 잔여 hits 모두 ① migration note "Claude baseline 예시일 뿐" 문맥, ② RUNTIME-ABSTRACTION §5.4 의 "runtime별 비규범 예시" 표, ③ 본 review 가 fix 한 historical/yaml 2 건. → **clean**.

### Scope guard (task body negative 항목 준수)

- ✅ 코드/script 변경 0 (sfs-loop.sh / install.sh / upgrade.sh / bin/sfs 미터치).
- ✅ Packaging 변경 0.
- ✅ Windows/Scoop 미터치.
- ✅ git add / commit / push / release apply 0.

### Closing

verdict: **pass**. 2 minimal wording fix 적용 + 5 file 변경 0. 코드 영역 변경 0. 후속 task 8407 (release readiness audit 0.5.40) 가 8404+8405 완료 후 unblock 되어 다음 chain.
