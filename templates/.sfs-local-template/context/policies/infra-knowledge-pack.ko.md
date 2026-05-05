---
id: sfs-policy-infra-knowledge-pack-ko
summary: Infra/DevOps 지식 항목 인벤토리(한글 버전).
language: ko
load_when:
  - infra
  - devops
  - deployment
  - cloud
  - AWS
  - secrets
  - observability
  - rollback
  - cost
status: filled-v1
content_policy: "compact operating guidance; apply only matching ids and keep infra depth proportional to runtime exposure"
---

# Infra/DevOps Knowledge Pack Inventory

이 파일은 infra/DevOps 작업을 위한 compact filled guidance pack 이다. sprint,
review, release 에서 deployment, secrets, observability, cloud, cost, release
check 중 무엇이 활성화되는지 판단하고 matching id 만 적용한다.

## Activation Rules

- Activate only the infra depth justified by runtime, ownership, risk, and scale.
- Do not activate Kubernetes, service mesh, or heavy IaC for a first MVP without
  concrete operational evidence.
- Production exposure, secrets, public endpoints, PII, money, partner systems,
  or release tooling make infra review mandatory.
- SFS product development should consider install, upgrade, cross-platform, and
  release-distribution paths as infra surfaces.

## INF-SCALE - Review Depth By Project Size

- INF-SCALE-001: Local prototype needs reproducible setup and no secret leakage.
- INF-SCALE-002: MVP needs environment config, simple deploy path, logs, and rollback notes.
- INF-SCALE-003: First production exposure needs monitoring, alerting, backup, access control, and incident owner.
- INF-SCALE-004: Public or sensitive systems need network boundary, TLS, IAM, WAF/security group, and audit review.
- INF-SCALE-005: High traffic needs capacity model, scaling policy, bottleneck hypothesis, and load evidence.
- INF-SCALE-006: Multi-environment release needs parity, config drift detection, migration safety, and rollback rehearsal.
- INF-SCALE-007: Platform or many-team usage needs IaC, tagging, cost controls, and operational governance.

## INF-PROP - Proposition Inventory

- INF-PROP-001: Environment variables and runtime config must have source of truth and drift policy.
- INF-PROP-002: Secrets must be stored, rotated, and audited outside plaintext config.
- INF-PROP-003: CI/CD must produce immutable artifacts tied to source revision.
- INF-PROP-004: Deployment strategy must define rollback and partial-failure behavior.
- INF-PROP-005: Graceful shutdown and drain behavior must match load balancer or worker semantics.
- INF-PROP-006: Logs, metrics, traces, and business signals must make incidents diagnosable.
- INF-PROP-007: Alerts need owner, severity, threshold, and runbook link.
- INF-PROP-008: Backup and restore are not complete until restore is tested.
- INF-PROP-009: Network topology must identify public/private boundary, DNS, TLS, NAT, and ingress path.
- INF-PROP-010: IAM and security groups must follow least privilege.
- INF-PROP-011: Cost controls need budget, tag strategy, ownership, and scaling assumptions.
- INF-PROP-012: IaC becomes active when manual cloud drift or repeatability risk is material.
- INF-PROP-013: Container images need non-root execution, patch cadence, and vulnerability scanning when deployed.
- INF-PROP-014: Cross-platform CLI/release tooling needs macOS/Linux/Windows path and shell behavior review.
- INF-PROP-015: Upgrade scripts must be idempotent, backup user data, and handle interrupted runs.
- INF-PROP-016: Production data migration needs snapshot, rollback, dry-run, and audit trail.
- INF-PROP-017: Incident response needs escalation, communication, mitigation, and postmortem loop.
- INF-PROP-018: Kubernetes requires workload, scaling, deployment, and ownership evidence before activation.

## INF-AWS - AWS Service Topics

- INF-AWS-001: EC2 baseline sizing and runtime profile (CPU, memory, I/O, patching cadence) are explicit.
- INF-AWS-002: ALB/NLB boundary and health-check protocol must preserve graceful rollout and drain timing.
- INF-AWS-003: Auto Scaling 정책은 scale-in protection, cooldown, instance refresh, and failed deployment rollback.
- INF-AWS-004: Aurora topology (writer/reader role, failover behavior, timeout alignment) is part of release risk.
- INF-AWS-005: Redis topology (replication, failover, eviction policy, keyspace protection) is reviewed for blast radius.
- INF-AWS-006: S3 security (access block, encryption, lifecycle, versioning) is active when file lifecycle exists.
- INF-AWS-007: DNS/TLS/WAF/IP-exposure decisions are required before public ingress.
- INF-AWS-008: IAM/service role matrix includes secret paths, least privilege, and key rotation ownership.
- INF-AWS-009: RDS/Aurora and cache metrics are part of operational SLO evidence before production.
- INF-AWS-010: AWS service costs and scaling economics are part of release-readiness checks.

## INF-FILL - Operating Guidance

### INF-FILL-ENV - Environment And Config

- runtime config 는 source of truth, owner, allowed environments, default
  behavior, drift detection path 를 가져야 한다.
- secrets 는 repo, log, screenshot, command history, sample config 에 있으면 안 된다.
  저장 위치, rotation owner, leak 시 revoke 방법을 기록한다.
- environment parity 는 local/dev/stage/prod 사이에서 의도적으로 다른 점을 명명한다.

### INF-FILL-DEPLOY - CI/CD And Rollback

- 한 번 build 한 artifact 를 동일하게 deploy 한다. environment 별 rebuild 를 한다면
  이유와 equivalence check 를 기록한다.
- deployment strategy 는 health check, readiness, drain, partial failure behavior,
  rollback trigger, manual stop command 를 정의한다.
- user-facing package 라면 release tooling 은 package metadata, installed version,
  upgrade path, clean handoff state 를 검증해야 한다.

### INF-FILL-OBS - Observability And Incident Response

- logs, metrics, traces, domain counters 는 무엇이 실패했는지, 누가 영향받는지,
  data 가 안전한지, operator next action 이 무엇인지 답해야 한다.
- alert 는 severity, threshold, owner, runbook, noise policy 를 가진다.
- incident response 는 mitigation, communication, escalation, recovery validation,
  retro/postmortem hook 을 포함한다.

### INF-FILL-DATA - Backup, Migration, And Recovery

- restore 를 테스트하기 전까지 backup 은 완료가 아니다. production data 가 scope 이면
  restore target, frequency, retention, RPO/RTO, last drill evidence 를 기록한다.
- migration/backfill 은 dry-run, snapshot 또는 backup, idempotent rerun,
  rollback path, audit trail 이 필요하다.
- long-running job 은 resume/retry policy 와 interrupted-run cleanup 을 가져야 한다.

### INF-FILL-COST - Capacity And Cost

- capacity review 는 traffic/load shape, concurrency, bottleneck hypothesis,
  limits, safety margin 에서 시작한다.
- cost review 는 budget owner, cost units, tag strategy, expected scaling driver,
  alert threshold 를 가진다.
- Kubernetes, service mesh, complex IaC 는 runtime ownership 과 repeatability 요구가
  증명될 때 활성화한다.

## INF-REVIEW - Review Questions

- deployed artifact 는 무엇이며 source 와 trace 되는가?
- release 가 부분 실패해도 rollback/stop 을 안전하게 할 수 있는가?
- secret 은 어디 저장되고 어떻게 rotate 되는가?
- operator 가 logs/metrics/alerts 만 보고 상황을 이해할 수 있는가?
- 어떤 cost/capacity assumption 이 가장 먼저 깨질 수 있는가?

## INF-EVIDENCE - Suggested Evidence

- commit/tag 와 연결된 CI/release command output.
- installed-version, upgrade, rollback, package-manager smoke result.
- secret value 없는 config/secrets matrix.
- health check, alert, runbook note.
- data scope 일 때 backup/restore 또는 migration dry-run evidence.

## INF-GAP - Deepening Slots

- INF-GAP-001: MVP-to-production infra ladder.
- INF-GAP-002: Cloud resource review by AWS service.
- INF-GAP-003: Secrets and config drift playbook.
- INF-GAP-004: CI/CD and release artifact checklist.
- INF-GAP-005: Observability and alerting rubric.
- INF-GAP-006: Backup/restore and DR drill template.
- INF-GAP-007: Cost tagging and budget governance.
- INF-GAP-008: Cross-platform install/upgrade smoke matrix.
