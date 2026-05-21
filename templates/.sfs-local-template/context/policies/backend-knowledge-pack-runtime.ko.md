---
id: sfs-policy-backend-knowledge-pack-runtime-ko
summary: Backend architecture, deployment runtime, JVM, JPA, HikariCP 점검 항목(한글 버전).
language: ko
load_when:
  - backend
  - architecture
  - runtime
  - JVM
  - Spring Boot
  - JPA
  - Hibernate
  - HikariCP
status: split-v1
parent_doc: backend-knowledge-pack.ko.md
split_from_section: "Backend Proposition Inventory"
content_policy: "backend-knowledge-pack.ko.md 가 BE-ARCH, BE-CICD, BE-JVM, BE-JPA, BE-HIKARI 를 활성화할 때 읽는다"
---

# Backend Runtime Pack

## BE-ARCH - Backend Architecture Shape

- BE-ARCH-001: MVP/small backend starts as a clean layered monolith.
- BE-ARCH-002: Non-initial backend work may need CQRS at the application boundary even on one database.
- BE-ARCH-003: Hexagonal architecture is proposed when domain seams, integration seams, or release cadence make boundaries visible.
- BE-ARCH-004: MSA requires explicit deploy/scale/ownership/resilience/blast-radius evidence and user approval.
- BE-ARCH-005: Architecture artifacts must include context, component, sequence, state, data-flow, ERD, API/event contract, runbook, capacity, SLO, and security agreement when partner integration is material.

## BE-CICD - 배포 / 운영 런타임

- BE-CICD-001: CI/CD는 빌드-테스트-검증-패키징-공개까지 하나의 신뢰 경로로 연결되어야 한다.
- BE-CICD-002: 배포 전략은 blue/green, canary, rolling 중 프로젝트 리스크와 가용성 요구에 맞춰 선택된다.
- BE-CICD-003: Blue/green 또는 canary는 상태 확인, 롤백 임계치, 그리고 부분 실패 정리 절차가 함께 정립되어야 한다.
- BE-CICD-004: 배포 아티팩트는 환경별 재생성이 아니라 동일 산출물을 배포한다.
- BE-CICD-005: Secrets와 시크릿 스토어(Secrets Manager/SSM/CI secret store) 사용이 기본값이다.
- BE-CICD-006: server shutdown/컨테이너 종료 동작과 로드밸런서 드레인·커넥션 회수 정책은 함께 정합성 검토한다.
- BE-CICD-007: 이벤트 수신/웹훅은 배포 시점에도 최소 유실 조건으로 동작해야 한다.
- BE-CICD-008: 배포 도중 로그/헬스·메트릭의 상시 가시성은 회귀 탐지의 기본 조건이다.
- BE-CICD-009: 배포 파이프라인이 커버하지 않는 수동 작업은 체크리스트와 점검책임자가 명시되어야 한다.

## BE-JVM - JVM / Spring Boot Runtime

- BE-JVM-001: Spring Boot 3.x implies Java 17+ and Jakarta package migration review.
- BE-JVM-002: Actuator exposure, management port, liveness/readiness, and sensitive value masking are security review topics.
- BE-JVM-003: Profile separation must be explicit across local/dev/stage/prod.
- BE-JVM-004: JVM GC, heap, OOM, timezone, and encoding settings are deployment review topics.
- BE-JVM-005: Embedded Tomcat and graceful shutdown must align with load balancer draining.
- BE-JVM-006: Virtual threads are a workload-specific option, constrained by pinning, ThreadLocal use, and external pools.

## BE-JPA - JPA / Hibernate / Data Access

- BE-JPA-001: OSIV should be explicitly reviewed and usually disabled.
- BE-JPA-002: `ddl-auto` must not mutate production schema implicitly.
- BE-JPA-003: ID generation strategy must be explicit; `AUTO` is a review smell.
- BE-JPA-004: IDENTITY, SEQUENCE, and TABLE strategies carry different batching and connection-demand tradeoffs.
- BE-JPA-005: N+1 mitigation, batch fetch size, entity graph, fetch join, and projection choices must be intentional.
- BE-JPA-006: Query settings such as IN-clause padding and collection-fetch pagination failure are review topics.
- BE-JPA-007: Auto-commit and `provider_disables_autocommit` must match the transaction model.
- BE-JPA-008: SQL logging must avoid `show_sql` and use logger-based controls.
- BE-JPA-009: Optimistic locking is required when partner events and internal state changes can race.
- BE-JPA-010: Envers revision type and audit scope require explicit review.

## BE-HIKARI - HikariCP / Connection Pool

- BE-HIKARI-001: Pool sizing must account for all concurrent DB-accessing threads.
- BE-HIKARI-002: Pool sizing must account for one task needing multiple simultaneous connections.
- BE-HIKARI-003: `REQUIRES_NEW`, sequence/table ID allocation, direct JDBC, reader datasource, and nested service calls can increase connection demand.
- BE-HIKARI-004: Blue/green deployment doubles connection pressure during overlap.
- BE-HIKARI-005: `maxLifetime`, `idleTimeout`, `keepaliveTime`, and DB wait timeout must be coherent.
- BE-HIKARI-006: Leak detection and pool metrics are early warning requirements.
- BE-HIKARI-007: Batch/non-realtime apps should have different pool assumptions from realtime APIs.
