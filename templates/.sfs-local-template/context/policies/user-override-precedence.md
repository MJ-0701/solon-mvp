---
id: sfs-policy-user-override-precedence
summary: Explicit user command outranks SFS product default; every override carries a scope (wu|sprint|until-revoked) and all policy transitions surface — never silent in either direction.
load_when: ["override", "user command", "정책 우선", "충돌", "conflict", "model 직접", "scope", "default 이탈"]
---

# User-Override Precedence (#3 conflict-surface guard)

## 우선순위
- **explicit user command > SFS product default.** 제품은 fresh 한 명시 사용자 명령을 덮지 않는다.
- 구분: explicit user command(권위, 따름) vs inherited stored policy/memory(advisory, 충돌 시 재-surface 대상).
  저장된 정책/메모리를 fresh 명령처럼 silent 적용하지 않는다. ← 원래 worker-tiering 버그의 근인.

## scope 필수
- 모든 override 는 scope 보유: `wu` | `sprint` | `until-revoked`.
- set-time 에 미명시면 제품이 묻는다. 비대화 fallback = 가장 좁게 `wu` + 다음 진입 surface.
- 기록: `sfs capture --kind exception --scope <wu|sprint|until-revoked> "<명령>"`.

## 전이 always-surface (양방향 silent 금지)
1. override 시작 → scope 확정받고 적용. `conflict_surfaced` 이벤트 emit.
2. 만료 → 다음 작업 진입 시 lapse 를 알리고 revert(default 복귀) 또는 연장 확정. **SFS default 로 silent auto-revert 금지.**
3. override ↔ default 충돌(진입 시점) → 진입 전 surface, 사용자 확정.

## entry-check + FCP 통합
- 새 WU/sprint/loop wake 진입 시 live override 점검: scope 가 이 단위 커버 & default 와 충돌 → surface. scope 만료 → lapse surface.
- flowcheck `fcp-model-tier`/`fcp-conflict-surfaced` 는 default 이탈을 **live·scoped·user-authorized override capture** 로 covered 일 때만 conformant 처리.
  inherited-but-unconfirmed 또는 expired override → critical surface(silent pass 금지).

## 비목표
- auto 로 SFS 설정을 silent 하게 끌어오지 않는다(어느 방향도).
- helper-grade 단순 I/O 까지 매번 묻지 않는다 — 모델 tier/flow 이탈 같은 product-affecting override 에 한함.
