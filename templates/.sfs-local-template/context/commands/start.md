---
id: sfs-command-start
summary: SFS start/status-class commands keep adapter output verbatim, then may add compact state and Next.
load_when: ["sfs start", "start", "new sprint", "status-class", "bash-first"]
---

# Start / Bash-First Command Context

Applies to `sfs start` and similar bash-first commands (`status`, `guide`,
`auth`, `version`, `commit`, `loop`) unless a more specific routed module
exists.

Rules:
- Run the adapter first and show stdout/stderr verbatim.
- "Bash-first" means no AI-side artifact refinement. It does not forbid a
  short user-facing Solon recap/status after the verbatim adapter output.
- For `start`, adapter stdout should include exactly one `next:` line. If that
  line is already enough, do not add a second multi-step plan.
- Shared report/retro/handoff docs should be domain-first when the product
  domain is known:
  `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/...`.
  For example, order work should look like
  `docs/solon/order/order-items/quantity-update/<yyyyMMdd>/...`, not a flat
  folder such as `order-items-quantity-update`.
- Users should not have to type domain flags. Run `sfs start "<goal>"` with the
  natural goal; the adapter performs deterministic high-confidence inference,
  and the agent should silently add/override labels only when it has stronger
  project context. `--domain`, `--subdomain`, and `--feature` are override
  levers, not the normal user-facing workflow.
- If the domain is genuinely unclear, allow the legacy `--workspace
  <english-name>` fallback. Do not let the workspace collapse to a sprint id
  such as `2026-W19-sprint-5`.
- Do not create or imply step-doc creation for `start`. `start` makes the
  sprint pointer only; `brainstorm`, `plan`, `implement`, `review`, and `retro`
  create their own workbench doc when that phase is actually needed.
- Do not create or imply durable `report.md` creation for `start`. The durable
  sprint `report.md` lifecycle belongs to `report`, `retro`, or `tidy`.
- After `start`, infer `Next` from sprint mode:
  - fresh discovery/planning goal -> show the depth selector and let the user
    pick `simple`, default `normal`, or `hard`:
    `sfs brainstorm --simple ...`, `sfs brainstorm ...`,
    `sfs brainstorm --hard ...` (recommend normal unless the goal is tiny or
    strategically ambiguous).
  - inherited implementation sprint -> first implementation slice, then later
    `sfs review --gate 6` (Gate 6 Review)
  - unclear mode -> ask 1 blocking question or point to `sfs status`
- A compact chat Solon report is allowed when it adds state or next action, but
  it must not paraphrase or contradict adapter stdout.
