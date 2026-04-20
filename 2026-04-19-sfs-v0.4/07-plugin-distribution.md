---
doc_id: sfs-v0.4-s07-plugin-distribution
title: "§7. Plugin 배포 + Phase 2 상품화 로드맵"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [implementers, packagers, product-owners]
required_reading_order: [s00, s02, s03, s07]

depends_on:
  - sfs-v0.4-s03-c-level-matrix

defines:
  - concept/sfs-plugin
  - structure/sfs-plugin-tree
  - phase/phase1-scope
  - phase/phase2-roadmap
  - rule/divisions-yaml-customization
  - concept/cli-cowork-shared-fs
  - rule/tier-backend-selection                           # 🆕 v0.4-r2
  - rule/plugin-drivers-dir                               # 🆕 v0.4-r2

references:
  - division/* (defined in: s03)
  - role/* (defined in: s03)
  - rule/model-allocation-concrete (defined in: s03)
  - principle/cli-gui-shared-backend (defined in: s02)
  - principle/phase1-phase2-separation (defined in: s02)
  - principle/human-final-filter (defined in: s02)         # 🆕 v0.4-r2
  - channel/l1-s3 (defined in: s08)
  - channel/l2-git-docs-submodule (defined in: s08)
  - channel/l3-human-view (defined in: s08)                # ← was channel/l3-notion
  - contract/l3-driver-interface-v1 (defined in: s08)      # 🆕 v0.4-r2
  - rule/driver-compatibility-warn-not-block (defined in: s08)  # 🆕 v0.4-r2
  - schema/divisions-yaml-v1 (defined in: appendix/schemas/divisions.schema.yaml)  # 🆕 v0.4-r2
  - impl/observability-sync (defined in: appendix/hooks/observability-sync.sample.ts)

affects:
  - sfs-v0.4-s10-phase1-implementation
---

# §7. Plugin 배포 + Phase 2 상품화 로드맵

> **Context Recap (자동 생성, 수정 금지)**
> Phase 1: **단일 sfs-plugin**으로 Claude Code(CLI) + Claude Desktop(Cowork)에 동시 설치.
> 두 환경이 같은 파일시스템 공유 → GUI 별도 빌드 불필요(원칙 2.7).
> v0.4-r2: 플러그인은 `tier_profile(minimal|standard|collab)` × `l3_backend(notion|none|obsidian|...)` 조합으로 배포 프로필을 선택하며,
> 신규 프로젝트뿐 아니라 **기존 프로젝트(brownfield) 도입 모드**도 지원한다 (§7.10).
> Phase 2: 상품화 (RBAC, 모듈화, multi-tenant, 마켓플레이스, driver 생태계).

---

## TOC

- 7.1 Phase 1: 단일 sfs-plugin 구조
- 7.2 plugin.json 핵심 필드
- 7.3 divisions.yaml — 커스터마이징 진입점
  - 7.3.4 tier × l3_backend × Claude 플랜 매트릭스 🆕 v0.4-r2
- 7.4 install.sh — CLI + Cowork 동시 설치 흐름
- 7.5 CLI ↔ Cowork 파일시스템 공유 메커니즘
- 7.6 Phase 2 상품화 로드맵
- 7.7 Phase 2 일정
- 7.8 배포 모드별 사용 시나리오
- 7.9 plugin 업데이트 & 버전 정책
- 7.10 Brownfield / 기존 프로젝트 도입 모드 🆕 v0.4-r2

---

## 7.1 Phase 1: 단일 sfs-plugin 구조

`concept/sfs-plugin`, `structure/sfs-plugin-tree`: Phase 1에서는 **하나의 플러그인 패키지**로 모든 기능을 배포한다. 모듈 분할은 Phase 2로 연기 (원칙 2.8 phase1-phase2-separation).

```
sfs-plugin/
├── plugin.json                       # 플러그인 매니페스트 (§7.2)
├── install.sh                        # 설치 스크립트 (§7.4)
├── README.md                         # 5분 퀵스타트
├── LICENSE                           # Phase 1은 MIT, Phase 2에서 dual license
│
├── config/
│   ├── divisions.yaml                # 본부 정의 (커스터마이징 진입점, §7.3)
│   ├── divisions.default.yaml        # 🆕 플러그인 제공 기본값 (보호 대상, §7.9.3)
│   ├── tier-profiles.yaml            # 🆕 v0.4-r2: minimal/standard/collab 정의
│   ├── l3-backends.yaml              # 🆕 v0.4-r2: driver 매니페스트 목록 + 기본값
│   ├── models.yaml                   # Opus/Sonnet/Haiku 할당 (§3.6)
│   ├── gates.yaml                    # G1~G5 트리거/임계치 (§5)
│   └── .env.example                  # S3, Notion API 키 예시
│
├── agents/
│   ├── c-level/                      # Opus tier (3개)
│   │   ├── ceo-planner.yaml          # role/ceo (§3.2)
│   │   ├── cto-generator.yaml        # role/cto
│   │   └── cpo-evaluator.yaml        # role/cpo
│   │
│   ├── division-leads/               # Sonnet tier (6개)
│   │   ├── strategy-pm-lead.yaml
│   │   ├── taxonomy-lead.yaml
│   │   ├── design-lead.yaml
│   │   ├── dev-lead.yaml
│   │   ├── qa-lead.yaml
│   │   └── infra-lead.yaml
│   │
│   ├── evaluators/                   # Sonnet tier, read_only=true (§3.5)
│   │   ├── plan-validator.yaml
│   │   ├── prd-validator.yaml
│   │   ├── user-flow-validator.yaml
│   │   ├── prd-lock-validator.yaml
│   │   ├── taxonomy-reqs-validator.yaml
│   │   ├── taxonomy-draft-validator.yaml
│   │   ├── taxonomy-consistency.yaml
│   │   ├── design-critique.yaml      # cowork plugin 재사용 (§5.2.2)
│   │   ├── design-reqs-validator.yaml
│   │   ├── accessibility-review.yaml # cowork 재사용
│   │   ├── design-handoff.yaml       # cowork 재사용
│   │   ├── design-validator.yaml     # bkit 재사용
│   │   ├── code-analyzer.yaml        # bkit 재사용
│   │   ├── gap-detector.yaml         # bkit 재사용
│   │   ├── test-case-validator.yaml
│   │   ├── qa-reqs-validator.yaml
│   │   ├── qa-readiness.yaml
│   │   ├── tech-reqs-validator.yaml
│   │   ├── infra-reqs-validator.yaml
│   │   ├── terraform-validator.yaml
│   │   ├── k8s-manifest-validator.yaml
│   │   ├── cost-estimator.yaml
│   │   ├── security-scan.yaml
│   │   └── sprint-retro-analyzer.yaml  # Opus tier (G5 전용)
│   │
│   └── workers/                       # Sonnet tier (Phase 1: 본부당 1명, §3.7)
│       ├── strategy-pm-worker.yaml
│       ├── taxonomy-worker.yaml
│       ├── design-worker.yaml
│       ├── dev-worker.yaml
│       ├── qa-worker.yaml
│       └── infra-worker.yaml
│
├── skills/
│   ├── sfs-pdca/                     # PDCA 전체 사이클 진행 (§4 구현)
│   │   ├── SKILL.md
│   │   └── prompts/
│   ├── sfs-gates/                    # Gate 호출 스킬 (§5 구현)
│   │   └── SKILL.md
│   ├── sfs-escalate/                 # Escalate-Plan 스킬 (§6 구현)
│   │   └── SKILL.md
│   ├── sfs-retro/                    # G5 Sprint Retro 스킬
│   │   └── SKILL.md
│   └── sfs-doc-validate/             # 문서 의존성 검증 (appendix/tooling)
│       ├── SKILL.md
│       └── validate.mjs
│
├── commands/
│   ├── pdca.md                       # /pdca (plan|design|do|check|act|status|escalate)
│   ├── sprint.md                     # /sprint (start|end|retro|status)
│   ├── escalate.md                   # /escalate {pdca-id} --case alpha|beta
│   ├── gate.md                       # /gate {G1..G5} {pdca-id}
│   └── doc-validate.md               # /doc-validate (frontmatter 검증)
│
├── hooks/
│   └── observability-sync.ts         # L1→L2→L3 sync (§8, appendix/hooks)
│
├── drivers/                          # 🆕 v0.4-r2: L3 driver 구현 레지스트리 (§8.11)
│   ├── notion/                       # Phase 1 default driver
│   │   ├── manifest.yaml             # contract/l3-driver-interface-v1 충족
│   │   ├── README.md                 # 설정 가이드
│   │   └── adapter.ts                # TS 구현 (MD 70% + TS 30% 경계)
│   ├── none/                         # driver 비활성 (L2-only 운영)
│   │   └── manifest.yaml
│   └── _template/                    # community driver 추가용 skeleton (Phase 2)
│       ├── manifest.yaml
│       └── README.md
│
├── templates/                         # PDCA 템플릿 (appendix/templates)
│   ├── plan.md
│   ├── design.md
│   ├── analysis.md                   # Check 산출물
│   └── report.md                     # Act 산출물
│
└── schemas/                           # 표준 스키마 (appendix/schemas)
    ├── gate-report.schema.yaml       # §5.4
    ├── escalation.schema.yaml        # §6.7
    └── l1-log-event.schema.yaml      # §8 L1 이벤트
```

### 7.1.1 파일 수 요약

| 카테고리 | Phase 1 파일 수 | 비고 |
|---------|:---:|------|
| agents/c-level | 3 | Opus |
| agents/division-leads | 6 | Sonnet |
| agents/evaluators | 24 | Sonnet (+ sprint-retro-analyzer Opus 1) |
| agents/workers | 6 | Sonnet |
| agents/discovery (brownfield) | 1 | 🆕 v0.4-r2: `brownfield-discovery-worker` (§7.10) |
| skills | 6 | sfs-* 전용 (+ `sfs-discover` 🆕) |
| commands | 6 | slash commands (+ `/sfs discover` 🆕) |
| hooks | 1 | observability-sync.ts |
| templates | 5 | PDCA 4개 + `discovery-report.md` 🆕 |
| schemas | 4 | v1 freeze (+ `discovery-report.schema.yaml` 🆕) |
| drivers | 3 | 🆕 v0.4-r2: notion / none / _template |
| config | 6 | divisions + default + tier + l3-backends + models + gates (+ .env 예시) |
| **합계 (yaml/md 기준)** | **~75** | v0.4-r2 확장분 포함 |

### 7.1.2 의도적으로 **포함하지 않는** 것

- **상품 특화 agent** (예: commerce-seller-lead) — Phase 2 마켓플레이스에 `sfs-commerce` 등 별도 플러그인
- **유료 Evaluator** — Phase 1은 모두 MIT
- **UI 대시보드 바이너리** — L3 Notion 템플릿(.yaml)만 제공 (§8)
- **자체 MCP 서버** — Phase 1은 Claude 기본 tool + git/파일만 사용

→ "얇지만 완결된 코어"가 Phase 1 원칙.

### 7.1.3 플러그인 루트에 `docs/`가 없는 이유

`docs/`는 **플러그인 사용자의 프로젝트**에 생긴다 (L2 SSoT). 플러그인 자체에는 포함하지 않음. 이유:
- 플러그인이 업데이트되어도 사용자의 `docs/`는 영향받지 않음 (독립성)
- L2 SSoT는 사용자의 git history이지 플러그인 history가 아님
- Phase 2의 docs.sfs.dev 사이트는 **플러그인 문서**, 사용자의 docs/는 **프로젝트 문서** — 완전히 분리

---

## 7.2 plugin.json 핵심 필드

```json
{
  "name": "sfs-plugin",
  "displayName": "Solo Founder Agent System",
  "version": "0.4.0",
  "description": "Company-as-Code agent system for 1-person founders (6 divisions × 3 C-Level).",
  "license": "MIT",

  "engines": {
    "claude-code": ">=1.5.0",
    "claude-desktop-cowork": ">=0.2.0"
  },

  "agents": "./agents/**/*.yaml",
  "skills": "./skills/",
  "commands": "./commands/",

  "hooks": {
    "PostToolUse": "./hooks/observability-sync.ts",
    "Stop": "./hooks/observability-sync.ts"
  },

  "config": {
    "divisions": "./config/divisions.yaml",
    "divisions_default": "./config/divisions.default.yaml",
    "tier_profiles": "./config/tier-profiles.yaml",
    "l3_backends": "./config/l3-backends.yaml",
    "models": "./config/models.yaml",
    "gates": "./config/gates.yaml"
  },

  "profile_defaults": {
    "tier_profile": "minimal",
    "l3_backend": "notion",
    "install_mode": "greenfield"
  },

  "drivers": {
    "registry": "./drivers/",
    "phase1_supported": ["notion", "none"],
    "phase2_planned": ["obsidian", "logseq", "confluence", "custom"]
  },

  "install_modes": {
    "greenfield": "새 프로젝트. 빈 docs/ 생성.",
    "brownfield": "기존 프로젝트. /sfs discover 필수 (§7.10)."
  },

  "env": {
    "required": [],
    "optional": [
      "AWS_S3_BUCKET",
      "AWS_REGION",
      "NOTION_API_KEY",
      "NOTION_DATABASE_ID"
    ]
  },

  "peerDependencies": {
    "bkit": ">=1.5.0",
    "cowork-design": ">=0.1.0"
  },

  "phases": {
    "current": "phase1",
    "next": "phase2",
    "next_eta": "2026-Q3 (잠정)"
  }
}
```

### 7.2.1 주요 필드 의미

| 필드 | 역할 |
|------|------|
| `engines` | **양쪽 엔진 동시 지원**이 Phase 1의 핵심 (원칙 2.7). 한쪽만 지원하면 GUI/CLI 분리가 깨진다. |
| `agents` glob | 새 agent 추가 시 `plugin.json` 수정 없이 파일만 추가하면 자동 로드 |
| `hooks.PostToolUse / Stop` | L1 로깅 + L2 commit + L3 sync 자동 실행 (§8) |
| `env.required: []` | Phase 1은 **환경 변수 없이도 실행 가능** (로컬 파일만으로 동작). S3/Notion은 optional |
| `peerDependencies` | bkit/cowork를 재사용하되 **플러그인 동시 설치 필수**는 아님 (soft dep, missing 시 해당 evaluator만 비활성) |
| `profile_defaults.tier_profile` | 🆕 v0.4-r2. `minimal`/`standard`/`collab` 중 install 시점 기본값. 사용자는 `config/divisions.yaml`의 `tier_profile`로 override 가능 (§7.3.4). |
| `profile_defaults.l3_backend` | 🆕 v0.4-r2. Phase 1 default=`notion`. `none`이면 L2-only 운영. 다른 값은 Phase 2 driver 완성 이후 지원. |
| `profile_defaults.install_mode` | 🆕 v0.4-r2. `greenfield`(기본)와 `brownfield`(기존 프로젝트 도입, §7.10). install.sh의 `--mode` 플래그로 override. |
| `drivers.registry` | 🆕 v0.4-r2. `drivers/` 디렉토리 루트. 각 하위 폴더의 `manifest.yaml`이 `contract/l3-driver-interface-v1`을 선언 (§8.11). |
| `drivers.phase1_supported` | 🆕 v0.4-r2. Phase 1 release에서 공식 지원하는 driver 화이트리스트. 이 외 값은 install 시 경고(block 아님). `rule/driver-compatibility-warn-not-block` 준수. |

### 7.2.2 env optional 처리

- `AWS_S3_BUCKET`이 없으면 → L1 로깅은 로컬 파일(`.sfs-local/logs/`)로 대체
- `NOTION_API_KEY`가 없으면 → L3 동기화 건너뜀, L2 git만 유지
- 모든 observability는 **graceful degradation** (§8.X)

→ **오프라인 1일차에도 동작**이 Phase 1의 개발자 경험 원칙.

---

## 7.3 divisions.yaml — 커스터마이징 진입점

`rule/divisions-yaml-customization`: 본부 정의는 **YAML로 관리**, 하드코딩 금지. 사용자는 이 한 파일만 수정해서 자기 조직 형태를 정의한다.

```yaml
# ────────────────────────────────────────────────
# sfs-plugin/config/divisions.yaml
# Phase 1 기본값 (6 본부). 사용자 override 가능.
# schema: appendix/schemas/divisions.schema.yaml (v1 frozen)
# ────────────────────────────────────────────────
version: "v1"
schema_ref: "appendix/schemas/divisions.schema.yaml"

# 🆕 v0.4-r2: 배포 프로필 (top-level)
tier_profile: minimal          # minimal | standard | collab (§7.3.4 매트릭스 참조)
l3_backend: notion             # notion | none | obsidian | logseq | confluence | custom
                               # Phase 1 공식 지원: notion, none
                               # 그 외: Phase 2 driver 완성 후 (warn-not-block 규칙)

rbac_config:                   # 🆕 v0.4-r2: Phase 1은 항상 disabled 강제 (schema validation)
  enabled: false
  tenant_isolation: false
  role_mapping: {}             # Phase 2 RBAC에서 활성화

divisions:
  - id: strategy-pm
    display_name: "기획 본부 (PM)"
    head_agent: "strategy/pm/lead"
    workers: 1
    evaluators:
      - plan-validator
      - prd-validator
      - user-flow-validator
      - prd-lock-validator
    pdca_artifacts:
      plan: [prd, user_flow, ac_list]
      design: [flow_diagram, ac_metadata]
      do: [feature_spec, release_note]
      check: [ac_coverage_report]
      act: [sprint_summary]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "AC-coverage × 0.4 + 5-Axis × 0.6"

  - id: taxonomy
    display_name: "택소노미 본부"
    head_agent: "product/taxonomy/lead"
    workers: 1
    evaluators:
      - plan-validator
      - taxonomy-reqs-validator
      - taxonomy-draft-validator
      - taxonomy-consistency
    pdca_artifacts:
      plan: [term_scope, glossary_seed]
      design: [term_graph, relationship_map]
      do: [glossary, term_index]
      check: [consistency_report]
      act: [glossary_diff]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "taxonomy-consistency × 0.4 + 5-Axis × 0.6"

  - id: design
    display_name: "디자인 본부"
    head_agent: "product/design/lead"
    workers: 1
    evaluators:
      - plan-validator
      - design-reqs-validator
      - design-critique           # cowork 재사용
      - accessibility-review      # cowork 재사용
      - design-handoff            # cowork 재사용
      - design-validator          # bkit 재사용
    pdca_artifacts:
      plan: [ux_brief, persona]
      design: [figma_frames, design_tokens, component_inventory]
      do: [exported_assets, handoff_spec]
      check: [guide_match_report]
      act: [design_debt_log]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "design-guide-match × 0.4 + 5-Axis × 0.6"

  - id: dev
    display_name: "기술개발 본부"
    head_agent: "tech/dev/lead"
    workers: 1
    evaluators:
      - plan-validator
      - tech-reqs-validator
      - code-analyzer             # bkit 재사용
      - design-validator          # bkit 재사용
      - gap-detector              # bkit 재사용
    pdca_artifacts:
      plan: [tech_brief, arch_sketch]
      design: [api_spec, data_model, arch_diagram]
      do: [source_code, unit_tests]
      check: [gap_report, code_metrics]
      act: [refactor_log, tech_debt_entry]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "gap-detector × 0.4 + 5-Axis × 0.6"

  - id: qa
    display_name: "품질 본부"
    head_agent: "quality/qa/lead"
    workers: 1
    evaluators:
      - plan-validator
      - qa-reqs-validator
      - test-case-validator
      - qa-readiness
    pdca_artifacts:
      plan: [qa_strategy, coverage_target]
      design: [test_cases, test_data_plan]
      do: [test_results, defect_list]
      check: [coverage_report, leak_report]
      act: [qa_retro]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "test-coverage-delta × 0.3 + defect-leak × 0.1 + 5-Axis × 0.6"

  - id: infra
    display_name: "인프라 본부"
    head_agent: "ops/infra/lead"
    workers: 1
    evaluators:
      - plan-validator
      - infra-reqs-validator
      - terraform-validator
      - k8s-manifest-validator
      - cost-estimator
      - security-scan
    pdca_artifacts:
      plan: [infra_scope, cost_envelope]
      design: [terraform_modules, k8s_manifests, network_diagram]
      do: [provisioned_resources, deploy_pipelines]
      check: [cost_variance, stability_metrics]
      act: [ops_runbook_diff]
    default_model:
      lead: "claude-sonnet-4-6"
      worker: "claude-sonnet-4-6"
    g4_formula: "cost-variance × 0.2 + stability-score × 0.2 + 5-Axis × 0.6"

# ────────────────────────────────────────────────
# 커스터마이징 규칙
# ────────────────────────────────────────────────
customization:
  # 본부 추가 예시 — marketing division
  # - id: marketing
  #   display_name: "마케팅 본부"
  #   head_agent: "growth/marketing/lead"
  #   workers: 1
  #   evaluators: [plan-validator, marketing-reqs-validator]
  #   pdca_artifacts: { ... }
  #   default_model: { lead: "claude-sonnet-4-6", worker: "claude-sonnet-4-6" }
  #   g4_formula: "campaign-fit × 0.4 + 5-Axis × 0.6"
  #
  # 본부 제거: 해당 항목 삭제 → plan-validator가 경고만 출력 (강제 안 함)
  # workers 증설: workers: 2 → worker 파일 이름 추가 로드
```

### 7.3.1 divisions.yaml 수정의 영향 범위

| 필드 변경 | 영향 |
|---------|------|
| `divisions[].id` 추가 | 새 본부의 worker/lead agent 파일 추가 필요 → `/doc-validate`가 경고 |
| `divisions[].evaluators` 추가 | `agents/evaluators/`에 해당 yaml 존재하는지 검증 |
| `divisions[].workers` 증설 | Phase 2 기능, Phase 1은 경고만 출력 |
| `divisions[].g4_formula` 변경 | §5.5 공식 override. 자유 서술 허용하되 5-Axis 비중 ≥ 50% 권장 |
| `divisions[].default_model` 상향 | Opus 사용 시 비용 경고 |

### 7.3.2 왜 YAML인가 (JSON/TOML 대비)

- **주석 지원**: 본부별 의도/근거를 주석으로 남길 수 있음 (1인 창업가의 기록)
- **multi-line 문자열**: `g4_formula` 같은 수식을 자연스럽게 표현
- **플러그인 사용자가 IDE에서 편집하기 쉬움**: syntax highlighting + 스키마 validation
- JSON: 주석 불가, TOML: 중첩 구조 표현 낮음

→ **원칙 2.8의 "설정은 선언적"** 요건에 가장 적합.

### 7.3.3 divisions.yaml vs 코드 하드코딩의 비교

| 항목 | hardcoded (anti-pattern) | divisions.yaml |
|------|------|------|
| 본부 추가 시 수정 파일 수 | 10~15 파일 | 1 파일 |
| 한 본부 g4 공식 변경 | 소스 수정 + 테스트 | yaml 1줄 |
| 도메인 특화(예: 금융) 변형 | fork 필수 | override 파일로 충분 |
| Phase 2 marketplace | 불가능 | 설정 파일 단위 배포 |

→ divisions.yaml이 있는 것이 **Company-as-Code의 "Code" 지점** (§0.4 주장 1).

### 7.3.4 tier × l3_backend × Claude 플랜 매트릭스 🆕 v0.4-r2

`rule/tier-backend-selection`: install 시 `tier_profile`과 `l3_backend`를 어떤 조합으로 선택해야 하는지에 대한 권장 매트릭스. 강제가 아닌 **가이드**이며, schema validation은 `warn-not-block` 준수(§8.11.3).

#### (1) tier_profile 정의 (요약, schema 원문: `appendix/schemas/divisions.schema.yaml`)

| tier_profile | C-Level model | Worker 수/본부 | Evaluator pool | L3 sync | 대표 사용자 |
|---|---|---|---|---|---|
| **minimal** | Sonnet 3 + Opus 보조(중요 gate만) | 1 | 핵심 12개만 | 비동기 flush | 1인 창업가 (월 $200~500) |
| **standard** | Opus 3(C-Level 고정) | 1~2 | 전체 24개 | 5분 polling | 1인 + 외부 고문 (월 $500~1.5k) |
| **collab** | Opus 3(C-Level) + Critic A/B | 2 (일부 본부 3) | 전체 24개 + A/B 병렬 | 1분 polling + realtime | 1인 + 비개발자 2~3명 (Phase 2) |

#### (2) l3_backend 정의 (§8.11 driver 목록 기준)

- **notion** — Phase 1 공식 default. MCP 연결 + database template 제공
- **none** — L3 비활성. L2 git commit log만 human view로 사용 (degraded mode)
- **obsidian / logseq / confluence / custom** — Phase 2 driver 완성 후 지원. Phase 1에서 선택 시 `warn-not-block` 경고

#### (3) Claude 플랜별 권장 조합

| Claude 플랜 | 권장 tier | 권장 backend | 월 예상 비용 | 근거 |
|---|---|---|---|---|
| **Pro ($20/월, API 별도)** | minimal | none 또는 notion | API $50~200 | Opus 최소, L3 notion은 optional |
| **Max ($100~200/월, API 별도)** | minimal | notion | API $200~500 | Phase 1 기본 타겟 구성 |
| **Team** | standard | notion | API $500~1.5k | C-Level Opus 풀가동, 외부 고문이 Notion 리뷰 |
| **Enterprise** | collab | Phase 2 driver (obsidian/confluence) | Phase 2 TBD | Phase 2 RBAC/multi-tenant과 결합 |

> 🔑 **기본값 채택 알고리즘** (install.sh):
> 1. `--mode brownfield`이면 무조건 `tier=minimal` 시작 (discovery 단계에서 비용 최소화)
> 2. 환경변수에 `NOTION_API_KEY` 없으면 `l3_backend=none` 권장
> 3. 사용자가 명시 override하면 그 값 채택하되 `warn-not-block`

#### (4) 호환성 경고 매트릭스 (install 시 경고 출력)

| 조합 | 경고 | 사유 |
|---|---|---|
| `minimal` + `collab evaluator 전체 사용` | WARN | tier 의도(비용 최소) vs 실제 호출 비대칭 |
| `collab` + `l3_backend=none` | WARN | 협업자가 L3 없이는 리뷰 불가 (degraded) |
| `standard` + `driver 미지원값` | WARN | Phase 2 대기 필요. 당분간 `none`으로 동작 |
| `minimal` + `default_model: claude-opus-*` | WARN | tier 비용 가이드 이탈 |
| Phase 1 + `rbac_config.enabled: true` | **ERROR** (schema validation) | Phase 1은 항상 disabled 강제 |

→ 경고는 install.sh 콘솔에 요약 출력 + L1 `l1.plugin.install` 이벤트에 `warnings[]` 배열로 기록.

#### (5) install.sh에서 자동 적용되는 프로필 결정 흐름

```
install.sh 실행
  ├─ --mode 플래그 체크 → greenfield/brownfield 결정
  ├─ config/divisions.yaml 없음 → divisions.default.yaml 복사 (§7.9.3)
  ├─ 환경변수 스캔 (NOTION_API_KEY, AWS_S3_BUCKET)
  │   └─ 스캔 결과에 따라 l3_backend 기본값 제안
  ├─ schema validation (sfs-doc-validate)
  │   └─ 경고 배열 수집 → 사용자 확인 prompt (block 아님)
  └─ 설치 완료 요약 출력
      "tier=minimal, l3_backend=notion, install_mode=greenfield"
```

---

## 7.4 install.sh — CLI + Cowork 동시 설치 흐름

```bash
#!/usr/bin/env bash
# sfs-plugin/install.sh
# Phase 1: Claude Code CLI + Claude Desktop Cowork 동시 등록
set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_NAME="sfs-plugin"

echo "[sfs-plugin] Installing from: $PLUGIN_DIR"

# ────────────────────────────────────────────────
# 1. 사전 체크
# ────────────────────────────────────────────────
command -v claude >/dev/null 2>&1 || {
  echo "ERROR: claude CLI not found. Install from https://claude.com/code"
  exit 1
}
command -v node >/dev/null 2>&1 || {
  echo "ERROR: node >=18 required for hooks (observability-sync.ts)"
  exit 1
}

# ────────────────────────────────────────────────
# 2. Claude Code 플러그인 등록 (CLI)
# ────────────────────────────────────────────────
echo "[1/4] Registering with Claude Code CLI..."
claude plugin install "$PLUGIN_DIR"

# ────────────────────────────────────────────────
# 3. Claude Desktop Cowork 심볼릭 링크 (shared FS)
# ────────────────────────────────────────────────
echo "[2/4] Linking with Claude Desktop Cowork..."
COWORK_PLUGIN_DIR="$HOME/.claude-desktop/plugins"
mkdir -p "$COWORK_PLUGIN_DIR"

# 이미 있으면 덮어쓰기 확인
if [ -L "$COWORK_PLUGIN_DIR/$PLUGIN_NAME" ]; then
  echo "  (existing symlink replaced)"
  rm "$COWORK_PLUGIN_DIR/$PLUGIN_NAME"
fi
ln -s "$PLUGIN_DIR" "$COWORK_PLUGIN_DIR/$PLUGIN_NAME"

# ────────────────────────────────────────────────
# 4. divisions.yaml 자동 검증
# ────────────────────────────────────────────────
echo "[3/4] Validating divisions.yaml..."
node "$PLUGIN_DIR/skills/sfs-doc-validate/validate.mjs" \
  --config "$PLUGIN_DIR/config/divisions.yaml" || {
    echo "ERROR: divisions.yaml validation failed"
    exit 1
}

# ────────────────────────────────────────────────
# 5. 환경 변수 안내 (optional)
# ────────────────────────────────────────────────
echo "[4/4] Optional environment variables:"
cat <<EOF
  Set the following for full 3-Channel observability:
    export AWS_S3_BUCKET="your-sfs-logs-bucket"
    export AWS_REGION="ap-northeast-2"
    export NOTION_API_KEY="secret_..."
    export NOTION_DATABASE_ID="..."
  (All optional. Without them, L2 git commits still work.)
EOF

echo ""
echo "[sfs-plugin] Installation complete."
echo "  CLI:     use '/pdca plan <feature>' inside any project"
echo "  Cowork:  same plugin auto-available in Claude Desktop"
echo "  Docs:    $PLUGIN_DIR/README.md"
```

### 7.4.1 install.sh의 핵심 가정

1. **symlink 기반** — copy가 아님. 플러그인 업데이트 시 양쪽 동시 반영 (§7.9)
2. **fail-fast** — 사전 체크 실패 시 어떤 부분도 설치하지 않음 (부분 설치 금지)
3. **divisions.yaml 검증 필수** — 잘못된 config로 전파 차단
4. **환경 변수는 optional 안내만** — 강제화 시 Phase 1 진입 장벽 상승

### 7.4.2 uninstall 대칭 스크립트 (Phase 1 포함)

```bash
# uninstall.sh
claude plugin remove sfs-plugin
rm -f "$HOME/.claude-desktop/plugins/sfs-plugin"
# 사용자 프로젝트의 docs/, .sfs-local/ 는 보존 (데이터 손실 방지)
```

→ **데이터 보존 원칙**: 플러그인 제거가 사용자의 PDCA 기록을 지우지 않음.

### 7.4.3 install 중 발생 가능한 오류

| 오류 | 원인 | 복구 |
|------|------|------|
| `claude plugin install` 실패 | CLI 버전 < 1.5.0 | CLI 업그레이드 |
| symlink 실패 (permission) | `~/.claude-desktop/plugins/`에 쓰기 권한 없음 | 디렉토리 권한 확인 |
| divisions.yaml validation 실패 | YAML 문법 오류 또는 schema 불일치 | 에러 메시지의 line/field 수정 |
| node 없음 | node 미설치 | node 18+ 설치 |

---

## 7.5 CLI ↔ Cowork 파일시스템 공유 메커니즘

`concept/cli-cowork-shared-fs`: Phase 1의 **기술적 핵심 레버리지**. GUI를 따로 만들지 않고도 비개발자까지 커버한다 (원칙 2.7).

### 7.5.1 공유 디렉토리 구조

```
프로젝트 루트/  (사용자의 git repo)
├── docs/                              # L2 SSoT (§8)
│   ├── 00-sprint-plan/
│   ├── 01-plan/                       # PDCA plan 문서
│   ├── 02-design/
│   ├── 03-analysis/                   # Check + escalation
│   ├── 04-reports/                    # Act 산출물
│   └── memory/
│       └── learnings-v1.md            # H6 학습 (§6.6)
│
├── .sfs-local/                        # PC별 로컬 상태 (원칙 2.6)
│   ├── logs/                          # L1 로컬 폴백 (S3 없을 때)
│   ├── cache/                         # Evaluator 결과 캐시
│   └── sessions/                      # 진행 중인 session 메타
│
├── .gitignore                         # .sfs-local/ 자동 추가
└── (애플리케이션 소스 등)
```

### 7.5.2 CLI와 Cowork가 같은 파일을 바라보는 원리

- **Claude Code CLI**: 사용자가 프로젝트 디렉토리에서 `claude` 실행 → 현재 CWD 기준으로 `docs/`, `.sfs-local/` 접근
- **Claude Desktop Cowork**: 사용자가 프로젝트 디렉토리를 **워크스페이스로 마운트** → 동일 경로 접근

| 환경 | 파일 읽기 | 파일 쓰기 | tool invocation |
|------|:---:|:---:|:---:|
| CLI | ✅ | ✅ | Bash, Read, Write, Edit |
| Cowork | ✅ | ✅ | Read, Write, Edit, Bash |

→ **동일 파일을 양쪽이 편집**. 충돌은 git (staged/unstaged로 관리). 동시 편집 방지는 사용자의 책임(솔로 사용 가정).

### 7.5.3 ".sfs-local/ 은 왜 gitignore인가"

- **PC별 로컬 상태**: MacBook/Windows PC/iPad의 Cowork 세션이 서로 오염되면 안 됨
- **민감 정보**: S3 로컬 폴백 로그에 API 호출 raw(토큰은 제외되지만 prompt 내용 포함)가 있을 수 있음
- **크기**: 수천 개의 로그 파일 → git 이력에 들어가면 repo 비대화

→ L2 SSoT는 `docs/`만, 로컬 runtime은 `.sfs-local/`에. 이 분리가 **원칙 2.6 local-state-private**의 물리적 구현.

### 7.5.4 공유 FS의 경계

공유 FS 모델은 강력하지만 한계가 있음:

| 시나리오 | 공유 FS로 해결? | 대안 |
|---------|:---:|------|
| 같은 PC, CLI와 Cowork 번갈아 사용 | ✅ 즉시 반영 | — |
| 다른 PC, 세션 이어서 | ⚠️ git push/pull 필요 | HANDOFF.md (product-image-studio 프로젝트 사례) |
| 실시간 협업 (2명 이상) | ❌ | Phase 2 multi-tenant 필요 |
| 모바일 (iPad Cowork) | ✅ mount 되면 동작 | — |

### 7.5.5 MCP 도구와의 조합

플러그인 자체는 MCP 서버를 포함하지 않음 (Phase 1 원칙). 그러나 사용자가 별도로 설치한 MCP(Notion, Jira 등)는 **양쪽 엔진이 모두 접근** 가능:
- CLI: `claude mcp connect notion` → Cowork에도 자동 인식
- Cowork: GUI에서 MCP 추가 → CLI에서도 사용 가능

→ Phase 1은 **외부 MCP 재사용**, Phase 2에서 sfs 전용 MCP 제공 검토.

---

## 7.6 Phase 2 상품화 로드맵

`phase/phase2-roadmap`: Phase 1 단일 플러그인을 **상품**으로 확장한다. Phase 1 완주(§10)가 전제 조건 — dogfooding 없이는 Phase 2 의사결정 불가.

| 항목 | Phase 1 (0.4) | Phase 2 (1.0 목표) | 도입 시점 |
|------|---------|---------|---------|
| **패키지 구조** | 단일 sfs-plugin | core + 본부별 선택 설치 (sfs-core + sfs-commerce + sfs-saas 등) | Phase 1 완료 +0~3개월 |
| **RBAC** | 없음 (솔로) | 본부별 권한 분리, Evaluator read_only 외부 감사 | Phase 1 완료 +1~2개월 |
| **Multi-tenant** | 없음 | tenant별 divisions.yaml/DB 격리, 조직당 subdomain | Phase 1 완료 +3~6개월 |
| **Marketplace** | 없음 | 본부 템플릿 배포, 유료/무료 라이선싱, 사용자 fork/publish | Phase 1 완료 +4~6개월 |
| **문서 사이트** | README.md | docs.sfs.dev (versioned) | Phase 1 완료 +1개월 |
| **온보딩** | install.sh | `sfs init` wizard, sample project, 30분 튜토리얼 | Phase 1 완료 +2개월 |
| **Observability UI** | L3 Notion template | 전용 대시보드 (metrics, cost, gate_pass_rate) | Phase 1 완료 +4개월 |
| **라이선스** | MIT | Commercial dual license (MIT core + enterprise add-on) | Phase 1 완료 +3개월 |
| **지원 모델** | Claude only | OpenAI/Gemini/Open-source model adapter | Phase 1 완료 +6개월+ |
| **Agent 증원** | 본부당 1 worker | 본부당 multi-worker + 병렬 실행 | Phase 1 완료 +2~4개월 |
| **L3 Driver 생태계** | notion, none | obsidian, logseq, confluence, custom + community driver 제출 절차 | Phase 1 완료 +2~5개월 |
| **tier_profile 확장** | minimal/standard/collab | 도메인별 tier (fintech/edu/commerce 등) | Phase 1 완료 +3~4개월 |
| **Brownfield 성숙도** | discovery-report.md + `/sfs discover` | 레거시 호환성 matrix + migration cookbook | Phase 1 완료 +1~3개월 |

### 7.6.1 Phase 2의 3대 목표

1. **상품화**: 1인 창업가가 "sfs를 쓰기 위해 sfs를 먼저 배우는" 허들을 낮춤 (wizard, 문서사이트)
2. **커뮤니티**: 본부/Evaluator 템플릿을 fork/publish 할 수 있는 마켓플레이스. 네트워크 효과 시작점
3. **수익화**: enterprise add-on(RBAC, multi-tenant, advanced observability)을 유료화. 오픈 core + 유료 extension 모델

### 7.6.2 Phase 2 의사결정에서 Phase 1이 답해야 할 질문

- 6 본부 고정이 1인 창업 전반에 맞았는가, 도메인별로 다르게 해야 하는가?
- Evaluator Pool 중 어떤 것이 실제로 많이 호출되고 어떤 것은 거의 안 쓰이는가?
- H6 학습 항목이 실제로 다음 Sprint failure 예방에 기여했는가?
- 비용 구조가 지속 가능한가 (Opus 비중이 합리적인가)?

→ 이 질문들의 답이 **Phase 1 종료 조건(§10)** 이자 **Phase 2 입력**이다.

### 7.6.3 Phase 2로 연기한 결정들

Phase 1 설계에서 결정을 미룬 항목들:
- **Evaluator critic A/B 병렬**: v0.3에서 제안, Phase 1은 단일 evaluator. Phase 2 모델 adapter 도입 후 재검토.
- **본부 간 cross-division worker 공유**: Phase 1은 본부당 1 worker 전용. Phase 2에서 sharing model 검토.
- **Sprint > 1주 / < 2주 외의 Sprint 길이**: Phase 1은 2주 고정. Phase 2에서 도메인별 조정.
- **Gate 자동 재시도 정책 세분화**: Phase 1은 policy.max_retries 단일값. Phase 2에서 본부/gate별 세분화.

---

## 7.7 Phase 2 일정

> **[OPEN → SEMI-RESOLVED]**
> Phase 1 완주(14~18주, §10) 후 **dogfooding 결과**를 보고 Phase 2 plan 작성을 시작한다.

### 7.7.1 잠정 타임라인

```
2026-04-19 ────> Phase 1 실행 시작 (이 문서 작성 시점)
              │
              │ Phase 1 = 14~18주
              │
2026-08-09 ───┘ Phase 1 MVP 완주 (잠정)
              │
              │ Dogfooding 4~8주
              │
2026-10-04 ───┘ Phase 2 Plan 작성 시작 (잠정)
              │
              │ Phase 2 계획 수립 2~4주
              │
2026-11-01 ───┘ Phase 2 실행 착수 (잠정)
```

### 7.7.2 Phase 2 plan 작성 시 적용될 원칙

- **Phase 1 data-driven**: Phase 2 결정은 Phase 1 L3 대시보드 metric을 근거로 해야 함 (주장이 아닌 측정)
- **모듈 분리 우선**: core/commerce/saas 분리가 Phase 2 1st priority (RBAC보다 먼저)
- **하위 호환**: Phase 1 사용자의 `docs/`, `divisions.yaml`이 Phase 2에서도 그대로 동작해야 함 (breaking change 없음)

### 7.7.3 Phase 2 진입 조건 (gatekeeper)

다음 중 **하나라도 미달**이면 Phase 2 plan 작성 중단하고 Phase 1 연장:
- Phase 1에서 최소 2개의 실제 MVP 프로젝트를 SFS로 완주
- H6 학습 패턴이 최소 10개 축적되고 활성(active) 상태
- Escalation-to-abort 비율이 Sprint당 1건 이하로 안정화
- 월 비용이 목표 상한(Phase 1 $500/월) 안에 수렴

→ **Phase 1 성공이 Phase 2 전제**. 성급한 상품화 방지.

---

## 7.8 배포 모드별 사용 시나리오

같은 플러그인, 다른 사용법.

| 사용자 유형 | 주 환경 | 진입점 | 핵심 활용 |
|-----------|-------|-------|---------|
| **개발자 솔로 창업가** | Claude Code CLI | `claude` + `/pdca plan` | 6 본부 전체 활용, git 직접 조작 |
| **비개발자 솔로 창업가** | Claude Desktop Cowork | GUI 채팅 + 파일 드래그앤드롭 | PM/Design/Taxonomy 중심, dev/infra는 agent에 위임 |
| **디자이너 솔로** | Cowork 위주, 가끔 CLI | GUI + HANDOFF.md | design 본부 deep use, dev 본부 Evaluator로 코드 확인만 |
| **기술 고문이 옆에 있는 솔로** | CLI + Cowork 병행 | 같은 docs/ 공유 | CLI로 빠른 커맨드, Cowork로 문서 리뷰 |

### 7.8.1 왜 같은 플러그인으로 다 가능한가

- `agents/`, `skills/`, `commands/`는 **환경에 무관**하게 동작 (Claude 엔진이 공통)
- `config/divisions.yaml`은 사용자 override로 본부를 늘리고 줄일 수 있음
- GUI/CLI 차이는 **입력 방식**만 다를 뿐 (prompt + tool call은 동일 규격)

→ "1 플러그인, N 사용자 유형" — Phase 1 배포 효율의 정점.

### 7.8.2 비개발자 대상 UX 고려

Cowork에서 비개발자가 사용할 때:
- **divisions.yaml 직접 편집 X**: Phase 2에서 wizard 기반 설정
- **git commit 강제 X**: L2 자동 commit (observability hook)
- **escalation 결정**: `request_user_decision` prompt를 평문 설명으로 렌더 (Haiku)
- **terminology 간소화**: "PDCA" → "사이클"로 치환하는 i18n 계층 (Phase 2 검토)

Phase 1은 **개발자 중심**, Phase 2에서 비개발자 UX 고도화.

---

## 7.9 plugin 업데이트 & 버전 정책

### 7.9.1 버전 정책 (semver)

- **MAJOR**: schema breaking change (gate-report-v1 → v2 등). Phase 1에서는 발생하지 않음
- **MINOR**: 신규 기능 (새 evaluator 추가, 새 slash command 등). 사용자 divisions.yaml 호환 유지
- **PATCH**: 버그 수정, 프롬프트 튜닝, 의존성 업데이트

Phase 1 버전 계획:
- 0.4.0 — 본 문서셋 기준 초기 릴리스
- 0.4.x — 버그 수정 + 프롬프트 튜닝
- 0.5.0 — Phase 1 확장 기능 (Phase 2 진입 전)
- 1.0.0 — Phase 2 첫 릴리스 (schema v1 freeze 유지)

### 7.9.2 업데이트 흐름

```bash
# 업데이트 (git pull 기반)
cd ~/path/to/sfs-plugin
git pull origin main

# symlink 기반 설치이므로 별도 재설치 불필요
# 단, divisions.yaml schema 변경 시 validation 재실행
node skills/sfs-doc-validate/validate.mjs
```

### 7.9.3 사용자 divisions.yaml 보호

플러그인 업데이트가 사용자 `config/divisions.yaml`을 덮어쓰는 것을 방지하기 위해:
- **플러그인 기본값**: `config/divisions.default.yaml` (플러그인 git 포함)
- **사용자 override**: `config/divisions.yaml` (플러그인 `.gitignore`에 포함)
- **첫 install 시**: `cp config/divisions.default.yaml config/divisions.yaml`

→ 업데이트가 사용자 설정을 파괴하지 않음. **설정 파일 보호 = 신뢰의 기본**.

### 7.9.4 rollback 정책

- 플러그인은 symlink 기반 → `git checkout <이전 tag>` 만으로 rollback
- 사용자의 `docs/` (L2 SSoT)는 플러그인 버전과 독립적 → rollback이 프로젝트 데이터에 영향 없음
- schema breaking change(Phase 2) 시에만 migration guide 제공

---

## 7.10 Brownfield / 기존 프로젝트 도입 모드 🆕 v0.4-r2

> **맥락**: Solon은 신제품 개발만을 위한 것이 아니다. 이미 진행 중인 프로젝트(이하 **brownfield**)에도 도입되어야 한다. §7.1~§7.9는 암묵적으로 **greenfield**(빈 repo에 신규 시작)를 가정하므로, 본 절에서 brownfield 모드의 진입점·절차·산출물·gate를 정의한다.

### 7.10.1 정의

`mode/brownfield`: 다음 중 하나에 해당하는 repo에 Solon을 투입하는 모드.
- (a) 이미 source code/배포 이력이 존재함
- (b) 문서(`docs/`)나 Notion/Jira 등의 비정형 아카이브가 축적되어 있음
- (c) 팀/1인이 수작업 개발 중이었고 agent system을 **중간 투입**하려 함
- (d) 이전 SFS/bkit 계열을 사용 중이던 프로젝트의 version migration

→ `greenfield`는 (a)~(d) 중 어느 것도 해당하지 않는 "처음부터 Solon" 프로젝트.

### 7.10.2 왜 별도 모드가 필요한가

신제품 모드와 달리 brownfield는 다음 위험이 구조적으로 발생:

| 위험 | 예시 | 완화 장치 |
|---|---|---|
| **L2 SSoT 충돌** | `docs/` 폴더가 이미 존재, 구조/명명이 Solon 규약과 다름 | `/sfs discover`로 기존 구조 스냅샷 후 **공존 맵핑 테이블** 생성 |
| **원칙 9 위반 위험** | "이미 구현된 기능을 원칙 9 (G0)으로 역설계하라"는 요구 발생 → agent가 brainstorm 없이 after-the-fact PRD 작성 위험 | `principle/brownfield-no-retro-brainstorm`: 이미 구현된 것에는 G0 적용 안 함, 대신 `evidence/existing-implementation`으로 기록 |
| **원칙 10 부담 증가** | 기존 코드 해석의 최종 승인도 사람이 해야 → human-final-filter 부하 증가 | `minimal` tier 강제 + discovery 단계에서 cost budget cap |
| **비용 폭발** | 수만 라인 코드베이스 전체 분석 요청 시 Opus 비용 과다 | discovery phase는 **Haiku 우선 + Sonnet 샘플링**, Opus는 escalation 케이스에만 |
| **L3 back-filling 유혹** | 지난 수개월 이력을 Notion에 역삽입 시도 → L1 원본과 불일치 발생 | `rule/l3-no-backfill`: L3는 Solon 도입 시점 이후만 기록 |

### 7.10.3 install.sh `--mode brownfield` 흐름

```bash
./install.sh --mode brownfield [--tier minimal|standard] [--l3-backend notion|none]
```

실행 흐름:

```
[1/7] 사전 체크 (기존 greenfield와 동일)
[2/7] Claude Code + Cowork 등록 (기존과 동일)
[3/7] Brownfield 감지
       ├─ git history ≥ 1 commit?
       ├─ docs/ 폴더 존재?
       ├─ package.json / pyproject.toml / Cargo.toml 등 manifest?
       └─ 결과 요약 → discovery 입력으로 전달
[4/7] divisions.yaml 기본값 생성 (tier=minimal 강제)
[5/7] /sfs discover 자동 실행 (next section)
[6/7] discovery-report.md 산출 + 사용자 승인 prompt (원칙 10)
[7/7] 승인 완료 시 본격 PDCA 시작 가능 (Sprint 0 자동 skeleton 생성)
```

→ **[6/7]의 사용자 승인**이 brownfield 고유의 추가 human gate (G-1 Intake Gate, §5 cross-ref).

### 7.10.4 `/sfs discover` — 기존 프로젝트 분석 스킬

플러그인 내 신규 skill: `skills/sfs-discover/SKILL.md` + `agents/discovery/brownfield-discovery-worker.yaml`.

#### (1) 입력
- repo 루트 경로
- (optional) 기존 `docs/` 폴더 경로
- (optional) 외부 아카이브 힌트 (Notion DB ID, Jira project key, Confluence space)

#### (2) 출력 (L2에 저장)
`docs/00-discovery/discovery-report.md` — 다음 섹션을 반드시 포함:

1. **Repo Vital Stats** — SLOC, 언어 분포, 첫/마지막 commit, 활성 브랜치 수
2. **Architecture Snapshot** — 자동 감지된 modules/services + 의존성 그래프 (텍스트 기반)
3. **Domain Terminology** — 코드/주석에서 추출한 도메인 어휘 → taxonomy 본부 seed
4. **Existing Docs Inventory** — 기존 `docs/` 파일 목록 + 역할 라벨링 (PRD/ADR/README/기타)
5. **External Archive Links** — Notion/Jira/Confluence에서 발견된 artifact 링크
6. **Gap Matrix** — Solon 6 본부 × 기존 산출물 존재 여부 (O/△/X)
7. **Risk Register** — 기존 코드의 알려진 debt/scar 이슈 (TODO/FIXME/XXX 스캔)
8. **Suggested First Sprint Focus** — Gap Matrix 기반 우선순위 Top 3 (CEO 제안)
9. **Human Approval Checklist** — 사용자가 체크해야 하는 항목 (원칙 10 필수)

#### (3) 모델 할당
- 대부분 Haiku (파일 스캔, 패턴 추출, 카운팅)
- Sonnet은 Architecture Snapshot + Gap Matrix 합성에만
- Opus는 사용 안 함 (brownfield discovery 단계 cost cap)

#### (4) schema
`appendix/schemas/discovery-report.schema.yaml` (v1, frozen)

### 7.10.5 Brownfield Gate Framework 확장

기존 §5 Gate에 **G-1 Project Intake Gate**가 brownfield 전용으로 추가된다:

| Gate | 위치 | 트리거 | Evaluator | 통과 조건 |
|---|---|---|---|---|
| **G-1 Intake** | Solon 설치 직후 (G0 이전) | `install.sh --mode brownfield` | `discovery-report-validator` + **human approval (원칙 10)** | discovery-report.md 9 섹션 모두 존재 + 사용자 승인 signature |

- G0 Brainstorm Gate는 **brownfield 도입 이후 신규 기능**에 한해 적용 (이미 구현된 기능에는 적용 안 함, `principle/brownfield-no-retro-brainstorm`)
- G1~G5는 greenfield와 동일

### 7.10.6 사용자 승인의 형태 (원칙 10 이중 방어 적용)

discovery-report.md 마지막에 **Human Approval Block**:

```markdown
## Human Approval Block (원칙 10 — 사람 최종 필터)

나는 아래 사항을 확인했다:
- [ ] Repo Vital Stats의 숫자가 실제와 일치한다
- [ ] Architecture Snapshot에 빠진 핵심 서비스가 없다
- [ ] Gap Matrix의 우선순위가 현재 사업 우선순위와 맞다
- [ ] Risk Register에 이의 없음 / 또는 보강 완료
- [ ] Suggested First Sprint Focus Top 3에 동의
- [ ] 나는 이 Discovery 결과로 Solon을 가동하는 것에 동의한다

signed_by: @<user>
signed_at: <ISO 8601>
```

- 체크박스 6개 전부 체크 + signed_by/signed_at 모두 채워져야 G-1 통과
- 미통과 시 install.sh는 완료되지만 `/pdca plan` 등 run-time command는 **block** (원칙 10은 진행 block 허용)

### 7.10.7 기존 docs/ 폴더 충돌 처리

discovery 시점에 이미 `docs/00-plan` 류 폴더가 있으면:

```
프로젝트 루트/
├── docs/
│   ├── (기존 사용자 문서들)               # 그대로 유지
│   ├── 00-discovery/                     # 🆕 Solon 생성
│   │   └── discovery-report.md
│   ├── .solon-manifest.yaml             # 🆕 기존 경로 → Solon 역할 맵핑
│   └── memory/                           # Solon 생성 (기존 있으면 merge)
```

- **파괴적 수정 금지**: 기존 파일은 읽기만, 생성/수정은 `00-discovery/` 하위에만
- `.solon-manifest.yaml`: 기존 `docs/existing-PRD.md` 같은 파일을 Solon의 PM 본부 `plan` artifact로 **참조**(복제 아님)하는 맵핑 테이블

### 7.10.8 비용 및 시간 예상 (Phase 1)

| Repo 규모 | Discovery 시간 | 예상 비용 (Haiku/Sonnet 혼합) |
|---|---|---|
| Small (<10k SLOC, <50 docs) | 10~20분 | $0.5~2 |
| Medium (10~100k SLOC, 50~500 docs) | 30분~2시간 | $2~15 |
| Large (>100k SLOC, >500 docs) | 2~6시간 (분할 실행 권장) | $15~60 |
| Very Large | `/sfs discover --scope subset`로 부분 실행 권장 | TBD |

→ Large 이상은 **분할 discovery** (본부별/모듈별) + 매 단계 human approval.

### 7.10.9 Phase 2 확장 계획

- **Migration Cookbook**: bkit / SFS-v0.3 / 기타 agent system에서 Solon으로 이주하는 케이스별 레시피
- **Incremental Adoption**: 한 본부만 먼저 도입 (예: dev 본부만) 후 확장
- **Legacy Compatibility Matrix**: 기존 tool stack (Jira/Notion/Linear/Confluence 등) 별 driver mapping

---

*(끝)*
