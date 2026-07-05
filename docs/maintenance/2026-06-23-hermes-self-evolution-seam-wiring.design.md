---
doc_id: hermes-self-evolution-seam-wiring-design
title: "Design — Hermes self-evolution seam wiring"
visibility: oss-public
doc_type: design-doc
language: ko
updated: 2026-06-23
summary: "External-orchestrator (Hermes) self-improvement seam을 prep-only에서 runtime wiring으로 승격하는 설계. Seam A(SIGNAL feed) + Seam B(proposal-review surface), OCP 어댑터 추상화, standalone/no-auto-patch/gate-bypass 회귀잠금."
load_when: "Hermes 외부 오케스트레이터 연동, self-improvement 루프 seam 배선, external_orchestrator 스키마/어댑터 작업 시. team topology 설계(2026-06-23-multi-agent-team-topology.design.md)의 자매 문서."
---

# Design — Hermes self-evolution seam wiring

- **status**: draft (design, pre-implementation)
- **date**: 2026-06-23
- **target repo**: solon-product (distribution)
- **scope**: external-orchestrator self-improvement seam을 prep-only → runtime wiring
- **sibling**: [2026-06-23-multi-agent-team-topology.design.md](2026-06-23-multi-agent-team-topology.design.md) (워커 층; 본 문서는 오케스트레이터 층)
- **author**: Cowork 설계 초안 (사용자 검토 → sprint 정식화 대기)

---

## 1. 배경 / 문제

solon은 8단계 자체개선 루프(SIGNAL→RECORD→CURATE→PROPOSE→MEASURE→GATE→APPLY
→CAPTURE)를 이미 갖고 있고, 외부 상주 오케스트레이터(**Hermes**, 외부 상품)가
이 루프에 붙는 **두 seam**이 `external-orchestrator-entry.md` §"Self-improvement
seam"에 정의돼 있다. 단 현재는 **prep-only** — "어디에 붙는가"만 문서화, **런타임
배선 0**(신규 command·`bin/sfs` 변경·어댑터 코드 없음).

사용자 목표: 이 두 seam을 **실제 runtime wiring으로 승격**해, Hermes와 연동된
solon 자체진화 프로세스를 만든다. 사용자 결정: **두 seam 모두**(SIGNAL feed +
proposal-review surface), team topology와 **별도 자매 설계문서**로 진행.

외부 검증(2026-07-05 추가): 이슈 트래커·Slack 등 일이 들어오는 입구에서 바로
에이전트에게 위임하는 패턴은 조직 스케일에서 검증됐다(`idea_wiki:L087-I8`) —
본 seam 설계(입구 위임)의 방향을 대규모 사례가 뒷받침한다. 신규 구현 없음.

## 2. 목표 / 비목표

**목표**
- Seam A(External SIGNAL source)·Seam B(External proposal-review surface) 둘 다
  실제 배선.
- Hermes 연동을 **어댑터로 추상화**(OCP) — API/CLI/webhook 어느 인터페이스든
  어댑터 교체만으로 대응, solon 본체 분기 0.
- 6 invariants + inviolable gates + read-only-first + standalone을 **배선 후에도
  불변**으로 유지(회귀잠금).

**비목표 (중요)**
- **코드 자동패치 금지 유지.** Hermes 연동이 DGM식 코드 자기수정을 풀지 않는다.
  진화 적용은 measured → human-gated → **MD-only**. (self-improvement-loop
  `no code auto-patch` invariant.)
- standalone guarantee 훼손 0 — Hermes 떼면 `doctor + curation + tidy`로 동작.
- Hermes를 번들/핀/필수화하지 않음 — opt-in 외부 연동.
- 릴리스/머지/푸시/승인 자동화 0 — inviolable gates 그대로.

## 3. 설계 원칙

1. **OCP — Hermes 어댑터 추상화.** Hermes의 실제 인터페이스(REST API / webhook /
   CLI / 파일 drop)를 `external_orchestrator_adapter`(데이터+얇은 어댑터)로 감싼다.
   solon 루프는 어댑터의 **typed 계약**만 보고 Hermes를 모른다. Hermes가 바뀌거나
   다른 오케스트레이터로 교체돼도 어댑터만 갈아끼움 → 본체 분기 0. (team
   topology의 `runtime_registry`와 동형 패턴.)
2. **Standalone guarantee.** seam 전체 제거 시 루프가 doctor+curation+tidy로 동작
   (discriminating test, 회귀잠금).
3. **Authority 불변.** Hermes는 신호를 더 주고 검토 표면을 호스팅할 뿐, 루프의
   권위를 못 바꾼다: 후보 suggest-only, inviolable gates, first scope read-only,
   measured-but-not-sufficient.
4. **Typed handoff only.** Hermes↔solon 모든 교환은 capsule 8필드 계약
   (`sub-agent-capsule-contract.md`) + `sfs event` typed key=value. raw narration
   금지.
5. **데이터 경계.** Hermes로 나가는 건 signal/proposal 메타만. 소스코드·시크릿·
   원본 evidence는 경계 밖(runtime-token-firewall, source-pointer-citation 포인터
   인용). credential은 per-runtime boundary attachment(credential-hygiene).

## 4. Seam A — External SIGNAL source (Hermes → solon)

Hermes의 cross-system 완료작업·탐지 신호를 루프의 SIGNAL/CURATE/PROPOSE 입력으로
주입.

- **수신 표면**: `sfs` read 경로에 typed signal ingest. 후보 형태
  `sfs signal ingest --from hermes --file <capsule.json>` (또는 어댑터가 알려진
  inbox 경로에 typed capsule을 drop → 다음 curation 패스가 소비).
- **계약**: signal capsule = {source, kind(completed-work|detection|hotspot),
  evidence_pointer, confidence, ts} — 8필드 계약 준수, downstream이 검증 후 소비.
- **권위**: ingest는 SIGNAL 입력을 **추가**할 뿐, RECORD/CURATE/PROPOSE의 기존
  소유 정책(lessons-accumulation, skill-promotion-loop)을 안 바꾼다. ingest된
  신호도 suggest-only 경로로만 흐른다.
- **안전**: ingest는 write가 아니라 "큐에 typed 신호 적재"(read→propose 단계).
  ledger/skill 자동 기록 0.

## 5. Seam B — External proposal-review surface (solon ⇄ Hermes)

curation·promotion 후보를 Hermes 표면에서 사람이 cross-system 검토.

- **내보내기**: solon이 curation report / promotion candidates(suggest-only
  산출물)를 typed export로 Hermes에 노출(어댑터가 Hermes 인터페이스로 변환).
  내보내는 건 후보 메타 + evidence **포인터**(원본 아님).
- **회수**: Hermes에서의 사람 검토 결과(approve/defer/reject + 코멘트)를 typed로
  회수. 단 이 결정은 **suggest-only를 못 넘는다** — 실제 APPLY는 여전히 solon
  `tidy` 레일 + 로컬 human gate. Hermes 검토 = cross-system 가시성·의견이지
  solon gate 대체가 아님.
- **inviolable gates**: Hermes 검토가 release cut/publish/push/merge/Gate3
  승인을 트리거 못 함. 그런 boundary actions는 Tier B/C typed surface(permission
  deny / pre-tool hook)로 강제.

## 6. Hermes adapter (OCP 확장점, 신규)

```yaml
# .sfs-local/orchestrator.yaml (또는 model-profiles 인접 섹션)
external_orchestrator:
  enabled: false                 # 기본 off = standalone (opt-in)
  adapter: hermes                # 어댑터 id (교체 가능)
  transport:                     # 인터페이스 추상화 — 실측 후 채움 (open)
    kind: "<api|webhook|cli|file-drop>"
    endpoint: "<…>"              # credential은 여기 두지 않음(per-runtime store 참조)
  scope: read-only               # first-permission; read→propose→bounded-write 점진
  signal_inbox: ".sfs-local/orchestrator/inbox/"     # Seam A typed drop
  review_outbox: ".sfs-local/orchestrator/outbox/"   # Seam B typed export
  emits: [signal-ingest, proposal-export, review-import]
  # 새 오케스트레이터 추가 = adapter 항목 추가만. 루프 코드 분기 0 → OCP.
```

- 어댑터는 transport별 구현만 다르고 **typed 계약은 동일**. 루프는 inbox/outbox의
  typed capsule만 본다.
- `enabled: false`가 기본 → 설치/업그레이드가 standalone을 안 깬다.

## 7. team topology와의 계층 관계

| 층 | 누가 | 역할 | 문서 |
|---|---|---|---|
| 오케스트레이터 | Hermes (외부 상품) | 루프에 SIGNAL feed + proposal-review host | **본 문서** |
| 워커 | claude / codex / antigravity | 작업 실행 dispatch | team topology |

같은 `external-orchestrator-entry` 계약 공유. Hermes가 진화 신호를 주고 → solon
루프가 돌고 → 그 안 실제 작업은 team이 분배. 두 어댑터(orchestrator / runtime)는
동형 OCP 패턴.

## 8. Acceptance Criteria (초안)

1. `external_orchestrator.enabled: false`(기본)에서 모든 명령·루프·release가
   현재와 동일 — **standalone 회귀잠금**.
2. seam 전체(어댑터+inbox+outbox) 제거 후 doctor+curation+tidy로 루프 동작.
3. Seam A: typed signal ingest가 SIGNAL 큐에만 적재, ledger/skill 자동기록 0.
4. Seam B: Hermes review 결과가 APPLY를 트리거 못 함 — `tidy` + 로컬 human gate
   필수(**gate-bypass 불가 회귀잠금**).
5. **no code auto-patch 유지**: 어떤 Hermes 신호/검토도 코드 파일 자동수정으로
   이어지지 않음(MD-only adoption 회귀잠금).
6. 어댑터 transport.kind를 바꿔도(api↔file-drop) 루프 코드 diff 0 — **OCP 회귀잠금**.
7. credential은 prompt/capsule/inbox 파일에 평문 부재 — per-runtime store 참조.

## 9. 리스크 / 미결

- **Hermes 실제 인터페이스 미확정** — REST/webhook/CLI/파일 중 무엇인지, auth
  방식, rate/quota. 어댑터 transport 채우려면 실측 필요. _확인 항목 (사용자/제품
  문서)._
- "자체진화" 기대치 정렬: solon 진화 = measured + human-gated + MD-only. 완전자율
  코드진화(DGM)는 범위 밖 — 사용자 기대와 어긋나면 P0에서 결정.
- 양방향 신뢰 경계: Hermes가 외부 상품이라 inbound signal의 신뢰도/검증
  (악성/오염 신호 방어), outbound 데이터 최소화(포인터만).
- review 결과 회수의 동기/비동기 + 충돌(로컬 gate vs Hermes 의견 불일치 → 로컬
  우선, 충돌 surface).

## 9.1 보안 결정 (P3 선행): route real-exec `eval` → argv array

P3 가 transport 를 실제 외부 호출에 연결하면 team topology P3 의 `sfs-route.sh`
real-exec 경로에 닿는다. 그 경로는 invoke 템플릿에 capsule 텍스트를 치환한 뒤 `eval`
했다 — **goal 에 `$(…)`/백틱이 있으면 shell 실행되는 injection seam** (dry-run 만 테스트돼
잠재적이었음). **수정**: 템플릿을 argv WORD 로 분해, `{prompt}`/`{tools}`/`{prompt_file}`
값을 각각 1개 argv 원소로 넣은 배열을 직접 실행 → capsule 은 inert data, shell 재파싱 없음.
dry-run 은 같은 배열을 공백 join 표시만. **회귀**: `test-route-exec-argv-injection.sh` —
REAL exec 로 `$(touch PWNED)`/백틱이 실행 안 되고 1 literal argv 로 전달됨 + 정적 eval 부재
확인. dry-run 표시 문자열 동일 → team-route-dispatch 무변경.

## 10. 단계 (phasing)

각 완료 항목의 커밋 sha 는 호스트 commit/push 시 기록.

- **P0 (이 문서)**: 설계 확정 + AC 합의 + Hermes 인터페이스 실측.
- **P1** ✅(0.8.45): `external_orchestrator` 스키마(flat-scalar, `enabled:false`, template
  2.0→2.1) + read-only resolver `sfs orchestrator`(`sfs-orchestrator.sh`, sfs-team.sh 동형)
  + `test-hermes-seam-p1.sh`(standalone / no-auto-patch / gate 구조적 / OCP transport_kind).
  policy §seam prep-only→default-off 재서술(불변식 SSoT 복제 0). 계약만. run-all 199/0.
- **P2** ✅(0.8.46): Seam A — `sfs orchestrator ingest` 가 typed SIGNAL 캡슐을 검증해
  `.sfs-local/orchestrator/signal-queue.md` 에 1 항목 append; curation 이 read-only 추가
  입력으로 소비(prose, by-ref). enabled-gate(off→exit3 큐0), schema reject(exit5 큐보존),
  suggest-only. **SIGNAL schema = 설계 §4 의 5 필드** — task "8필드" 는 capsule-contract 의
  typed-handoff *규율*(필드 수 아님; detection/hotspot 은 AC/budget 없어 8필드로 못 담음).
  `test-hermes-seam-p2.sh`. run-all 200/0.
- **P3** ✅(0.8.47): §9.1 eval→argv 선행 후 Seam B — `sfs orchestrator export`(pointer-only,
  whitelist id/kind/evidence_pointer/title, raw body 유출 0) + `import-review`(decision
  enum + 전 inbound 필드 sanitize=pipe/control strip+cap, advisory review-log, APPLY 불가)
  + file-drop transport 실구현(api/webhook/cli 는 config+future adapter, OCP-narrow) +
  credential_ref indirection scalar(평문 0, template 2.1→2.2). enabled-gate 양쪽(off→exit3
  무쓰기), schema reject exit5. `test-hermes-seam-p3.sh` + `test-route-exec-argv-injection.sh`.
  run-all 202/0. 채널 publish 는 0.8.45+46+47 묶어서.

> 점진 도입: 각 phase 는 계약+회귀잠금 위에 다음을 얹고 standalone·no-auto-patch 를
> 유지한다 — team topology 와 동일 철학.
