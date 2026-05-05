---
id: sfs-policy-infra-knowledge-pack
summary: Infra/DevOps topic and proposition inventory for SFS division activation.
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

This file is a compact filled guidance pack for infra/DevOps work. Use it to
decide which deployment, secrets, observability, cloud, cost, and release
checks are active for a sprint, review, or release. Apply only the matching ids.

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

- Runtime config needs a source of truth, owner, allowed environments, default
  behavior, and drift detection path.
- Secrets must not live in repo, logs, screenshots, command history, or sample
  config. Document where they are stored, who can rotate them, and how a leaked
  secret is revoked.
- Environment parity should name what differs intentionally across local, dev,
  stage, and prod.

### INF-FILL-DEPLOY - CI/CD And Rollback

- Build once, deploy the same artifact. If the release process rebuilds per
  environment, record why and how equivalence is checked.
- Deployment strategy should define health check, readiness, drain, partial
  failure behavior, rollback trigger, and manual stop command.
- Release tooling must verify package metadata, installed version, upgrade
  path, and clean handoff state when packages are user-facing.

### INF-FILL-OBS - Observability And Incident Response

- Logs, metrics, traces, and domain counters should answer: what failed, who is
  affected, whether data is safe, and what operator action is next.
- Alerts need severity, threshold, owner, runbook, and noise policy.
- Incident response should include mitigation, communication, escalation,
  recovery validation, and retro/postmortem hook.

### INF-FILL-DATA - Backup, Migration, And Recovery

- Backup is incomplete until restore is tested. Record restore target,
  frequency, retention, RPO/RTO, and last drill evidence when production data
  is in scope.
- Migration/backfill work needs dry-run, snapshot or backup, idempotent rerun,
  rollback path, and audit trail.
- Long-running jobs need resume/retry policy and interrupted-run cleanup.

### INF-FILL-COST - Capacity And Cost

- Capacity review starts with traffic/load shape, concurrency, bottleneck
  hypothesis, limits, and safety margin.
- Cost review needs budget owner, cost units, tag strategy, expected scaling
  driver, and alert threshold.
- Do not activate Kubernetes, service mesh, or complex IaC until runtime
  ownership and repeatability needs justify the added system.

## INF-REVIEW - Review Questions

- What is the deployed artifact, and can it be traced to source?
- Can we roll back or stop safely if the release partially fails?
- Where are secrets stored and how are they rotated?
- Would an operator know what happened from logs/metrics/alerts?
- What cost or capacity assumption would break first?

## INF-EVIDENCE - Suggested Evidence

- CI/release command output tied to commit or tag.
- Installed-version, upgrade, rollback, or package-manager smoke result.
- Config/secrets matrix without secret values.
- Health check, alert, and runbook notes.
- Backup/restore or migration dry-run evidence when data is in scope.

## INF-GAP - Deepening Slots

- INF-GAP-001: MVP-to-production infra ladder.
- INF-GAP-002: Cloud resource review by AWS service.
- INF-GAP-003: Secrets and config drift playbook.
- INF-GAP-004: CI/CD and release artifact checklist.
- INF-GAP-005: Observability and alerting rubric.
- INF-GAP-006: Backup/restore and DR drill template.
- INF-GAP-007: Cost tagging and budget governance.
- INF-GAP-008: Cross-platform install/upgrade smoke matrix.
