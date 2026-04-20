---
command_id: "sfs-install"
command_name: "/sfs install"
version: "2.0.0"                      # v0.4-r3 재설계: Socratic wizard + division-aware
phase: "setup"
mode: "common"                        # 내부적으로 --mode greenfield|brownfield 선택
operator: "user-cli"                  # 사람이 직접 실행 (agent 아님)
triggers:
  - "install"
  - "설치"
  - "initialize"
  - "setup"
  - "init"
  - "solon install"
requires_gate_before: []              # 최초 진입점
produces:
  - ".solon/config.yaml"
  - ".solon/divisions.yaml"           # v0.4-r3: 2개 active + 4개 abstract
  - "docs/.solon-version"
  # brownfield only:
  - ".solon-manifest.yaml"
calls_evaluators: []                   # install 자체는 평가자 호출 없음
model_allocation:
  default: "claude-haiku-4-5-20251001"
  opus_allowed: false
cost_budget_usd: 0.10
timeout_ms: 120000                    # 대화형 wizard 포함 (60s→120s)
tool_restrictions:
  allowed: ["Read", "Write", "Bash(plugin-install-only)", "AskUserQuestion"]
  forbidden: ["Edit(on existing user files)", "NotebookEdit"]
audit_fields: ["called_at", "install_id", "mode", "tier_profile", "l3_backend", "wizard_trace_id"]
references:
  - "07-plugin-distribution.md §7.2 플러그인 개요"
  - "07-plugin-distribution.md §7.3 install.sh 동작"
  - "07-plugin-distribution.md §7.4 Tier Profile & L3 Backend"
  - "07-plugin-distribution.md §7.10 Brownfield 모드"
  - "02-design-principles.md §2.11 원칙 11 brownfield-first-pass"
  - "02-design-principles.md §2.13 원칙 13 progressive-activation 🆕"
  - "10-phase1-implementation.md §10.11 CLI-First Tool Selection Policy 🆕"
  - "appendix/dialogs/division-activation.dialog.yaml (wizard 의 기반 패턴)"
---

# /sfs install (v2.0 — Socratic Wizard)

## 의도 (Intent)

Solon 플러그인을 프로젝트에 초기화하는 **단일 진입점**.

v0.4-r3 부터는 **Socratic wizard 를 기본값** 으로 제공한다. 설치 자체가 원칙 13
(progressive-activation + non-prescriptive) 의 첫 적용 지점이다.

- 사용자에게 단계별로 질문하고 **3-tier + 👍/⚪/⚠ 옵션 카드** 를 제시
- 플래그로 전체 답을 넘기면 **질문 생략, 기본값 경로 실행**
- 결과 미리보기(dry-run) 를 항상 보여주고 **최종 확정 체크포인트** 1 회

### 두 가지 모드

- **greenfield (default)**: 신규 repo 또는 빈 프로젝트. 기본 구조 생성 후 `/sfs brainstorm` 안내.
- **brownfield**: 이미 코드·docs 존재. `P-1 Discovery` + `G-1 Intake Gate` 자동 트리거.

---

## 입력 (Input)

### 모든 입력은 선택사항 (wizard 가 질문으로 대체)

| 플래그 | 값 | wizard 질문 시점 | 기본값 |
| --- | --- | --- | --- |
| `--project-path <path>` | repo 루트 | (질문 없음, 현재 위치) | `cwd` |
| `--mode` | `greenfield` / `brownfield` | Q2 | 자동 감지 |
| `--tier-profile` | `minimal` / `standard` / `collab` | Q3 | `minimal` |
| `--l3-backend` | `notion` / `none` / `obsidian` / `logseq` / `confluence` / `custom` | Q4 | `notion` |
| `--activate` | `divisions` list | Q5 (optional preview) | `dev,strategy-pm` (Phase 1 기본) |
| `--yes` | (flag) | 전체 wizard skip | — |
| `--dry-run` | (flag) | dry-run preview 만 | — |
| `--no-wizard` | (flag) | 플래그만으로 실행, 질문 스킵 | — |

### CLI 호출 예시

```bash
# (권장) 대화형 wizard
/sfs install

# 플래그 전체 전달 (no-wizard)
/sfs install --mode brownfield --tier-profile collab --l3-backend notion --no-wizard

# dry-run preview
/sfs install --dry-run

# 자동 승인 (CI/CD, 모든 질문 skip → 기본값 사용)
/sfs install --yes
```

---

## Socratic Wizard Flow

**단계 수**: 최대 6 개. 각 단계는 skip 가능 (`-` 입력 또는 Enter = default).

### Phase 0 — 환경 점검 (질문 없음)

- Claude Code CLI 버전 확인 (`>= 1.0.0`)
- git 저장소 여부 (`.git/`)
- write 권한
- Cowork 설치 여부 (optional, warn only)
- 기존 `.solon/config.yaml` 존재 여부 (`--force` 없으면 중단)

### Q1 — Repo 상태 감지 & 모드 확정

**system 자동 감지**:
- 빈 repo (<10 파일) → greenfield 제안
- 파일 다수 + README + src/ → brownfield 제안

**사용자 질문** (감지 결과를 기본값으로):
```
Q1: 이 repo 는 어떻게 보이세요?
  👍 brownfield — 기존 코드와 docs 가 있습니다 (감지됨: 347 파일)
  ⚪ greenfield — 새 프로젝트, 빈 상태로 시작
  ⚠ 뭔지 모르겠음 — dry-run 으로 먼저 살펴보기
  — 취소
```

### Q2 — Tier Profile 선택

context: "운영 tier 는 Phase 1 비용·기능 범위를 결정합니다"

```
Q2: 어떤 tier 로 시작하시겠어요?
  👍 minimal — 1인 / 월 예산 ≤ $50 / 기본 L1+L2
  ⚪ standard — 2~5인 / 월 예산 ~$200 / L3 대시보드 추가
  ⚪ collab — 6+ 인 / 팀 협업 / full observability
  — minimal 로 진행 (skip)
```

(v0.4-r3 Phase 1 에서는 minimal 외 선택 시 "Phase 1 은 minimal 로 폴백, 기록만 저장" 경고 표시. 실제 폴백은 수용 — 원칙 13 never-hard-block.)

### Q3 — L3 Backend 선택

context: "L3 대시보드는 사람이 보는 요약 뷰입니다. 나중에 바꿀 수 있어요."

```
Q3: L3 대시보드 백엔드를 고르세요.
  👍 notion — 대부분의 팀 (API 공식 지원, CLI-first 연동)
  ⚪ none — 대시보드 없이 L1+L2 만
  ⚪ obsidian — 로컬 파일 기반, 1인 사용자 적합
  ⚪ logseq — 로컬 + outline 선호
  ⚠ confluence — 기존 계정 있을 때만 (API 복잡)
  ⚪ custom — 직접 driver 작성
  — notion (skip)
```

### Q4 — Brownfield 전용 추가 질문 (mode=brownfield 일 때만)

```
Q4a: 기존 docs 와 어떻게 공존할까요?
  👍 coexist — 기존 docs/ 유지 + .solon-manifest.yaml 로 매핑
  ⚪ keep — 기존 구조 그대로, Solon 은 별도 경로
  ⚠ archive — 기존 docs 를 docs-legacy/ 로 이동 (파괴적)
  — coexist (skip)
```

```
Q4b: /sfs discover 를 지금 실행할까요?
  👍 지금 실행 (권장) — 설치 직후 P-1 + G-1 자동
  ⚪ 나중에 실행 — install 만 완료하고 수동으로 /sfs discover
  — 지금 실행 (skip)
```

### Q5 — Division Activation Preview 🆕 (v0.4-r3)

**원칙 13 의 install 시점 적용**: 6 본부 중 4 개를 **abstract** 로 설치.

```
Q5: 본부 활성화 전략을 보여드릴게요. (원칙 13 — 필요할 때 활성화)

Phase 1 기본 활성:
  ✅ dev           — 코드·시스템 구현
  ✅ strategy-pm   — 제품 전략·우선순위

Phase 1 기본 비활성 (abstract, 나중에 /sfs division activate):
  ⚪ qa            — MVP 출시 임박 시 활성
  ⚪ design        — 첫 유입 발생 시 활성
  ⚪ infra         — Vercel 한계 도달 시 활성
  ⚪ taxonomy      — 도메인 용어가 복잡할 때 활성

이 구성으로 진행할까요?
  👍 예 — Phase 1 기본 (2 active, 4 abstract)
  ⚪ qa 도 지금 active — MVP 출시 1달 이내
  ⚪ taxonomy 도 지금 active — 보험/의료/법률 도메인
  ⚠ 6개 모두 active — 1인 환경에서는 overkill 위험
  — Phase 1 기본 (skip)
```

### Q6 — 최종 확정 (dry-run preview 표시 후)

```
[install wizard] 아래 변경사항을 수행합니다:
  - mode:           brownfield
  - tier_profile:   minimal
  - l3_backend:     notion
  - divisions:      [dev, strategy-pm] active + [qa, design, infra, taxonomy] abstract
  - create:         .solon/config.yaml, .solon/divisions.yaml, docs/00-governance..09-learnings
  - hook:           .git/hooks/post-commit
  - symlink:        ~/.claude/plugins/solon/ → ./.solon/plugin/
  - manifest:       .solon-manifest.yaml (coexist)
  - auto-trigger:   /sfs discover (예상 $2~$15)

Q6: 진행하시겠어요?
  👍 예, 진행
  ⚪ --dry-run 으로 다시 (실제 실행 안 함)
  — 취소
```

---

## 절차 (Procedure — 실제 실행 단계)

1. **Phase 0 환경 검증** (Haiku, < 5s)
2. **wizard 질문 Q1~Q6** (또는 flag 기반 skip)
3. **core 디렉토리 생성**
   - `.solon/` (config 저장)
   - `docs/{00-governance, 01-plan, 02-design, 03-implementation, 04-qa, 05-escalation, 09-learnings}`
4. **config 파일 작성**
   - `.solon/config.yaml`
   - `.solon/divisions.yaml` — **v0.4-r3**: `activation_state` 포함, 2 active + 4 abstract
   - `docs/.solon-version`
5. **git hook + plugin symlink 설치**
6. **mode 분기**:
   - greenfield → `l1.install.complete` 후 "`/sfs brainstorm` 안내"
   - brownfield → `l1.install.complete` → `/sfs discover` 자동 호출 (또는 Q4b 에서 "나중"이면 보류)
7. **wizard_trace_id 기록**: `dlg-install-YYYY-MM-DD-<install_id>-00` 형태로 L1 저장

### `.solon/divisions.yaml` v0.4-r3 초기 내용

```yaml
schema_version: 1.1
divisions:
  - id: dev
    activation_state: active
    activation_scope: full
    tier: core
    recommendation_trigger: manual
  - id: strategy-pm
    activation_state: active
    activation_scope: full
    tier: core
    recommendation_trigger: manual
  - id: qa
    activation_state: abstract
    tier: core
  - id: design
    activation_state: abstract
    tier: opt-in
  - id: infra
    activation_state: abstract
    tier: opt-in
  - id: taxonomy
    activation_state: abstract
    tier: opt-in
```

---

## 산출물 (Output)

### 공통
- `.solon/config.yaml` — 전역 설정 (install_id, mode, tier_profile, l3_backend, wizard_trace_id)
- `.solon/divisions.yaml` — **6 division, 2 active + 4 abstract** (v0.4-r3)
- `docs/.solon-version` — 버전 고정

### Brownfield 추가
- `.solon-manifest.yaml` — 기존 docs 공존 전략 (Q4a 결과)
  - 실제 내용은 `/sfs discover` Pass 3 에서 채움

### L1 이벤트

```json
{
  "event_type": "l1.install.complete",
  "install_id": "inst-<ulid>",
  "wizard_trace_id": "dlg-install-2026-04-25-inst-XXX-00",
  "mode": "greenfield|brownfield",
  "tier_profile": "minimal|standard|collab",
  "l3_backend": "notion|none|obsidian|logseq|confluence|custom",
  "divisions_active": ["dev", "strategy-pm"],
  "divisions_abstract": ["qa", "design", "infra", "taxonomy"],
  "solon_version": "0.4.0",
  "wizard_questions_asked": 6,
  "wizard_overrides": [
    {"q": "Q2", "recommended": "minimal", "chosen": "standard"}
  ],
  "called_at": "2026-04-25T12:34:56Z",
  "dry_run": false,
  "warnings": []
}
```

---

## 오류 처리 (Error Handling)

| Error | 원인 | 복구 |
| --- | --- | --- |
| `E_NOT_GIT_REPO` | `.git/` 없음 | `git init` 제안 후 retry, `--allow-no-git` (비권장) |
| `E_PERMISSION_DENIED` | write 권한 부족 | chmod 안내, 종료 |
| `E_PLUGIN_ALREADY_INSTALLED` | `.solon/config.yaml` 존재 | `--force` 또는 `/sfs status` 제안 |
| `E_UNKNOWN_L3_DRIVER` | 등록되지 않은 driver | 지원 driver 목록 출력 |
| `E_BROWNFIELD_EMPTY_REPO` | `--mode brownfield` 인데 빈 repo | greenfield 재확인 (Q1) |
| `E_SYMLINK_FAILED` | Cowork symlink 실패 | CLI 단독 fallback, 경고 |
| `E_COWORK_NOT_INSTALLED` | Cowork Desktop 없음 | warn only, 계속 진행 |
| `E_WIZARD_ABANDONED` | 사용자 중간 종료 | resume_context 저장 (dialog-state.schema.yaml 참조) |
| `E_WIZARD_TIMEOUT` | 120s 응답 없음 | auto-save + abandoned 상태, 재개 시 resume prompt |

---

## 예시 (Examples)

### 예시 1: 신규 프로젝트 + wizard 전체 실행

```bash
$ cd my-new-saas
$ /sfs install

[install] 환경 점검 완료.
[install] Q1: 이 repo 는 어떻게 보이세요?
  👍 greenfield — 감지됨 (빈 repo)
  ⚪ brownfield
  — greenfield (skip)
>

[install] Q2: tier 선택
  👍 minimal
  ⚪ standard
  ⚪ collab
> minimal

[install] Q3: L3 backend
  👍 notion
  ...
> notion

[install] Q5: Phase 1 기본 활성 (dev + strategy-pm, 나머지 abstract) 로 진행?
  👍 예
> y

[install] dry-run preview:
  - mode: greenfield / tier: minimal / l3: notion
  - divisions: dev+strategy-pm active, qa/design/infra/taxonomy abstract
  - 생성: .solon/, docs/00-governance..09-learnings, hooks, symlink

[install] Q6: 진행?
> y
[install] 완료 (install_id: inst-01HXYZABC)

Next: `/sfs brainstorm` 으로 첫 Initiative 시작.
```

### 예시 2: Brownfield + CLI flags (no-wizard)

```bash
$ cd legacy-monorepo
$ /sfs install --mode brownfield --tier-profile minimal --l3-backend notion --no-wizard
[install] wizard 생략 (flag 전체 제공)
[install] 환경 점검 완료.
[install] 디렉토리 생성 완료.
[install] .solon-manifest.yaml stub 생성 (coexist, default).
[install] 이어서 /sfs discover 자동 호출...
[discover] Pass 1/3: Read-only inventory ...
```

### 예시 3: dry-run 으로 계획만 확인

```bash
$ /sfs install --dry-run --mode brownfield
[install] (dry-run) 아래 변경사항이 수행됩니다:
  - Create dir: .solon/
  - Create dir: docs/{00-governance..09-learnings}
  - Create: .solon/config.yaml
  - Create: .solon/divisions.yaml (6 divisions: 2 active + 4 abstract)
  - Create: .solon-manifest.yaml (empty stub, coexist default)
  - Install hook: .git/hooks/post-commit
  - Symlink: ~/.claude/plugins/solon/ → ./.solon/plugin/
  - Trigger: /sfs discover (예상 $2~$15, medium repo)
(변경 없음. 실제 실행하려면 --dry-run 제거)
```

### 예시 4: 사용자 override (원칙 13 실제 동작)

```bash
$ /sfs install
[install] Q2: tier 선택
  👍 minimal   ⚪ standard   ⚪ collab
> collab

[install] ⚠ Phase 1 은 minimal 권장입니다. collab 선택 시 일부 기능이 minimal 로 폴백될 수 있습니다.
        alternatives:
          - standard 로 시작 → Phase 2 에서 collab 승격
          - minimal 로 시작 → tier-profile 변경은 /sfs config tier 로 가능
        계속하시겠어요?
> y

[install] recommendation_trigger=declined, warnings=["phase1_tier_override:collab→partial"]
[install] 진행...
```

---

## Wizard 와 Dialog 통합

본 wizard 는 `appendix/dialogs/division-activation.dialog.yaml` 과 동일한 구조(5-phase:
A context / B why-now / C clarify / D option / E terminal) 를 따르지만, 본부 활성화가 아닌
**install 설정**을 대상으로 한다. 모든 L1 이벤트, override 기록, resume 프로토콜은 동일 규약 적용.

- `dialog_id`: `install-wizard` (division-activation 과 별개)
- `wizard_trace_id` 형식: `dlg-install-YYYY-MM-DD-<install_id>-00`
- INV-3 (never-hard-block) 동일 적용 — ⚠ 선택 시 경고 + 진행 가능

---

## 관련 docs

- `README.md` — 사용자 온보딩 전체 흐름
- `07-plugin-distribution.md §7.3` — install.sh 내부 동작
- `07-plugin-distribution.md §7.4` — Tier Profile & L3 Backend 조합표
- `07-plugin-distribution.md §7.10` — Brownfield 모드 개요
- `10-phase1-implementation.md §10.11` — CLI-First Tool Selection Policy 🆕
- `02-design-principles.md §2.13` — 원칙 13 progressive-activation 🆕
- `appendix/commands/discover.md` — brownfield 시 자동 호출
- `appendix/commands/brainstorm.md` — greenfield 다음 단계
- `appendix/commands/division.md` — 설치 후 본부 활성화
- `appendix/dialogs/division-activation.dialog.yaml` — wizard 의 기반 패턴
- `appendix/schemas/dialog-state.schema.yaml` — resume/override 프로토콜
- `appendix/drivers/_INTERFACE.md` — L3 driver 계약
