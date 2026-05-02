---
id: sfs-policy-mutex
summary: Session locks prevent concurrent agents from editing the same Solon work unit.
load_when: ["mutex", "lock", "conflict", "owner", "domain_locks"]
---

# Mutex Policy

- If another owner holds a fresh lock, stop and ask the user before takeover.
- If the lock is stale, explain age and request takeover approval.
- Release lock on natural close.
- Never use destructive git or revert unrelated user changes to resolve a lock.
