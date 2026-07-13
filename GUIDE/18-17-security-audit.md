---
doc_id: sfs-product-guide-ko-18
title: "17. 정기 보안 감사 (audit)"
visibility: oss-public
doc_type: user-guide
language: ko
updated: 2026-07-13
parent: GUIDE.md
summary: "자기 저장소의 취약점 표면을 코드에서 정적으로 뽑는 방어적 보안 감사 — 시크릿·injection·설정·의존성·위생"
load_when: "Read when GUIDE.md routes to this section."
---
## 17. 정기 보안 감사 (audit)

`sfs audit` 은 운영자 **자기 저장소**의 보안 취약점 표면을 코드에서 정적으로
찾아 OWASP 계열로 정리합니다. 스캔·severity·시크릿 마스킹은 LLM 없이 결정론으로
완결됩니다. 대상 코드는 절대 수정하지 않고 (read-only), 모든 결과는
signal-only — 아무것도 차단하지 않습니다.

### 무엇을 찾나 (5개 렌즈)

- **secret (A02)** — 하드코딩된 키·토큰·비밀번호, 커밋된 `.env`, 개인키. 값은
  항상 마스킹되어 나옵니다 (원문 노출 없음).
- **owasp (A03/A08)** — command/eval 실행 sink, SQL 문자열 결합, 안전하지 않은
  역직렬화, XSS sink.
- **config (A05)** — debug 켜짐, TLS 검증 off, 와일드카드 CORS.
- **deps (A06)** — 매니페스트·락파일 유무, 느슨한 버전 핀 + 직접 돌릴 생태계
  audit 명령(`npm audit`/`pip-audit` 등 — 네트워크는 수동).
- **hygiene (A09)** — 남은 디버그 출력, 보안성 TODO/FIXME 등 프로젝트 이슈.

### 순서

1. `sfs audit scan --write` — 전체 렌즈 스캔, `docs/solon/<도메인>/audit/
   00-audit.md` 에 severity 정렬 표 + 마스킹된 증거 + 카운트.
2. `sfs audit status` — severity별·waived 카운트, open critical 목록.
3. 허용 가능한 finding 은 `.sfs-local/audit-waivers` 에 `<file:line>|<사유>`
   한 줄로 기록 → 재스캔이 `waived` 로 반영. 코드를 고치면 다음 스캔에서 사라짐.
4. 판단이 필요한 3단계(위협모델 → exploit 가설(추론만) → 수정)는 리포트 말미가
   가리키는 대로 AI 에게 맡깁니다. 자세한 계약은 routed context
   `commands/audit.md`.

### 안전 경계 (꼭 알아둘 것)

- **정적 위협모델 표면만.** audit 은 실행형 모의해킹 도구가 아닙니다 — 라이브
  타깃에 공격을 실행·침투하지 않습니다. 결과는 검증·수정 가이드이지 무기화된
  exploit 절차가 아닙니다.
- **자기 저장소 한정.** 소유·권한을 가진 현재 repo 만 대상입니다.

### 주기 실행

기본은 수동입니다. 주기 자동화를 원하면 개발자가 명시적으로 기존
`SCHEDULED_RUN_CONTRACT`(새 세션·파일 상태·4제어)에 붙이거나 `daily` 루프에
audit 훅을 넣습니다 — audit 이 스스로 스케줄러를 켜지 않습니다.
