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
custom) 하나가 프로젝트 전체에 걸리고 그 안에서 16개 agent-role이 8 tier로 라우팅된다.
divisions(역할 축)와 runtime 축은 이미 분리됐지만 runtime은 프로젝트당 하나뿐.

사용자 요구: ① **이종 역할 전문화**(claude=lead, codex=worker, antigravity=researcher);
② **자동 업무분배**(진입 CLI 무관); ③ **OCP**(역할 재배치 + N번째 CLI 가 설정만으로);
④ **opt-in**(기본 solo는 현재 동작 그대로).

## 2. 목표 / 비목표

**목표**: team preset(solo/pair/trio)을 install·config 옵션으로; 선언적
`role → runtime` binding(override 자유); entry-agnostic auto-dispatch; OCP(agent
enum-하드코딩 0, runtime은 데이터); standalone guarantee 유지.

**비목표**: solo 동작 변경 0; 새 역할 체계 신설(기존 divisions/agent-role 재사용);
agent 강제 spawn/상시 데몬(dispatch는 opt-in, headless 1-shot).

## 3. 설계 원칙 (1원칙 = OCP)

1. **OCP — binding은 데이터, 코드 아님.** role↔runtime 매핑·CLI 호출법 전부 설정
   데이터. 역할 재배치/새 CLI = **config edit only**, 분기 코드 0. preset=닫힌 기본값,
   `agent_runtime_bindings` override = 열린 확장점.
2. **Standalone guarantee.** team/dispatch 레이어 제거해도 모든 gate/release 동일 동작.
3. **기존 표면 재사용.** divisions, capsule-contract(8필드), advisor↔Code 파일버스,
   external-orchestrator-entry, credential-hygiene 그대로. 새 통신 규약 신설 금지.
4. **Entry-agnostic.** 진입 agent 무관 같은 binding/registry 읽고 같은 판정.

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

**예시 (trio, 진입=codex):** "설계 필요" 작업 → lead capsule 발행 → claude headless →
설계/리뷰 회수 → 자신은 worker 구현 → 리서치 시 researcher dispatch. 진입 무관 동일.

### 4.5 OCP 확장 시나리오 (검증용)

역할 재배치(`lead:` 한 줄), 새 CLI 추가(`runtime_registry` 항목 + binding 1줄),
preset 신설(`team_preset_catalog` 묶음 추가) — 셋 다 분기 코드 불변.

## 5. 옵션 표면

- **install.sh / upgrade.sh**: `--team solo|pair|trio` + `SFS_AGENT_TEAM`, 기본 `solo`.
- **model-profiles.yaml**: `runtime_registry` + `agent_runtime_bindings` + `team_preset`
  + `team_preset_catalog` + `unassigned_role_policy`(backward-compatible, 기본 solo).
- **어댑터**: team≠solo 일 때 CLAUDE/AGENTS/GEMINI.md frontmatter 에 `team_dispatch:` 주입.
- **doctor/drift**: bindings ↔ registry ↔ preset 불일치 경고.

## 6. Standalone & 안전

- **제거 테스트**: team/dispatch 표면 제거 → solo로 모든 명령·gate·release 통과.
- **비용/쿼터**: trio = 3 구독/키 (doctor advisory). **무한 dispatch**: hop 상한 + 순환 감지.
- **credential per-runtime**: CLI 키는 boundary attachment + per-consumer 스코프 재사용. prompt/capsule 에 키 금지.

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
- **D2 — dispatch 실행 주체: 헬퍼가 1차 메커니즘(명칭은 D5 참조).** 어댑터는 "자기
  role 아니면 헬퍼 호출" 얇은 규약만. 근거: entry-agnostic · OCP · standalone(헬퍼
  없어도 solo). Hermes 는 그 위 선택적 상위 계층.
- **D3 — 결과 회수: 동기 1-shot + capsule `timeout`.** 장시간은 async 폴링을 P3 옵션.
- **D4 — config 위치: `model-profiles.yaml` 내 섹션.** 별도 team.yaml 분리 안 함.
  남은 실측(P3): codex `exec` JSON 플래그, `agy` 인증/SSH, stdin vs 파일 prompt 한계.

### 8.1 결정 (Resolved — 2026-06-24, P2/P3 구현)

- **D5 — P3 헬퍼명 = `sfs route <role> <capsule>` (D2의 `sfs dispatch` 폐기).**
  `dispatch`=라우터 엔진 자체(`sfs-dispatch.sh` exec), `handoff`=점유됨. 의미는 D2
  그대로, 이름만 `route`. usage + dispatch case 등록.
- **D6 — preset→bindings 는 데이터(`team_preset_catalog`).** `sfs team preset-bindings
  <preset>` (read-only) 가 묶음을 방출 → install/upgrade 가 `agent_runtime_bindings:` 에
  박음. 새 preset = 카탈로그 묶음 추가, 코드 diff 0 → OCP(§4.5 3번째 시나리오 잠금).
- **D7 — dispatch rule 주입 = 설치본 어댑터 frontmatter `team_dispatch:` 키.** dist
  템플릿 불변(solo 무변경 + `test-thin-agent-adapter-docs.sh` 게이트 통과). team≠solo 일
  때만 `$TARGET/{CLAUDE,AGENTS,GEMINI}.md` 닫는 `---` 앞에 동일 블록 삽입(entry-agnostic).
- **D8 — `--team` 기본 solo, backward-compatible.** `--team solo|pair|trio` +
  `SFS_AGENT_TEAM`. 미지정=solo=무변경(bindings `{}`, dispatch 키 부재). upgrade 는
  `--team` 명시 시에만 재머티리얼라이즈(idempotent), 미지정 시 기존 team 설정 불변.

## 9. 단계 (phasing)

- **P0**: 설계 확정 + AC 합의. **P1** ✅(0.8.42): registry + bindings 스키마 + solo
  무변경 + OCP/standalone headline test.
- **P2** ✅: `--team` preset 머티리얼라이즈 + 어댑터 `team_dispatch:` 주입 (install/upgrade).
- **P3**: `sfs route` 헬퍼 + CLI invoke 실측 + hop/cost/loop 가드. 각 P는 데이터 표면 +
  회귀잠금만으로 standalone 불변 — 실제 자동 호출(P3)은 위에 얹음.
