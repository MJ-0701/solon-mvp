---
id: sfs-evals-readme
summary: Held-out eval scaffold — where the fixed-before-change scoring set lives and the stage-1 deterministic shape it uses.
load_when: ["evals", "held-out", "eval set", "benchmark", "head-to-head", "eval-first"]
---

# Held-Out Evals (scaffold)

이 디렉토리는 **held-out 채점 세트의 입구**입니다. 정책 SSoT 는
`policies/skill-promotion-loop.md` (HELD_OUT_SCORING) /
`policies/self-improvement-loop.md` (MEASURE) /
`policies/model-workaround-sunset.md` (MODEL_HEAD_TO_HEAD_ON_UPGRADE) 이고,
여기서는 형식만 요약합니다.

## 규율 (요약)

- **eval-first** — 채점 케이스와 차원은 변경(스킬 편집·WU 코드·모델 교체)이
  존재하기 *전에* 고정합니다 ("eval = first commit"). 작업 후 만든 측정 기준은
  작업을 잘 보이게 채점합니다.
- **held-out** — 편집 중에는 이 세트를 읽지 않습니다. 세트에 맞춰 튜닝된
  변경은 held-out 이 아닙니다.
- **necessary-but-not-sufficient** — 점수는 게이트도 사람 승인도 뒤집지
  못합니다. 동점/후퇴면 기존 버전 유지.
- **표면 확장** — 벤치마크 표면은 릴리스마다 자랍니다 (새 케이스·새 채점
  차원). 정체된 표면은 포화되어 "no gain" 으로 잘못 읽힙니다.
- **model head-to-head** — 모델 교체 판단은 같은 도메인 세트로 현행 vs 후보를
  나란히 채점합니다.

## 케이스 형식 (stage 1 — deterministic, LLM 0토큰)

케이스 하나 = md 파일 하나. grep-assert 형식 (`tests/` 의 has-assert 와 동형):

```markdown
---
case_id: <slug>
target: <skill/command/policy/model being scored>
fixed_at: <YYYY-MM-DD — 변경 이전이어야 함>
---

## Input
<프롬프트/시나리오/입력 데이터 또는 그 포인터>

## Must contain (anchors)
- <출력에 반드시 존재해야 하는 문자열/구조>

## Must NOT contain
- <출력에 나오면 실패인 문자열>
```

Stage 2 (cost-gated LLM judge) 는 stage 1 통과 후 non-trivial 변경에만 —
tidy 레일에서 grader-style 로 수행하고, 엔진은 배포에 추가하지 않습니다
(by-reference: skill-creator eval harness 패턴).

## WRONG_PREMISE_EVAL_FIXTURE (fixture 유형 축)

케이스 세트에 **"underspecified 프롬프트 + 일부러 틀린 전제"** 유형을
포함합니다 — 스택트레이스에 "fix" 한 단어, 또는 엉뚱한 모듈을 범인으로
지목한 지시. 판정 대상은 정답 산출이 아니라 **잘못된 전제를 반박하고 root
cause 로 갔는가** — `Must contain` 에 반박/재진술 앵커를, `Must NOT contain`
에 틀린 전제를 그대로 따른 흔적을 둡니다. restate-and-clarify
(`policies/work-delegation-and-startup.md`) / unknown-knowns flush
(`policies/unknowns-and-deviations.md`) 의 eval 짝입니다. 또한 judge 자체는
음성 대조를 통과해야 합니다 — 일부러 깨뜨린 fixture 에서 fail 이 나는지 1회
확인 (`policies/harness-autonomy.md` JUDGE_NEGATIVE_CONTROL).

## 위치

- 케이스 파일: 이 디렉토리 (`.sfs-local/evals/*.md`) 또는 프로젝트가 정한
  `evals/` (루트). 어디든 **변경 전 고정 + 편집 중 미열람** 규율이 본질입니다.
- 채점 결과(before/after delta)는 sprint workbench 에 기록합니다.
