# Solon 제품

> AI-native solo founder 를 위한 **Solo Founder System (SFS)**.
> Solon 은 AI 의 속도를 제품 운영으로 바꿔 주는 얇은 레일입니다.

**언어**: 한국어 / [영어 문서](./docs/en/index.md)

---

## 왜 Solon인가

AI 로 만드는 속도는 이미 빠릅니다. 문제는 속도가 아니라 흐름입니다.

- 대화는 길어지는데 결정은 어디에도 남지 않습니다.
- AI 가 많이 바꿨지만 무엇을 통과 기준으로 봐야 할지 흐려집니다.
- 구현자는 자기 결과를 스스로 승인하고, review 는 뒤늦게 몰립니다.
- Claude, Codex, Gemini 를 같이 쓰면 각 agent 가 서로 다른 프로젝트를 보는 것처럼 움직입니다.
- sprint 가 끝나도 다음 사람이 이어받을 한 장짜리 맥락이 없습니다.

Solon 은 이 문제를 앱 generator 로 풀지 않습니다. 앱 뼈대는 각 프레임워크와 AI 가 가장 잘하는
방식으로 만들고, Solon 은 그 다음부터의 제품 운영을 맡습니다.

```text
fuzzy idea
-> shared intent
-> scoped sprint
-> acceptance criteria
-> implementation slice
-> independent review
-> handoff / retro
```

Solon 을 쓰면 AI 는 더 멀리 혼자 달리는 대신, 사용자가 이해할 수 있는 작은 계약과 검증 루프 안에서
움직입니다. 결과는 단순히 더 많은 output 이 아니라, 다음 변경도 믿고 이어갈 수 있는 iteration 입니다.

더 깊은 설명은 [Solon 10x 가치](./docs/ko/10x-value.md)에 정리했습니다.

---

## SFS란

SFS 는 두 가지 의미를 함께 가집니다.

- **Sprint Flow System**: `start → brainstorm → plan → review (Gate 3) → implement → review (Gate 6) → retro`
  로 생각과 실행을 통과시키는 매일의 작업 흐름입니다. review 는 plan 직후와 implement 직후
  두 번 등장합니다.
- **Solo Founder System**: 혼자 제품을 만드는 사람이 여러 AI agent 를 팀처럼 쓰기 위한 운영
  시스템입니다. 역할, 결정, 검토, 회고, 인수인계를 프로젝트 안에 고정합니다.

핵심 약속은 단순합니다.

- AI 는 실행을 돕습니다.
- Solon 은 흐름과 기록을 잡아줍니다.
- 사용자는 방향, 우선순위, 최종 통과 여부를 결정합니다.

---

## 기본 흐름

```text
sfs status
-> sfs start "<goal>"
-> sfs brainstorm [--simple|--hard] "<raw context>"
-> sfs plan
-> sfs review --gate 3
-> sfs implement "<first slice>"
-> sfs review
-> sfs retro
```

각 단계가 하는 일은 짧습니다.

- `start`: 지금부터 어떤 작업 묶음을 진행할지 엽니다.
- `brainstorm`: 의도, 우선순위, 포기할 것, 성공 기준을 정리합니다.
- `plan`: 목표, 범위, 완료 기준, 검증 방법을 한 sprint 안에서 닫히는 계약으로 만듭니다.
- `review --gate 3`: 구현으로 넘어가기 전에 plan 자체를 독립 검토합니다. PASS 가 나야
  `implement` 가 열립니다. (정말 건너뛰어야 할 때만 `--allow-unreviewed-plan`.)
- `implement`: 코드, 문서, 전략, 디자인 handoff, QA evidence, 운영/runbook 중 필요한 산출물을 만듭니다.
- `review`: 만든 쪽이 스스로 통과시키지 않도록 검토 역할과 근거를 분리합니다. 구현 완료 후의
  artifact acceptance review (Gate 6) 가 기본값이고, `--gate 3` 으로 plan review 도 같은 명령에서
  수행됩니다.
- `retro`: 결과, 배운 점, 다음 action 을 남기고 sprint 를 닫습니다.

---

## 설치

개발, 터미널, CLI 환경이 낯설다면 먼저 [BEGINNER-GUIDE.md](./BEGINNER-GUIDE.md)를 보시면 됩니다.

### Mac

```bash
brew install MJ-0701/solon-product/sfs

cd ~/workspace/my-project
sfs init --layout thin --yes
sfs status
```

### Windows

```powershell
winget install --id Git.Git -e --source winget

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs

cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

### AI 도구 연결 확인

```bash
sfs doctor
```

Claude Code, Gemini CLI, Codex CLI 가 모두 연결되면 각 도구에서 같은 Solon 흐름을 사용할 수 있습니다.

| Runtime | 진입 명령 |
|---|---|
| Claude Code | `/sfs status` |
| Gemini CLI | `sfs status` |
| Codex CLI | `$sfs status` |
| Windows PowerShell/cmd | `sfs.cmd status` |

---

## 새 앱에서 시작하기

처음 쓰는 사람이 Next.js, Spring, Java, API 같은 말을 알고 있을 필요는 없습니다. 사용자는 그냥 만들고
싶은 것을 말하면 됩니다.

Solon 을 쓰는 AI 는 앱 뼈대가 필요하다고 판단하면 먼저 사용자에게 묻고, 동의 후 프레임워크나 AI 의
native 방식으로 초기 구성을 만든 다음 Solon 흐름으로 돌아옵니다.

```bash
cd my-new-app
sfs init --layout thin --yes
sfs start "첫 작업 목표"
```

Solon 의 강점은 앱을 대신 찍어내는 것이 아니라, 앱을 만든 뒤부터 이어지는 의도 정리, 범위 결정,
실행 기록, 검토, 회고를 프로젝트 안에 남기는 데 있습니다.

---

## 어디에 기록되나

| 경로 | 역할 |
|---|---|
| `SFS.md` | 프로젝트 운영 지침 |
| `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` | 각 AI 도구가 Solon 을 찾는 입구 |
| `.sfs-local/` | gitignored private active workbench/state |
| `docs/solon/<english-workspace>/<yyyyMMdd>/report.md` | 공유 가능한 작업 결과 인계 문서 |
| `docs/solon/<english-workspace>/<yyyyMMdd>/retro.md` | 공유 가능한 회고/후속 인계 문서 |

`.sfs-local/` 은 영구 히스토리 폴더가 아닙니다. 현재 sprint 를 진행하는 데 필요한 상태만 보이고,
팀이나 미래의 내가 읽어야 할 내용은 `docs/solon/...` 공유 문서와 git history 로 남깁니다.

---

## 자주 쓰는 명령

| 명령 | 용도 |
|---|---|
| `sfs status` | 현재 sprint 상태 확인 |
| `sfs guide` | 설치된 프로젝트에서 짧은 터미널 가이드 보기 |
| `sfs start <goal>` | 새 작업 묶음 시작 |
| `sfs brainstorm [--simple|--hard] [text|--stdin]` | 만들기 전에 의도와 기준 정리 |
| `sfs plan` | 목표/범위/완료 기준 계약 작성 |
| `sfs review --gate 3 [--lens ...]` | plan 자체를 implement 전에 독립 검토 (PASS 필수) |
| `sfs implement [slice|--stdin]` | 작은 실행 조각 진행 |
| `sfs review [--lens ...]` | 구현 산출물 검토 (기본 Gate 6 / artifact acceptance) |
| `sfs retro [--draft]` | 회고와 마무리 |
| `sfs commit plan` | 변경 그룹 확인 |
| `sfs commit apply --group <name>` | 선택 그룹을 commit 하고 현재 branch push |
| `sfs upgrade` | 프로젝트의 Solon 파일과 흐름 최신화 |
| `sfs tidy [--apply]` | 끝난 작업의 임시 기록 정리 |

---

## 문서 지도

| 문서 | 한국어 | 영어 |
|---|---|---|
| 문서 index | [docs/ko](./docs/ko/index.md) | [docs/en](./docs/en/index.md) |
| Solon 10x 가치 | [KO](./docs/ko/10x-value.md) | [EN](./docs/en/10x-value.md) |
| 현재 제품 흐름 | [KO](./docs/ko/current-product-shape.md) | [EN](./docs/en/current-product-shape.md) |
| 30분 가이드 | [KO](./GUIDE.md) | [EN](./docs/en/guide.md) |
| 초보자 가이드 | [KO](./BEGINNER-GUIDE.md) | 예정 |
| 릴리스 노트 | [RELEASE-NOTES.md](./RELEASE-NOTES.md) | 예정 |
| 상세 변경 이력 | [CHANGELOG.md](./CHANGELOG.md) | [CHANGELOG.md](./CHANGELOG.md) |

---

## 안전 계약

- Solon 은 사용자 산출물을 조용히 덮어쓰지 않습니다.
- commit/push 는 `sfs commit apply` 로 묶어 수행합니다.
- 공유해야 하는 기록은 `docs/solon/...` 아래에 남깁니다.
- 검토는 작성자와 독립된 역할로 분리합니다.
- 최종 제품 판단은 항상 사용자에게 남깁니다.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
