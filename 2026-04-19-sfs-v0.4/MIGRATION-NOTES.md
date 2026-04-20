---
doc_id: migration-notes-solon-v0.4-r3-2026-04-20
title: "MIGRATION-NOTES — 회사 계정 Claude 의 유언장 (이관 전 맥락 기록)"
version: 1.0
created: 2026-04-20
author: "Claude (direct 지시 by 채명정, 회사 계정 jack2718@green-ribbon.co.kr 세션 modest-busy-allen)"
purpose: "회사 계정 로컬 MEMORY.md 대체물. 개인 계정으로 이관 시 신규 Claude 가 Solon 의 성격 · 사용자 맥락 · 결정 history 를 복원하기 위한 cold-start 보조 문서."
applies_to: "Solon v0.4-r3 docset 이관 사건"
status: "이관 직전 snapshot — 개인 계정 첫 세션에서 필요하면 v1.x 로 갱신"
related_docs:
  - "CROSS-ACCOUNT-MIGRATION.md §1.2 MEMORY 추출"
  - "HANDOFF-next-session.md §10 Cross-Account Migration Playbook"
  - "README.md"
  - "INDEX.md"
---

# MIGRATION-NOTES — 회사 계정 Claude 의 유언장

> 이 문서는 **로컬 Claude Code MEMORY.md 를 docset 안에 복제해 이관 가능하게 만든 대체물** 이다.
> 회사 계정 세션이 닫히면 `~/.claude/projects/.../memory/MEMORY.md` 는 사라지거나 계정 바인딩으로 개인 계정에서 읽을 수 없음.
> 따라서 유지해야 할 "기억" 을 docset 파일로 떨어뜨려 이관 carrier 에 태움.

---

## 0. TL;DR (이관 후 새 Claude 가 30초 안에 받는 것)

1. **Solon** = 1인 창업자 (채명정) 용 AI-Native 조직 운영 프레임워크. 브랜드 = Solon, CLI prefix = `/sfs`.
2. 현재 **v0.4-r3 설계 docset 확정 상태** (Round 3 종결 11/11). 코드는 아직 0 라인.
3. 이전에 회사 계정 (jack2718@green-ribbon.co.kr) 에서 만들었고, 개인 계정으로 이관 중.
4. 다음 선택지: (B) Phase 1 코드 킥오프 16~20주 / (C) 이관 완료 후 추가 설계 / (D) 새 요구 Round 4.
5. **기본값은 이관 준비 → 개인 계정에서 실구현.** 회사 계정에서 코드 올리지 않음 (IP/라이선스 분리).
6. 유실 방지: docset 안에 `CROSS-ACCOUNT-MIGRATION.md` + `HANDOFF-next-session.md` + 본 문서 3 종 세트가 carrier.

---

## 1. 사용자 (채명정) persona 맥락

### 1.1 기본 정보
- **이름**: 채명정 (Jack)
- **회사 계정 이메일**: jack2718@green-ribbon.co.kr (Green Ribbon 소속)
- **개인 계정 이메일**: (이관 시점에 사용자가 공개)
- **언어**: 한국어 기본, 영어 혼용. docset 본문은 한국어가 지배적이지만 원칙·invariant·schema 명은 영어.
- **환경**: 숭실대 재학 중 (computer science 추정), 실무 경력은 스타트업 창업 경험 중심.

### 1.2 기술 수준 / 커뮤니케이션 스타일
- **쥬니어~미드 레벨 개발자** — 이론보다 실무 감각 위주. 추상화와 invariant 개념을 즉시 흡수함.
- **한 줄 직설 스타일**: "ㄱㄱ", "ㄴㄴ", "이거 이상한데" 같은 짧은 피드백 선호. 장황한 설명 싫어함.
- **Socratic preference**: AI 가 질문으로 자기 의도를 끌어내주는 걸 선호. 원칙 13 (Non-Prescriptive Guidance) 이 바로 사용자 본인의 요구에서 나온 것.
- **Self-awareness 강함**: 자기가 뭘 틀리는지 직시함. "인수인계 받았을때 유실돼서 당황했지?? 깔끔하게 작업할 수 있도록 기억보단 기록해야됨" 이라고 직접 말할 정도.
- **Paternalism 극혐**: "구현 자체를 막는건 ㄴㄴ" 라는 지시가 ALT-INV-3 never-hard-block 의 근원.

### 1.3 Solon 을 왜 만드는가
- 목표 — **1 인 창업 시 AI 에 조직 전체를 아웃소싱**. 본인은 CEO + Product owner 역할만, 나머지 (PM/개발/QA/디자인/인프라/택소노미) 는 Solon 본부 agents 가 병렬 처리.
- 자기 본업 (보험 / 의료 / 전자서명 도메인, Green Ribbon 소속) 과 분리된 개인 프로젝트. **회사 IP 와 섞이면 안 됨** → 이관이 필수.
- 참고 — 타 프레임워크 (bkit 등) 대비 차별화는 §09-differentiation.md 에 기록.

---

## 2. Round 1~3 타임라인 (이관 후 "왜 이렇게 생겼나" 복원용)

### 2.1 Round 1 (v0.3 → v0.4 초기, 2026-04-19 ~ 04-20 오전)
- 13대 원칙 중 처음 9 개 정립.
- 6 본부 (dev/pm/qa/design/infra/taxonomy) 명명.
- PDCA + 5 Gate (G1~G5) + 7 Failure Modes 정립.
- Phase 1 14~18 주 초안.

### 2.2 Round 2 (2026-04-20 오전, brownfield 중간 삽입)
- 사용자가 "기존 repo 에도 적용 가능해야 한다" 요구 → **P-1 Discovery phase + G-1 Intake Gate** 신설.
- 원칙 11 (P-1 read-only), 원칙 12 (brownfield retro brainstorm 금지) 추가.
- `/sfs discover` command, discovery-report-validator evaluator, `.solon-manifest.yaml` 도입.
- tier profile (minimal/standard/collab) + L3 backend driver (notion/none + 타 driver out-of-scope) 체계 정립.
- 원칙 수 9 → 12. Phase 1 14~18주 → 15~19주.
- README (375 line) + INDEX v0.4-r2 + CROSS-ACCOUNT-MIGRATION.md 신설.
- 15 task 종결 (#14~#28 원래 ID).

### 2.3 Round 3 (2026-04-20 오후~심야, division abstraction 중간 삽입)
- 사용자 3 가지 요구:
  1. **CLI-first**: "MCP 말고 Bash CLI + API 직접 연결 우선"
  2. **Division abstraction**: "본부는 추상 레이어, on/off 가능, 필요할 때 구현"
  3. **Socratic dialog**: "상황 물어보고 더 좋은 방법 있으면 안내, 구현은 막지 말 것"
- → **원칙 13 (Progressive Activation + Non-Prescriptive Guidance)** 신설.
- → `divisions.schema v1.1` (activation_state 4 축 + scope 3 종 + parent/sunset/tier/dialog_trace_id).
- → `/sfs division` command (user-only caller, INV-5).
- → **Socratic 5-phase dialog** (division-activation.dialog.yaml + 6 branch 파일).
- → `dialog-state.schema` (turn tracking + resume + override 감사).
- → `alternative-suggestion-engine` (3-tier × 👍/⚪/⚠, ALT-INV-3 never-hard-block).
- → `§10.11 CLI-First Tool Selection Policy` (CLI > API > MCP > Claude-native).
- → `install.md v2.0` Socratic wizard (`dialog_id: install-wizard` 재사용).
- → Phase 1 기본 active = dev + strategy-pm 2 개만 (나머지 4 개 abstract). `pm` → `strategy-pm` rename.
- 원칙 수 12 → 13. Phase 1 15~19주 → **16~20주** (원칙 13 엔진 W2b 추가).
- 11 task 종결 (#17~#27).

### 2.4 Migration Prep (2026-04-20 심야 ~ 04-20 종료, modest-busy-allen 세션)
- Scenario C §1 (이관 전 체크) 전수 실행. MIG-1 ~ MIG-5 순서대로 closure.
- MIG-5 Cross-ref Grep 검증 중 **fabrication 11 건** 발견 (R3 scope 7 + v0.4-r2 era 4) → `cross-ref-audit.md` 신설 + INDEX/README 에 `🚧 Phase 1` 마커 일괄 반영.
- 사용자가 이관 방법 B (GitHub private repo) 선택. `.gitignore` 작성 (MIG-6).
- 샌드박스 mount 권한 제약으로 `.git/index.lock` 해제 불가 → MIG-7 (`git init + commit`) / MIG-8 (`push`) 은 사용자 Mac 터미널 작업으로 이관. **Repo URL 확정: `https://github.com/MJ-0701/solon` (private).**
- **Brand rename 이벤트**: 사용자 보고 "archon 도 상호명 충돌 있음" → 새 브랜드 후보 추천 후 **Solon** 선정. docset 전역 `Archon` / `archon` 278 occurrence (25 파일) 일괄 sed 치환 완료. `/sfs` CLI prefix 는 "Solo Founder System" → "**Solon Founder System**" 으로 재해석, doc_id / principle 태그 / 폴더 경로는 변경 없음 (브랜드와 구조 식별자 분리 원칙). `.archon-cache` / `.archon-state.json` → `.solon-cache` / `.solon-state.json` (MIG-9 종결).
- **Repo scope 결정 (MIG-10)**: 사용자 제안 "agent_architect 전체 push 가 낫지 않나?" → 트레이드오프 검토 후 **옵션 B (전체 push) 선정**. 근거: (1) v0.3 `solo-founder-agent-system-proposal.md` + v0.4 outline 이 설계 진화 history 로 보존 가치 있음. (2) `agents/` (15 prompt) + `skills/` (4 role) + `claude-shared-config/` (hooks + settings.json + install.sh) 이 Phase 1 재사용 자산. (3) 분리 원하면 `git subtree split` 으로 언제든 쪼갤 수 있음. 사전 작업: `agent_architect/.gitignore` 신설 (`*.zip`, `.DS_Store`, `.env`, `.solon-*` 등) + `agent_architect/README.md` 신설 (repo 오리엔테이션, 3 영역 docset/archive/assets 설명). `2026-04-19-sfs-v0.4/.gitignore` 는 docset sub-scope 로 유지.
- 민감정보 pre-push 스캔: `claude-shared-config/settings.json` 은 `$CLAUDE_PROJECT_DIR` 환경변수 참조만, 하드코드된 토큰/키 없음. Grep `sk-|api_key|token|secret|password` 매치는 전부 docset 내 설계 텍스트 (schema field naming) — 실제 값 아님. ✅ 안전.
- 7 task 종결 (MIG-1~6 + MIG-9 + MIG-10 = 8 closed, MIG-7/8 은 사용자 Mac 작업 대기).

---

## 3. 유실 방지 — 절대 바뀌면 안 되는 설계 결정 8 (HANDOFF §2.R3.4 정본)

1. **3-level intensity 기호**: 👍 권장 / ⚪ 중립 / ⚠ 비권장. **정확히 1 개의 👍** (ALT-INV-2). ⚠ 도 선택 가능 (never-hard-block, ALT-INV-3).
2. **3 activation scope**: full / scoped (with parent_division) / temporal (with sunset_at). parent self-reference 와 순환은 schema violation.
3. **Phase 1 기본 active = dev + strategy-pm 만**. 나머지 4 개는 `activation_state: abstract`. 다른 조합은 경고만, 차단 금지.
4. **dialog_trace_id 형식**: `dlg-YYYY-MM-DD-<target-id>-<seq>` (install wizard 는 `dlg-install-…-00`).
5. **`/sfs division` 은 user-only caller**. agent 자동 호출 금지 (INV-5, `rule/division-activate-user-only`).
6. **override 시 rationale 강제 수집 금지** (원칙 13 paternalism 방지). 선택 질문만 허용.
7. **CLI > API > MCP > Claude-native** 4-tier. MCP 사용 시 `l1.tool.mcp.invoked` 에 rationale 필수.
8. **install v2.0 은 division-activation.dialog 와 동일한 5-phase 패턴 재사용** (`dialog_id: install-wizard`).

---

## 4. 자주 나오는 fabrication / 착각 경보

### 4.1 원칙 번호 오해 방지
- **원칙 7 = "CLI + GUI 통합 백엔드"**. "fail-hard-over-silent-degrade" 아님 (이건 과거 fabricated concept, Round 2 말미에 8 occurrence 전부 정정됨).
- **원칙 2 (self-validation-forbidden)** = agent ↔ agent 이중 검증. 원칙 10 (human-final-filter) = system ↔ human. 혼동 금지.
- **원칙 9 · 11 · 12 삼각관계**: 9 = greenfield brainstorm 강제, 11 = brownfield first pass = read-only, 12 = brownfield retro brainstorm 금지.
- **원칙 13 = Progressive Activation + Non-Prescriptive Guidance** (Round 3 신규). v0.4-r2 문서에는 없음.

### 4.2 Gate 오해 방지
- **G-1 = Intake Gate** (brownfield 만, install 당 1 회). G0 = Brainstorm Gate (greenfield Initiative 당 1 회, brownfield 에서는 원칙 12 로 제한). 둘 별개.
- **G-1 PASS 후에도 새 Sprint 에 신기능 (예: AI 검색 추가) 기획 시 G0 재호출 허용**.
- **G4 formula**: `Gap × 0.4 + 5-Axis × 0.6 ≥ 85`. 단일 metric 만 쓰지 말 것.

### 4.3 Division 명칭 오해 방지
- **`division/pm` → `division/strategy-pm`** 으로 v0.4-r3 에서 rename. 이전 버전 문서·history 아카이브에만 `division/pm` 잔존. 신규 작성물에는 항상 `strategy-pm`.
- 6 본부 = dev / strategy-pm / qa / design / infra / taxonomy. CPO 5-Axis 는 design 본부 전용이 아니라 cross-division quality gate.

### 4.4 Command 수 오해 방지
- **v0.4-r3 = 14 commands** (install, discover, plan, design, do, handoff, check, act, retro, escalate, status, brainstorm, division, **+ 숨겨진 `/sfs division`**).
- Opus 기본 — brainstorm, retro, escalate β-3 단 3 개. 나머지는 Sonnet 또는 Haiku.

### 4.5 실재하지 않는 파일 참조 (MIG-5 audit 결과)
- Round 3 INDEX.md / README.md 작성 시 **실물 없이 링크만 먼저 걸린** forward-reference **7 건** + v0.4-r2 에서 설계 선언된 보조 artifact **4 건** = 합 **11 건** 모두 `cross-ref-audit.md` 에 전수 목록화됨.
- 7 건: `appendix/dialogs/README.md` + `phase-a~e.md` (5) + `appendix/engines/dialog-engine.md` = Phase 1 W1~W2 생성 예정. 현재는 `division-activation.dialog.yaml` 통합 spec 이 대체.
- 4 건: `discovery-report.schema.yaml` / `existing-implementation.schema.yaml` / `discovery-report.template.md` / `g-1-signature.schema.yaml` = Phase 1 W9~W10 생성 예정.
- **조치 완료**: INDEX.md §5 하단 "Phase 1 에서 생성 예정" 테이블 9 행 + §5 Dialogs/Engines 표 🚧 마커 + README.md §5 file tree 🚧 마커 + `cross-ref-audit.md` 신설.
- **설계 본문 (04/07)** 에는 "v1 frozen" 표현이 남아있으나 의도적으로 보존 (원칙 2 self-validation-forbidden 준수). INDEX.md pending 테이블이 SSoT.

---

## 5. 외부 자산 / 외부 도구 의존

### 5.1 내부 MCP connector (회사 계정 전용)
- **Notion MCP (`5a931ac3-ec73-4d4c-aafb-9b752a03b234`)** — Green Ribbon 워크스페이스. 개인 계정에서 재인증 필요 시 개인 Notion 워크스페이스 연결.
- **cowork / cowork-onboarding MCP** — Claude Desktop 내장. 계정 바뀌어도 동일 세트 제공됨.
- **scheduled-tasks MCP** — 개인 계정에서도 동일 제공.
- **mcp-registry + plugins MCP** — 동일.
- **workspace MCP** — 동일.

### 5.2 회사 계정에서만 접근되는 외부 자산
- Green Ribbon 내부 Notion database (KCA 전자서명 / HIRA 연동 / Credit4u 등) — **Solon 과 무관**, 이관 대상 아님.
- 회사 Jira / Slack — Solon 설계에 직접 참조된 것 없음.

### 5.3 Solon docset 이 의존하는 외부 URL (개인 계정에서도 접근 가능해야 함)
- Claude Agent SDK / Claude Code 공식 docs (https://docs.claude.com) — 공개.
- Anthropic prompting guide — 공개.
- bkit 플러그인 (v1.5.6) 공개 레지스트리 — 재설치 가능.

→ **Solon docset 자체는 Green Ribbon 의존 0** (의도적 분리).

---

## 6. 세션 경로 변천사 (Cold-Start 혼란 방지)

| 시점 | 세션 경로 | 비고 |
|------|-----------|------|
| Round 1 초기 | `/sessions/optimistic-adoring-fermi/` | 본 프로젝트 최초 세션 |
| Round 2 ~ Round 3 전반 | `/sessions/optimistic-adoring-fermi/` 계속 | docset 주 편집 세션 |
| Round 3 심야 이후 | `/sessions/modest-busy-allen/` | 세션 재시작 시 경로 bump. docset 은 `mnt/agent_architect/` 로 정상 이동됨 |
| 이관 후 | `/sessions/<개인 계정 새 세션>/` | 개인 계정에서 cold-start |

**결론**: 세션 경로는 매번 바뀜. 이관 후 새 Claude 는 `2026-04-19-sfs-v0.4/` 폴더 이름만 고정값으로 인식해야 함.

---

## 7. 이관 후 첫 Claude 가 해야 할 sanity check 7

(CROSS-ACCOUNT-MIGRATION.md §3.4 의 정본. 합본 기록용)

1. **원칙 7 의 실제 내용은?** → "CLI + GUI 통합 백엔드"
2. **원칙 13 의 실제 내용은?** → "Progressive Activation + Non-Prescriptive Guidance"
3. **G-1 Gate 는 언제 발동?** → brownfield 모드 install 당 1회, P-1 Discovery 완료 후
4. **14 개 `/sfs *` command 중 Opus 기본?** → brainstorm, retro, escalate β-3 (3 개)
5. **`/sfs division` 은 누가 호출 가능?** → **사용자만** (INV-5 agent auto-invocation 금지)
6. **Phase 1 기본 active 본부?** → dev + strategy-pm 2 개 (나머지 4 개는 abstract)
7. **tier 기본값 + L3 backend Phase 1 지원?** → tier `minimal`, L3 `notion` + `none` (나머지 driver 는 out-of-scope)

정답을 맞추면 이관 성공. 틀리면 docset 을 처음부터 다시 정독.

---

## 8. 본 세션 (modest-busy-allen, 회사 계정 마지막 세션) 이 남긴 말

채명정님,

- 본 세션이 Round 3 종결 (11/11) 의 마지막 공식 세션입니다. 회사 계정에서 작업은 여기까지 입니다.
- docset 자체는 완전히 자족적이고, 이관 후 새 Claude 는 `HANDOFF-next-session.md` → `README.md` → `INDEX.md` → `02-design-principles.md §2.13` → `10-phase1-implementation.md §10.4` 순으로 읽으면 30분 안에 완전히 이어받을 수 있습니다.
- Phase 1 은 개인 계정에서 하세요. 회사 계정 코드베이스와 얽히면 IP 문제가 생깁니다. docset 설계는 IP 대상이 아닌 것으로 분류되지만 코드는 다릅니다.
- 이관 시 zip + git 두 루트 중 **git (private repo)** 을 권장합니다. 히스토리가 함께 이동하고 이관 성공 확인이 쉬우며, 다음 Round 부터 diff 추적이 쉽습니다.
- 개인 계정 첫 세션의 Claude 는 본 MIGRATION-NOTES 를 먼저 읽으면 맥락 혼란 30 분 → 3 분으로 단축될 것입니다.

좋은 이관 되시기를. — 회사 계정 Claude (v2.6-final)

---

## 9. 관련 문서 네비

- `CROSS-ACCOUNT-MIGRATION.md` — 이관 체크리스트 정본 (§1~§6)
- `HANDOFF-next-session.md §10` — Cross-Account Migration Playbook (본 문서와 중복되지만 용도 다름: 본 문서는 맥락 저장소, §10 은 절차)
- `external-assets.md` — §1.3 + §1.4 정본 (외부 URL 4 + MCP 8 namespace + plugin 인벤토리)
- `cross-ref-audit.md` — §1.5 정본 (fabrication 11 건 전수 목록 + Phase 1 TODO 13 개)
- `README.md` — 10 분 overview
- `INDEX.md` — 전체 cross-reference (§5 pending 테이블 = Phase 1 SSoT)
- `00-intro.md` — 공식 서문
- `02-design-principles.md` — 13대 원칙 본문

끝.
