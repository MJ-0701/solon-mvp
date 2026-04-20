# solon

> **1인 창업용 AI-Native 조직 OS — 설계 아카이브 + 활성 docset + 재사용 자산 통합 repo.**

`repo_type: design-archive + active-docset + reusable-assets` · `brand: Solon` · `cli_prefix: /sfs (Solo Founder System)` · `active_version: v0.4-r3` · `last_updated: 2026-04-20`

---

## 📣 새 Claude 에게 — 이거 먼저 읽어 (STOP & READ)

> 이 섹션은 `git clone` 직후 repo 를 처음 여는 Claude 가 **반드시 맨 처음 마주치도록** 의도된 강제 브리핑이다. 사용자 (채명정) 는 이 repo 를 만든 당사자이며, 아래 지시문은 이관의 공식 인수인계 채널이다.

```
이 repo 는 "Solon" 이라는 AI 조직 운영 프레임워크의 설계 아카이브야.
회사 계정에서 만들다가 개인 계정으로 넘어왔고, 너는 이관 후 첫 Claude 야.
루트 README.md 를 먼저 읽고 (= 지금 이 파일),
그 다음 2026-04-19-sfs-v0.4/HANDOFF-next-session.md.
읽고 나서 "내가 뭘 이어받았는지, 다음 할 일이 뭔지" 3문단으로 요약해줘.
내 이름은 채명정이고, Solon 은 1인 창업용으로 쓸 도구야.
```

**새 Claude 가 해야 할 첫 행동**:
1. 지금 이 루트 `README.md` 를 끝까지 읽는다 (§1 ~ §6).
2. `2026-04-19-sfs-v0.4/HANDOFF-next-session.md` 를 읽는다 — 현재 상태 / 다음 할 일 / MIG-1~10 전수 기록.
3. `2026-04-19-sfs-v0.4/README.md` 와 `INDEX.md §3.0 (10분 overview)` 를 읽는다.
4. `2026-04-19-sfs-v0.4/00-intro.md` + `02-design-principles.md` (13대 원칙) 읽는다.
5. 사용자에게 3문단 요약 + 다음 작업 확인 (Phase 1 착수 여부 등).

**피해야 할 실수**:
- "Solon 이 뭐예요?" 재질문 금지 — docset 에 다 있다.
- 회사 계정 MCP 호출 시도 금지 — 개인 계정에서 재인증된 connector 만.
- docset 구조 임의 변경 금지 — 우선 읽고, 변경은 사용자 허가 후.

더 상세한 이관 프로토콜 + 새 Claude sanity check 질문 8개는 `2026-04-19-sfs-v0.4/CROSS-ACCOUNT-MIGRATION.md §3` 에 있음.

---

## 1. 이 repo 는 무엇인가

**Solon** 은 "6명의 본부장이 있는 회사를 1명으로 운영하는 OS" 를 지향하는 AI-Native 조직 운영 프레임워크다. 이 repo 는 Solon 의 **설계 진화 전체 + 현재 활성 스펙 + Phase 1 재사용 자산** 을 한 곳에 담은 아카이브형 저장소다.

- **설계 (docset)**: `2026-04-19-sfs-v0.4/` — 현재 활성 v0.4-r3 설계 문서 23개 + appendix
- **아카이브 (archive)**: `solo-founder-agent-system-proposal.md` (v0.3) + `2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md` (v0.4 초안) — 진화 history
- **자산 (assets)**: `agents/`, `skills/`, `claude-shared-config/` — Solon 6 본부 agent prompt 원자재 + Claude Code 공용 설정

---

## 2. 폴더 구조

```
agent_architect/  (repo root)
├── README.md                                       ← 본 문서 (repo 오리엔테이션)
├── .gitignore                                      ← 루트 제외 규칙 (*.zip, .DS_Store 등)
│
├── 2026-04-19-sfs-v0.4/                            ★ 활성 Solon docset v0.4-r3
│   ├── README.md                                   ← docset 자체 오리엔테이션
│   ├── INDEX.md
│   ├── HANDOFF-next-session.md                     ← 개인 계정 새 Claude 가 먼저 읽을 파일
│   ├── CROSS-ACCOUNT-MIGRATION.md
│   ├── MIGRATION-NOTES.md
│   ├── cross-ref-audit.md
│   ├── external-assets.md
│   ├── 00-intro.md ~ 10-phase1-implementation.md   (본문 11개)
│   ├── appendix/
│   │   ├── commands/    (13개 CLI spec)
│   │   ├── schemas/
│   │   ├── dialogs/     (Socratic 5-phase dialog)
│   │   ├── engines/
│   │   ├── templates/
│   │   ├── hooks/
│   │   ├── drivers/
│   │   └── tooling/
│   └── .gitignore                                  ← docset sub-scope 규칙 (migration snapshot)
│
├── solo-founder-agent-system-proposal.md           ← [archive] v0.3 원조 proposal (21KB)
├── 2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md  ← [archive] v0.4 초안 outline (13KB)
│
├── agents/                                         ★ [assets] agent prompt 원자재 (15개)
│   ├── README.md
│   ├── CLAUDE.md
│   ├── chief-of-staff.md
│   ├── strategy-lead.md
│   ├── dev-lead.md
│   ├── developer.md
│   ├── qa-lead.md
│   ├── qa-engineer.md
│   ├── planner.md
│   ├── researcher.md
│   ├── tech-researcher.md
│   ├── data-collector.md
│   ├── prompt-analyst.md
│   ├── evaluator.md
│   ├── generator.md
│   └── skills/
│
├── skills/                                         ★ [assets] role-based skill 정의 (4개)
│   ├── cto/
│   ├── dev-lead/
│   ├── planner/
│   └── researcher/
│
└── claude-shared-config/                           ★ [assets] Claude Code 공용 설정
    ├── README.md
    ├── CLAUDE.md
    ├── install.sh                                  ← 개인 계정에서 직접 install 가능
    ├── settings.json                               ← PreToolUse/PostToolUse hooks 정의
    ├── agents/
    ├── hooks/                                      (6개 guard script)
    ├── skills/
    └── standards/
```

---

## 3. 읽는 순서 (새 Claude / 새 협업자)

### 3.1 이관 직후 첫 Claude (개인 계정)

**읽는 순서** (`git clone` 직후 기준, 사용자 verbatim brief 와 동일):

1. **본 루트 `README.md`** (지금 이 파일) — repo 구조 / 3 영역 (docset/archive/assets) 파악. `git clone` 후 첫 대면 문서.
2. **`2026-04-19-sfs-v0.4/HANDOFF-next-session.md`** — 현재 상태 / 다음 할 일 / R3 종결 snapshot (§5.1 에 MIG-1~10 전수 기록)
3. **`2026-04-19-sfs-v0.4/README.md`** — docset 자체 오리엔테이션
4. **`2026-04-19-sfs-v0.4/INDEX.md`** — 23 파일 맵 + §3 reading orders (§3.0 10분 overview 추천)
5. **`2026-04-19-sfs-v0.4/00-intro.md`** + **`02-design-principles.md`** (13대 원칙)
6. 사용자에게 "뭘 이어받았는지, 다음 할 일이 뭔지" 3 문단 요약 + 작업 확인

### 3.2 Phase 1 구현 시

- **agent 프롬프트 재사용**: `agents/chief-of-staff.md`, `dev-lead.md`, `planner.md`, `qa-lead.md` → Solon 6 본부의 `division-activation.dialog.yaml` 에 정의된 본부와 매핑. 프롬프트 구조를 원자재로 삼아 Phase 1 src/ 의 agent definition 생성.
- **Claude Code 설정 install**: `claude-shared-config/install.sh` → 개인 계정 Claude Code 에 hooks/settings 설치. `erd-generate-guard.sh`, `pdca-phase-guard.sh` 등은 Solon PDCA 사이클 강제 수단으로 재사용 가능.
- **skill 템플릿**: `skills/cto/`, `planner/` 등은 Solon tier profile (minimal/standard/collab) 의 skill 세트 참고.

### 3.3 설계 근거 추적

- **"왜 이 결정을 했나?"** → `2026-04-19-sfs-v0.4/02-design-principles.md` 의 13 원칙 + 각 본문 문서의 frontmatter `references:` / `affects:` 필드
- **"v0.3 에서 v0.4 로 뭐가 바뀌었나?"** → `solo-founder-agent-system-proposal.md` (v0.3) ↔ `2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md` ↔ `2026-04-19-sfs-v0.4/01-delta-v03-to-v04.md` 삼각 비교
- **"v0.4-r1 → r2 → r3 progression 은?"** → `2026-04-19-sfs-v0.4/MIGRATION-NOTES.md §2 Round 1~3 타임라인`

---

## 4. 브랜드 / 네이밍 규칙

| 영역 | 값 | 비고 |
|------|----|------|
| 제품명 (brand) | **Solon** | 2026-04-20 `Archon` 에서 개명 (상호 충돌 회피). 278 occurrence 전수 치환 완료. |
| CLI prefix | `/sfs` | "**Solon** Founder System" 의 약자. 브랜드 변경되어도 유지 (내부 식별자). |
| doc_id | `sfs-v0.4-*` | principle 태그와 함께 **구조 식별자**. 브랜드 rename 시 건드리지 않음. |
| principle 태그 | `principle/*` | 의미 고정. 태그 rename 시 모든 cross-ref 깨짐 → 금지. |
| runtime cache | `.solon-cache/`, `.solon-state.json` | `.gitignore` 에서 제외 대상. |

---

## 5. 이관 history (간략)

| 시점 | 사건 | 산출 |
|------|------|------|
| ~2026-04-19 | v0.3 proposal 작성 | `solo-founder-agent-system-proposal.md` |
| 2026-04-19 | v0.4 outline 정리 | `2026-04-19-solo-founder-agent-system-proposal-v0.4-outline.md` |
| 2026-04-19 ~ 04-20 | v0.4 docset Round 1 ~ Round 3 | `2026-04-19-sfs-v0.4/` (R3 종결) |
| 2026-04-20 (심야) | Scenario C §1 이관 전 체크 전수 | MIG-1 ~ MIG-6 완결 |
| 2026-04-20 | Brand rename `Archon` → `Solon` | docset 278 occurrence 치환 |
| 2026-04-20 | 회사 계정 → 개인 계정 GitHub push | 본 repo 초기 commit |

세부 내용은 `2026-04-19-sfs-v0.4/MIGRATION-NOTES.md` 와 `HANDOFF-next-session.md §5.1` 참조.

---

## 6. 참고

- 이 repo 는 **private**. 개인 창업 자료이며 외부 공개 예정 없음.
- 코드 저장소가 아니라 **설계 + 아카이브** 가 주. Phase 1 실제 구현 코드는 별도 repo (`solon-phase1/`) 에서 진행 예정.
- 다음 pivot 시 (v0.5 등장) 에는 `2026-04-19-sfs-v0.4/` 와 병렬로 `YYYY-MM-DD-sfs-v0.5/` 폴더 신설 권장. 기존 docset 은 아카이브화.
