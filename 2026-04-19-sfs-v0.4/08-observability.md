---
doc_id: sfs-v0.4-s08-observability
title: "§8. 3-Channel Observability"
version: 0.4-r4
status: draft
last_updated: 2026-04-29
audience: [architects, ops, c-level]
required_reading_order: [s00, s02, s03, s04, s05, s06, s07, s08]

depends_on:
  - sfs-v0.4-s04-pdca-redef
  - sfs-v0.4-s05-gate-framework
  - sfs-v0.4-s06-escalate-plan
  - sfs-v0.4-s07-plugin-distribution

defines:
  - channel/l1-s3
  - channel/l2-git-docs-submodule
  - channel/l3-human-view
  - channel/l3-notion                 # optional driver (specialization of l3-human-view)
  - rule/unidirectional-sync
  - concept/ssot-l2
  - concept/observability-hook
  - rule/local-state-gitignore
  - schema/l1-log-event

references:
  - schema/gate-report-v1 (defined in: s05)
  - schema/escalation-v1 (defined in: s06)
  - concept/sprint (defined in: s04)
  - principle/local-state-private (defined in: s02)
  - division/* (defined in: s03)
  - impl/observability-sync (defined in: appendix/hooks/observability-sync.sample.ts)
  - contract/l3-driver-interface-v1 (defined in: appendix/drivers/_INTERFACE.md)
  - rule/driver-compatibility-warn-not-block (defined in: appendix/drivers/_INTERFACE.md)
  - schema/divisions-yaml-v1 (defined in: appendix/schemas/divisions.schema.yaml)

affects:
  - sfs-v0.4-s09-differentiation
  - sfs-v0.4-s10-phase1-implementation
---

# §8. 3-Channel Observability

> **Context Recap (자동 생성, 수정 금지)**
> Solon은 모든 산출물 + Gate 결과 + Escalation 로그를 **3개 채널**에 일방향 sync한다.
> L1 (S3): 기계용 raw log / L2 (git docs submodule): SSoT, 감사용 / L3 (Human View, driver-backed): 사람용 view.
> L3는 **driver 교체 가능한 추상 채널**. Phase 1 default=`none`, 필요 시 notion 등 driver manifest 기반으로 교체 (§8.11, `contract/l3-driver-interface-v1`).
> 원칙 2.6 (로컬 상태 private)과 결합되어 race condition을 구조적으로 방지.
> 여기서 정의된 hook은 §7 plugin 패키징에 포함됨.

---

## TOC

- 8.1 3개 채널 정의
- 8.2 동기화 원칙 (일방향 + L2 SSoT)
- 8.3 채널별 저장 데이터
- 8.4 동기화 트리거 (hook 위치)
- 8.5 로컬 상태 처리 (gitignore)
- 8.6 L1 로그 이벤트 스키마
- 8.7 Notion 뷰 구조 (Sprint 대시보드)
- 8.8 Graceful Degradation — 채널 부분 실패 처리
- 8.9 데이터 보존 & 비용 정책
- 8.10 보안·민감 데이터 처리
- 8.11 L3 Driver 교체 시나리오 🆕

---

## 8.1 3개 채널 정의

`channel/l1-s3`, `channel/l2-git-docs-submodule`, `channel/l3-notion`: Solon의 모든 관측 데이터는 **3개 분리 채널**에 흐른다. 각 채널은 **독자가 다르고**, **편집 가능성이 다르며**, **단일 진실(SSoT)에서의 위치가 다르다**.

| 채널 | 수신자 | 저장소 | 용도 | 편집 가능? | SSoT? |
|:---:|------|--------|------|:---:|:---:|
| **L1 Raw Logs** | Machine (sfs-doc-validate, retro analyzer) | S3 (또는 로컬 폴백 `.sfs-local/logs/`) | agent JSON 로그, metric, trace | ❌ append-only | ❌ |
| **L2 Versioned Docs** | Git / 감사 / sfs agent | `docs/` (submodule 또는 동일 repo) | **SSoT** — PDCA 산출물, GateReport, escalation, learnings | ✅ 커밋으로만 | ✅ |
| **L3 Human View** | Human / 비개발자 / 외부 이해관계자 | L3 driver (phase1 default: `none`; [notion / obsidian / logseq / confluence / custom] 교체 가능 — §8.11) | 읽기 뷰, 비개발자 UX, Sprint 대시보드 | ❌ (읽기 전용) | ❌ |

### 8.1.1 왜 3개로 분리하는가

- **수신자가 다름**: 기계는 raw 데이터, 감사는 versioned 결정, 사람은 시각적 요약을 원함. 한 저장소로 모두 만족 불가.
- **수정 가능성이 다름**: L1은 절대 수정 X (감사), L2는 git 추적 가능, L3은 sync 결과만.
- **장애 영향도 다름**: L3 다운(Notion 장애)이 L2 작업에 영향 주면 안 됨. 채널 간 **장애 격리** 필수.

### 8.1.2 한 데이터 = 세 표현

같은 GateReport 1건이 3개 채널에 다음과 같이 존재:

| 채널 | 표현 | 예시 |
|------|------|------|
| L1 | 호출 trace + raw I/O | `{"event_id":"...","tool_calls":[...],"input_tokens":1234,...}` |
| L2 | 결정의 기록 (yaml) | `docs/.../gates/GR-042-G3-001.yaml` (§5.4 schema) |
| L3 | 시각화/요약 (driver 의존) | 예: Notion 페이지 "PDCA-042 — G3 PASS (87점)" (driver=`notion` 기준. 다른 driver에서는 각자 UI로 표현) |

→ 같은 사실(fact)의 3가지 view. **L2가 정답**, L1은 출처, L3은 인간 친화 요약.

### 8.1.3 (anti) 단일 채널의 함정

bkit/cowork는 git만 사용 (≈ L2 only). 결과:
- 비개발자 → git 못 봄, 정보 단절
- 비용/메트릭 집계 → 별도 도구 필요
- raw debugging → 로그가 휘발

→ Solon의 3-Channel은 **분업의 비용**(sync 복잡도)을 받아들이고 **분업의 가치**(독자별 최적화)를 얻는다.

---

## 8.2 동기화 원칙 (일방향 + L2 SSoT)

`rule/unidirectional-sync`, `concept/ssot-l2`: 모든 sync는 **단방향**, 모든 진실은 **L2** 기준.

```
[Agent 실행 (Claude Code / Cowork)]
    │
    │ PostToolUse hook
    ↓
[L1 S3] (raw log, append-only, immediate)
    │
    │ batch summary (PDCA step 종료 시)
    ↓
[L2 docs/] (SSoT, git commit)
    │
    │ post-commit / cron sync
    ↓
[L3 Human View] (driver-backed, read-only; phase1 default: notion)
```

### 8.2.1 단방향 sync의 4가지 규칙

1. **L3 → L2 역류 금지**: Notion에서 페이지를 편집해도 L2(`docs/`)에 반영되지 않는다. Notion은 항상 stale될 수 있고, L2가 수정의 유일한 진입점.
2. **L1 → L2는 요약만**: 모든 raw log를 git에 커밋하면 repo가 폭발. 요약/집계만 (예: Sprint 비용 합계, gate_pass_rate)
3. **L2 → L3는 mirroring**: L2 커밋 → L3 동기화. L3는 L2의 view 함수 결과.
4. **L1 자체 비파괴**: L2/L3 동기화가 실패해도 L1은 손상되지 않음. L1을 출처로 재구성 가능.

### 8.2.2 왜 L2가 SSoT인가 (L1 또는 L3가 아니라)

| 후보 | 장점 | 결정적 단점 |
|------|------|-----------|
| L1 (S3) | 가장 raw, 손실 없음 | 사람이 읽기 어려움, 결정의 맥락 부재 |
| **L2 (git)** | 결정 단위로 commit, diff/blame, branch (escalation) | 한 채널의 비용은 있지만 가치 압도 |
| L3 (Notion) | 사람 친화, 외부 공유 쉬움 | 외부 SaaS 의존, snapshot 단일 |

→ **결정의 단위 = commit**. PDCA의 모든 의사결정 산출물은 commit graph로 추적 가능. 이게 L2가 SSoT인 이유.

### 8.2.3 SSoT 위반 시나리오

**문제**: 사용자가 Notion에서 수정 → L2와 다름 → 어느 게 진짜?
**Solon의 답**: L3(Notion)는 항상 L2 기준으로 덮어씌워짐. **사용자 수정은 다음 sync에서 사라진다**. UI에 명시적 경고 표시.

**문제**: 동일 PDCA에 대해 두 PC에서 동시 commit
**Solon의 답**: git 표준 충돌 해결 — `.sfs-local/`는 PC별 분리이므로 충돌 안 남, `docs/`만 git rebase로 해결.

→ 두 시나리오 모두 Solon은 **L2(git)를 단일 진실**로 선언함으로써 해결.

### 8.2.4 docs submodule vs 동일 repo

`channel/l2-git-docs-submodule`이 권장이나 강제는 아님:
- **submodule 권장 시나리오**: docs와 source code의 lifecycle이 다름 (예: prod hotfix는 docs 변경 없음)
- **동일 repo 권장 시나리오**: 1인 창업 초기, 단순 구조 우선
- 둘 다 plugin은 동작 (sync hook은 `docs/` 경로만 인식)

→ Phase 1은 사용자 선택. Phase 2에서 best practice 가이드 추가.

---

## 8.3 채널별 저장 데이터

### 8.3.1 L1 (S3) — Raw Logs

**저장 데이터**:
- 모든 agent 호출 로그 (prompt, response, tool calls)
- 토큰 사용량 (input/output), 비용
- Latency (시작~종료, tool별)
- Session 메타 (session_id, started_at, ended_at)
- Trace ID (분산 trace 연결)

**저장 형식**: JSON Lines (`.jsonl`), 하루 1파일, S3 prefix `s3://bucket/sfs-logs/YYYY/MM/DD/`

**보존 기간**: **90일** (Phase 1 기본). S3 lifecycle policy로 자동 archive(90일+) → delete(365일+).

**보존 기간이 90일인 이유**:
- H6 학습은 직전 4 Sprint(8주) 기준 (§6.6.2) → 90일이 충분히 길게 커버
- S3 비용 vs 디버깅 가치 trade-off → 분기별 retro에 90일이면 충분
- 90일 이상 데이터는 L2의 GateReport 요약으로 대체 가능

### 8.3.2 L2 (git `docs/`) — Versioned Docs (SSoT)

**저장 데이터** (디렉토리 구조):

```
docs/
├── 00-sprint-plan/
│   └── SP-{N}.plan.md                           # Sprint 계획
├── 01-plan/
│   └── PDCA-{NNN}.plan.md                       # PDCA Plan 산출물 (§4)
├── 02-design/
│   └── PDCA-{NNN}.design.md                     # PDCA Design 산출물
├── 03-analysis/
│   ├── PDCA-{NNN}.analysis.md                   # PDCA Check 산출물
│   ├── escalations/
│   │   └── ESC-{date}-{seq}.yaml                # §6.7 escalation
│   └── gates/
│       └── GR-{pdca}-{gate}-{seq}.yaml          # §5.4 gate report
├── 04-reports/
│   ├── PDCA-{NNN}.report.md                     # PDCA Act 산출물
│   └── SP-{N}.retro.md                          # Sprint Retro (G5)
├── 05-learning/
│   └── memory/learnings-v1.md                   # H6 학습 (§6.6)
└── INDEX.md                                       # auto-generated cross-ref
```

**저장 형식**: Markdown (산출물) + YAML (구조화 데이터: gate report, escalation)

**보존 기간**: **영구** (git history). 삭제 없음.

**커밋 정책**: 
- Agent가 자동 commit: 1 PDCA step 종료 시
- 사용자가 수동 review/squash: Sprint 종료 시 cleanup commit

### 8.3.3 L3 (Human View) — driver-backed read-only view

**저장 데이터** (driver 무관 공통 의미):
- Sprint 대시보드 (현재 Sprint 진척)
- 본부별 PDCA 진척 (active/blocked/done)
- Open Escalation 목록
- 5-Axis 점수 트렌드 (line chart)
- Gate Pass Rate (Gate별, Sprint별)
- Cost per PDCA (월별, 본부별)

**저장 형식**: driver 의존. Phase 1 default=`notion` 기준 Notion DB + page. sync hook은 driver interface의 `publish`/`query`/`archive` 3 메서드만 호출 ([contract/l3-driver-interface-v1](appendix/drivers/_INTERFACE.md)).

**보존 기간**: driver 정책 따름. `notion` driver는 영구 (Notion 자체), archive 페이지로 이동. `none` driver는 비활성화 (보존 없음).

**갱신 주기**:
- 실시간(수 초): 새 PDCA, gate pass/fail
- 배치(분 단위): metric 집계 (gate_pass_rate 등)
- Sprint 단위: retrospective 페이지

---

## 8.4 동기화 트리거 (Hook 위치)

`concept/observability-hook`: sync는 **자동**이며, 사용자가 명시 호출 안 함. Hook은 §7 plugin의 `hooks/observability-sync.ts`에 위치.

| Hook 위치 | 트리거 채널 | 트리거 조건 | 호출 함수 |
|----------|-----------|----------|---------|
| Claude Code `PostToolUse` | L1 | 모든 tool 호출 직후 | `onPostToolUse(toolUseEvent)` |
| Claude Code `Stop` | L1 + L2 | Session 종료 시 | `onSessionStop(sessionInfo)` |
| Git `post-commit` (선택) | L3 | `docs/` 경로 commit 시 | `syncToL3(commitInfo)` |
| Sprint end (수동/자동) | L3 (대시보드 갱신) | `/sprint end` 또는 G5 통과 후 | `refreshSprintDashboard()` |

### 8.4.1 PostToolUse hook (L1)

```typescript
// 모든 agent의 tool 호출 후 발화 — synchronous, 빠름
export async function onPostToolUse(toolUseEvent: ToolUseEvent): Promise<void> {
  const event: L1Event = enrichEvent(toolUseEvent);  // session_id, agent_id 등 추가
  await publishToL1(event);                          // S3 또는 로컬 fallback
  // L2/L3는 여기서 건드리지 않음 (성능)
}
```

→ 호출당 비용 < 50ms. agent 응답 latency에 영향 최소화.

### 8.4.2 Stop hook (L1 + L2)

```typescript
// Session 종료 시 — 누적 데이터 commit
export async function onSessionStop(sessionInfo: SessionInfo): Promise<void> {
  await flushL1Buffer(sessionInfo.session_id);       // 미전송 L1 이벤트 마무리

  const artifacts = collectSessionArtifacts(sessionInfo);  // gate-report, escalation 등
  for (const artifact of artifacts) {
    const commit = await commitToL2(artifact);             // docs/ 커밋
    if (commit) await syncToL3(commit);                    // L3로 propagate
  }
}
```

→ Session 단위 batch. PDCA 한 step 동안 발생한 산출물을 묶어 1 commit.

### 8.4.3 Git post-commit hook (L3, optional)

사용자가 수동 commit하는 경우(예: `git commit`을 IDE에서)에도 L3가 stale 안 되게:

```bash
# .git/hooks/post-commit (install.sh가 설치)
node ./node_modules/sfs-plugin/hooks/observability-sync.ts --mode=post-commit
```

→ commit 후 자동으로 L3 push. 실패해도 commit 자체는 성공 (L3 sync는 best-effort).

### 8.4.4 Sprint dashboard 갱신

`/sprint end` 명령 또는 G5 통과 시:
- 새 Sprint 페이지 생성 (Notion DB)
- 이전 Sprint 페이지를 archive로 이동
- Cross-Sprint trend chart 재계산

→ Sprint 경계는 **사람의 의사결정 시점**이므로 batch sync로 충분.

---

## 8.5 로컬 상태 처리 (gitignore)

`rule/local-state-gitignore`: PC별/세션별 로컬 상태는 **반드시** git에서 제외. 원칙 2.6의 물리적 구현.

### 8.5.1 gitignore 표준 항목

```gitignore
# ───────── Solon local state (PC별, 동기화 금지) ─────────
.sfs-local/
.sfs-local/logs/
.sfs-local/cache/
.sfs-local/sessions/

# Claude Code local memory (PC별 auto-memory)
.claude/projects/*/memory/

# bkit local cache (호환성)
.bkit-memory.json
docs/.bkit-memory.json

# Plugin user override (보존하지만 commit 안 함)
sfs-plugin/config/divisions.yaml
# (사용자가 명시적으로 commit 원하면 -f 옵션 필요)
```

### 8.5.2 왜 이 항목들을 gitignore 하는가

| 항목 | 이유 | 미동기화 시 손실되는 것 |
|------|------|-------------------|
| `.sfs-local/logs/` | S3 로컬 폴백, PC별 다름 | 없음 (S3가 진실) |
| `.sfs-local/cache/` | Evaluator 결과 캐시 | 없음 (재계산 가능) |
| `.sfs-local/sessions/` | 진행 중인 session 메타 | session 중단 시 resume 불가 (트레이드오프 수용) |
| `.claude/projects/*/memory/` | Claude Code auto-memory, PC별 컨텍스트 | 다른 PC에서 컨텍스트 낮음 (Claude Code 특성) |
| `.bkit-memory.json` | bkit 호환, PC별 | bkit 자체 동작 영향 없음 |

### 8.5.3 race condition을 어떻게 방지하는가

**시나리오**: MacBook과 Windows PC에서 같은 프로젝트를 번갈아 사용.

- **나쁜 설계**: `.sfs-local/`을 git에 포함 → push 충돌 → 한쪽 작업 손실
- **Solon 설계**: `.sfs-local/`은 무조건 PC별. push 안 함 → 충돌 자체가 발생 불가
- **L2 작업물**: `docs/`만 push/pull. 의식적 commit이므로 사용자 통제 가능

→ "자동 sync로 race를 푼다"가 아니라 **"sync해야 할 항목 자체를 줄여서 race를 없앤다"**. 이것이 원칙 2.6의 본질.

### 8.5.4 동기화 필요한 부분만 명시 export

만약 `.sfs-local/`의 일부 데이터를 다른 PC에서도 참조하고 싶다면:
- 사용자가 명시적으로 `docs/`로 export (예: 학습 패턴을 `docs/05-learning/`로 commit)
- 자동 sync 안 함 (사용자가 결정)

→ "데이터를 옮기려면 한 번 결정해야 한다" — 의도하지 않은 sync 방지.

---

## 8.6 L1 로그 이벤트 스키마

`schema/l1-log-event`: L1에 publish되는 표준 이벤트. 전체 정의는 [appendix/schemas/l1-log-event.schema.yaml](appendix/schemas/l1-log-event.schema.yaml).

```json
{
  "event_id": "evt_01HXYZ1234ABCDEF",
  "schema_version": "v1",
  "timestamp": "2026-04-19T10:00:00.123Z",

  "session_id": "sess_abc123",
  "agent_id": "tech/dev/worker",
  "agent_role": "worker",
  "model": "claude-sonnet-4-6",

  "tool_calls": [
    {
      "tool_name": "Read",
      "tool_input_summary": "src/services/UserService.kt",
      "duration_ms": 12,
      "status": "success"
    }
  ],

  "tokens": {
    "input": 12450,
    "output": 820,
    "cache_read": 8000,
    "cache_creation": 0
  },
  "cost_usd": 0.042,
  "latency_ms": 4200,

  "context": {
    "sprint_id": "SP-005",
    "pdca_id": "PDCA-042",
    "gate_id": null,
    "escalation_id": null,
    "trace_id": "trc_xyz789"
  },

  "result": {
    "status": "success",
    "error_code": null,
    "produced_artifacts": ["docs/02-design/PDCA-042.design.md"]
  }
}
```

### 8.6.1 필드 그룹

| 그룹 | 목적 | 예시 |
|------|------|------|
| 식별 | event_id, timestamp, session_id, trace_id | 유니크 + 시계열 + 분산 trace |
| 주체 | agent_id, agent_role, model | 누가 무슨 모델로 |
| 동작 | tool_calls (배열) | 무엇을 호출했나 |
| 비용 | tokens, cost_usd, latency_ms | 얼마 들었나 |
| 컨텍스트 | sprint/pdca/gate/escalation IDs | 어느 PDCA의 일부인가 |
| 결과 | status, error_code, artifacts | 결과는 어떻게 됐나 |

### 8.6.2 스키마 진화 정책

- 새 필드 추가 → MINOR (v1.1, v1.2 — 후방 호환)
- 필드 삭제/타입 변경 → MAJOR (v2 — schema_version 변경)
- L1 consumer는 unknown 필드 무시 (forward-compatible)

### 8.6.3 PII / 민감 데이터

L1 이벤트는 **prompt 본문을 포함**할 수 있다. 따라서:
- S3 버킷은 사용자 own AWS 계정 (멀티테넌트 X)
- 사용자가 도메인 특화 PII가 포함되면 자체 redaction 책임
- `tool_input_summary`는 hash 또는 truncate (전문 저장 X)

→ §8.10 보안 섹션 참조.

---

## 8.7 Notion 뷰 구조 (Sprint 대시보드)

Notion driver 선택 시의 L3 워크스페이스 표준 구조. `driver=none` 에서는 같은 정보를 local report/status view 로 남긴다.

```
Solon Workspace (Notion top page)
│
├── 📊 Current Sprint Dashboard            (Sprint별 자동 갱신)
│   ├── Sprint Header (SP-005, 2026-04-15 ~ 2026-04-26)
│   ├── 본부별 PDCA 진척
│   │   ├── 🔵 strategy-pm:    PDCA-051 (Design 진행)
│   │   ├── 🔵 taxonomy:       PDCA-052 (Plan 완료)
│   │   ├── 🟢 design:         PDCA-053 (Do 진행)
│   │   ├── 🟢 dev:            PDCA-054 (Check 대기)
│   │   ├── 🟡 qa:     PDCA-055 (blocked, ESC-...)
│   │   └── ⚪ infra:          PDCA-056 (Plan 시작 전)
│   │
│   ├── Gate Pass Rate (Gate × Division 매트릭스)
│   │   ┌──────┬──┬──┬──┬──┬──┐
│   │   │      │PM│TX│DS│DV│QA│  G1 G2 G3 G4 G5
│   │   ├──────┼──┼──┼──┼──┼──┤  100/100/95/87/—
│   │   │ G1   │..│..│..│..│..│
│   │   └──────┴──┴──┴──┴──┴──┘
│   │
│   ├── Open Escalations (3건)
│   │   ├── ESC-2026-04-19-001 (α-1, dev, AC-051-002)
│   │   ├── ESC-2026-04-22-003 (α-1, dev, AC-049-007)
│   │   └── ESC-2026-04-25-002 (α-1, design, AC-053-003)
│   │
│   └── Cost This Sprint (USD)
│       └── $42.30 / $50 budget
│
├── 📈 5-Axis Score Trends                  (Sprint history)
│   ├── Value-Fit (line chart)
│   ├── User-Outcome
│   ├── Soundness
│   ├── Maintainability
│   └── Future-Proof
│
├── 🚨 H6 Active Learnings                  (memory/learnings-v1.md mirror)
│   ├── PTRN-MAIL-SLA-001 (active, last violated 2026-04-19)
│   ├── PTRN-INFRA-COST-002 (dormant)
│   └── ...
│
├── 📦 Past Sprints (archive)               (자동 archive)
│   ├── SP-001 (closed 2026-01-25)
│   ├── SP-002 (closed 2026-02-08)
│   └── ...
│
└── 📚 Reference                             (정적 페이지, divisions.yaml mirror)
    ├── Divisions (6 본부)
    ├── Evaluators
    └── Failure Modes (§5.7)
```

### 8.7.1 Notion DB 권장 스키마

각 PDCA가 1 row인 master DB:

| Property | Type | 출처 |
|---------|------|------|
| `pdca_id` | Title | L2 plan.md frontmatter |
| `sprint` | Relation → Sprint DB | L2 |
| `division` | Select | L2 |
| `phase` | Select (plan/design/do/check/act) | L2 (현재 단계) |
| `status` | Status (active/blocked/done/aborted) | L2 |
| `g1_g2_g3_g4` | Select × 4 | L2 gate reports |
| `5_axis_avg` | Number | L2 latest G4 |
| `cost_usd` | Number | L1 aggregate |
| `escalations` | Relation → Esc DB | L2 escalation files |
| `last_synced_at` | Date | sync 메타 |

### 8.7.2 Notion이 아닌 다른 워크스페이스

L3는 Notion에 한정되지 않음. 호환 후보:
- **Confluence**: enterprise 환경. Phase 1은 sample만, 본격 지원은 Phase 2
- **Linear**: issue 중심 view. dev 본부에 친화적
- **Slack**: real-time alert (대시보드는 아님). hook으로 alarm만 push

→ Phase 1은 Notion 기본, plugin config로 sink 추가 가능 (Phase 2 확장).

### 8.7.3 사용자가 Notion 페이지를 편집하면

§8.2.3대로 **다음 sync에서 덮어씌워짐**. 사용자에게는 다음 안내:
- 페이지 상단에 "🔒 이 페이지는 Solon이 자동 생성합니다. L2(`docs/`)를 수정하세요." 배너
- 편집 시 sync hook이 변경 detect → "(local edit overwritten)" 로그를 L2에 기록

---

## 8.8 Graceful Degradation — 채널 부분 실패 처리

각 채널은 **독립적으로 실패 가능**해야 하고, 한 채널 실패가 다른 채널을 막으면 안 된다.

| 실패 채널 | 영향 | Solon의 대응 |
|---------|------|---------|
| **L1 (S3 down)** | raw log 미전송 | 로컬 `.sfs-local/logs/`에 폴백, S3 복구 시 batch upload |
| **L2 (git push 실패)** | 원격 sync 안 됨 | local commit은 성공, 사용자가 수동 `git push` |
| **L3 (driver error: API 장애, auth 만료 등)** | 대시보드 stale | 다음 sync로 catch-up. agent 동작에 영향 없음. driver interface의 `DriverResult: 'error'` 상태 반환 시 재시도 큐 적재 (§8.11) |
| **L1 + L3 동시 down** | metric 집계 불가 | L2만으로 PDCA 계속 진행 가능 |
| **L2 down (git server)** | local commit은 가능 | sync 큐에 적재, 복구 시 push |

### 8.8.1 채널별 우선순위

L1, L2, L3가 모두 가능하면 → 모두 sync. 하나가 실패하면:
- **L2 우선** — agent 작업의 다음 단계는 L2 commit 성공 여부에 의존
- **L1 best-effort** — 실패해도 agent는 계속 진행
- **L3 best-effort** — 실패는 알림만, agent 진행에 무관

→ "agent 작업 continuity > observability" 원칙. 관측이 작업을 막지 않게.

### 8.8.2 sync 실패 알림

- L1 폴백: 로컬 로그에 warning, 24시간 누적되면 사용자에게 prompt
- L2 push 실패: 다음 commit 시도 시 사용자에게 안내
- L3 sync 실패: 매 N회 누적 시 사용자에게 안내 (조용한 stale 방지)

### 8.8.3 disaster recovery

- **L2(git)가 SSoT**이므로 L1/L3가 모두 손실되어도 system은 복구 가능
- L1 손실: 90일 이내 데이터만 손실 (장기 metric은 L2의 GateReport에서 재집계)
- L3 손실: Notion 워크스페이스 재생성 + L2 → L3 full re-sync

→ L2(git)만 백업하면 Solon 전체가 복구된다. **single backup target**의 단순성.

---

## 8.9 데이터 보존 & 비용 정책

### 8.9.1 채널별 보존 정책 요약

| 채널 | Hot (즉시 접근) | Warm (드물게) | Cold (archive) | Delete |
|------|--------------|-------------|--------------|--------|
| L1 (S3) | 30일 | 30~90일 | 90일~365일 | 365일+ |
| L2 (git) | 영구 | — | — | 없음 |
| L3 (Notion) | active sprint | past sprints (last 12) | archive page | 없음 (수동 삭제) |

### 8.9.2 Phase 1 비용 추정 (월 기준)

가정: PDCA 30회/월, Sprint 2회/월, 평균 10K input tokens × 1K output tokens / event.

| 항목 | 추정 비용 (USD/월) |
|------|---|
| Claude API (Opus + Sonnet + Haiku 혼합) | $200 ~ $400 |
| AWS S3 (L1 storage + transfer) | $5 ~ $15 |
| Notion API (L3) | $0 (free tier 또는 워크스페이스 plan에 포함) |
| 네트워크 / 기타 | $5 |
| **합계** | **$210 ~ $420** |

### 8.9.3 비용 가시화

L3 driver view 의 "Cost This Sprint" property가 **실시간** 비용을 표면화. `driver=none` 이면 local report/status view 에 동일 지표를 남긴다. 임계치:
- Sprint budget의 80% 도달 → 경고
- Sprint budget의 100% 도달 → C-Level alert (Sprint 종료 또는 추가 승인 필요)

→ 비용은 **agent가 사용자에게 능동 보고**해야 할 신호. 숨기지 않음.

---

## 8.10 보안·민감 데이터 처리

### 8.10.1 민감 데이터 카테고리

| 카테고리 | 예시 | 채널별 처리 |
|---------|------|-----------|
| **API 키 / token** | AWS, Notion, OpenAI 키 | 어떤 채널에도 저장 X (env 변수만, redact) |
| **개인 정보 (PII)** | 사용자 이메일, 결제정보 | L1 prompt 저장 시 hash, L2/L3 명시 commit 금지 |
| **비즈니스 비밀** | 경쟁 분석, 가격 전략 | L2까지는 OK (private repo), L3 driver 는 권한 분리 필수 |
| **제3자 데이터** | 도메인별 규제(의료/금융) | 채널별 추가 redaction layer 필요 (Phase 2) |

### 8.10.2 sync hook의 redaction 규칙

`hooks/observability-sync.ts` 안에 redaction layer:

```typescript
function redact(content: string): string {
  return content
    .replace(/sk-[a-zA-Z0-9]{20,}/g, "[REDACTED-API-KEY]")
    .replace(/Bearer\s+[a-zA-Z0-9._-]+/g, "Bearer [REDACTED]")
    .replace(/[\w.-]+@[\w.-]+\.\w+/g, "[REDACTED-EMAIL]");
  // 더 많은 패턴은 plugin config에서 add
}
```

→ Phase 1은 **공통 패턴만**. 도메인 특화 redaction은 사용자 책임 (또는 Phase 2 plugin extension).

### 8.10.3 권한 모델 (Phase 1 vs Phase 2)

- **Phase 1**: 솔로 사용 가정 → 사용자 본인이 모든 채널 owner. RBAC 없음.
- **Phase 2**: multi-user. 본부별 RBAC, evaluator read_only 외부 감사, audit log.

### 8.10.4 보안 사고 대응 (Phase 1 minimum)

- API 키 leak 발견 → 즉시 rotate + L1 90일 retention 내 leak 흔적 검색
- L2 git에 PII commit → `git filter-branch` 또는 BFG로 history 재작성 (권장 X, redaction layer로 사전 차단이 본질)
- L3 권한 leak → Notion workspace permission 재설정

→ Phase 1은 **사고 대응 가이드만**, 자동화는 Phase 2 enterprise add-on.

---

## 8.11 L3 Driver 교체 시나리오

`contract/l3-driver-interface-v1` + `rule/driver-compatibility-warn-not-block` (상세: [appendix/drivers/_INTERFACE.md](appendix/drivers/_INTERFACE.md)).
L3는 **driver 교체 가능한 추상 채널**이다. Phase 1은 `notion` 기본, `divisions.yaml`의 `l3_backend` 필드로 교체.

### 8.11.1 Phase 1 지원 driver

| driver | phase1_supported | phase1_default | 비고 |
|--------|:---:|:---:|------|
| `notion` | ✅ | ✅ | Free/Plus/Team 모두 작동, §8.7 권장 스키마 즉시 적용 |
| `none` | ✅ | — | L3 비활성화. L2 git docs 직접 read (비개발자 UX 포기) |
| `obsidian` | ❌ (Phase 2) | — | 로컬 마크다운 vault. Phase 2 community contribution 후보 |
| `logseq` | ❌ (Phase 2) | — | 동상 |
| `confluence` | ❌ (Phase 2) | — | Enterprise 환경 권장 |
| `custom` | ⚠️ | — | 사용자 자작 driver (manifest + index.ts 구현 필요) |

Phase 1에서 미지원 driver 선택 시 `sfs-doc-validate`가 "driver 미구현" 경고 발생 — **block 아님**, fallback 안내.

### 8.11.2 driver 교체 절차

```yaml
# divisions.yaml (top-level)
l3_backend: notion          # 기본
# l3_backend: none          # L3 끄기 (solo dogfooding)
# l3_backend: obsidian      # Phase 2 community driver
# l3_backend: custom        # appendix/drivers/custom.manifest.yaml 작성 필수
```

1. `divisions.yaml`의 `l3_backend` 변경
2. plugin install 시 prompt 또는 수동 `sfs-doc-validate` 실행
3. manifest의 `phase1_supported`/`phase1_default` 확인
4. 비호환 조합 감지 시 경고 prompt (`on_warn` 분기)
5. 사용자가 `revise` 선택 → 권장값 자동 교정, `keep` 선택 → 원래대로 진행

**block 절대 금지** — `rule/driver-compatibility-warn-not-block` (contract §5, `schema/divisions-yaml-v1` validation_rules).

### 8.11.3 tier_profile × l3_backend 조합 경고 매트릭스

| tier | backend | 경고 여부 | 메시지 예시 |
|------|---------|:---:|------------|
| minimal | notion | — | (정상) Phase 1 default |
| minimal | none | — | (정상) 비용 최소화, solo dogfooding |
| standard | notion | — | (정상) Team/Max 사용자 |
| collab | notion (Team plan) | — | (정상) multi-tenant 협업 최적 |
| collab | none | ⚠️ | "L3 없이 collab tier — 비개발자 공유 불가, L2 git PR만 가능" |
| collab | obsidian | ⚠️ | "Realtime 협업 미지원 (async only). Notion Team 권장." |
| minimal | notion (Team plan) | 💰 | "Team plan 비용 발생. Free plan으로 동일 기능 가능." |
| 모든 tier | none + 8 sprint+ | ⚠️ | "L3 없이 8 sprint+ 누적. markdown 직접 read 부담. driver 활성화 검토." |

### 8.11.4 driver 교체 시 L2 불변성

L2(git docs)는 **L3 driver와 완전 독립**:
- L2 산출물·commit 히스토리 변경 없음
- 새 driver의 `archive` 메서드가 기존 L3 데이터를 원래 backend에 남기고 신규 `publish`만 전환
- L2 → L3 full re-sync 필요 시 driver interface의 `publish` 메서드를 전 Sprint에 대해 호출

→ **driver 교체는 observability layer만 영향**. agent 작업 continuity는 §8.8 graceful degradation 원칙 적용 — driver 다운에도 L2 commit은 정상.

### 8.11.5 Phase 2 community driver 추가 절차

(`appendix/drivers/_INTERFACE.md §6` 참조)

1. `appendix/drivers/<id>.manifest.yaml` 작성 (필수 필드: `collab_modes`, `multi_user`, `auth`, `capabilities`, `phase1_supported`)
2. `sfs-plugin/drivers/<id>/index.ts` 구현 (`publish`/`query`/`archive` 3 메서드 — `DriverResult` always-return, throw 금지)
3. `appendix/schemas/divisions.schema.yaml`의 `l3_backend` enum에 `<id>` 추가 PR
4. 본 §8.11.3 호환성 매트릭스에 row 추가
5. `sfs-doc-validate` manifest 형식 자동 통과 시 merge

→ Phase 1은 `notion` + `none` 2개로 시작. 나머지는 community 기여 받기 좋은 구조.

---

*(끝)*
