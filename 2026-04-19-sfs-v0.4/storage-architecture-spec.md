---
doc_id: storage-architecture-spec
title: "0.6.0-product Storage Architecture Spec"
version: 1.0
created: 2026-05-03
updated: 2026-05-03
visibility: oss-public
sprint_origin: "0-6-0-product-spec (G1 PASS LOCKED 2026-05-03)"
brainstorm_decisions:
  - "AS-D3 (C) Hybrid co-location (Google + ADR + 별도 .solon/ 트랙)"
  - "AS-D4 (a) archive 브랜치 + (d) 미래 S3 graduate hybrid"
  - "AS-D5 (b) Feature 폴더가 sprint 들 누적 + 병렬 conflict-free hard requirement"
  - "Round 1 Q3 / Axis C: C4 폴더 격리 + sprint.yml shared + lock layer REJECTED"
  - "Round 1 Q2 / Axis B: B3 단계적 + default 500 MB warn"
---

# Storage Architecture Spec — 0.6.0-product

> Layer 1 영구 + Layer 2 작업 히스토리 hybrid co-location + archive 브랜치 + N:M sprint × feature mapping + 폴더 격리 병렬 conflict-free 의 file path schema 명세.
> 핵심 철학: "히스토리는 정제되어 영구 문서가 된다" (Gate 7 정제 단계).
> SSoT 입력: brainstorm round 1+2 lock 7/7.

---

## §1. Layer 1 영구 (`docs/<domain>/<sub>/<feat>/`)

main / dev branch 의 영구 문서. sprint 종료 후 Gate 7 정제 단계에서 promote 되어 본 layer 로 이동.

```
docs/
├── <domain>/                         # 도메인 단위 (e.g. payment, auth, search)
│   ├── <sub>/                        # 서브-도메인 (옵션, 도메인 비대 시)
│   │   └── <feat>/                   # feature 단위
│   │       ├── README.md             # feature overview
│   │       ├── design.md             # interface + data model
│   │       └── adr/<NN>-<title>.md   # Architecture Decision Record (Google + ADR co-location)
│   └── ...
└── ...
```

**규칙**:
- `<domain>` / `<sub>` / `<feat>` 는 ubiquitous language 정합 (브레인스토밍 시 user 가 결정).
- ADR co-location = Google ADR convention (개별 ADR 파일을 feature 폴더 내부에 둠).
- 본 layer 는 visibility=oss-public 또는 business-only (도메인 단위 결정).

## §2. Layer 2 작업 히스토리 (feature branch only, `.solon/sprints/<S-id>/<feat>/`)

feature branch 안에서만 존재 — 머지 시 본 layer 의 raw file 들은 **archive 브랜치로 이동** 되거나 **Layer 1 으로 promote**.

```
.solon/
├── sprints/
│   └── <S-id>/                       # sprint 단위 (e.g. 0-6-0-product-spec)
│       ├── sprint.yml                # ← shared file (§4 참조)
│       ├── <feat>/                   # feature 폴더 (sprint × feature N:M 매핑)
│       │   ├── brainstorm.md
│       │   ├── plan.md
│       │   ├── implement.md
│       │   ├── review.md
│       │   ├── retro.md
│       │   └── report.md             # Gate 7 정제 산출물
│       └── ...
└── ...
```

**규칙**:
- feature 폴더가 **sprint 들 누적** (AS-D5 lock) — 같은 feature 가 여러 sprint 걸쳐 진행되면 sprint 별로 다른 feature 폴더 instance 가 생성된다 (각 sprint 의 .solon/sprints/<S-id>/<feat>/ 각각 독립).
- 본 layer 는 visibility=raw-internal (oss-public 에서 자동 제외, .visibility-rules.yaml 정합).
- 머지 후 본 layer 의 raw file 은 **삭제** (Gate 7 정제 후 archive 브랜치로 이동 + Layer 1 promote 분리).

## §3. Archive 브랜치 (B3 단계적, default 500 MB warn)

머지 시점에 Layer 2 의 sprint history 가 main / dev 가 아닌 별도 **archive 브랜치** 로 이동.

```
archive/
├── 2026-05/<S-id>/<feat>/...         # 시간 + sprint + feature 단위 retention
└── ...
```

**규칙**:
- archive 브랜치 = git native (LFS 도입은 trigger 조건 도달 시).
- **size monitor**: `sfs archive doctor` (script TBD, 0.6.x patch) 가 archive 브랜치 repo size 감시. **default warn = 500 MB** (문서 기반이라 충분, 정확 임계점은 0.6.x patch 시 재조정).
- **LFS trigger**: 단일 sprint > N MB OR 누적 > M GB (실 limit 도달 시 0.6.x patch 로 도입).
- **S3 graduate trigger**: archive 브랜치 자체가 비대 임계점 도달 (LFS 와 별도 또는 동시 timing — 0.6.x patch 시 결정).
- **release 별 amend (squash)**: 매 release 마다 오래된 sprint 들 squash 가능 (B1 + B3 hybrid).

## §4. Co-Location Pattern (AS-D3 (C) Hybrid)

Layer 1 영구 + Layer 2 raw + ADR 가 **co-located** (Google + ADR + 별도 `.solon/` 트랙):

- `docs/<domain>/<feat>/design.md` (Layer 1 영구) ↔ `.solon/sprints/<S-id>/<feat>/plan.md` (Layer 2 raw, sprint 별).
- `docs/<domain>/<feat>/adr/NN-<title>.md` (Google + ADR) — feature 영구 폴더 내부에 ADR co-located.
- `.solon/sprints/<S-id>/<feat>/` 의 brainstorm/plan/review/retro 산출물 = sprint 단위 raw → Gate 7 정제 후 영구 layer 의 design.md / adr/ 등으로 promote.

## §5. N:M Sprint × Feature Mapping

한 sprint 안 여러 feature 작업 가능 / 한 feature 가 여러 sprint 에 걸침 가능 (AS-D5 lock):

```
sprint S-1 ─┬─ feature A (instance #1)
            ├─ feature B (instance #1)
            └─ feature C (instance #1)

sprint S-2 ─┬─ feature A (instance #2, 누적)
            └─ feature D (instance #1)
```

- N feature 동시 작업 시 각 feature 폴더가 독립 (§6 폴더 격리).
- M sprint 가 같은 feature 진행 시 각 sprint 의 feature 폴더가 독립 instance (Layer 2) — Gate 7 정제 시 Layer 1 영구 layer 의 단일 `<feat>/` 로 머지.

## §6. 폴더 격리 + `sprint.yml` Shared File + Pre-Merge Hook (C4 Hybrid)

**N feature 병렬 작업 + 동시 머지 conflict-free 보장** (AS-D5 hard requirement, Round 1 Q3 lock).

- **폴더 격리** (95% conflict 회피): feature 별 모든 산출물이 `.solon/sprints/<S-id>/<feat>/` 내부 → file path 충돌 0.
- **`sprint.yml` shared file** (sprint-level meta): sprint 단위 SSoT meta (S-id / opened_at / closed_at / sprints_index / 참여 features list / Gate 진행 상태 등). N feature 병렬 작업 시 본 file 만 공유 → pre-merge hook 으로 보호.
- **pre-merge hook 검증 대상 list**:
  1. `sprint.yml` (sprint 단위 meta) — 머지 전 N branch 의 본 file diff 가 conflict 없으면 PASS.
  2. (확장) feature 영구 layer 의 `docs/<domain>/<feat>/_INDEX.md` 같은 sprint-cross shared file 들 — sprint.yml 과 동일 검증.
- **lock layer 명시적 REJECTED** (Round 1 Q3 user 결정): C2 lock-based mutex 방식은 **채택 안 함**. bash 3.2 cross-platform lock 복잡성 회피 + defense-in-depth 미채택.

## §7. anti-AC (도메인 특화 hardcoding 금지)

본 spec 은 **도메인 중립** — 특정 도메인 / 제품 카테고리 명을 file path 또는 schema 에 hardcode 금지. `<domain>` / `<sub>` / `<feat>` 는 항상 placeholder. 본 spec 채택 시 `<domain>` slot 에 들어가는 실 단어는 user 가 brainstorm 단계에서 ubiquitous language 정의로 결정.

## §8. Out of Scope (별 implement sprint)

- 실 storage 마이그레이션 script (.solon/runtime 구조 마이그레이션).
- archive 브랜치 자동 생성 + size monitor `sfs archive doctor` 구현.
- LFS / S3 graduate trigger 자동 alert.
- pre-merge hook 실 implementation (현재는 spec 만).

## §9. References

- [`SFS-PHILOSOPHY.md`](./SFS-PHILOSOPHY.md) §4 Deep Module.
- [`migrate-artifacts-spec.md`](./migrate-artifacts-spec.md) — Gate 7 정제 단계의 archive vs promote propose-accept flow.
- [`improve-codebase-architecture-spec.md`](./improve-codebase-architecture-spec.md) — Layer 1 영구 layer 의 deep module 점검.
