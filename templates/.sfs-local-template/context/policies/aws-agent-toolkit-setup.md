---
id: sfs-policy-aws-agent-toolkit-setup
summary: Dev reference runbook for a human-controlled AWS Agent Toolkit setup with a named profile, AWS experience type, and region.
division: dev
load_when: [AWS Agent Toolkit, aws configure agent-toolkit, aws agent-toolkit, AWS MCP, AWS_MCP_PROXY_PROFILES, aws login, AWS CLI profile]
primary_source_url: https://raw.githubusercontent.com/aws/agent-toolkit-for-aws/refs/heads/main/setup-instructions/setup.md
supplemental_source_url: https://docs.aws.amazon.com/agent-toolkit/latest/userguide/aws-cli.html
retrieved: 2026-09-09
---

# AWS Agent Toolkit Setup Reference

## Grain

Dev-owned reference for safely following AWS's seven-step Agent Toolkit setup
flow without turning it into automatic credential setup.

## Scope

Use when a human wants to configure AWS Agent Toolkit for an AI coding tool.
This is a runbook and reference, not authorization to install AWS tools, log in
to AWS, create credentials, or request access keys. Do not put credentials, access keys, secret keys, tokens, or identity output in docs, prompts, logs, or MCP configuration.

Primary setup source: [AWS Agent Toolkit setup instructions](https://raw.githubusercontent.com/aws/agent-toolkit-for-aws/refs/heads/main/setup-instructions/setup.md), retrieved 2026-09-09. Supplemental product documentation: [AWS CLI — Agent Toolkit for AWS](https://docs.aws.amazon.com/agent-toolkit/latest/userguide/aws-cli.html). The seven-step flow below is a compact operational reference, not a copy of either source.

## Usage

Before any execution, collect and confirm all three inputs:

1. A named AWS CLI profile (`<profile_name>`), never an assumed `default` profile.
2. AWS experience type: **new AWS experience** (use the account's **project**
   terminology) or **advanced AWS experience**.
3. The account's default region; for the new experience, this is the region in
   which its project was created.

Do not ask for credentials, access keys, or secret keys. Browser sign-in is the
authentication path, and the human must be told its session lifetime before
sign-in starts: the issued credentials stay valid for **12 hours**, and they can
be renewed for **90 days** before another browser sign-in is required. State
this up front so an expiring session is read as normal renewal rather than a
broken setup. The only prerequisite probes are the platform's
`curl`/PowerShell availability, `uv`, network reachability to
`https://awscli.amazonaws.com`, and AWS CLI v2.35.0 or newer. Do not add Node.js,
Python, or other runtime prerequisites. Treat `aws sts
get-caller-identity --profile <profile_name>` as the access verification; do
not record its returned identity fields in a durable log.

## Seven-Step Flow

1. Detect whether the host is macOS, Linux, or Windows.
2. Check that AWS CLI v2.35.0 or newer is available. If it is absent or older,
   direct the human to the official AWS CLI installation guidance; this reference
   does not install or upgrade it.
3. Set the selected profile's default region, then run `aws login` for that
   named profile. **Human-interaction pause:** the browser sign-in belongs to the human; stop until it completes or is cancelled.
4. Verify the named profile with `aws sts get-caller-identity --profile
   <profile_name>`. Confirm only success/failure; never persist returned account or identity values.
5. Run the Agent Toolkit wizard with the named profile. **Human-interaction
   pause:** the toolkit wizard needs human review/completion. Its service region
   is fixed: `aws configure agent-toolkit --yes --region us-east-1 --profile
   <profile_name>` always uses `us-east-1`, even when the default region differs.
6. Verify the toolkit catalog with `aws agent-toolkit list-available-skills
   --region us-east-1 --profile <profile_name>`; this command also always uses
   `us-east-1`.
7. Retrieve the rules matching the confirmed AWS experience type and add them
   to each detected agent's rules file without replacing project instructions.
   Append a new block between `<!-- BEGIN AWS Agent Toolkit rules -->` and
   `<!-- END AWS Agent Toolkit rules -->`; if that marker pair already exists,
   replace only its contents. Project instructions take precedence. If an
   unfamiliar rules format makes marker-based editing unsafe, stop for a human
   decision.

## AWS MCP Profile Configuration

For each MCP configuration that the wizard updates, preserve every existing
server entry and generated setting. In the `aws-mcp` entry, add or merge only:

```json
"env": {
  "AWS_MCP_PROXY_PROFILES": "<profile_name>"
}
```

Use `AWS_MCP_PROXY_PROFILES`, never `AWS_PROFILE`; the former supports later
cross-account profile switching. For multiple profiles, keep a space-separated
list and restart the AI tool after the configuration changes. If an `aws-mcp`
entry already exists or an agent uses a different MCP schema, pause for the
human instead of overwriting or removing settings.

## Gotchas

- The toolkit wizard and catalog verification use `us-east-1`; they do not
  inherit the account's chosen default region.
- Browser login and the toolkit wizard are explicit human-interaction pauses.
- Keep both existing agent instructions and other MCP servers intact through
  marker-based append/replace or a human decision.
- Use relative, detected configuration locations in public documentation; never
  publish a private absolute path.

## Cross-Ref

- Parent dev/DevOps activation: `policies/backend-knowledge-pack.md`.
- Cloud, secrets, and IAM review: `policies/infra-knowledge-pack.md`.
- Credential boundaries: `policies/credential-hygiene.md`.
- Routed policy discovery: `context/_INDEX.md`.
