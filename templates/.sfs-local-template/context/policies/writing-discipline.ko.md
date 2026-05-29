---
id: writing-discipline-ko
summary: 사용자용 산출물은 독자가 진짜 필요한 것만 남긴다. 서두/hedging/자기 칭찬/재진술/마무리 상투구 금지. 핵심 (사실·결정·근거·경로·정확한 명령) 보존.
load_when: ["writing", "readme", "guide", "report", "summary", "documentation", "docs", "user-facing", "README.md", "GUIDE.md", "RELEASE-NOTES.md", "caveman", "no fluff", "tone", "lens:docs", "lens:source-docs", "보고서", "안내서", "사용자 문서", "문서 작성", "글쓰기", "미사여구"]
---

# Writing Discipline (사용자용 산출물)

agent 가 사용자용 산출물에 *쓰는 내용* 을 규율한다. 대상: README.md,
GUIDE.md, BEGINNER-GUIDE.md, RELEASE-NOTES.md, 학습 노트, 프로젝트
보고서, 요약, 고객용 안내서. agent 내부 로그 / evidence capture / routed
context 모듈은 본 정책의 대상이 아니다 — 그쪽은
`context-pollution-guard.md`, `token-harness.md` 가 따로 규율한다.

## 룰

독자가 진짜 필요한 것만 남기고 나머지는 잘라낸다.

다음은 **금지** 한다:

- **서두 (preamble)** — "좋은 질문입니다", "물론입니다", "본 문서는
  ... 를 다룹니다", "Let me explain..."
- **자기 칭찬** — "comprehensive", "robust", "powerful", "seamless",
  "world-class", "포괄적인", "강력한", "혁신적인"
- **정보 없는 hedging** — "may", "perhaps", "I think", "potentially",
  "아마도", "추측건대"
- **재진술** — heading 이나 앞 문장이 이미 말한 내용을 다시 풀어
  쓰는 행위
- **마무리 상투구** — "In summary...", "I hope this helps", "감사
  합니다", "도움이 되길 바랍니다"
- **마케팅 톤** — 형용사 체인, 의미 없는 em-dash 장식, 운율을 위한
  대구 구조

다음은 **보존** 한다:

- **사실** — 무엇인지, 누구를 위한 것인지, 무엇을 하는지
- **결정** — 왜 이 모양으로 갔는지, 무엇을 거절했는지
- **근거** — 파일 경로, 라인 번호, 정확한 명령, 테스트 이름, 버전
- **경계** — 무엇이 범위 안이고 무엇이 밖인지
- **위험 경고** — 어떻게 실패하는지, 무엇을 확인해야 하는지

성공 조건은 "짧아짐" 이 아니다. "남긴 모든 것이 자리값을 한다" 이다.
문단을 "흐름 있게" 만들기 위해 정보 없는 문장을 추가했다면 그 문장은
삭제 대상이다.

## Caveman vs writing-discipline

"Caveman" 은 Solon 안 다른 위치
(`docs/ko/10x-value/06-token-diet-10x.md`) 에서 **OPT-IN 페르소나/말투
모드** 로 등장한다 — 일부러 짧고 장난스러운 톤. 그건 *스타일 토글* 이지
글쓰기 품질 계약이 아니다.

본 `writing-discipline` 정책은 *품질 계약* 이다. Caveman 페르소나가
켜져 있든 꺼져 있든 동일하게 적용된다. 페르소나 OFF → 일반 톤이지만
미사여구 없이 쓴다. 페르소나 ON → Caveman 톤으로 *그리고* 미사여구
없이 쓴다. 두 룰은 합쳐지지 같지 않다.

## 발화 조건

routed-context 로더가 `load_when` 트리거를 보고 본 정책을 자동
로드한다. 가장 흔한 경우:

- README.md / GUIDE.md / BEGINNER-GUIDE.md 생성 또는 정리
- RELEASE-NOTES.md entry 작성
- sprint / 프로젝트 / handoff 보고서
- 학습 노트, 고객용 문서, 온보딩 페이지

agent 내부 산출물 (sprint log, capture, decision file, context module)
은 `context-pollution-guard.md` 와 `token-harness.md` 를 참조.

## review 검사

`sfs review --lens docs` 와 `--lens source-docs` 는 다음을 확인한다:

- 산출물이 정보 없는 서두 문단으로 시작하지 않는다.
- heading 과 첫 문장이 같은 내용을 두 번 말하지 않는다.
- 형용사 밀도가 낮다 — "포괄적이고, 강력하고, 매끄러운 ..." 같은
  체인이 없다.
- 파일 경로, 명령어, 버전 번호, 결정 근거가 정확하게 들어 있다.
- 마무리 상투구가 없다.

기술적으로 맞지만 서두 / 자기 칭찬 / 마무리 상투구로 가득한 산출물을
CPO 가 발견하면 PASS 가 아닌 PARTIAL 판정 + 본 정책 id 를 기록한다.

## 본 정책이 존재하는 이유

codex / Claude / Gemini 의 기본 학습은 verbose / hedged / 자기 칭찬형
prose 쪽으로 밀어붙인다 — 그게 rating benchmark 에서 점수가 잘 나왔기
때문. Solon 으로 만드는 사용자용 산출물의 청중은 다르다: 문서를 읽는
실제 사람, release notes 를 읽는 maintainer, 자기 학습 노트를 읽는
프로젝트 소유자. 기본 verbose prose 는 그들의 시간을 낭비하고 evidence
를 희석한다. `kernel.md` 의 compactness floor 가 "evidence 잃지 마라"
를 정했다면, 본 정책은 그 위에 상한을 더한다 — "padding 도 하지 마라".
