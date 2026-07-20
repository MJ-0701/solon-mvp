---
id: sfs-command-audit
summary: Static, read-only security audit of the operator's own repository — deterministic OWASP-family scan, then LLM threat-model / exploit-hypothesis (reasoning only) / fix. Defensive, signal-only.
load_when: ["audit", "보안감사", "security scan", "취약점", "OWASP", "모의해킹", "penetration", "secret scan", "vulnerability"]
---

# Audit (Static Security Audit)

새 커넥터/MCP/외부 도구를 워크플로에 붙이기 *전*의 결정 렌즈는 별도로
`policies/credential-hygiene.md` FOUR_QUESTION_RISK_PREFLIGHT (untrusted
ingest / 액션·신원 / blast radius / 관측성) — audit 은 이미 있는 코드 표면을
사후 스캔하고, preflight 는 연결 전에 리스크를 legible 하게 만든다.

운영자 **자기 저장소**의 보안 취약점 표면을 코드에서 정적으로 뽑는다. 방향은
dig 와 같은 아래→위(코드→발견→OWASP 계열 매핑)이고, 스캔·severity·redaction·
재스캔 diff 는 LLM 0토큰 결정론이다. 대상 소스는 **read-only** — audit 은 대상
코드를 절대 수정하지 않고, 산출물은 `docs/solon/<domain>/audit/` 에만 쓴다
(`--write` consent, 없으면 stdout 프리뷰).

## 안전 경계 (범위 = 방어)

- **정적 위협모델 표면만.** audit 은 실행형 익스플로잇 엔진이 아니다 — 라이브
  타깃에 공격 페이로드를 실행·침투하지 않는다. 발견 항목은 검증(verify)·수정
  (fix) 가이드를 달지, 무기화된 exploit 절차를 담지 않는다.
- **자기 저장소 한정.** 스캔 대상은 운영자가 소유·권한을 가진 현재 repo 다.
  타 조직·대량 타깃·미인가 시스템 대상은 범위 밖이다.
- **시크릿 값은 항상 redact.** 하드코딩 자격증명을 탐지하되 값 원문은 어떤
  산출물에도 남기지 않는다 — 패턴 클래스 + file:line + 앞 4자 마스킹만
  (`policies/credential-hygiene.md`).
- **signal-only.** 어떤 finding 도 명령을 차단하지 않는다 (ALT-INV-3).

## 결정론 렌즈 (LLM 0토큰)

`sfs audit scan [--lens <name|all>] [--severity-min low|medium|high|critical] --write`

| lens | OWASP | 탐지 |
|---|---|---|
| `secret` | A02 | 하드코딩 키/토큰/자격증명, committed `.env`, PEM 개인키 (값 redact) |
| `owasp` | A03/A08 | command/eval 실행 sink, SQL 문자열 결합, 안전하지 않은 역직렬화, XSS sink |
| `config` | A05 | debug on, TLS 검증 off, 와일드카드 CORS |
| `deps` | A06 | 매니페스트·락파일 유무, 느슨한 핀 + 직접 돌릴 생태계 audit 명령(네트워크는 수동) |
| `hygiene` | A09 | stray 디버그 출력, 보안성 TODO/FIXME (프로젝트 이슈) |

산출: `00-audit.md` (severity 정렬 표, redact 증거, counts) + `findings.tsv`
(status 인덱스) — 둘 다 audit 디렉토리에만 쓴다. `sfs audit report` 는 마지막
리포트 출력, `sfs audit status` 는 severity/waived 카운트 + open critical 목록.

## Waiver (수용 판정)

허용 가능하다고 판단한 finding 은 `.sfs-local/audit-waivers` 에
`<file:line>|<rule ...사유>` 한 줄로 기록한다. 재스캔이 `waived` 로 반영한다.
코드를 고치면 다음 스캔에서 finding 이 사라진다(결정론 재파생 — 저장 상태 아님).

## LLM 지정 지점 (스크립트 밖)

결정론 스캔 뒤, 판단이 필요한 세 단계는 LLM 이 수행한다 — 리포트 말미가 이 순서
를 가리킨다:

1. **위협모델** — finding 들을 이 repo 기준 공격 시나리오로 클러스터링, 악용
   가능성 × 영향으로 우선순위. honest-unknowns 계약 적용
   (`policies/flow-conformance-postflight.md`): 확신도·미확인 명시.
2. **exploit 가설 (추론만)** — finding 들이 어떻게 연쇄될 수 있는지 서술한다.
   **라이브 타깃 실행 절대 금지** — 방어적 추론이지 공격 실행이 아니다.
3. **수정** — finding 별 secure-by-default 변경 제안
   (`policies/agentic-security-logging-pack.md` SEC-AIERA-002).

## 리뷰 렌즈 연결

audit 은 `agentic-security-logging-pack.md` 의 상시 스캔 표면이다 — 그 정책이
리뷰 시점(Gate 6) OWASP 렌즈·Datadog·secret/PII 증거를 소유하고, audit 은 그
표면을 코드에서 결정론으로 채운다. Gate 6 security 리뷰는 audit 산출물을
증거로 소비할 수 있다.

## 주기 실행 (opt-in, 자동 아님)

기본은 **수동** (`sfs audit scan`). 주기 자동화를 원하는 운영자는 기존
`SCHEDULED_RUN_CONTRACT` (`policies/work-delegation-and-startup.md`) 로만
붙인다 — 매 실행 fresh session, 상태는 파일로, 4제어(pause/resume/archive/
on-demand). `daily` bookend 루프에 audit 훅을 넣는 것도 운영자가 명시 지정할
때만이다. audit 은 새 스케줄러 인프라를 도입하지 않는다.

## 경계

- 대상 저장소 read-only — audit 은 대상 코드 수정 절대 금지.
- 쓰기는 `--write` consent; 산출물은 audit 디렉토리에만.
- 시크릿 값·네트워크 페이로드·데이터 로우는 산출물에 불록.
- 모든 판정 signal-only; hard-block 없음.
- healthcheck 가 open critical finding 수를 advisory 로 surface 한다
  (verdict/exit 불변).
