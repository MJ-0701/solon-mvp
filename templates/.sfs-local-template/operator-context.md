---
doc_id: sfs-operator-context
title: "Operator context — who is running this project"
doc_type: note
status: template
tags:
  - operator-context
  - onboarding
  - user-layer
---

# Operator context

The **user layer** of the three-way context split (see
`policies/user-context-separation.md`): who the operator is and how they want to
work — kept separate from the agent's identity (`personas/`, the *soul* layer)
and from the project itself (`llm-wiki/project-context.md`).

Fill the placeholders once at onboarding and revise as preferences change. Keep
it short and human-owned: it personalizes how the agent works *for you*, it is
not a transcript or a second project doc. Every field below is a placeholder —
do not ship fixed values in the template.

## Who

- **Role / hat**: <OPERATOR-ROLE>
- **Team size**: <OPERATOR-TEAM-SIZE>
- **Domain expertise**: <OPERATOR-EXPERTISE>
- **Technical depth**: <OPERATOR-TECH-DEPTH>
- **Working language**: <OPERATOR-LANGUAGE>

## How I want the agent to work

- **Autonomy level**: <OPERATOR-AUTONOMY>
- **Ask-vs-act bias**: <OPERATOR-ASK-BIAS>
- **Explanation depth**: <OPERATOR-EXPLANATION-DEPTH>
- **Risk tolerance**: <OPERATOR-RISK-TOLERANCE>

## Runtimes, tools, reporting

- **Primary runtime(s)**: <OPERATOR-RUNTIMES>
- **Connected tools / MCP**: <OPERATOR-TOOLS>
- **Reporting channel**: <OPERATOR-REPORT-CHANNEL>
- **Schedule / availability**: <OPERATOR-SCHEDULE>
- **External knowledge wiki**: <EXTERNAL-WIKI-NAME> → <LOCAL-CHECKOUT-PATH> (namespace, advisory; see `policies/source-pointer-citation.md` + `policies/obsidian-llm-wiki.md`)

## Standing preferences and boundaries

- **Always**: <OPERATOR-ALWAYS>
- **Never**: <OPERATOR-NEVER>
- **Decision authority kept by operator**: <OPERATOR-DECISIONS>
