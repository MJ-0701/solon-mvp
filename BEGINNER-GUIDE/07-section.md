---
doc_id: sfs-beginner-guide-ko-7
title: "첫 작업 예시"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "첫 작업 예시"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
---
## 첫 작업 예시

제품 아이디어나 화면 흐름을 정리하고 싶다면 이렇게 시작합니다.

```text
/sfs start "랜딩 페이지의 첫 사용자 경험 정리"
/sfs brainstorm "처음 방문한 사람이 무엇을 이해해야 하는지 정리하고 싶다"
/sfs plan
```

`/sfs start` 가 끝나면 다음 줄에 `simple`, `normal`, `hard` brainstorm 선택지가 보입니다.
잘 모르겠으면 추천값인 normal 을 그대로 쓰면 됩니다. 빠르게 정리만 하고 싶으면
`/sfs brainstorm --simple ...`, 더 깊게 질문받고 싶으면 `/sfs brainstorm --hard ...` 를 씁니다.

Codex CLI 라면 `/sfs` 대신 `$sfs` 를 씁니다.

```text
$sfs start "랜딩 페이지의 첫 사용자 경험 정리"
$sfs brainstorm "처음 방문한 사람이 무엇을 이해해야 하는지 정리하고 싶다"
$sfs plan
```

코딩을 바로 시키지 않아도 됩니다. Solon 의 `implement` 는 코드만 뜻하지 않습니다. 화면 구조,
문구, 디자인 handoff, QA 체크리스트, 운영 문서도 구현 산출물입니다.

AI 모델 이름을 전부 외울 필요도 없습니다. Solon 의 기본 role routing 이 자동으로 적용됩니다.
단순 입출력은 helper-grade intake 모델이 맡고(Codex 는 `gpt-5.4-mini`), 질문 생성은 standard
facilitator 모델이 맡습니다(Codex 는 `gpt-5.4`). 설계와 검토, 그리고 하위모델이 만든 질문/해석이
방향을 바꾸는 경우는 최상위 advisor 가 봅니다. Codex advisor 는 `gpt-5.5` xhigh 이고,
Gemini 는 모든 role 을 strategy/research/review 는 `gemini-3.1-pro-preview`, agentic coding/bounded 구현 helper 는 `gemini-3-flash-preview`, relay/probe/economy helper 는 `gemini-3.1-flash-lite` 로 둡니다. 3.x 미만 fallback 은 쓰지 않습니다. Codex 쪽
일반 구현 worker 는 `gpt-5.4`, 단순 helper 는 `gpt-5.4-mini`, 좁은 code helper 는
`gpt-5.3-codex` 입니다. 이미 결정된 사항을 그대로 옮기는 무판단 단순 구현일 때만
`gpt-5.3-codex-spark` 를 씁니다. Claude 쪽 코딩 가능한 worker/helper 는 Sonnet 4.6이고,
Haiku 는 코딩하지 않는 relay, 요약, 작은 read-only helper 전용입니다.
위험한 구조 변경이나 보안/데이터 손실 위험이 있으면 Solon 이 더 강한 판단 모델로 올리는 흐름을
권장합니다.

단, advisor 를 불렀다는 사실만으로 plan 이 통과되지는 않습니다. cross review 전에 self-CPO
mini-check 로 요구사항, AC, 구현 slice, ADR/decision id 가 이어지는지와 각 AC 의
file/artifact/evidence 매핑, SEED/placeholder/mock/fallback 의 non-acceptance 상태를 확인해야
합니다.

새로운 앱의 빈 틀부터 필요할 때도 Next.js, Spring, Java 같은 말을 알 필요는 없습니다.
사용자는 그냥 만들고 싶은 것을 말하면 됩니다. 대화하다가 AI 가 "앱 뼈대가 먼저 필요하겠다"고
판단하면 이렇게 물어보는 흐름이 좋습니다.

```text
초기 프로젝트 구성해드릴까요?
```

동의하면 AI 가 목적에 맞는 초기 구성을 고릅니다. 단순 페이지인지, 작은 웹앱인지, 서버와 저장소가
필요한지 같은 크기 판단은 AI 가 먼저 잡고, 꼭 필요한 결정만 사용자에게 묻습니다. 내부적으로는
`sfs bootstrap "<만들고 싶은 것>"` handoff 를 쓸 수 있지만, 사용자가 이 명령을 외울 필요는
없습니다.

Mac/Git Bash:

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "첫 작업 목표"
```

Windows PowerShell/cmd:

```powershell
cd C:\workspace\my-new-app
sfs.cmd init --layout thin --yes
sfs.cmd start "첫 작업 목표"
```

---

