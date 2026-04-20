---
doc_id: sfs-v0.4-appendix-drivers-interface
title: "L3 Backend Driver Interface — v1"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [implementers, driver-authors, plugin-customizers]

depends_on:
  - sfs-v0.4-s08-observability
  - sfs-v0.4-s07-plugin-distribution

defines:
  - contract/l3-driver-interface-v1
  - rule/driver-manifest-required-fields
  - rule/driver-compatibility-warn-not-block

references:
  - channel/l3-notion (defined in: s08)
  - rule/unidirectional-sync (defined in: s08)
  - principle/worker-parallelism (defined in: s02)

affects: []
---

# L3 Backend Driver Interface — v1

L3 (Human View Channel)은 Notion에 한정되지 않는다. 이 문서는 모든 L3 driver가 만족해야 하는 계약(contract)을 명시한다. tier_profile과 l3_backend는 **직교(orthogonal)** — 자유롭게 조합 가능하며, 비호환 조합은 **경고만** 발생하고 사용자가 최종 결정한다.

---

## 1. Driver 정의

L3 driver = `divisions.yaml` top-level의 `l3_backend` 값에 대응하는 구현체.

| 항목 | 위치 |
|------|------|
| Manifest | `appendix/drivers/<driver_id>.manifest.yaml` |
| Implementation (Phase 1 = `notion` + `none`) | `sfs-plugin/drivers/<driver_id>/` (Phase 2 별도 패키지 가능) |
| Capability 선언 | manifest의 `collab_modes`, `multi_user`, `auth`, `capabilities` 등 |
| Phase | `phase1_supported`, `phase1_default` 표시 |

---

## 2. 필수 인터페이스 (3 메서드)

```typescript
interface L3Driver {
  // Sprint/PDCA 단위 publish (L2 commit 직후 호출)
  publish(target: SprintId | PdcaId, summary: SummaryPayload): Promise<DriverResult>;

  // Sprint/PDCA 조회 (대시보드 view 갱신용)
  query(target: SprintId | PdcaId, range?: TimeRange): Promise<QueryResult>;

  // Sprint 종료 시 archive (12-sprint rolling 정책)
  archive(sprintId: SprintId): Promise<DriverResult>;
}

type DriverResult = {
  status: 'success' | 'warning' | 'error' | 'noop';
  message?: string;
  metadata?: Record<string, unknown>;
};
```

각 메서드는 **항상 반환** (throw 금지). 실패 시 `error` 상태로 반환 → §8.8 graceful degradation 보장.

---

## 3. Manifest 필수 필드

```yaml
id: <driver_id>                    # kebab-case (예: notion, obsidian, custom-x)
display_name: <human-readable>
version: <semver>

collab_modes: [realtime|async|comment|mention|view-only]
multi_user: native | via-sync-service | via-git | not-supported

auth:
  type: api-key | oauth | local-fs | none
  required_env: [<ENV_VAR_NAME>...]

capabilities:
  publish: true|false
  query: true|false
  archive: true|false
  rich_view: true|false           # 대시보드 chart, embed 등

phase1_supported: true|false
phase1_default: true|false        # 단 1개의 driver만 true

known_limitations: [<text>...]

# tier별 권장사항 (optional)
tier_recommendations:
  minimal: <text>
  standard: <text>
  collab: <text>

# 비호환 경고 트리거 (optional, 없으면 모든 tier에서 OK 가정)
warn_when:
  - tier: <minimal|standard|collab>
    condition: <free-form 또는 키워드>
    message: <text>
```

`sfs-doc-validate`가 manifest 형식 자동 검증 (Phase 1 W11~W13 도구 구현 시).

---

## 4. Phase 1 driver 목록

| driver | phase1_supported | phase1_default | 비고 |
|--------|:---:|:---:|------|
| notion | ✅ | ✅ | Free/Plus/Team 모두 작동 |
| none   | ✅ | — | L3 비활성화. L2 git docs 직접 read |
| obsidian | ❌ | — | Phase 2 community contribution 후보 |
| logseq | ❌ | — | Phase 2 |
| confluence | ❌ | — | Phase 2 enterprise |
| custom | ⚠️ | — | 사용자 자작 driver (manifest 작성 + 구현 필요, advanced) |

`divisions.schema.yaml` enum: `[notion, obsidian, logseq, confluence, custom, none]`. Phase 1에서 `obsidian/logseq/confluence/custom` 선택 시 sfs-doc-validate가 "driver 미구현" 경고 + fallback 안내.

---

## 5. 호환성 경고 (block 절대 금지)

`tier_profile × l3_backend` 조합 일부는 capability 한계로 경고 표시. **차단(block)은 절대 하지 않음** — 사용자 의도 우선.

`rule/driver-compatibility-warn-not-block`

| tier | backend | 경고 트리거 (driver manifest 또는 schema) | 메시지 예시 |
|------|---------|----------------------------------------|------------|
| collab | obsidian | `multi_user: via-sync-service\|via-git` | "Realtime 협업 미지원 (async only). Notion Team 권장." |
| collab | logseq | 동상 | 동상 |
| collab | none | `collab_modes: []` | "L3 비활성화 + collab tier. L2 git PR/issue 워크플로로만 협업 가능." |
| minimal | notion (Team plan 사용) | (cost 정보 비교) | "Team plan 비용 발생. Free plan으로 동일 기능 가능." |
| 모든 tier | none + 8 sprint+ | (sprint count) | "L3 없이 8 sprint+ 누적. markdown 직접 read 부담. driver 활성화 검토." |

### 경고 발생 시 사용자 분기

```yaml
on_warn:
  - id: revise
    label: "권장 조합으로 변경"
    action: "set <field>=<recommended_value>"
  - id: keep
    label: "원래 의도대로 진행"
    action: "noop"
default: keep         # 사용자 의도 우선 (block 없음)
```

이 분기는 plugin install 시 prompt + `divisions.yaml` 변경 시 validation 두 시점에 동작.

---

## 6. driver 추가 절차 (Phase 2 community contribution)

1. `appendix/drivers/<id>.manifest.yaml` 작성 (이 문서 §3 형식 준수)
2. `sfs-plugin/drivers/<id>/index.ts` 구현 (이 문서 §2 인터페이스 3 메서드)
3. `appendix/schemas/divisions.schema.yaml` enum에 `<id>` 추가 PR
4. 호환성 매트릭스 갱신 (이 문서 §5 표에 row 추가)
5. `sfs-doc-validate`가 manifest 형식 검증 자동 통과 시 merge

→ Phase 1은 `notion` + `none` 2개로 시작. 나머지는 community 기여 받기 좋은 구조.

---

*(끝)*
