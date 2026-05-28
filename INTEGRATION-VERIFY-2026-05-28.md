---
doc_id: solon-integration-verify-2026-05-28
title: "Solon 실전 통합 검증 — 2026-05-28 (0.7.0)"
visibility: oss-public
doc_type: integration-verification-report
language: ko
updated: 2026-05-28
summary: "실전 임시 프로젝트에 sfs init → 7-step → 0.7.0 surface 검증한 결과. 6본부 council 구조와 0.7.0 4-feature 모두 살아 있고, agent-build lens 자동 라우팅 1개만 outrank 회귀."
load_when: "Read when reviewing whether the 0.7.0 features actually work in practice, before planning 0.7.1."
---

# Solon 실전 통합 검증 — 2026-05-28

- **대상**: VERSION 0.7.0 직후 시점
- **방법**: sandbox 안 `/tmp/solon-flow-e2e` 임시 git repo 에 `sfs init` →
  `sfs start` → `sfs brainstorm` → `sfs plan` 진행 + 각 단계 산출물 검사 +
  0.7.0 신규 surface 4개 실제 호출
- **결과 요약**: 12 검증 항목 중 **11 PASS**, **1 회귀** (agent-build lens
  자동 라우팅이 더 넓은 substring 매칭에 outrank 됨 — explicit 호출은
  작동). 6본부 council 구조와 0.7.0 신규 surface 모두 실 동작 확인.

## 0. 한 줄 결론

**0.7.0 까지의 핵심 기능은 실 호출/실 파일 단위에서 살아 있음.** 다음
0.7.1 patch 에서 1건 회귀 (agent-build auto-routing) 와 2건 minor 정합성
정리만 처리하면 됨.

## 1. 검증 결과 (12 항목)

| # | 항목 | 결과 | 비고 |
| --- | --- | --- | --- |
| 1 | `sfs init --layout thin --yes` 성공 | ✅ | SFS.md / CLAUDE.md / AGENTS.md / GEMINI.md / .sfs-local/ 생성 |
| 2 | `<PROJECT-NAME>` substitution (0.6.142 fix) | ✅ | divisions.yaml `project: "solon-flow-e2e"` 로 치환됨 |
| 3 | `sfs start` → sprint workspace 생성 | ✅ | `.sfs-local/sprints/2026-W22-sprint-1/` + `docs/solon/<slug>/<yyyyMMdd>/` |
| 4 | `sfs brainstorm` → brainstorm.md scaffold | ✅ | 6본부 4-line lens hint 포함 |
| 5 | `sfs plan` → plan.md scaffold | ✅ | §7 / §7.1 / §8 council ledger 3개 테이블 모두 포함 |
| 6 | routed context `sfs context cat plan` 가 council 룰 명시 | ✅ | "Empty six-division ceremony 는 PASS 아님" 룰 노출 |
| 7 | routed `policies/enterprise-plan-council-pack` 로드 가능 | ✅ | `sfs context cat policies/enterprise-plan-council-pack` 동작 |
| 8 | 0.6.138 enhancement (asset_candidate + domain-knowledge-assets) | ✅ | plan.md §7.1 / §8 에 컬럼 있고, `test-domain-knowledge-assets` 통과 |
| 9 | **0.7.0-A** MCP server — FastMCP("solon") 인스턴스 + 12 tool 등록 | ✅ | `mcp` 1.27.1 설치 후 `asyncio.run(s.mcp.list_tools())` 12 반환 |
| 10 | **0.7.0-A** MCP tool 의 verbatim forward | ✅ | `sfs_status` 결과가 CLI `sfs status` 와 1바이트 단위 동일 |
| 11 | **0.7.0-B** permission preset YAML 파싱 + 로드-베어링 룰 | ✅ | pyyaml 로 파싱, `bash:git push*` / `bash:rm -rf *` / `mainline_first: true` / `require_gate_6: true` 모두 존재 |
| 12 | **0.7.0-C** agent-build lens — explicit | ✅ | `sfs review --lens agent-build` → review.md 에 `review_lens: agent-build (..., explicit)` 기록 |
| 12-b | **0.7.0-C** agent-build lens — auto-routing | ⚠️ **회귀** | infer_review_lens case-chain 안 broader-substring 패턴 (`*"ui"*` 등) 이 agent-build 보다 앞에 있어 outrank. §3 참고 |
| 13 | **0.7.0-D** scaffold simulation — 6 smoke pytest 전수 통과 | ✅ | `pytest tests/test_agent_smoke.py -v` → 6/6 PASS |

## 2. 6본부 council 의 작동 메커니즘 (확인된 사실)

질문하셨던 "예전엔 필요한 시점에 활성화 → 이제 plan 단계 sub-agent 회의"
변화는 코드 수준에서 다음과 같이 구현돼 있음:

1. **divisions.yaml** 의 `activation_state` 는 *깊이* (active/abstract) 만
   제어, 참여 여부는 제어하지 않는다. `policies/division-subagent-council.md`
   첫 줄에 명시: "6본부 sub-agent council 은 항상 개입한다."
2. **plan.md 템플릿** 이 §7 (Division Sub-agent Ledger 6행), §7.1 (Domain
   Asset Promotion Ledger), §8 (Enterprise Plan Council 6행 + risk_flag)
   세 개 테이블을 자동 scaffold. LLM 이 이걸 비워두면 §12 리뷰 체크리스트가
   실패 신호를 낸다.
3. **routed policy** (`enterprise-plan-council-pack.md` / `.ko.md`) 가
   "Empty six-division ceremony is not PASS; each row needs a finding,
   evidence, asset_candidate, waiver, or concrete N/A reason." 룰을 강제.
4. **0.6.138 enhancement** 가 council ledger 에 `asset_candidate` 컬럼을
   추가하고, 별도의 `domain-knowledge-assets.md` 정책을 도입해 "회의 결과
   = 재사용 가능한 도메인 자산 후보" 까지 끌어올림.

즉 6본부 "회의" 는 LLM 의 prompt-driven 행동이지 bash subprocess fork 가
아님. bash adapter 가 자리만 깔고, LLM 이 6 행을 채우면 review 가 통과,
비우면 partial. 이 설계는 kernel.md "bash adapter SSoT" 원칙과 일관됨.

contract test 3개 (`test-domain-knowledge-assets.sh`,
`test-enterprise-agent-team-knowledge-packs.sh`,
`test-division-subagent-continuation-guard.sh`) 가 정책 doc / 템플릿 /
load_when 트리거의 정합성을 정적으로 잠가둠 — 전부 PASS.

## 3. 발견된 회귀 — agent-build lens 자동 라우팅 (§1 항목 12-b)

### 증상
plan.md / brainstorm.md 에 "Claude Agent SDK", "MCP server", "Sub-agent
isolation" 같은 명백한 agent-build 키워드가 들어가도 `sfs review --lens
auto` 가 `agent-build` 가 아닌 다른 lens (`design`, `ops`) 를 잡는다.

### 원인
`infer_review_lens` 의 `case "$lowered" in ... esac` 분기 순서가:

```
source-docs → security → performance → api-contract → simplify →
process-lean → release → ops → design → ddd-tdd → taxonomy → strategy →
management-admin → qa → docs → agent-build
```

여기서 `design` 분기는 `*"ui"*` 같은 너무 넓은 substring 패턴을 포함한다.
plan/brainstorm 안 "**bui**ld" 단어가 `*"ui"*` 에 매칭되면서 agent-build
가 도달도 못 하고 design 으로 라우팅된다.

비슷하게 `*"ops"*` 패턴도 "develop**ops**", "**ops**ervable" 같은 substring
에 잡힐 위험이 있음 (실제로 이번 검증 중 한 번 ops 로 잡힘).

### 영향
- explicit `--lens agent-build` 는 정상 작동. 사용자가 lens 를 명시하면 됨.
- 자동 라우팅이 0.7.0 의 의도된 UX 였는데 실질적으로 작동 안 함. 이 lens
  의 진짜 라우팅은 path-signal (`mcp-server/`, `claude-agent-sdk-zero/`)
  branch 가 살아 있음 — 그쪽은 우선순위 더 위라 통과.

### 권장 fix (0.7.1)
1. `infer_review_lens` 의 `agent-build` text branch 를 case chain 의
   **맨 앞** 또는 적어도 `design`/`ops` 보다 앞으로 이동. agent-build
   키워드는 매우 specific 하니까 안전.
2. 동시에 `design` 의 `*"ui"*` 와 `ops` 의 `*"ops"*` 패턴을 word-boundary
   인지 (`*" ui "*|*"ui:"*|*"/ui/"*`) 로 좁히는 것도 검토 — 이건 별도 fix,
   pre-existing 이슈.
3. test-agent-build-review-lens 에 "build" 단어가 포함된 plan text 로
   auto-routing 검증 추가.

## 4. 기타 minor 정합성 발견

### 4.1 review.md append vs overwrite
`sfs review --prompt-only` 를 같은 sprint 에 두 번 호출하면 review.md 가
append 됨. 일반 동작이지만 sandbox 검증 시 헷갈리는 원인이 됨. 문제는
아니지만 doc 에 명시 가치 있음.

### 4.2 `sfs context list` 미지원
`sfs context list` 가 "unknown context subcommand" 로 실패. 현재 API 는
`sfs context cat <key>` 와 `sfs context path <key>` 만. routed module 의
색인을 보려면 `_INDEX.md` 직접 읽어야 함. 0.7.x 어딘가에 추가하면 사용자
편의 + agent-build lens 같은 신규 정책 doc 의 discoverability ↑.

### 4.3 MCP server 의 `solon-mcp` 콘솔 스크립트는 PyPI publish 시 노출
현재는 `pip install -e mcp-server/` 가 필요. PyPI 에 `solon-mcp` 가 publish
되기 전까지 `pipx install solon-mcp` 안내문은 미래형. README 에 이 사실을
명시하거나, 0.7.1 에서 source-clone 안내문을 더 굵게.

## 5. 0.7.1 권장 작업

1. **agent-build lens auto-routing fix** (§3) — 한 줄 이동 + test 보강.
2. **infer_review_lens 의 broad-substring 패턴 word-boundary 화** — 별도
   sprint 로 가도 됨. design 의 `*"ui"*`, ops 의 `*"ops"*` 가 substring
   매칭이라 false positive 발생. pre-existing 이슈지만 §3 fix 와 자연스러운
   pair.
3. **`sfs context list` 신설** — _INDEX.md 의 슬러그 목록 출력. 사용자 + LLM
   양쪽 discoverability ↑.
4. **MCP server install 안내 명확화** — README 에 "현재는 source clone 만
   가능, PyPI publish 는 0.7.x 후속" 명시.

이 4개는 모두 additive — flow 갈아엎기 0건. CLAUDE.md §"수정 원칙" 의
mainline-first / additive 정신 그대로.

## 6. 검증 방법 (재현 절차)

```bash
TEST_DIR=/tmp/solon-flow-e2e
rm -rf "$TEST_DIR" && mkdir -p "$TEST_DIR" && cd "$TEST_DIR"
git init -q
git config user.email "test@solon.invalid"
git config user.name "Solon Flow Test"
printf '# Test\n' > README.md
git add . && git commit -qm "init"

# Init the Solon flow into this empty repo.
SFS_DIST_DIR=/path/to/solon-product
bash $SFS_DIST_DIR/bin/sfs init --layout thin --yes

# Run the 7-step.
bash $SFS_DIST_DIR/bin/sfs start "verify-flow"
bash $SFS_DIST_DIR/bin/sfs brainstorm "verify the 0.7.0 surface"
bash $SFS_DIST_DIR/bin/sfs plan

# Inspect the council scaffold.
cat .sfs-local/sprints/*/plan.md   # check §7 / §7.1 / §8 tables exist

# Verify the routed council policy is reachable.
bash $SFS_DIST_DIR/bin/sfs context cat policies/enterprise-plan-council-pack

# 0.7.0-A: MCP server.
pip install mcp pyyaml
python3 -c "
import asyncio
import sys
sys.path.insert(0, '$SFS_DIST_DIR/mcp-server')
import solon_mcp_server as s
print(s.mcp.name, len(asyncio.run(s.mcp.list_tools())))
"

# 0.7.0-D: scaffold smoke pytest.
cp -r $SFS_DIST_DIR/templates/claude-agent-sdk-zero /tmp/scaffold
cd /tmp/scaffold
sed -i 's|<PROJECT-NAME>|test-agent|g; s|<DOMAIN>|test|g' *.py *.toml *.md *.yaml tests/*.py
python3 -m pytest tests/test_agent_smoke.py -v
```

전체 재현 시간: ~30초.

## 부록 — 회의 결과 형태 예시

LLM 이 plan.md §8 (Enterprise Plan Council) 를 채워야 할 모양 (현재
빈 채로 scaffold 되며, LLM 이 fillin 책임):

```
| division | risk flag | finding | AC/files/evidence | asset_candidate | waiver/N/A |
|---|---|---|---|---|---|
| strategy-pm | none | "MCP server 출시는 0.7.0 minor bump 의 첫 host channel 확장" | AC1 / mcp-server/README.md | "MCP server 운영 가이드 → 도메인 자산화 후보" | - |
| dev | api-contract | "12 tool 의 schema 가 LLM 가독성에 적합한지" | AC2 / mcp-server/solon_mcp_server.py | "FastMCP tool decorator 패턴 → 사내 표준 후보" | - |
| QA | none | "verbatim forward 회귀 테스트가 정적" | AC2 / tests/test-mcp-server-contract.sh | "MCP server e2e 테스트 → 후속 자산" | - |
| design | N/A | "user-facing UI 변경 없음" | - | - | "API 채널, UX surface 아님" |
| infra | security | "stdio 외부 노출 없음, $SOLON_MCP_SFS_PATH 검증 필요" | mcp-server/solon_mcp_server.py shutil.which | "MCP server 환경변수 안전 처리 → 자산" | - |
| taxonomy | none | "tool 이름 = sfs <cmd> 1:1 매핑 강제" | AC / 모든 sfs_* 함수 docstring | "MCP tool 명명 규칙 → 자산" | - |
```

위 같은 ledger 가 plan.md 에 채워지지 않으면 Gate 3 review 는 partial.
이 자기검증 loop 이 6본부 council 의 실제 작동 형태.
