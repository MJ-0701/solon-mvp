---
doc_id: sfs-v0.4-appendix-tooling-doc-validate
title: "sfs-doc-validate — 문서 의존성 검증 도구 스펙"
version: 0.4
status: draft
last_updated: 2026-04-19
audience: [implementers, ops]

depends_on:
  - sfs-v0.4-index   # INDEX.md의 의존성 그래프 정의 참조

defines:
  - tool/sfs-doc-validate
  - rule/dangling-reference-detection
  - rule/dag-cycle-detection
  - rule/affects-bidirectional-check
  - rule/locked-file-mutation-detection

references:
  - schema/gate-report-v1 (defined in: s05)
  - schema/escalation-v1 (defined in: s06)

affects: []
---

# sfs-doc-validate — 문서 의존성 검증 도구

> **목적**: 모든 Solon 문서의 frontmatter (depends_on / defines / references / affects)가
> 일관성을 갖는지 자동 검증한다. **Phase 1 동반 구현 (W11~W13).**

---

## 1. 사용법

```bash
sfs-doc-validate ./agent_architect/2026-04-19-sfs-v0.4/
sfs-doc-validate --strict --output report.json
sfs-doc-validate --fix-suggest    # 자동 수정 제안
```

---

## 2. 검사 항목

### 2.1 Dangling Reference Detection
- 어떤 파일이 `references: [foo]`인데 어디에도 `defines: [foo]` 없음 → ERROR
- exception: `references: [foo (defined in: external/...)]` 명시 시 무시

### 2.2 DAG Cycle Detection
- `depends_on` 그래프에 cycle 존재 → ERROR
- 위상 정렬 가능해야 함

### 2.3 Affects Bidirectional Check
- A.affects=[B] 이면, B.depends_on ⊇ {A} 이거나 B가 A의 defines를 references해야 함
- 위배 시 → WARNING (의도적일 수 있음)

### 2.4 Locked File Mutation Detection
- `status: locked` 파일이 마지막 lock 이후 변경됐는지 git blame 기반 확인
- 변경 발견 시 → ERROR (status를 review로 내리고 재승인 필요)

### 2.5 Frontmatter Schema Validation
- 필수 필드: doc_id, title, version, status, last_updated, depends_on, defines, references, affects
- doc_id 형식: `sfs-v{major}.{minor}-s{nn}-{slug}` 또는 `sfs-v{ver}-appendix-{type}-{slug}` 또는 `sfs-v{ver}-index`

### 2.6 Cross-Reference Notation Validation
- 본문 내 `[text]({s06#anchor})` 형식 검증
- 참조하는 doc_id 또는 anchor가 실재하는지 확인

---

## 3. 출력 포맷

```json
{
  "summary": {
    "files_scanned": 18,
    "errors": 0,
    "warnings": 2,
    "passed": true
  },
  "checks": {
    "dangling_reference": [],
    "dag_cycle": [],
    "affects_bidirectional": [
      {
        "level": "WARNING",
        "file": "06-escalate-plan.md",
        "message": "affects [s09] declared but s09 doesn't reference any defines from s06"
      }
    ],
    "locked_file_mutation": [],
    "frontmatter_schema": [],
    "cross_reference": []
  },
  "dependency_graph": {
    "nodes": [...],
    "edges": [...],
    "topological_order": ["s00", "s02", "s01", "s03", ...]
  }
}
```

---

## 4. 구현 계획 (Phase 1 W11~W13)

| 주차 | 작업 |
|------|------|
| W11 | Frontmatter 파서 (Markdown / YAML / JS 주석에서 `# ---` 추출) |
| W12 | Dangling reference + DAG cycle + affects bidirectional check |
| W13 | Locked mutation + cross-ref + 출력 포맷 + CLI 패키징 |

**기술 스택**: Node.js (Claude Code hook 환경과 통일)
**라이선스**: MIT (Phase 2 상품화 시 재검토)

---

## 5. CI 통합

```yaml
# .github/workflows/doc-validate.yml
name: Solon Doc Validate
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npx sfs-doc-validate ./agent_architect/2026-04-19-sfs-v0.4/ --strict
```

---

## 6. Phase 2 확장 후보

- 자동 의존성 그래프 시각화 (Mermaid 출력)
- Notion sync에 검증 결과 push
- Auto-fix mode (frontmatter 누락 시 LLM이 제안)
- VS Code Extension (실시간 frontmatter 검증)

---

*(끝)*
