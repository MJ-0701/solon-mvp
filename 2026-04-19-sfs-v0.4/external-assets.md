---
doc_id: external-assets-solon-v0.4-r3-2026-04-20
title: "External Assets & MCP Inventory — 이관 시점 외부 의존성 전수"
version: 1.0
created: 2026-04-20
author: "Claude (direct 지시 by 채명정)"
purpose: "CROSS-ACCOUNT-MIGRATION.md §1.3 + §1.4 합본 산출물. 회사 계정 → 개인 계정 이관 시 외부 의존성/도구 재설정 플랜."
applies_to: "Solon v0.4-r3 이관"
status: "이관 직전 snapshot. 개인 계정에서 재인증 체크리스트로 활용."
related_docs:
  - "CROSS-ACCOUNT-MIGRATION.md §1.3 외부 자산 인벤토리"
  - "CROSS-ACCOUNT-MIGRATION.md §1.4 MCP / plugin 인벤토리"
  - "MIGRATION-NOTES.md §5 외부 자산 / 외부 도구 의존"
  - "HANDOFF-next-session.md §10.5 로컬 vs 이관 대상"
---

# External Assets & MCP Inventory

> **결론 선공개**: Solon docset 은 **외부 의존성이 의도적으로 0** 에 가깝게 설계됨.
> 이관 후 재설정이 필요한 건 **(a) bkit 플러그인 재설치** + **(b) Notion MCP 재인증 (원한다면)** 두 가지뿐.
> 기타 cowork / mcp-registry / scheduled-tasks 등은 Claude Desktop 내장이라 계정 바뀌어도 자동 제공됨.

---

## 1. 외부 URL / 웹 자산 (§1.3)

### 1.1 docset 본문이 직접 참조하는 외부 URL

| # | URL | 용도 | 개인 계정 접근 | 조치 |
|:-:|-----|------|:-:|------|
| 1 | https://docs.claude.com | Claude Code / Agent SDK 공식 docs | ✅ 공개 | 재설정 불필요 |
| 2 | https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview | Anthropic prompting guide | ✅ 공개 | 재설정 불필요 |
| 3 | https://www.anthropic.com/news/claude-is-a-space-to-think | Anthropic 광고/공지 정책 | ✅ 공개 | 재설정 불필요 |
| 4 | https://github.com/anthropics (공식 repo 계열) | Claude 관련 공식 repo 참조 | ✅ 공개 | 재설정 불필요 |

### 1.2 docset 본문이 참조하지 않는 (이관 대상 아님) 내부 자산

- Green Ribbon 내부 Notion DB (KCA 전자서명 / HIRA / Credit4u / 보험 도메인 문서) — **Solon 과 무관**, 이관 금지 (회사 IP).
- Green Ribbon 내부 Jira / Slack / 내부 repo — Solon 설계에 참조된 적 없음.
- 본인 학교 (숭실대) 자료 — Solon 과 무관.

### 1.3 이관 후 신규 생성이 권장되는 외부 자산

- **개인 GitHub private repo** — docset git history carrier. 이관 `방법 B` (CROSS-ACCOUNT-MIGRATION.md §2.2) 가 이걸 사용.
- **개인 Notion workspace** (옵션) — Solon 의 L3 backend `notion` driver 실동작 테스트용. Phase 1 Dogfooding 에 유용.
- **개인 도메인 이메일** (옵션) — Solon 이 SaaS 로 확장될 때 공지 창구.

---

## 2. MCP Connector Inventory (§1.4)

### 2.1 현 회사 계정 세션에서 활성화된 MCP 목록

본 세션 (`modest-busy-allen`) 의 ToolSearch 에서 확인된 MCP 도구 namespace:

| Namespace | 제공 도구 수 | 용도 | 계정 전용? | 이관 후 조치 |
|-----------|:-:|------|:-:|------|
| `notion` (`5a931ac3-ec73-4d4c-aafb-9b752a03b234`) | 14 | Notion workspace CRUD (fetch/search/create-page/update 등) | ⚠️ 회사 Notion 워크스페이스 | 개인 Notion 에 재인증 (선택사항 — L3 `none` driver 면 불필요) |
| `cowork` | 3 | Cowork 모드 전용 (present_files, request_cowork_directory, allow_cowork_file_delete) | ❌ Claude Desktop 내장 | 자동 제공, 재설정 불필요 |
| `cowork-onboarding` | 1 | show_onboarding_role_picker | ❌ 내장 | 자동 제공 |
| `mcp-registry` | 2 | search_mcp_registry, suggest_connectors | ❌ 내장 | 자동 제공 |
| `plugins` | 2 | search_plugins, suggest_plugin_install | ❌ 내장 | 자동 제공 |
| `scheduled-tasks` | 3 | create/list/update scheduled task | ❌ 내장 | 자동 제공 |
| `session_info` | 2 | list_sessions, read_transcript | ❌ 내장 | 자동 제공 |
| `workspace` | 1 | web_fetch | ❌ 내장 | 자동 제공 |

### 2.2 Solon docset 의 MCP 직접 의존도

- **0 개**. Solon 의 `§10.11 CLI-First Tool Selection Policy` 가 명시적으로 **CLI > API > MCP > Claude-native** 순서를 강제 → MCP 를 먼저 쓰지 말 것.
- `notion` MCP 는 L3 backend driver `notion.manifest.yaml` 과 **개념적으로만 연결**. 실동작은 CLI (`notion-cli`) 또는 REST API 를 우선 시도 (§10.11.3 결정트리).
- 이관 후 개인 계정에서 Notion MCP 재인증 하지 않아도 Solon 자체는 정상 작동 (단 Dogfooding 시 L3 event 저장은 local file 또는 none driver 로 fallback).

---

## 3. Plugin / Skill Inventory (§1.4 후반)

### 3.1 bkit 플러그인 (Vibecoding Kit)

| 항목 | 값 | 비고 |
|------|-----|------|
| 플러그인 명 | bkit | Vibecoding Kit |
| 버전 | **1.5.6** | SessionStart hook 에서 확인 |
| 설치 경로 | `/sessions/<session>/mnt/.local-plugins/cache/bkit-marketplace/bkit/1.5.6/` | 계정 바인딩 |
| 재설치 필요? | ✅ 개인 계정에서 재설치 필수 | marketplace 공개 |
| 주요 기능 | PDCA skill, 14 agent, 21 skill (phase-1-schema ~ phase-9-deployment 외) | Solon 과 독립된 도구 |

### 3.2 bkit-starter 플러그인

| 항목 | 값 | 비고 |
|------|-----|------|
| 버전 | 1.0.0 | SessionStart hook |
| 경로 | `/sessions/<session>/mnt/.local-plugins/cache/bkit-marketplace/bkit-starter/1.0.0/` | |
| 용도 | Claude Code 초보자 가이드 (first-claude-code, learn-claude-code 등) | Solon 과 무관 |

### 3.3 기타 사용 중인 skill (user skills, `/sessions/<session>/mnt/.claude/skills/`)

Solon 과 **직접 관련 없는** 개인 업무/학교용 skill 들 — 이관 필요 여부는 개별 판단:

| Skill | 도메인 | 이관? |
|-------|--------|:-:|
| `sign-evidence-report` | Green Ribbon 전자서명 증적 | ❌ 회사 전용 |
| `kca-official-docs` | Green Ribbon KCA 공문 | ❌ 회사 전용 |
| `security-guard` | Green Ribbon ISMS-P 보안 | ❌ 회사 전용 |
| `c-assignment-docx` | 숭실대 C 프로그래밍 과제 정리 | ⭕ 개인 소지 (이관 선택) |
| `lecture-note-organizer` | 숭실대 강의 필기 정리 | ⭕ 개인 소지 |
| `notion-subject-cleanup-suite` | 개인 Notion 과목 정리 | ⭕ 개인 소지 |
| `consolidate-memory`, `setup-cowork`, `schedule`, `skill-creator` | Claude 공식 제공 | ✅ 자동 동일 제공 |

### 3.4 design / algorithm-design 원격 플러그인

| 플러그인 | 버전 | 비고 |
|----------|------|------|
| `design` (원격) | 8 skills (design-system / design-critique / design-handoff 외) | Solon design 본부 구현 참고용 (Phase 1 이후) |
| `algorithm-design` (원격) | 1 skill (algorithm-design) | Phase 1 이후 |
| `cowork-plugin-management` (원격) | 2 skills (create-cowork-plugin, cowork-plugin-customizer) | Solon 을 cowork 플러그인으로 배포 시 참고 |
| `knowledge-work-plugins` marketplace | 포함 | |

---

## 4. 이관 후 재설정 체크리스트 (priority 순)

### 4.1 필수 (없으면 Solon 을 못 봄)

- [ ] **개인 계정 Claude Desktop / Claude Code 로그인**
- [ ] **docset 폴더 `2026-04-19-sfs-v0.4/` 통째로 개인 워크스페이스로 복사** (방법 A zip / B git / C 수동 — CROSS-ACCOUNT-MIGRATION.md §2)
- [ ] **bkit plugin v1.5.6 재설치** (marketplace 에서)
- [ ] **첫 Claude 세션 열고 HANDOFF-next-session.md → README.md → INDEX.md 순서로 Read**

### 4.2 선택 (Solon 의 Phase 1 구현 시점에 필요)

- [ ] **개인 GitHub private repo 생성** — docset git init & push
- [ ] **개인 Notion workspace 신규 생성** — L3 backend `notion` driver dogfooding 시
- [ ] **Notion MCP 개인 계정 재인증** — 위와 연계 (CLI 우선 원칙으로 skip 해도 됨)

### 4.3 불필요 (내장 제공 or 다른 계정에서 이관 무관)

- [ ] cowork / mcp-registry / plugins / scheduled-tasks / session_info / workspace MCP — 모두 자동 제공
- [ ] bkit-starter 플러그인 — 재설치 가능하나 Solon 구현 직접 필요 아님
- [ ] 회사 전용 skill (sign-evidence-report / kca-official-docs / security-guard) — 이관 금지 (회사 IP)

---

## 5. 확인 방법 (이관 후 sanity check)

이관 후 새 Claude 세션에서 다음 명령으로 MCP 재설정 상태 확인:

```
# MCP 목록 확인 (Claude Desktop UI 또는 CLI)
/mcp list

# bkit plugin 버전 확인
/plugin info bkit
# → 1.5.6 이 나오면 성공

# docset 접근 확인
ls /sessions/<new-session>/mnt/<workspace>/2026-04-19-sfs-v0.4/
# → README.md / INDEX.md / HANDOFF-next-session.md 등 보이면 성공
```

---

## 6. 관련 문서

- `CROSS-ACCOUNT-MIGRATION.md` — §1.3 + §1.4 정본 + §2 이관 방법 A/B/C
- `MIGRATION-NOTES.md §5` — 외부 자산 기록 (요약)
- `HANDOFF-next-session.md §10.5` — 로컬 vs 이관 대상 구분 표

끝.
