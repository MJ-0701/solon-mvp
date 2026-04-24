---
pattern_id: P-01
title: "Solon MVP scope 모호성 → consumer vs distribution 혼동"
status: captured
category: scope-definition
severity: high
recurrence_risk: high
detected_at: 2026-04-24T21:50:00+09:00
detected_by: amazing-happy-hawking (10번째 세션, WU-20 진입 중)
resolved_at: 2026-04-24T22:30:00+09:00
related_wu: WU-20
related_docs:
  - HANDOFF-next-session.md §0 #16
  - sprints/WU-20.md
  - solon-mvp-dist/APPLY-INSTRUCTIONS.md
---

# P-01 · solon-mvp scope 혼동 (consumer vs distribution)

## 무엇이 일어났나 (Observation)

Phase 1 MVP W0 단계에서 사용자가 `setup-w0.sh` 를 실행해 `solon-mvp` repo 를 GitHub private
으로 생성하고 3 initial commit (CLAUDE.md / README.md / .sfs-local/) 까지 push 완료.
이어서 `verify-w0.sh` 실행 시 check #7 (CLAUDE.md 에 Solon 키워드 포함 여부) 에서
**false-positive FAIL** 발생 — repo 이름 `solon-mvp` 가 grep 패턴 `solon|agent_architect|sfs-v0.4`
중 `solon` 단독 키워드에 매치된 것.

Claude 가 check #7 grep 패턴을 patch 하려는 안을 제시한 순간, 사용자가 **원 의도** 를 명확히 제기:

> "난 지금 solon mvp(sfs 로 실행하는 단계)를 내 개인프로젝트랑, 새로시작할 프로젝트에서
> 사용하기 위해서 mvp 출시를 하겠다는거임 그래서 내가 repo 이름을 solon-mvp로 진행했던건데
> 프로젝트에서 sh로 임시 설치해서 사용할 수 있게 만들어 둔거면 내가 진행하고있는 사이드프로젝트,
> 그리고 앞으로 만들 신규 프로젝트에서 sh로 설치하면 되나?"

이 발화로 scope 혼동이 드러남.

## 근본 원인 (Root Cause)

**용어 "MVP" 의 이중 해석**:

| Claude 해석 (오해)                                | 사용자 의도 (원안)                                     |
|------------------------------------------------|----------------------------------------------------|
| Consumer 프로젝트의 MVP 단계 (admin panel 등 특정 도메인) | SFS/Solon **시스템 자체의 MVP 배포판** (설치 가능한 도구)    |
| `solon-mvp` = Solon 방법론을 **사용하는** 프로젝트     | `solon-mvp` = Solon 방법론을 **제공하는** 배포 패키지       |
| setup-w0.sh / verify-w0.sh 원 설계 대상            | install.sh 가 있어야 하는 전혀 다른 종류의 repo            |

Claude 가 HANDOFF §0 #11~#13 (admin panel MVP, Solon 참조 zero) 를 "현재 작업" 으로 해석하고
PHASE1-KICKOFF-CHECKLIST / setup-w0.sh / verify-w0.sh 를 자동 적용. 그러나 사용자의 최근
의도 (#13 의 "Solon docset 은 내 개인자산이니까 사실 플러그인 형태로 배포가 돼야하는게 맞음"
의 연장선) 는 **Solon 자체의 distribution MVP** 를 뜻했음.

문서상 단서:
- HANDOFF §0 #11: "sfs시스템으로 다음주부터 난 새로운 프로젝트 mvp를 구축할거야 이걸 염두해둬"
  → "새로운 프로젝트 mvp" 가 SFS-powered 프로젝트 (consumer) 인지, SFS 시스템의 MVP 배포
  (distribution) 인지 **양의적 해석 가능**.
- HANDOFF §0 #13: "플러그인 형태로 배포가 돼야하는게 맞음" — distribution 의도 명시.
  그러나 MVP 단계 fallback 으로 "사용자 개인 workspace 로컬 clone" 이 허용돼 Claude 가
  consumer project 쪽으로 기울어짐.

## 징후 (Symptoms Before Detection)

1. **setup-w0.sh 의 repo 생성 패턴**: 빈 repo clone → template cp → 3 commit → push.
   이 패턴은 consumer 프로젝트를 가정. distribution 이면 install.sh 가 있어야 정상.
2. **verify-w0.sh check #7**: "CLAUDE.md 에 Solon 키워드 없어야 함" 가정.
   distribution repo 에는 Solon 키워드가 **당연히** 포함돼야 하므로 가정 자체가 맞지 않음.
3. **repo 이름 `solon-product` → `solon-mvp` rename**: 사용자가 "solon" 을 이름에 포함시킨
   순간부터 단서. Claude 가 이 때 질문을 3가지 분기 (α/β/γ) 로 던졌지만, "rename solon-mvp"
   응답에서 의도를 과소해석 (naming 변경으로만 이해).

Claude 가 이 중 어느 단서에서도 "consumer vs distribution" 구분 질문을 명시적으로 던지지 않음.

## 해결 (Resolution)

WU-20 재정의 — "W0 결정 기록" 에서 "Solon MVP distribution 설계 + 실체화" 로 scope 전환.
사용자 3개 답변 기반으로 `solon-mvp-dist/` staging 구축:

1. install.sh (dual mode: `curl | bash` + local, interactive conflict s/b/o/d)
2. upgrade.sh (VERSION 기반 diff + 파일별 merge)
3. uninstall.sh (산출물 보존 옵션)
4. templates/ (도메인 중립, admin-panel 특화 제거)
5. README.md / CHANGELOG.md / VERSION / CLAUDE.md (distribution 설명)
6. APPLY-INSTRUCTIONS.md (기존 consumer-scope solon-mvp repo → distribution scope 전환)

## 재발 방지책 (Prevention Rules)

### R-01: scope 구분 명시 질문 의무화

새 WU 진입 시 repo / 산출물 이름에 "mvp" 또는 "template" 이 포함되면, Claude 는 **반드시**
다음 2항 중 하나로 분기 질문을 선제 제시:

- 이 repo / 산출물은 **도구 자체 (distribution)** 인가, **도구 사용자 (consumer)** 인가?
- 해당 mvp 는 **특정 도메인 (예: admin panel)** 의 mvp 인가, **방법론 자체** 의 mvp 인가?

### R-02: scope 문서의 frontmatter 필수 필드

모든 sprint / repo / template 산출물의 frontmatter 에 다음 2 필드 추가:

```yaml
scope: distribution | consumer | tooling | docs
audience: [solon_maintainer | consumer_developer | end_user]
```

이 필드가 비어 있으면 PROGRESS.md `② In-Progress` 에 WARN 마커.

### R-03: verify-script 패턴의 context-sensitivity

IP 경계 / 키워드 grep 은 **repo 타입별로 다른 허용 리스트** 를 가져야 함:
- consumer repo: "solon" 등장 시 FAIL (distribution 경로 유입)
- distribution repo: "solon" 등장 **정상** (repo 자체가 solon 이므로)
- distribution repo 에서도 `agent_architect|sfs-v0.4|solon-docset|solon-wip` 등 **docset 내부 경로** 는 여전히 FAIL

### R-04: 자동화 스크립트의 scope 태깅

setup-*.sh / verify-*.sh 등 자동화 스크립트 파일 상단 주석에 대상 scope 명시:

```bash
# setup-w0.sh — Phase 1 MVP W0 환경 준비 (대상 scope: consumer)
# 주의: distribution repo 에는 사용 금지 (install.sh 가 따로 있음)
```

### R-05: 사용자 의도 재확인 주기

context window 30% 도달 혹은 새 세션 진입 시, Claude 는 직전 5개 이내 사용자 발화에서
"의도 이동" 이 있었는지 명시적으로 확인:

- 과거 HANDOFF §0 지시와 현재 사용자 발화의 미묘한 차이 감지 → clarifying Q
- 특히 #14, #15, #16 처럼 **pivot / 재정의 발화** 뒤에는 반드시 scope 재확인.

## 학습된 패턴 일반화

**"MVP" 라는 단어는 항상 두 가지 중 하나다**:
1. **Tooling MVP** — 도구 / 배포판의 최소 실행 가능 릴리스
2. **Product MVP** — 특정 도메인 / 제품의 최소 기능 출시

두 개는 **repo 구조 / 스크립트 / 테스트 기준이 모두 다르다**. 섞이면 방향성이 왜곡된다.

Solon 의 경우: 사용자가 원하는 것은 (1) Tooling MVP. 그로부터 consumers (사이드프로젝트 / 신규
프로젝트) 가 (2) Product MVP 를 만든다. 두 레이어는 **다른 repo** 다.

## 회고 (Retrospective)

### 잘한 것

- 사용자가 의도 명확화 발화를 했을 때 Claude 가 즉시 방향 전환 (약 1 턴 내) — "⚠️ 스코프
  오해 있었어" 명시적 자인.
- 3개 결정 질문으로 설계 방향을 수렴시킴 (install method / conflict handling / upgrade).

### 아쉬운 것

- 최소 2 턴 전에 scope 혼동 징후를 포착할 수 있었음. 특히 `solon-product` → `solon-mvp`
  rename 시 질문이 부족.
- `phase1-mvp-templates/` 라는 이름 자체가 "Phase 1 (consumer) MVP template" 가정을 고착.
  distribution 가능성을 "Phase 2 예약" 으로만 분류해 둔 것이 blind spot.

### 다음 사이클 적용

- R-01 ~ R-05 를 CLAUDE.md §1 절대 규칙 확장 후보로 검토.
- 다음 WU 진입 시 scope 필드 (R-02) frontmatter 에 반드시 기입.

## 참고 아티팩트

- Solon docset `solon-mvp-dist/` — distribution staging
- Solon docset `HANDOFF-next-session.md` §0 #16 — verbatim 사용자 지시
- Solon docset `sprints/WU-20.md` — WU metadata
- Consumer repo `https://github.com/MJ-0701/solon-mvp` — distribution 전환 대상 (사용자 apply 대기)
