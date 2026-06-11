---
id: sfs-policy-credential-hygiene
summary: Agent-visible surfaces carry credential placeholders only; real keys live in a store, attach at the boundary with per-consumer scope, and rotate in one place.
load_when: ["api key", "API key", "secret", "credential", "token", "env var", ".env", "rotate key", "key rotation", "vault", "keychain", "unattended runner", "scheduled run auth", "mcp server auth"]
---

# Credential Hygiene

How an operator hands credentials to agents, unattended runners, MCP servers,
and CLI tools without ever letting a real key live where an agent (or a repo)
can read it. Source pattern: vault-style environment variables for managed
scheduled agents ("New in Claude Managed Agents", 2026-06-09, by-reference) —
the platform feature itself is held out; the portable principle is adopted:
**the agent sees a placeholder; the real key attaches at the boundary.**

This is the secret-specialized form of the templates rule "placeholders only,
never fixed values" (`docs/maintenance/release-policy.md`): a real credential
is the most dangerous fixed value a template or context file can carry.

## PLACEHOLDER_ONLY_SURFACES

A real credential never appears in any agent-visible or durable surface:

- prompts, scheduled-task prompt files, and handoff documents;
- agent entry docs (`CLAUDE.md` and equivalents), routed context, templates;
- logs, telemetry, screenshots, review capsules, evidence captures
  (enforced jointly with `agentic-security-logging-pack.md` Secrets/PII);
- committed files of any kind, including `.env` checked into a repo.

These surfaces carry **indirection only**: an env-var name, a store reference,
or an explicit placeholder (`<YOUR_API_KEY>`). If a grep for a live key pattern
over these surfaces ever matches, that is a finding, not a style issue.

## BOUNDARY_ATTACHMENT

The real key lives in exactly one store the operator controls (OS keychain,
secret manager, or an env file outside the repo, chmod-restricted). Processes
receive it by indirection at spawn time — the launchd/cron unit, shell profile,
or runner wrapper exports the env var; the agent process reads the name, never
the file the value came from.

Scope each credential to its consumer: a key is named for the tool/domain it
serves (`SERVICE_X_API_KEY`) and is exported only to the process that calls
service X. A credential for one service never rides a request — or a prompt —
bound for another. Broad "one key for everything in the environment" grants are
the credential equivalent of full-history forwarding
(`runtime-token-firewall.md`) and fail review the same way.

## ROTATION_SINGLE_POINT

Rotation must be a one-place edit: update the store, and the next call picks up
the new value. If rotating a key requires grep-and-replace across files, the
key was stored in more than one place — treat the extra copies as the incident
and collapse them back to the store. After any suspected exposure (a key seen
in a log, a pasted transcript, a committed file), rotate first, clean up
second.

## UNATTENDED_AND_SCHEDULED_RUNS

Unattended runners (launchd/cron jobs, headless code sessions, MCP servers) get
credentials via environment at spawn, never embedded in the skill/prompt file
that defines the job — the prompt file is a durable agent-visible surface
(see `work-delegation-and-startup.md` SCHEDULED_RUN_CONTRACT). Runner logs and
reports obey the same redaction rules as any production log. An unattended run
that would need a *new* credential mid-flight stops and surfaces instead of
improvising one (human boundary, `harness-autonomy.md`).

## Cross-references

- Secrets/PII in logs, telemetry, and review prompts:
  `agentic-security-logging-pack.md` (Required Checks; SEC-AIERA-002 secure-by-
  default routes keys to env/keystore, never inline).
- Scheduled/unattended run operating contract:
  `work-delegation-and-startup.md` (LONG_RUNNING_AND_SCHEDULED axis).
- Templates placeholder discipline: `docs/maintenance/release-policy.md`.
- External source cited by pointer, vendor feature held out:
  `source-pointer-citation.md`.
