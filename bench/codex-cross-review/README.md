# Codex Cross-Review Bake-off

> 본 디렉토리는 **벤치마크 스크래치** 이다. solon-mvp 배포 surface 가 아니므로
> install.sh / templates / upgrade.sh 와는 무관. 필요 없어지면 통째로 삭제 가능.

## 목적

동일 plan artifact 를 두 review 경로로 돌려 **토큰 / 지연 / 발견 이슈** 를 비교한다.

| Run | Path | 비고 |
|---|---|---|
| A | 공식 `openai/codex-plugin-cc` `/codex:review` | Claude Code 안에서 Codex 호출 |
| B | Solon `/sfs review --executor codex` | Solon shell bridge → Codex CLI 직결 |
| C (옵션) | Solon `/sfs review --executor codex-plugin` | Solon → Claude 플러그인 → Codex (`SFS_REVIEW_CODEX_PLUGIN_CMD` 필요) |

## 디렉토리

- `scenario/plan.md` — Gate 3 plan artifact (review 대상)
- `scenario/sprint-context.md` — Solon 가 native 로 갖는 sprint contract 요약. A/B 양쪽에 동일 input 으로 주입해 surface 를 맞춘다.
- `RUN.md` — Claude Code 가 따라야 할 절차 (0~4 단계)
- `expected-issues.md` — **답안지**. 비교 리포트 작성 직전까지 열지 말 것
- `results/` — run 산출물 저장처

## 사전 조건

1. `~/.codex/` Codex CLI 로그인 (`!codex login` from Claude Code)
2. Claude Code 에 `openai/codex-plugin-cc` 마켓플레이스 추가 + 설치
3. solon-mvp 0.6.1 설치되고 `/sfs review` 슬래시 사용 가능
   - 0.6.1 실측 시그니처: `/sfs review [--gate <1..7>] [--lens <...>] [--executor <profile|cmd>] [--print-prompt|--prompt-only]`
   - **review 는 sprint-scoped** (임의 파일 `--target` 옵션 없음). 따라서 RUN.md step 2-A 에서
     throwaway 샌드박스 sprint 를 띄워 plan.md 를 Gate 3 artifact 로 등록한 뒤 review 호출.
   - plan-review 는 `--gate 3 --lens artifact` 정답 (Gate 6 은 Release/Review 게이트).
4. (옵션 — Run C) `SFS_REVIEW_CODEX_PLUGIN_CMD` 가 codex-plugin-cc 의 shell-callable 진입점 가리키도록 export.

## 발화 명령어 (Claude Code 에서 한 줄)

```
bench/codex-cross-review/RUN.md 절차대로 plan-review bake-off 실행.

규칙:
- 기본은 Run A + Run B. Run C (codex-plugin) 도 돌릴지는 A/B 끝나고 사용자에게 묻기.
- expected-issues.md 는 step 3 비교 리포트 작성 직전까지 절대 열지 말 것 (오염 방지)
- 각 run 직전/직후 ~/.codex/sessions/ 스냅샷 diff 로 codex 측 토큰 분리
- Claude 측 토큰은 turn 별 usage 를 results/{A,B,C}.claude-tokens.txt 로 기록
- 끝나면 results/compare.md 요약을 채팅에 출력

지금 시작.
```

## 결과 해석 가이드

- **codex 토큰** = 실제 추론 비용. 두 path 의 prompt design 차이가 여기로 직접 드러남.
- **claude 토큰** = 오케스트레이션 / wrapper overhead. Solon path 가 sprint context 까지 들고 가는 만큼 base 가 더 크기 쉬움.
- **이슈 발견율** = `expected-issues.md` 의 13~15 개 plant 중 몇 개를 잡았는지.
- **false positive** = plant 외 이슈 — 노이즈 vs 진짜 발견 구분 필요.
