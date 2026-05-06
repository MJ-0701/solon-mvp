# RUN — Codex Cross-Review Bake-off (0.6.1 검증판)

> Claude Code 가 본 파일을 읽고 0~4 단계를 순서대로 실행한다.
> 모든 산출물은 `bench/codex-cross-review/results/` 아래에.

## 비교 매트릭스

| Run | Path | 호출 |
|---|---|---|
| A | 공식 플러그인 단독 | `/codex:review` (Claude Code 안에서) |
| B | Solon → Codex CLI 직결 | `/sfs review --executor codex` |
| C | Solon → Claude 플러그인 → Codex | `/sfs review --executor codex-plugin` (`SFS_REVIEW_CODEX_PLUGIN_CMD` 필요) |

A/B 만 돌려도 원안 검증 가능. C 는 옵션 (오케스트레이션 비용 분리).
사용자가 "B 만" 또는 "A+B+C" 를 사전에 지시하지 않았으면 **A+B 만** 돌리고, 끝에 C 도 돌릴지 묻기.

## 0) Baseline 캡처

```bash
mkdir -p bench/codex-cross-review/results
ls -la ~/.codex/sessions/ > bench/codex-cross-review/results/codex-sessions.before.txt
date -Iseconds > bench/codex-cross-review/results/run.start
```

체크:
- `codex --version` 정상 출력 (Codex CLI 설치/로그인). 미로그인이면 사용자에게 `codex login` 직접 실행 요청.
- `/codex:setup` healthy (공식 플러그인 설치).
- 현재 cwd 에서 `bash bin/sfs version` 이 `sfs 0.6.1` 또는 그 이상 출력 (Solon 설치 + bin PATH 확인).

## 1) Run A — 공식 `/codex:review`

`/codex:review` 는 코드 review 디폴트지만, plan-review 용도로 일반 prompt 를 넘기면 됨.

1-1. Claude Code 에서:

```
/codex:review

다음 plan artifact 를 artifact-acceptance review 관점에서 review 해줘 (코드 review 아님).
plan 자체의 완전성 / 일관성 / 위험 식별 / 측정가능성 / Release Readiness 를 본다.

=== plan.md ===
[bench/codex-cross-review/scenario/plan.md 내용 전체]

=== sprint-context.md ===
[bench/codex-cross-review/scenario/sprint-context.md 내용 전체]
```

1-2. Codex 가 반환한 review 출력 전체를 `results/A.review.md` 로 저장.

1-3. Codex session 캡처:
```bash
ls -la ~/.codex/sessions/ > bench/codex-cross-review/results/codex-sessions.after-A.txt
diff bench/codex-cross-review/results/codex-sessions.before.txt \
     bench/codex-cross-review/results/codex-sessions.after-A.txt \
     > bench/codex-cross-review/results/A.codex-session-diff.txt
```
diff 의 신규 session 파일을 `results/A.codex-session.json` 으로 cp.
session JSON 의 `usage.input_tokens` / `usage.output_tokens` 합산 → `results/A.codex-tokens.txt` (형식: `input=<n>\noutput=<n>\ntotal=<n>`).

1-4. Claude 측 토큰: 직전 turn 의 usage (input / output / cache_read / cache_creation) 를
`results/A.claude-tokens.txt` 로 기록.

## 2) Run B — Solon `/sfs review --executor codex`

⚠ `/sfs review` 는 **sprint-scoped**. 임의 파일을 `--target` 으로 못 넘김.
따라서 본 step 은 throwaway 샌드박스 sprint 를 한 번 띄워서 plan.md 를 Gate 3 artifact 로 등록하고 거기서 review 를 호출한다.

### 2-A. Throwaway 샌드박스 sprint 셋업

```bash
mkdir -p bench/codex-cross-review/sandbox
cp bench/codex-cross-review/scenario/plan.md  bench/codex-cross-review/sandbox/plan.md
cp bench/codex-cross-review/scenario/sprint-context.md bench/codex-cross-review/sandbox/sprint-context.md
cd bench/codex-cross-review/sandbox

# Solon 0.6.1 의 install/start 시그니처에 맞춰 (실제 명령은 sfs --help 로 확인):
#   1) .sfs-local 초기화: sfs install 또는 init
#   2) 새 sprint 시작: sfs start
#   3) plan.md 를 Gate 3 artifact 로 등록 (sprint-templates/review.md 흐름 참고)
```

(샌드박스 셋업이 0.6.1 의 실제 install/start 옵션과 정확히 매칭되는지는 Claude Code 가 `bash ../../../bin/sfs --help` 로 확인 후 진행. 막히면 사용자에게 물어보고 진행.)

### 2-B. Review 호출

```
/sfs review --gate 3 --lens artifact --executor codex
```

(주의: `--gate 3` = Plan review. 기존 RUN.md 초안의 `--gate 6` 은 Review/Release 게이트라 plan review 와 lens 가 다름.)

### 2-C. 결과 캡처

2-C-1. review 본문 → `results/B.review.md` (Solon 이 자동 기록한 review.md 를 cp).

2-C-2. Codex session diff:
```bash
ls -la ~/.codex/sessions/ > bench/codex-cross-review/results/codex-sessions.after-B.txt
diff bench/codex-cross-review/results/codex-sessions.after-A.txt \
     bench/codex-cross-review/results/codex-sessions.after-B.txt \
     > bench/codex-cross-review/results/B.codex-session-diff.txt
```
신규 session JSON → `results/B.codex-session.json`. 토큰 → `results/B.codex-tokens.txt`.

2-C-3. Claude 측 토큰 → `results/B.claude-tokens.txt`.
(B 는 `codex exec` shell 직결이므로 Claude turn 비용은 `/sfs review` 호출/결과 받기만의 작은 turn 1개.)

## 2'). Run C — Solon `/sfs review --executor codex-plugin` (옵션)

A+B 끝나고 사용자가 "C 도" 라고 하면 실행. 같은 샌드박스 sprint 그대로 활용.

```bash
export SFS_REVIEW_CODEX_PLUGIN_CMD='...'   # codex-plugin-cc 의 shell-callable 진입점
```

```
/sfs review --gate 3 --lens artifact --executor codex-plugin --print-prompt
# 또는 SFS_REVIEW_CODEX_PLUGIN_CMD 가 세팅되어 있으면 그대로:
/sfs review --gate 3 --lens artifact --executor codex-plugin
```

캡처 규칙은 Run B 와 동일. session diff base 는 after-B → after-C.

`SFS_REVIEW_CODEX_PLUGIN_CMD` 가 막히면 `--print-prompt` 로 prompt 만 추출 → 사용자가 `/codex:rescue` / `/codex:review` 에 직접 붙여넣는 fallback 도 OK. 그 경우 `results/C.note.md` 에 fallback 사실 기록.

## 3) 비교 리포트

이 시점에 처음으로 `bench/codex-cross-review/expected-issues.md` 를 연다.
(Run A/B/C 출력이 이 답안지에 영향받지 않게 절대 그 전엔 X.)

`results/compare.md` 작성:

```markdown
# Compare — Codex Cross-Review Bake-off (0.6.1)

## 메타
- 실행 일시: <run.start ~ run.end>
- plan.md size: <line / char>
- 실행한 Run: A, B (, C)

## 토큰 사용량

| Layer | Run A | Run B | Run C | Δ B-A | Δ C-A |
|---|---|---|---|---|---|
| Codex input | | | | | |
| Codex output | | | | | |
| Codex 합계 | | | | | |
| Claude input | | | | | |
| Claude output | | | | | |
| Claude 합계 | | | | | |
| **Total** | | | | | |

## 지연

| | Run A | Run B | Run C |
|---|---|---|---|
| Wall clock | | | |

## 이슈 발견 (expected-issues.md 14 plant 기준)

| Run | S 잡음 (5) | A 잡음 (5) | B 잡음 (4) | False positive | 가중치 점수 |
|---|---|---|---|---|---|
| A | | | | | |
| B | | | | | |
| C | | | | | |

가중치: S=3 / A=2 / B=1, 부분 발견 0.5 곱.

### A 가 잡고 B 가 놓친 것
- ...

### B 가 잡고 A 가 놓친 것
- ...

### 양쪽 다 놓친 것
- ...

## 정성 메모

- Review 의 **구조** 차이 (요약 / 항목별 / 우선순위 부여)
- Review 의 **톤** 차이 (지시형 / 진단형 / adversarial)
- 어느 path 가 sprint 맥락 (1주 / dogfooding / 사이드) 을 더 잘 활용
- 어느 path 가 Release Readiness 6 항목 (secret/auth/data/monitoring/rollback/cost) 을 native 로 점검
- Solon path 의 wrapper overhead (Claude 측 토큰 ↑) vs 발견율 향상 trade-off
```

## 4) 종료

```bash
date -Iseconds > bench/codex-cross-review/results/run.end
```

채팅에 `results/compare.md` 의 토큰 표 + 이슈 발견 표 + 정성 메모 한 단락만 출력. 나머지는 파일 링크.

샌드박스 정리:
```bash
# 결과 검토 끝나면:
# rm -rf bench/codex-cross-review/sandbox/.sfs-local
# (plan.md / sprint-context.md 사본은 보관해도 무방)
```
