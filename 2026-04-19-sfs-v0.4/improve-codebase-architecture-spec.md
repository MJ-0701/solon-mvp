---
doc_id: improve-codebase-architecture-spec
title: "0.6.0-product `sfs improve-deep-modules` + `sfs implement --change-deep` Spec"
version: 1.0
created: 2026-05-03
updated: 2026-05-03
visibility: oss-public
sprint_origin: "0-6-0-product-spec (G1 PASS LOCKED 2026-05-03)"
brainstorm_decisions:
  - "Round 1 Q5 / Axis E: E3 3-pass (정적 + AI + interactive) + E-cmd-γ 둘 다 surface"
  - "도메인 사이즈 자동 감지 + 반자동 승인 (안내 → 사용자 승인 → 진행)"
  - "정적 분석 언어 scope = bash + markdown + YAML 우선, 추가 언어는 0.6.x patch"
---

# `sfs improve-deep-modules` + `sfs implement --change-deep` Spec

> Deep Module 정제의 **3-pass flow** (정적 + AI + interactive) + **3 surface** (implement 자동 감지 / `--change-deep` flag / standalone subcommand).
> 핵심 철학: shallow module 잔존 = AI agent 가 스스로 갇힘 (context overflow). Deep module 로 묶으면 testable + 경계 단순.
> SSoT 입력: `SFS-PHILOSOPHY.md` §4 Deep Module dogma.

---

## §1. Three Surfaces

### §1.1 Surface (a) — `sfs implement` 자동 감지 (반자동, default)

trigger: `sfs implement` 진행 중 generator 가 도메인 사이즈 > N file (자동 감지) 발견.

response:
1. AI 가 정적 분석 (§2 Pass 1) 실행 → shallow module 후보 list 산출.
2. user 에게 prompt: "도메인 X 의 shallow module N 건 발견. deep module 로 정제하시겠습니까? (y/n/skip-this-sprint)"
3. user `y` → §3 interactive review pass → §4 apply.
4. user `n` → 본 implement slice 만 진행, deep module 정제 별 sprint 위임.
5. user `skip-this-sprint` → 본 sprint 종료까지 prompt 안 띄움.

UX 우선 — 명령어 surface 추가 0 (사용자가 implement 흐름 안에서만 만남).

### §1.2 Surface (b) — `sfs implement --change-deep` (force-on power-user flag)

trigger: power-user 가 자동 감지 skip 하고 force-on 으로 deep module 정제 강제.

```
sfs implement <slice> --change-deep [--threshold <N>] [--lang <list>]
```

- `--change-deep`: 자동 감지 prompt 우회, 항상 §2~§4 3-pass 실행.
- `--threshold <N>`: shallow module trigger threshold (default 자동 감지 algo).
- `--lang <list>`: 정적 분석 대상 언어 제한 (default = bash + markdown + YAML).

### §1.3 Surface (c) — `sfs improve-deep-modules` (standalone subcommand)

trigger: legacy 정제 — implement 와 무관, 별 standalone refactor sprint 의 entry point.

```
sfs improve-deep-modules [--baseline <git-ref>] [--scope <path>] [--lang <list>] [--apply]
```

- `--baseline <git-ref>`: 변경 비교 기준 (default = main).
- `--scope <path>`: 분석 directory (default = `.`).
- `--lang <list>`: 분석 대상 언어 (default = bash + markdown + YAML).
- `--apply`: dry-run 이 아닌 실 변경 (default = dry-run preview).

implement context 밖에서도 호출 가능 — 전사 codebase 점검에 적합.

## §2. Pass 1 — 정적 분석

shallow module 후보 식별. 의존성 그래프 + module 크기 + cohesion metric.

```pseudo
function pass_1_static_analysis(scope, lang_list):
    files = find_files(scope, lang_list)
    modules = group_into_modules(files)  # heuristic: directory or naming convention
    candidates = []
    for module in modules:
        if module.surface_count > THRESHOLD_SURFACE \
           and module.file_count < THRESHOLD_SIZE \
           and module.cohesion < THRESHOLD_COHESION:
            candidates.append(module)
    return candidates  # shallow module 후보 list
```

**언어 scope** (Round 2 Q5 lock):
- 0.6.0 default = **bash + markdown + YAML** (3 종).
- 0.6.x patch = Python / TypeScript 추가 가능.
- 모든 언어 = 0.7.x 이후 timing.

## §3. Pass 2 — AI deep module 후보 묶음

Pass 1 산출 candidates 를 AI (model-profiles.yaml `strategic_high` tier) 가 deep module 묶음 + interface 초안 작성.

```pseudo
function pass_2_ai_grouping(candidates):
    clusters = []
    for candidate in candidates:
        related = find_related_via_ai(candidate)  # AI inference
        cluster = build_cluster(candidate, related)
        cluster.interface_draft = ai_design_interface(cluster)
        clusters.append(cluster)
    return clusters  # deep module 후보 + interface 초안
```

## §4. Pass 3 — Interactive Review (반자동, AS-D6 정합)

user 가 cluster 별 accept / reject / modify.

```pseudo
function pass_3_interactive_review(clusters):
    for cluster in clusters:
        show_to_user(cluster.before, cluster.after_proposal, cluster.interface_draft)
        decision = ask_user("accept / reject / modify <hint>")
        if decision == "accept":
            apply_cluster(cluster)
        elif decision == "modify":
            cluster = ai_revise(cluster, hint=user_input)
            re-prompt
        elif decision == "reject":
            keep_as_is(cluster)
```

## §5. Input / Output Contract

### §5.1 Input

| Surface | input |
|---|---|
| (a) `sfs implement` 자동 감지 | implement context 의 work slice + scope (default = `.`) |
| (b) `sfs implement --change-deep` | implement work slice + `--threshold` / `--lang` flags |
| (c) `sfs improve-deep-modules` | `--baseline <git-ref>` + `--scope <path>` + `--lang <list>` + `--apply` |

### §5.2 Output

```yaml
# sfs improve-deep-modules report (.solon/sprints/<S-id>/<feat>/deep-modules-report.md)
status: dry-run | applied
clusters:
  - name: <module-name>
    before:
      files: [...]
      surface_count: N
    after:
      files: [...]      # 묶인 deep module
      interface: ...    # interface 초안
    user_decision: accept | reject | modified
verdict: <N>건 정제, <M>건 reject, <K>건 modified
```

## §6. Domain Size 자동 감지 Algorithm

trigger: surface area / file count / cohesion 의 ratio.

```pseudo
function auto_detect_shallow(module):
    surface_count = count_public_interfaces(module)
    file_count = count_files(module)
    cohesion = measure_cohesion(module)  # 0.0 ~ 1.0
    # shallow if surface 가 크고 file 적고 cohesion 낮음
    return (surface_count > 5 and file_count < 3) or cohesion < 0.4
```

threshold 는 0.6.0 default — 0.6.x patch 시 user feedback 으로 재조정.

## §7. Out of Scope (별 implement sprint)

- 실 `sfs improve-deep-modules` / `sfs implement --change-deep` script 구현.
- 정적 분석 library 선택 (bash AST parser / markdown linter / YAML schema 등).
- 자동 감지 algo 의 정확 threshold 결정 (실 codebase 데이터 필요).

## §8. References

- [`SFS-PHILOSOPHY.md`](./SFS-PHILOSOPHY.md) §4 Deep Module dogma.
- [`storage-architecture-spec.md`](./storage-architecture-spec.md) §1 Layer 1 영구 layer 의 deep module 점검에 본 spec 적용.
