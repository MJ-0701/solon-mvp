---
doc_id: security-audit-design
title: "Design — sfs audit: 정적 보안 감사 파이프라인"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-07-13
summary: "운영자 자기 저장소의 취약점 표면을 코드에서 정적으로 뽑는 방어적 보안 감사. 결정론 OWASP-family 스캔(secret/owasp/config/deps/hygiene) + LLM 위협모델·exploit-hypothesis(추론만)·fix. 네이밍 결정 + 안전 경계 결정 포함."
load_when: "sfs audit / security audit 파이프라인의 설계 근거, 안전 경계(정적 vs 실행형), 렌즈 규칙을 확인할 때."
---

# Design — `sfs audit` (static security audit)

- **status**: shipped (0.10.0)
- **date**: 2026-07-13
- **scope**: 운영자 자기 저장소의 보안 취약점 표면 정적 감사

## 1. 문제

"정기적으로 보안감사 + 모의해킹 + 프로젝트 이슈 점검" 요구. 핵심 긴장은
"모의해킹"이 두 갈래로 갈린다는 것 — 정적 위협모델 표면 대 라이브 익스플로잇
실행. 후자는 오남용·법적 위험이 크고 solon(방법론 제품)의 벤더중립·standalone
경계와 안 맞는다.

## 2. 안전 경계 결정 (S1 — 1급 제약)

- **S1 — 정적 위협모델 표면만. 실행형 익스플로잇 엔진 불포함.** audit 은 운영자
  자기 저장소를 read-only 로 스캔해 OWASP 계열 취약점 표면을 낸다. 라이브 타깃
  공격 실행·침투·페이로드 주입은 범위 밖. finding 은 verify/fix 가이드를 달지
  무기화된 exploit 절차를 담지 않는다. 근거: 오남용 방지 + solon 제품 경계 +
  사용자 확정("정적 위협모델링 + 취약점 표면"). 회귀 잠금: 헤드라인 테스트가
  스크립트에 네트워크/익스플로잇 도구(nmap/sqlmap/metasploit/nc 등) 부재를
  정적 검사, 리포트에 "payload" 등 무기화 언어 부재를 검사.
- **S2 — 자기 저장소 한정.** 대상은 운영자가 소유·권한을 가진 현재 repo.
  타 조직·대량·미인가 타깃은 범위 밖 (문서 명시).
- **S3 — 시크릿 값 redact.** 하드코딩 자격증명을 탐지하되 값 원문은 어떤
  산출물에도 안 남긴다 — 앞 4자 마스킹만 (credential-hygiene 결). 회귀 잠금:
  테스트가 fixture 의 실제 키 문자열이 리포트에 부재함을 검사.

## 3. 설계 원칙 (dig 와 동형)

1. **결정론 코어**: 스캔·severity·redaction·재스캔 diff 는 LLM 0토큰. 판단 3단계
   (위협모델·exploit 가설·fix)만 LLM 지정 지점.
2. **read-only**: 대상 코드 수정 절대 금지. 산출물은
   `docs/solon/<domain>/audit/` 에만, `--write` consent.
3. **signal-only**: 어떤 finding 도 명령을 차단하지 않음 (ALT-INV-3).
4. **네트워크 없음**: deps 렌즈는 매니페스트·락파일 유무만 정적 판정하고, 실
   CVE 조회는 운영자가 직접 돌릴 생태계 명령(`npm audit` 등)을 surface 만 한다.

## 4. 결정

- **D1 — 네이밍: 신규 rail `sfs audit` (harness doctor 확장 기각).** 근거:
  자체 산출물 트리·severity 모델·렌즈 선택·waiver·상태를 가진 rail 이라
  dig/adopt/measure 선례를 따라 명령 신설. harness doctor 는 readiness/maturity
  진단이라 의미론이 다름. 배치는 dist-level `scripts/sfs-audit.sh`, consumer
  dispatch 미등록 (bin/sfs 직행 — dig/harness/measure 클래스).
- **D2 — 5개 렌즈 = OWASP 계열 매핑.** secret(A02) / owasp(A03·A08) /
  config(A05) / deps(A06) / hygiene(A09). "프로젝트 이슈"는 hygiene 렌즈(디버그
  잔여·보안성 TODO)로 흡수 — 광범위 프로젝트 건강은 harness doctor/healthcheck
  소관이라 중복 안 함.
- **D3 — 리뷰 렌즈와 관계: audit = 상시 스캔 표면, pack = 리뷰 렌즈.**
  `agentic-security-logging-pack.md` 가 Gate 6 리뷰 시점 OWASP·Datadog·
  secret/PII 증거를 소유하고, audit 은 그 표면을 코드에서 결정론으로 채운다.
  audit 산출물은 Gate 6 security 리뷰 증거로 소비 가능. 신규 정책 파일 없이
  기존 pack 을 SSoT 로 재사용.
- **D4 — waiver = 로컬 파일 라인.** `.sfs-local/audit-waivers` 의
  `<file:line>|<rule ...사유>` 한 줄로 수용 판정. 재스캔이 `waived` 로 반영,
  코드 수정 시 finding 이 결정론 재파생으로 사라짐(저장 상태 아님).
- **D5 — cadence = 수동 기본, 주기 자동은 opt-in.** 새 스케줄러 인프라 도입
  안 함. 기존 SCHEDULED_RUN_CONTRACT 또는 daily 훅에 운영자가 명시 지정할
  때만 붙는다. (사용자 지정: "개발자 설정에 따르도록 최초 수동, 자동은 지정시.")
- **D6 — healthcheck advisory.** open critical finding 수를 healthcheck 가
  say_warn 으로 surface — 이슈 카운트·exit 불변 (dig excavation-gate 선례).

## 5. 렌즈 계약 (SSoT: routed context `commands/audit.md`)

| lens | OWASP | 대표 규칙 |
|---|---|---|
| secret | A02 | AWS/GitHub/Slack 토큰, PEM 개인키, 하드코딩 자격증명 할당(값 redact), committed .env |
| owasp | A03/A08 | command/eval sink, SQL 문자열 결합, 안전하지 않은 역직렬화, XSS sink |
| config | A05 | debug on, TLS verify off, 와일드카드 CORS |
| deps | A06 | 매니페스트·락파일 유무, 느슨한 핀 + 생태계 audit 명령 포인터 |
| hygiene | A09 | stray 디버그 출력, 보안성 TODO/FIXME |

severity: critical/high/medium/low/info + waived. `--severity-min` 필터.

## 5.1 Codex 독립 리뷰 (0.10.1)

출하 후 Codex 2라운드 리뷰(gpt-5.5 xhigh — gpt-5.6-sol 은 CLI 0.142.0 미지원,
앱 전용)로 dig+audit 실 결함 18건(Critical 0) 확인·수정. 상세 증거:
`docs/solon/reviews/2026-07-13-dig-audit-codex-review.md`. 핵심 교훈:

- **read-only 불변식은 slug 강제로 지킨다** — 명시 `--domain` 도 예외 없이
  `[a-z0-9-]` 정규화(traversal 차단). 산출물 인덱스도 audit 디렉토리로.
- **BSD/GNU 이식성은 테스트로만 잡히지 않는다** — macOS 개발 fixture 가
  대문자 SQL 이라 GNU-only IGNORECASE 결함이 통과했다. 토큰 기반 tolower 로
  재작성 + 소문자 fixture 회귀 추가.
- **서브셸 파이프에서 누적 변수는 사라진다** — deps 느슨한 핀 loop 를
  here-string 으로. 스캐너 규칙 리터럴·테스트 픽스처 시크릿의 자기 오탐은
  경로/파일 제외로.

## 6. 회귀 잠금

- `tests/test-audit-scan.sh` — 2 취약 fixture(vuln-node/vuln-python) 전 렌즈
  탐지·file:line·시크릿 redaction(원문 부재)·env 참조 오탐 없음·severity-min·
  waiver flip·수정 후 clear·zero-LLM/zero-network 정적 잠금·무기화 언어 부재.
