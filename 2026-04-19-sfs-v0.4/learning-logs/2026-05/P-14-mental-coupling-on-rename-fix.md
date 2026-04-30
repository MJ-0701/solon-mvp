---
pattern_id: P-14
title: mental-coupling-on-rename-fix
status: documented
severity: high
first_observed: 2026-04-30
observed_by: 사용자 비판 — 26th-3 ε continuation 3 (Cowork user-active conversation, "코덱스 수정사항이 합리적이면 그걸 반영하란 소린데... 너 그냥 무작정 회귀만했지")
resolved_at: 2026-04-30
resolved_by: 26th-3 ε continuation 3 후반 (B2 codex narrative sync-back) + 사용자 비판 즉시 수신
resolved_via:
  - "[1] 26th-3 첫 시도 단순 string rename 즉시 stop + R-D1 §1.13 hotfix sync-back path 정합 진입."
  - "[2] git show <codex-sha>:<file> 로 codex narrative 의도 read → dev staging 으로 overwrite + 본 cycle multi-adaptor 1급 정합 통합."
  - "[3] 본 P-14 신설 (사고 narrative + invariant + dogfooding worked example)."
related_rule: CLAUDE.md §1.13 (R-D1 sync-back) + §1.20 (사용자 비판 즉시 stop)
related_docs:
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.13 (R-D1 invariant)
  - 2026-04-19-sfs-v0.4/CLAUDE.md §1.20 (사용자 비판 발견 시 즉시 stop + 그 문제만)
  - 2026-04-19-sfs-v0.4/learning-logs/2026-05/P-13-dev-stable-divergence-on-cut.md (직접 짝, release tooling 측 결함)
visibility: business-only
applicability:
  - "AI 가 stable hotfix 또는 외부 worker (codex / collaborator) commit 발견 시"
  - "rename / rebrand / refactor 류의 change 가 단순 string replace 처럼 보일 때 (실은 narrative 의도 가 묶여있을 가능성)"
  - "git log / git show 로 commit 의도 read 가능한 모든 환경"
reuse_count: 0   # 본 신설 자체가 dogfooding 첫 case
---

# P-14 — AI mental coupling on rename / refactor fix

## 1. 사용자 verbatim 비판 (26th-3 ε continuation 3)

> "아니 이걸 회귀를 하면 안되는데 내가 어제 코덱스한테 고치라는 사항이 이거였는데 너 그냥 무작정 회귀만했지?? 코덱스 수정사항이 합리적이면 그걸 반영하란 소린데.."

→ 핵심 = AI 가 stable hotfix (rename / rebrand) 발견 시 **단순 string replace 만 하지 말고 narrative 자체의 의도를 read 후 sync-back** 할 것. mental coupling = "rename 이라고 적힌 commit 은 string replace 만 했을 것이라는 추측" 자체가 안티패턴.

## 2. 안티패턴 정의

### 2.1 외부 증상

**AI 가 다음을 한다**: stable HEAD 와 dev staging 의 분기 fact 만 보고 "회귀 fix" 라며 dev staging 의 narrative 를 string replace 만 함. commit 본문 / commit message / git show 로 codex 의 narrative read **안 함**.

### 2.2 내부 안티패턴 (mental coupling)

다음 가정 중 하나라도 하면 P-14 진입:
- "rename commit 은 string replace 만 했을 것"
- "codex 가 stable 에서 한 일 = 내가 dev 에서 다음 cycle 에 했어야 할 일"
- "narrative 가 충돌하면 dev 본이 우선 (R-D1 dev-first 의 잘못된 해석)"
- "사용자가 빨리 release 원하니 단순한 fix 가 좋다"

→ R-D1 §1.13 의 정확한 의미 = stable 에서 발견된 버그는 stable 에서 수정 허용 + **dev 로 sync-back**. dev-first 는 신규 변경의 진입점이지, 기존 stable 변경을 무시하라는 뜻이 아님.

## 3. 진입 조건 (체크리스트)

stable HEAD 가 dev staging 과 narrative key 영역 (README / CHANGELOG / SOLON_REPO / VERSION suffix / 4 template) 에서 분기되어 있을 때:

1. **Read 단계**: `git -C <stable-repo> log --oneline -10` 로 최근 commit list 확인.
2. **Investigate 단계**: 각 분기 commit 의 `git show <sha>:<file>` 로 narrative 의도 read.
3. **Classify 단계**: 단순 string replace 인지 / narrative 개선 (rewrite / cleanup / contract change) 인지 분류.
4. **Decide 단계**:
   - 단순 string replace → dev staging 에서 동일 string replace 적용 OK.
   - narrative 개선 → **dev staging 의 narrative 를 stable 본으로 overwrite** + 본 cycle 의 추가 변경 (multi-adaptor / 신규 feature 등) 통합.
5. **Verify 단계**: 통합 후 dev staging 의 narrative 가 stable hotfix 의도 + 본 cycle 변경 둘 다 반영했는지 cross-check.

## 4. Worked Example (26th-3 본 cycle dogfooding)

### 4.1 Bad case (26th-3 첫 시도)

**상황**: 26th-2 helper 0.5.0-mvp release cut 직후 사용자가 "mvp → product rename 됐어, codex 가 작업한 수정 내용 확인해줘" 요청.

**잘못된 진행**:
- AI 가 git log 만 보고 codex commits 3 개 (`ced9cc1` + `5765abb` + `7977a75`) 의 메시지만 읽음 ("rename repository to solon product").
- "회귀 fix" 라며 단순 `solon-mvp` → `solon-product` string replace + h1 변경만 함.
- codex 의 README 본문 (product positioning rewrite, "친구야" 톤 제거, Why Solon / How It Works / Operating Model 구조) **read 안 함**.
- CHANGELOG entry narrative ("README product-facing rewrite", "/sfs start <goal> contract", "non-TTY handling" 등 11항목) **read 안 함**.

**증상**: 사용자가 첫 release 직후 README 캡처 보내며 "친구야 이게 뭐야" 톤 잔존 발견.

**사용자 비판 verbatim**: "내가 어제 코덱스한테 고치라는 사항이 이거였는데 너 그냥 무작정 회귀만했지... 코덱스 수정사항이 합리적이면 그걸 반영하란 소린데."

### 4.2 Good case (26th-3 후반, 사용자 비판 후)

**즉시 stop + sync-back path 정합**:

1. **Read 단계**: `git -C ~/workspace/solon-mvp show 7977a75:README.md` → codex 의 final README 추출 (321 lines).
2. **Investigate 단계**: `git show 7977a75:CHANGELOG.md | head -100` → codex 의 0.4.1-mvp Unreleased entry (Fixed 8 + Changed 4) narrative read.
3. **Investigate 단계**: `git show 5765abb` 으로 install.sh / upgrade.sh / uninstall.sh 의 legacy GIT_MARKER fallback 패턴 read.
4. **Classify 단계**:
   - codex 의 5765abb = 단순 string replace + legacy fallback 패턴 도입 (mixed)
   - codex 의 ced9cc1 + 7977a75 = README narrative 전체 rewrite (product positioning)
5. **Decide 단계**: dev staging README 를 codex 7977a75 baseline 으로 overwrite + 본 cycle multi-adaptor 1급 (4 entry point + 7-Gate enum + Codex Skills + Gemini commands) 통합.
6. **Verify 단계**: dev README 가 codex 의 product positioning 구조 (Why Solon / How It Works / Operating Model / Quickstart / Product Surface / Runtime Coverage / Installation / Installed Files / Safety Contract / Repository Map / Release Channel) + 본 cycle 신규 영역 (multi-adaptor 1급 entry point / 7-Gate enum) 둘 다 포함 확인.

**결과**: 0.5.1-product release 가 codex 의 product positioning narrative + 본 cycle multi-adaptor 1급 정합 통합 baseline 으로 정합 회복.

## 5. Invariant — 차후 reuse 시 의무 체크

stable hotfix / 외부 worker commit 발견 시 다음 단계 **모두** 통과하기 전에는 dev staging 변경 시작 금지:

```
1. git -C <stable-repo> log --oneline -10                 # 최근 commit fact
2. git -C <stable-repo> log --oneline <last-release>..HEAD # release 이후 commit
3. for each commit: git show <sha>:<key-file>             # narrative read
4. classify: string-only vs narrative-rewrite vs mixed
5. plan sync-back: 어떤 file 의 narrative 를 어떻게 통합?
6. (only after) dev staging edit
```

## 6. cousin patterns

- **P-13 dev-stable-divergence-on-cut** — release tooling (cut-release.sh) 측 결함. 본 P-14 가 AI worker 측 결함. 두 결함이 결합되어 26th 사고 발생.
- **P-11 sequential-disclosure** — 사용자 비판 즉시 stop 원칙 (§1.20) 의 cousin. 본 P-14 의 "사용자 비판 verbatim 즉시 수신 → 진행 stop" 부분이 §1.20 (2) 정합.
- **P-08 fuse-bypass-cp-a-broken** — 환경 의존 사고 패턴. 본 P-14 는 인지 의존 (AI 의 commit narrative read 누락) 사고.

## 7. 변경 이력

- 2026-04-30 (26th-3 ε continuation 3 후반): 신설 (status: documented, severity: high, reuse_count: 0).
