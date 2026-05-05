# Solon Cross-Review 의 본질

**Language**: 한국어 / [English](../en/cross-review-principle.md)

> Solon 의 sprint flow 는 CTO Generator ↔ CPO Evaluator 라는 cross-review
> 구조를 디폴트로 박아둔다. 이 문서는 "왜" 그렇게 박아두는지를 설명한다.
> 추상론이 아니라 0.6.1 → 0.6.2 hotfix 의 실제 발견 경로를 case study 로
> 깐다.

## 한 줄 요약

Cross-review 의 본질은 **"여러 모델의 의견"** 이 아니라 **"여러 evaluation
surface 의 다양성"** 이다. surface 가 단일하면 모델을 셋 붙여도 같은 사각
지대를 셋 다 통과시킨다.

## Case study — 0.6.1 의 `sfs upgrade` 크래시

### 사실

- 0.6.1 release pre-verification 통과: `tests/run-all.sh` **30/30**,
  `sfs doctor` **7/0/0**, placeholder scan / mirror check / `git diff --check`
  모두 깨끗.
- Build / review pipeline 에 Codex / Claude / Gemini 가 다 한 번씩 닿았고
  셋 다 release artifact 를 통과시켰다.
- 첫 실사용자 (=본인) 가 `brew install MJ-0701/solon-product/sfs` 직후
  `sfs upgrade` 를 옵션 없이 실행한 순간, 즉시 다음으로 죽었다:

  ```
  /opt/homebrew/Cellar/sfs/0.6.1/libexec/bin/sfs: line 848:
  dep_args[@]: unbound variable
  ```

- Codex review 가 30 초 안에 root cause 를 짚었다: macOS bash 3.2 + `set -u`
  환경에서 빈 배열 `"${dep_args[@]}"` expansion 이 nounset rule 에 걸려 죽는
  버그. bash 4.4+ 에서는 수정된 동작이라 Linux CI bash 5.x 에선 재현 불가.

자세한 hotfix 내역은 [CHANGELOG.md `[0.6.2]`](../../CHANGELOG.md) 참조.

### 무엇이 셋 다 통과시켰나

본 사건에서 build/review 를 다룬 모든 LLM-기반 단계는 **같은 환경 위에서**
돌았다:

- 같은 CI host (Linux)
- 같은 bash 메이저 버전 (5.x)
- 같은 test matrix (`tests/run-all.sh`)

bash 3.2 의 nounset+empty-array 동작은 LLM 의 정적 review 가 catch 할 수
있는 영역이지만, 어떤 모델도 "이건 macOS bash 3.2 에서 죽는다" 고 판단할
구체적 trigger 가 review prompt 에 없었다. test 도 그 환경을 한 번도 밟지
않았다. 셋 다 같은 사각 지대였다.

### 무엇이 잡았나

**첫 실사용자의 macOS shell** 이 잡았다. Codex 가 한 일은 그 사용자의 단
한 줄 stderr 메시지를 진단으로 변환한 것 — review 가 아니라 diagnostic
review 였다.

이 마지막 axis 가 cross-review 의 핵심을 드러낸다.

## Cross-review 의 진짜 axis

| Axis | 설명 | 0.6.1 에서 monoculture 였나 |
|---|---|---|
| **모델** | Codex / Claude / Gemini 등 다른 prior · 다른 blind spot | 다양 ✓ |
| **Runtime / 환경** | macOS bash 3.2 vs Linux bash 5.x, glibc vs musl, ASCII/UTF-8 etc | **단일 ✗** |
| **Role** | build / review / use / diagnose 의 lens 가 각기 다름 | review = use 로 가정함 ✗ |
| **Test matrix** | unit / integration / smoke / dogfood / production canary | dogfood 단계 누락 ✗ |
| **Time** | release 직전 review vs 첫 install 직후 사용 | 같은 시점 ✗ |

같은 0.6.1 artifact 가 모델 셋을 모두 통과한 것은 모델 다양성이 작동했다는
뜻이다. 그런데도 죽은 것은 모델 외 axis 가 다 단일했기 때문이다.

## Solon 의 sprint flow 가 이걸 어떻게 다루는가

Solon 의 **CTO Generator ↔ CPO Evaluator** 는 단지 "다른 모델 둘" 이
아니다. role 분리 (`generator` vs `evaluator`) 가 동일 모델로도 의미가
있는 이유는, 같은 모델이라도 **다른 prompt context · 다른 evaluation
surface** 위에 서기 때문이다.

본 0.6.2 hotfix 는 거기에 axis 두 개를 더 명시적으로 박을 근거를 준다:

1. **첫 실사용자 = cross-review 의 마지막 단계.**
   build/review 단계가 아무리 깨끗해도 `brew install` + 첫 실행 자체가
   process 의 우연이 아니라 의도된 step. Solon 의 release flow 는 이 단계를
   "test 가 끝난 뒤의 잔여 우연" 이 아니라 **"Gate 6 review 의 마지막
   evidence 라인"** 으로 본다.
2. **Diagnostic review 는 build agent 와 다른 agent 일 때 가치가 가장
   크다.** 본 사건에서 build 를 한 agent 가 동시에 review 도 했다면,
   `dep_args[@]` idiom 은 self-validation risk 영역에 속한다 (자기가 짠
   bash idiom 의 호환성을 자기가 검증). Solon 의 `/sfs review` 가 default
   로 `--executor codex` 를 쓰는 것은 이 self-validation 회피의 직접 구현이
   다. (`sfs-review.sh` 도 generator == evaluator 일 때 warn 을 띄운다.)

## 사용자 입장에서의 함의

- **단일 agent 만 쓰는 게 보통이다.** 그건 사실이고 비판할 일도 아니다.
  대부분의 사용자는 Codex 만 쓰거나 Claude 만 쓰거나 Gemini 만 쓴다.
  Solon 은 그 사용자에게도 cross-review 의 가치를 주려 한다 — 단, "다른
  모델" 로가 아니라 **"다른 surface"** 로.
- 같은 단일 agent 안에서도 cross-review 가 살아 있는 axis:
  - `generator` vs `evaluator` role 분리 (sprint contract 가 강제)
  - 1 인 dogfood 의 "내가 직접 쓰는 환경" axis (Solon 의 retro 가 항상
    묻는 것)
  - real CI / runtime matrix 다양화 (CHANGELOG `[0.6.2]` 의 Process learning
    참조)
- **단일 agent + cross-surface > 여러 agent + monoculture.** 본 사건이 그
  예시다. 셋 다 같은 surface 위에서 통과시킨 것보다, 한 명이라도 macOS
  bash 3.2 위에서 dogfood 하는 것이 강했다.

## Receipts (실측 cascade — 0.6.1 → 0.6.4, 24h 이내)

본 명제는 한 번이 아니라 **같은 release flow 의 한 source line 에서 연이어
3 번** 검증되었다. 같은 blind-spot 클래스 (외부 CLI / runtime 환경 차원의
monocultural test surface) 가 한 layer 씩 벗겨질 때마다 첫 실사용자의
macOS shell 이 다음 layer 를 잡아냈다.

| Receipt | release | 진단 source | 무엇이 죽었나 | 어느 surface 가 잡았나 |
|---|---|---|---|---|
| #1 | 0.6.1 → 0.6.2 | `bin/sfs:848` `dep_args[@]` | macOS bash 3.2 + `set -u` 의 빈 배열 expansion | macOS Homebrew bash 3.2 (Linux CI bash 5.x 와 다른 nounset 동작) |
| #2 | 0.6.2 → 0.6.3 | `scripts/sfs-release-sequence.sh:124` `brew audit --new-formula` | Homebrew 가 `--new-formula` 옵션 제거 | 첫 실사용자의 최신 Homebrew 설치본 (CI 의 brew 미설치 surface 와 다름) |
| #3 | 0.6.3 → 0.6.4 | 같은 라인 — `brew audit "${formula}"` | Homebrew 가 path-form `brew audit` 를 disable | 다시 같은 macOS Homebrew |
| #4 | 0.6.4 → 0.6.5 | 같은 audit phase, 이번엔 `brew style` 단계 | Homebrew 의 `brew style` 가 (a) cut-release 의 sha256 placeholder 를 3 개 lint 로 fail, (b) template 의 진짜 style 결함 6 개 (sigils, frozen literal, 문서, components order, livecheck regex) 를 fail | 같은 maintainer macOS Homebrew |

이 cascade 가 보여주는 것:

- **monocultural CI 가 미는 default surface 의 자기-강화 함정** — `--new-formula`
  를 고친 후에도 다음 시도에서 곧바로 path-form 까지 막혔다는 사실은,
  "외부 CLI 의 변경" 자체가 **연속 표면 (continuous surface)** 이라는 점.
  release flow 가 maintainer 의 macOS 셸 위에서 진짜로 한 번 돌아 evidence
  를 남기지 않으면, build/review 가 통과해도 다음 layer 에서 또 죽는다.
- **모델 다양성으로 해결되지 않는다** — 본 cascade 의 어느 step 에서도
  Codex / Claude / Gemini 의 review 만으로는 사전 차단이 안 됐다. CI matrix
  에 macOS Homebrew 단계를 의도적으로 박는 것 (= surface 다양화) 이 본질적
  fix.
- **Diagnostic round-trip 비용** — receipt #1 → #2 → #3 사이의 시간이 짧을
  수록 (24h) 사용자 dogfood 단계가 release process 의 design 에 박혀
  있었다는 신호. cross-review 가 process 우연이 아니라 의도된 단계로
  존재해서 가능한 일.

## 한 줄 정리

> **Cross-review 의 가치는 모델의 수가 아니라 surface 의 다양성에서 나온다.
> 0.6.1 → 0.6.5 의 receipt 4 개가 그 명제의 evidence 다.**

## 참고

- [CHANGELOG `[0.6.2]`](../../CHANGELOG.md) — 본 case study 의 release 기록
- [현재 제품 흐름과 최근 변화](./current-product-shape.md) — sprint flow 의
  default cross-review 구조
- [Solon 10x 가치](./10x-value.md) — 사용자가 product owner 자리에 남는
  설계 철학과의 연결
