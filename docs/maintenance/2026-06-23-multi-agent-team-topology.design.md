---
doc_id: multi-agent-team-topology-design
title: "Design — Multi-agent team topology + entry-agnostic auto-dispatch"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-06-23
summary: "Opt-in 멀티에이전트 역할 전문화 + 자동 업무분배 설계. runtime_registry(데이터로 runtime) + agent_runtime_bindings(role→runtime) + team preset(solo/pair/trio) + entry-agnostic dispatch. OCP 1원칙, solo 무변경, standalone guarantee."
load_when: "멀티에이전트 team topology, runtime_registry/agent_runtime_bindings 스키마, --team preset, sfs dispatch, 어댑터 dispatch rule 주입 작업 시. Hermes seam 설계(2026-06-23-hermes-self-evolution-seam-wiring.design.md)의 자매 문서(워커 층)."
---

# Design — Multi-agent team topology + entry-agnostic auto-dispatch

- **status**: draft (design, pre-implementation)
- **date**: 2026-06-23
- **target repo**: solon-product (distribution)
- **scope**: opt-in 멀티에이전트 역할 전문화 + 자동 업무분배
- **sibling**: [2026-06-23-hermes-self-evolution-seam-wiring.design.md](2026-06-23-hermes-self-evolution-seam-wiring.design.md) (오케스트레이터 층; 본 문서는 워커 층)
- **author**: Cowork 설계 초안 (사용자 검토 → sprint 정식화 대기)

---

## 1. 배경 / 문제

solon은 현재 **단일 runtime 가정**이다. `selected_runtime`(claude|codex|gemini|
custom)이 프로젝트 전체에 하나만 걸리고, 그 안에서 16개 agent-role이 8개 reasoning
tier로 라우팅된다. divisions(역할 축)와 `selected_runtime`(runtime 축)은 **이미
분리**돼 있다 — 단, runtime은 프로젝트당 하나.

사용자(소수 멀티에이전트 운영자) 요구: ① **이종 역할 전문화**(claude=설계·리뷰·
문서 lead, codex=구현 worker, gemini/Antigravity=리서치 researcher); ② **자동
업무분배**(어느 CLI에서 시작하든 적임 agent에게 분배); ③ **OCP**(역할 재배치 +
4번째 CLI 추가가 설정만으로); ④ **opt-in**(기본 solo는 현재 동작 그대로).

## 2. 목표 / 비목표

**목표**: team preset(solo/pair/trio)을 install·config 옵션으로; 선언적
`role → runtime` binding(override 자유); entry-agnostic auto-dispatch; OCP(agent
enum-하드코딩 0, runtime은 데이터); standalone guarantee 유지.

**비목표**: solo 동작 변경 0; 새 역할 체계 신설(기존 divisions/agent-role 재사용);
agent 강제 spawn/상시 데몬(dispatch는 opt-in, headless 1-shot).

## 3. 설계 원칙 (1원칙 = OCP)

1. **OCP — binding은 데이터, 코드 아님.** role↔runtime 매핑과 runtime별 CLI 호출
   방법은 전부 설정 데이터로 표현. 역할 재배치/새 CLI 추가 = **config edit only**,
   분기 코드 0. preset = 닫힌 기본값, `agent_runtime_bindings` override = 열린 확장점.
2. **Standalone guarantee.** team/dispatch 레이어 전부 제거해도 `doctor + curation +
   tidy` 및 모든 gate/release 동일 동작. dispatch는 라우팅이지 기능 의존성 아님.
3. **기존 표면 재사용.** divisions(역할), capsule-contract(typed handoff 8필드),
   advisor↔Code 파일버스, external-orchestrator-entry(headless), credential-hygiene
   (per-runtime 키)를 그대로 쓴다. 새 통신 규약 신설 금지.
4. **Entry-agnostic.** 진입 agent가 누구든 같은 binding/registry를 읽고 같은 판정.

## 4. 구성요소

### 4.1 Runtime registry — OCP의 핵심 (신규, 데이터)

새 runtime을 추가하거나 호출 방식을 바꾸는 **단일 확장점**. 코드가 아니라
데이터로 runtime을 안다.

```yaml
# model-profiles.yaml
runtime_registry:
  claude:
    invoke: "claude -p {prompt} --output-format json --allowedTools {tools}"
    capabilities: [plan, review, docs, code]
    models_ref: claude                        # 기존 runtime model_settings 참조
  codex:
    invoke: "codex exec {prompt} --sandbox workspace-write"
    env: { CODEX_NON_INTERACTIVE: "1" }
    capabilities: [code, refactor]
    models_ref: codex
  antigravity:                                 # gemini-cli 공식 후속(`agy`), 현역
    invoke: "agy -p {prompt} --output-format json"
    capabilities: [research, analyze, code]
    models_ref: gemini
  gemini:                                      # DEPRECATED: 개인 Pro/Ultra 2026-06-18 sunset
    invoke: "gemini -p {prompt} --non-interactive --output-format json --yolo"
    capabilities: [research, analyze]
    models_ref: gemini
    deprecated: "use antigravity"
  # 미래의 N번째 CLI = 여기에 항목 추가만. 분기 코드 수정 0 → OCP.
```

- `invoke` 템플릿이 CLI 추상화. dispatch는 이 템플릿만 본다 → runtime-agnostic.
  플레이스홀더(`{prompt}`/`{tools}`)는 dispatch가 capsule에서 채움. `capabilities`는
  역할↔능력 매칭 힌트.
- **OCP 실증**: gemini-cli sunset(2026-06-18) → antigravity 전환이 default gemini
  runtime 교체 한 줄로 끝남. 코드 분기 0.

### 4.2 Role → runtime binding (선언적, override 자유)

```yaml
agent_runtime_bindings:        # 미지정 role → selected_runtime fallback
  lead:        claude          # plan / ceo / review / docs 클러스터
  worker:      codex           # implementation-worker / dev division
  researcher:  gemini          # research_high
  # 재배치 예: lead: codex 로 한 줄만 바꿈 → OCP
unassigned_role_policy: use_selected_runtime   # standalone fallback
```

기존 16개 role을 3개 클러스터(lead/worker/researcher)로 그룹핑해 매핑. 세밀
제어는 role 단위 override 가능(개방).

### 4.3 Team presets (닫힌 기본값)

| preset | 구성 | dispatch |
|---|---|---|
| `solo` | 모든 role → selected_runtime (현재 동작) | off |
| `pair` | lead→claude, worker→codex | on |
| `trio` | lead→claude, worker→codex, researcher→gemini (**기본 추천**) | on |

preset은 4.2 binding의 미리 채운 묶음일 뿐. 선택 후 자유 override.

### 4.4 Entry-agnostic auto-dispatch contract (신규)

각 어댑터(CLAUDE/AGENTS/GEMINI.md) 생성 시 동일 dispatch rule을 role-scoped 주입:

```
진입 agent
  │ 1. team preset + bindings + registry 로드
  │ 2. 현재 작업 role 판정 (plan/review/docs=lead, 구현=worker, 조사=researcher)
  ▼
자기 role?
  ├─ 예 → 직접 수행
  └─ 아니오 → 3. capsule 발행(typed 8필드) → registry.invoke[target] headless 호출
                4. 결과 capsule 회수 → 5. (lead면) 통합·리뷰·문서화
```

- 실제 CLI 호출은 `registry.invoke` 템플릿 사용(새 runtime도 동일 경로). 선택적
  헬퍼 `sfs dispatch <role> <capsule-path>`가 3~4단계 캡슐화. dispatch off(solo)면
  2단계 후 항상 "직접 수행" → standalone 보장.

**예시 (trio, 진입=codex):** codex가 "설계 필요" 작업을 받으면 lead capsule 발행 →
claude headless → 설계/리뷰 회수 → 자신은 worker 구현 → 리서치 시 gemini dispatch.
진입이 claude/gemini여도 동일.

### 4.5 OCP 확장 시나리오 (검증용)

역할 재배치(`lead: claude`→`lead: codex` 한 줄), 새 CLI 추가(`runtime_registry`
항목 + binding 1줄), preset 신설(binding 묶음 추가) — 셋 다 코드/분기 로직 불변.

## 5. 옵션 표면

- **install.sh / upgrade.sh**: `--team solo|pair|trio` + `SFS_AGENT_TEAM` env, 기본
  `solo` (`--layout`/`--with-agent-adapters` 패턴 재사용).
- **model-profiles.yaml**: `runtime_registry` + `agent_runtime_bindings` +
  `team_preset` + `unassigned_role_policy` 섹션(backward-compatible, 기본 solo).
- **어댑터 생성**: `INSTALL_AGENT_ADAPTERS=1`일 때 CLAUDE/AGENTS/GEMINI.md에
  role-scoped 지시 + dispatch rule 주입.
- **doctor/drift**: bindings ↔ registry ↔ preset 불일치 경고(drift 감지 확장).

## 6. Standalone & 안전

- **제거 테스트**: team/dispatch 전 표면 제거 → solo로 모든 명령·gate·release 통과.
- **비용/쿼터**: trio = 3 구독/키. doctor advisory로 안내.
- **credential per-runtime**: 각 CLI 키는 boundary attachment + per-consumer 스코프(credential-hygiene 재사용). prompt/capsule 파일에 키 금지.
- **무한 dispatch 방지**: dispatch hop 상한 + role 순환 감지.

## 7. Acceptance Criteria

1. `--team trio` 설치 시 model-profiles에 registry+bindings 생성, 어댑터 3종에
   dispatch rule 주입.
2. `agent_runtime_bindings`의 `lead` 한 줄 변경으로 설계 담당 runtime이 바뀐다
   (코드 diff 0). — **OCP 회귀잠금**.
3. `runtime_registry`에 가짜 4번째 runtime 추가 시 dispatch가 그 invoke 템플릿을
   호출한다(코드 diff 0).
4. team/dispatch 제거 후 solo로 run-all 전부 통과 — **standalone 회귀잠금**.
5. 진입 어댑터(claude/codex/gemini) 3종 모두 동일 binding을 읽고 동일 role 판정.
6. 미배정 role은 `selected_runtime`으로 fallback.

## 8. 결정 (Resolved — 2026-06-23)

- **D1 — CLI headless 문법: 확정(실측).** §4.1 invoke 템플릿. claude
  `claude -p … --output-format json`, codex `codex exec … --sandbox workspace-write`
  (+`CODEX_NON_INTERACTIVE=1`), gemini→**antigravity `agy -p … --output-format json`**
  (gemini-cli 2026-06-18 sunset). registry에 4종 등록, default gemini=antigravity.
- **D2 — dispatch 실행 주체: `sfs dispatch` 헬퍼가 1차 메커니즘.** 어댑터는 "자기
  role 아니면 `sfs dispatch <role> <capsule>` 호출" 얇은 규약만. 근거: entry-agnostic
  · OCP(invoke 템플릿이 sfs 한 곳) · standalone(헬퍼 없어도 solo). 외부
  오케스트레이터(Hermes)는 그 위 선택적 상위 계층(제거 가능).
- **D3 — 결과 회수: 동기 1-shot(blocking) 기본 + capsule `timeout` 가드.** 장시간은
  `output_paths` 폴링(async)을 P3 옵션으로. 무한 dispatch는 hop 상한 + 순환 감지 차단.
- **D4 — config 위치: `model-profiles.yaml` 내 섹션 확정.** `runtime_registry` +
  `agent_runtime_bindings` + `team_preset` + `unassigned_role_policy`. 별도 team.yaml
  분리 안 함(SSoT 일관성, drift 감지 재사용).

**남은 실측(P3, blocking 아님)**: codex `exec` JSON 플래그 정확형, antigravity `agy` 인증/SSH, 각 CLI stdin vs 파일 prompt 한계 — 구현 중 실측.

## 9. 단계 (phasing)

- **P0 (이 문서)**: 설계 확정 + AC 합의.
- **P1**: runtime_registry + agent_runtime_bindings 스키마 + solo 무변경 보장 +
  OCP/standalone headline test (아직 dispatch 미배선).
- **P2**: `--team` preset + 어댑터 dispatch rule 주입(규약 문서).
- **P3**: `sfs dispatch` 헬퍼 + CLI invoke 실측 + loop/cost 가드.

> P1은 "데이터 표면 + 회귀잠금"만으로 끝나 standalone을 안 깬다. 실제 자동 호출(P3)은 그 위에 얹는다 — 점진 도입.
