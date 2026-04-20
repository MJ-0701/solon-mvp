---
command_id: "sfs-discover"
command_name: "/sfs discover"
version: "1.0.0"
phase: "p-1"
mode: "brownfield"
operator: "strategy/ceo"
triggers:
  - "discover"
  - "brownfield setup"
  - "기존 프로젝트 분석"
  - "existing project analysis"
  - "legacy repo solon"
requires_gate_before: []                  # G-1은 이 command 이후에 호출됨 (P-1 종료 시)
produces:
  - "docs/discovery-report.md"
  - "docs/discovery/evidence/*.yaml"
  - "docs/discovery/inventory/*.json"
  - ".solon/.g-1-signature.yaml"          # 사람 서명 블록 (빈 상태로 생성 → 사용자가 채움)
  - ".solon-manifest.yaml"                # 기존 docs 공존 전략
calls_evaluators:
  - "discovery-report-validator"           # G-1 intake gate에서 호출
model_allocation:
  default: "claude-sonnet-4-6"             # 본문 작성
  secondary: "claude-haiku-4-5-20251001"   # inventory scan, grep 요약
  opus_allowed: false                       # 원칙 11 비용 cap 강제
cost_budget_usd:
  small_repo: 2.00                          # <50k loc
  medium_repo: 15.00                        # 50k~300k loc
  large_repo: 60.00                         # >300k loc
  abort_threshold: 80.00                    # 이 이상 예상 시 install abort
timeout_ms: 7200000                         # 2시간 (large repo 상한)
tool_restrictions:
  allowed: ["Read", "Glob", "Grep", "Bash(read-only subset)"]
  forbidden: ["Write", "Edit", "NotebookEdit"]  # 원칙 11, rule/brownfield-discovery-read-only
  note: "Write/Edit는 discovery 완료 후 install.sh가 수행 (사용자 G-1 서명 후)"
audit_fields:
  - "install_id"
  - "repo_root_hash"
  - "called_by"
  - "called_at"
  - "total_cost_usd"
  - "duration_ms"
  - "files_scanned"

references:
  - phase/p-1-discovery (defined in: s04)
  - concept/g-1-intake-gate (defined in: s05)
  - principle/brownfield-first-pass (defined in: s02)
  - principle/brownfield-no-retro-brainstorm (defined in: s02)
  - principle/human-final-filter (defined in: s02)
  - rule/brownfield-discovery-read-only (defined in: s04)
  - rule/p-1-run-once-per-install (defined in: s04)
  - rule/l3-no-backfill (defined in: s07)
  - template/discovery-report (defined in: appendix/templates/discovery-report.template.md)
  - schema/g-1-signature-v1 (defined in: s05)
---

# /sfs discover

> **Brownfield 전용 Discovery Skill.** 기존 repo에 Solon을 도입하기 직전, 사람의 최종 승인(G-1)을 받기 위한 사전 조사를 수행한다.
> **Read-only**로 동작하며, 결과물은 `docs/discovery-report.md` + evidence + inventory + 미서명 G-1 signature block이다.

---

## 1. 의도 (Intent)

`/sfs discover`의 목표는 **"Solon을 이 repo에 도입해야 할까?"라는 질문에 사람이 답할 수 있도록, 정확한 정보를 읽기 전용으로 수집하는 것**이다. 다음 세 가지를 확립한다:

1. **repo 규모·기술 스택의 객관적 수치화** — loc, 파일 수, 테스트 커버리지, tech stack, CI/CD 현황.
2. **기존 문서와의 공존 전략** — 이미 있는 `docs/`, `README.md`, `CLAUDE.md`가 Solon L2 SSoT와 어떻게 병행할지.
3. **사람 최종 승인을 위한 서명 블록 준비** — `.g-1-signature.yaml` 빈 블록 생성 (사용자가 6개 체크박스 + 이름 + 날짜 채움).

**명시적 non-goals**:
- ❌ 기존 제품 방향을 재brainstorm **하지 않는다** (원칙 12 `brownfield-no-retro-brainstorm`).
- ❌ 기존 코드를 리팩토링 **하지 않는다** (read-only).
- ❌ 새 기능 아이디어 제안 **하지 않는다** (P-1은 현재 상태 파악만).
- ❌ L3 대시보드에 과거 데이터 back-fill **하지 않는다** (`rule/l3-no-backfill`).

---

## 2. 입력 (Input)

### 2.1 CLI 인자 (install.sh에서 전달)

```bash
sfs discover \
  --repo-root /absolute/path/to/repo \
  --install-id INST-20260420-001 \
  --tier-profile minimal \
  --l3-backend notion \
  --user-name "채명정" \
  --budget-cap 15.00              # USD
```

### 2.2 대화형 사용자 답변 (3가지만)

CLI 인자로 충분하지 않은 경우 Haiku가 3가지만 묻는다 (그 이상 묻지 않음 — 원칙 11 3-pass 제한):

| 질문 | 기본값 | 목적 |
|------|--------|------|
| "이 repo의 한 줄 설명은?" | (없음) | discovery-report §1 headline |
| "주요 사용자/고객은?" | "(미정)" | §3 domain evidence 단서 |
| "Solon 도입 후 첫 3개월 목표는?" | "기존 기능 안정화" | §9 migration path |

→ 이 답변들은 `evidence/user-intent.yaml`에 기록된다.

---

## 3. 절차 (Procedure)

P-1은 3-Pass pipeline으로 구성 (원칙 11 §2.11.2):

### Pass 1 — Read-only Inventory (Haiku, 저비용)

**목표**: repo의 객관적 수치 확보. 해석 X, 측정 O.

```
tool 사용: Glob, Grep, Bash(git log/ls/wc)
```

수집 항목:
- **파일 스캔**: `glob("**/*.{ts,tsx,js,jsx,py,go,java,kt,rs,rb,php,md,yaml,json}")` → 파일 수, 확장자 분포
- **loc**: `bash("find . -type f -name '*.ts' -o -name ... | xargs wc -l")` (언어별)
- **tech stack**: `package.json`, `requirements.txt`, `Cargo.toml`, `pom.xml`, `go.mod`, `Gemfile`, `composer.json`, `build.gradle(.kts)` 등 패키지 매니페스트 읽기 (Read only)
- **기존 docs 중복 판정**: `docs/`, `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, `.cursorrules` 존재 여부 + 각 파일 line count
- **CI/CD**: `.github/workflows/`, `.gitlab-ci.yml`, `bitbucket-pipelines.yml`, `Jenkinsfile`, `.circleci/`
- **테스트**: `*.test.*`, `*_test.*`, `test_*.py`, `__tests__/`, `spec/` 패턴 파일 수
- **git 메타**: `git log --oneline | wc -l` (커밋 수), `git log --format='%an' | sort -u | wc -l` (contributors 수), `git log --since="6 months ago" --name-only | sort -u | wc -l` (최근 6개월 touched files = hot paths 후보)

**산출**: `inventory/repo-stats.json` (structured)
```json
{
  "schema_version": "inventory-v1",
  "scanned_at": "2026-04-20T10:30:00Z",
  "total_files": 1847,
  "total_loc": 142350,
  "language_distribution": {"TypeScript": 98400, "Markdown": 18200, ...},
  "primary_language": "TypeScript",
  "tech_stack": {"frontend": "Next.js 14", "backend": "NestJS", "db": "PostgreSQL", ...},
  "existing_docs": [{"path": "README.md", "lines": 245}, ...],
  "ci_cd_systems": [".github/workflows/ci.yml"],
  "test_files_count": 234,
  "test_frameworks_detected": ["Jest", "Playwright"],
  "git_meta": {"commits": 2340, "contributors": 3, "hot_paths": ["src/services/auth.ts", ...]}
}
```

**비용 cap**: Haiku 호출만, 예상 $0.10 ~ $0.50.

### Pass 2 — Evidence Collection (Sonnet, 표적 분석)

**목표**: Pass 1의 수치를 단서로 **"왜 이렇게 구성돼 있는가"를 기존 코드·문서에서만 추출**. 신규 해석 X, 기존 evidence만 인용.

```
tool 사용: Read (필요한 파일만), Grep (표적 검색)
```

각 claim에 대해 `evidence/{claim-id}.yaml`을 생성:

```yaml
# evidence/EVID-001-domain-auth.yaml
schema_version: "evidence-v1"
claim_id: "EVID-001"
claim: "이 repo는 B2B SaaS 인증/권한 시스템을 제공한다"
confidence: 0.9
evidence_sources:
  - path: "README.md:L12-18"
    excerpt: "Authentication and authorization for B2B SaaS..."
    type: "readme"
  - path: "src/services/auth.ts:L1-5"
    excerpt: "// @description: JWT + OAuth2 for multi-tenant B2B"
    type: "code-comment"
  - path: "docs/architecture.md:L45-67"
    excerpt: "We support Google SSO, SAML, and email/password for tenant admins"
    type: "existing-doc"
collected_at: "2026-04-20T10:45:00Z"
collected_by: "solon-discover v1.0.0 (Sonnet)"
# 주의: claim이 evidence_sources에서 직접 도출되지 않으면 이 yaml 자체가 G-1에서 reject됨
```

수집하는 주요 claim 카테고리 (최소 5개):
1. **domain** — 이 repo가 어떤 비즈니스 도메인인가 (README/PRD 기반)
2. **architecture** — Monorepo? Microservices? Monolith? (package 구조 기반)
3. **deployment** — 어디에 배포되나 (Vercel/AWS/self-hosted, CI 파일 기반)
4. **user-flow** — 주 사용자 여정 (routes/controllers 기반)
5. **terminology** — 도메인 용어 (README + code comment 기반, `taxonomy/` 본부 초벌 입력)

**원칙 9 강제**: 각 claim은 `evidence_sources` 필드가 비어 있으면 불가. "agent가 추론한 것"이 아니라 **"repo에 실제로 존재하는 것"**만.

**비용 cap**: Sonnet 3~5회 호출, 예상 $1.00 ~ $8.00 (repo 규모 따라).

### Pass 3 — Draft Discovery Report (Sonnet, 종합)

**목표**: Pass 1 + Pass 2 결과를 `docs/discovery-report.md`로 **템플릿에 맞게** 작성. 9 필수 섹션 (§7.10.4 복제).

```
tool 사용: Read (Pass 1·2 산출물만), Bash(echo)로 diff/wc 요약  -- Write는 discovery-report.md 한 파일에만 허용
```

> ⚠️ **예외**: Pass 3는 유일하게 `discovery-report.md` **단일 파일**에 대한 Write를 허용한다. 그 외의 Write/Edit는 여전히 금지. `.g-1-signature.yaml` 빈 블록 생성도 여기서 수행(템플릿 복사).

생성되는 `discovery-report.md`의 9 필수 섹션:

1. **Repo Inventory** — Pass 1 수치 요약 (loc, file count, tech stack, git meta)
2. **Existing Docs Audit** — 기존 docs 목록 + 각각에 대한 공존 판정 (keep/supersede/migrate)
3. **Domain Evidence** — Pass 2 evidence 중 domain claim 요약 + 출처
4. **Terminology Extraction** — taxonomy 본부의 Sprint 1 입력 후보 용어 list
5. **Hot Paths** — 최근 6개월 자주 수정된 파일 (dev 본부의 첫 Sprint 집중 영역 후보)
6. **Test Coverage Snapshot** — 현재 커버리지 (%) + test framework + 누락 영역 주석
7. **CI/CD Inventory** — 기존 CI pipeline + Solon의 새 L1/L2 정책과 충돌 여부
8. **Migration Path** — 기존 `docs/` → Solon `docs/00-meta/`, `docs/01-plan/`, ... 이관 전략 (Phase 2 cookbook 참조)
9. **.g-1-signature.yaml 서명 블록** — schema/g-1-signature-v1 (§5.11.3)의 **미서명 템플릿**을 삽입. 사용자가 직접 6개 체크박스를 체크하고 이름·날짜를 기입해야 함.

**비용 cap**: Sonnet 1~2회, 예상 $0.50 ~ $3.00.

### Pass 간 총 비용 (Phase 1 목표)

| Repo 규모 | Pass 1 | Pass 2 | Pass 3 | 합계 |
|-----------|--------|--------|--------|------|
| Small (<50k loc) | $0.10 | $1.00 | $0.50 | **<$2** ✅ |
| Medium (50~300k loc) | $0.30 | $4.00 | $1.50 | **<$15** ✅ |
| Large (>300k loc) | $0.80 | $20.00 | $3.00 | **<$60** ✅ (Phase 1은 Small+Medium 권장) |

→ 합계가 `budget-cap` 초과 예상 시 **Pass 2 시작 전에 abort 하고 사용자에게 경고**.

---

## 4. 산출물 (Output)

`/sfs discover` 종료 시 repo-root에 생성되는 파일:

```
<repo-root>/
├── .solon/                             # 새로 생성
│   ├── .g-1-signature.yaml              # 미서명 템플릿 (G-1에서 사용자가 채움)
│   └── discover-summary.json            # install.sh가 G-1 호출 시 참조
│
├── .solon-manifest.yaml                # 기존 docs 공존 전략
│
└── docs/
    ├── discovery-report.md              # 사람이 읽을 보고서 (9 섹션)
    └── discovery/
        ├── evidence/
        │   ├── EVID-001-domain-auth.yaml
        │   ├── EVID-002-architecture-monolith.yaml
        │   ├── ...
        │   └── EVID-NNN-user-intent.yaml
        └── inventory/
            ├── repo-stats.json
            ├── hot-paths.json
            └── tech-stack.json
```

### 4.1 `.solon-manifest.yaml` 구조

```yaml
schema_version: "solon-manifest-v1"
install_id: "INST-20260420-001"
mode: "brownfield"
coexistence_strategy:
  existing_readme:
    path: "README.md"
    action: "keep"                        # keep | move-to-docs | supersede
    notes: "User-facing README는 유지, Solon docs는 docs/00-meta/에 별도로"
  existing_docs_dir:
    path: "docs/"
    action: "coexist"                     # coexist | migrate | archive
    solon_subdirs: ["00-meta", "00-initiatives", "01-plan", "02-design", ...]
    notes: "기존 docs/*.md는 유지, Solon이 docs/00-meta/ 등 새 하위만 생성"
  existing_claude_md:
    path: "CLAUDE.md"
    action: "augment"                     # keep | augment | supersede
    notes: "Solon 관련 규칙 추가. 기존 내용 유지"
migration_cookbook_ref: "s07 §7.10.9"
```

---

## 5. 오류 처리 (Error Handling)

| 상황 | 처리 |
|------|------|
| **Budget cap 초과 예상** (Pass 1 후 추정치 계산 시) | Pass 2 시작 전 abort, `discovery-report.md`에 "Budget exceeded" 섹션만 작성, 사용자에게 "tier-profile을 minimal로 낮추거나 repo 서브셋만 지정하세요" 안내 |
| **Repo가 shallow clone / detached HEAD** | Pass 1에서 감지 → 즉시 abort (`gate_report.verdict: ABORT`). 사용자에게 "git clone --depth=전체 로 다시 clone 하세요" |
| **Submodule 미초기화** | Pass 1에서 감지 → 경고만, 해당 submodule은 inventory에서 제외 |
| **Write/Edit tool 호출 시도됨** | runtime enforcement: 즉시 abort + L1 event `l1.rule-violation.brownfield-discovery-read-only` emit |
| **evidence_sources가 비어있는 claim 생성됨** | Pass 2에서 자체 검증 → 해당 yaml 폐기 + 재시도 1회, 2회째도 실패 시 해당 claim skip + warning log |
| **`/sfs discover` 2회째 호출** | `rule/p-1-run-once-per-install` 위반 → "이 repo는 이미 Solon 도입됨. 재진단은 새 Initiative로 만드세요" 안내 후 종료 |
| **LLM 호출 timeout (개별)** | Haiku 3회, Sonnet 2회 재시도 후 fail |
| **전체 timeout (2시간)** | 부분 결과 저장 + G-1에서 `FAIL-FIXABLE`로 routing (재실행 가능) |

---

## 6. 예시 (Examples)

### 6.1 정상 실행 (medium repo)

```bash
$ ./install.sh --mode brownfield --repo-root ~/work/my-saas
[install.sh] Solon brownfield mode starting...
[install.sh] Calling /sfs discover ...

[discover Pass 1/3] Scanning repo... (Haiku)
  ✓ 1847 files, 142350 loc
  ✓ Primary: TypeScript (Next.js + NestJS)
  ✓ Cost so far: $0.28

[discover Pass 2/3] Collecting evidence... (Sonnet)
  ✓ 7 claims extracted (domain, architecture, deployment, user-flow, terminology, testing, ci)
  ✓ 23 evidence sources cited
  ✓ Cost so far: $3.40

[discover Pass 3/3] Drafting discovery-report.md... (Sonnet)
  ✓ docs/discovery-report.md (9 sections) created
  ✓ .solon/.g-1-signature.yaml (unsigned template) created
  ✓ .solon-manifest.yaml (coexistence strategy) created
  ✓ Total cost: $4.85 (budget $15.00)
  ✓ Duration: 18m 32s

[install.sh] P-1 complete. Next: G-1 Intake Gate.
[install.sh] Please open docs/discovery-report.md, review carefully, then:
             1. Fill .solon/.g-1-signature.yaml (6 checkboxes + your name + date)
             2. Run: ./install.sh --continue
```

### 6.2 Abort 예시 (repo가 shallow clone)

```bash
$ ./install.sh --mode brownfield --repo-root ~/work/shallow-repo
[install.sh] Calling /sfs discover ...

[discover Pass 1/3] Scanning repo... (Haiku)
  ✗ Detected shallow clone (git rev-list --count HEAD returned 1)
  ✗ Cannot analyze repository history

[discover] ABORT: Shallow clone detected.
           → git clone --depth=all <url> 로 다시 clone 후 재시도하세요.
           → .solon/ 디렉토리는 생성되지 않았습니다.

[install.sh] Install aborted. No files created.
[exit 1]
```

### 6.3 Budget 초과 예시

```bash
$ ./install.sh --mode brownfield --repo-root ~/work/huge-monorepo --budget-cap 15.00
[install.sh] Calling /sfs discover ...

[discover Pass 1/3] Scanning repo... (Haiku)
  ✓ 45000 files, 3.2M loc
  ⚠ Estimated Pass 2 cost: $58.00 (exceeds budget-cap $15.00)

[discover] ABORT: Budget would be exceeded.
           Options:
             1. Increase --budget-cap to 80.00 (abort_threshold)
             2. Specify --subset-paths src/main,src/api (limit scan scope)
             3. Use --tier-profile minimal (reduces evidence passes)

[install.sh] Install paused. User decision required.
```

---

## 7. 관련 docs

- §2.11 원칙 11 `brownfield-first-pass` (3-pass pipeline 근거)
- §2.12 원칙 12 `brownfield-no-retro-brainstorm` (제품 방향 재brainstorm 금지)
- §2.10 원칙 10 `human-final-filter` (G-1에서 사람 서명 강제)
- §4.3 P-1 Discovery Phase (PDCA 내 위치)
- §5.11 G-1 Intake Gate (P-1 종료 게이트)
- §7.10 brownfield mode install 흐름
- `appendix/commands/README.md` — 전체 command index
- `appendix/schemas/g-1-signature.schema.yaml` — (Phase 1 구현 시 작성)
- `appendix/templates/discovery-report.template.md` — (Phase 1 구현 시 작성)

---

## 8. Phase 1 구현 체크리스트

`/sfs discover` skill을 코드로 구현할 때 확인할 항목:

- [ ] Write/Edit tool을 runtime에서 차단 (단, Pass 3의 `discovery-report.md` + `.solon/`·`.solon-manifest.yaml`만 예외)
- [ ] Opus 모델 호출 경로 전부 block (원칙 11)
- [ ] 2회째 호출 감지 로직 (`.solon/` 존재 시 abort)
- [ ] `evidence_sources` 비어있는 yaml 자체 검증
- [ ] shallow clone / detached HEAD 감지
- [ ] budget-cap 초과 예측 (Pass 1 후)
- [ ] L1 event emitter: `l1.p-1.pass-1.complete`, `l1.p-1.pass-2.complete`, `l1.p-1.pass-3.complete`, `l1.p-1.abort`, `l1.rule-violation.brownfield-discovery-read-only`
- [ ] `discovery-report-validator` (G-1에서 호출)가 이 skill의 출력을 정확히 parse 가능한지 스키마 일치 테스트

---

*(끝)*
