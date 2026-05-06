# Solon 제품 릴리스 노트

**언어**: 한국어 / 영어 문서 예정

이 문서는 사용자가 새 버전에서 무엇을 체감하게 되는지 짧게 정리합니다.
세부 구현 기록은 [CHANGELOG.md](./CHANGELOG.md) 에 따로 둡니다.

---

## 0.6.19

이번 버전은 Gate 3 계획이 끝났다고 바로 구현으로 넘어가며 사용자에게 모델 선택을 묻던 흐름을 막는 핫픽스입니다.

- `sfs implement` 는 이제 Gate 3 Plan review PASS 없이는 시작하지 않습니다.
- 정상 흐름은 `sfs plan` 다음 `sfs review --gate 3`, 그 다음 `sfs implement` 입니다.
- C-Level 모델은 설계, 계약, AC, 검토 handoff 를 책임지고, worker/generator 모델이 고정된 구현 slice 를 맡는다는 역할 경계를 명시했습니다.
- 예외적으로 사용자가 plan review 를 건너뛰라고 명시한 경우에만 `--allow-unreviewed-plan` 으로 진행할 수 있고, 그 waiver 는 기록됩니다.
- 앞으로 Action Rail 이 ready plan 에서 바로 구현/모델 선택으로 뛰면 guardrail 테스트가 실패합니다.

## 0.6.18

이번 버전은 UX가 있는 작업에서 Solon 이 "경고/차단"부터 말하지 않고, 사용자가 바로 고칠 수 있는 흐름을 먼저 설계하도록 바꾼 핫픽스입니다.

- 입력값 검증은 먼저 무엇을 어디서 어떻게 고치면 되는지 보여줘야 합니다.
- `[Product]` 같은 미치환 placeholder 는 field 가까이에 표시하고, focus/clear/replace/AI에게 맡기기 같은 회복 경로를 요구합니다.
- "잘못된 입력" 같은 막힌 문구보다 "아직 실제 값으로 바꿔야 할 부분이 있어요" 같은 coaching tone 을 쓰도록 디자인 지식팩을 보강했습니다.
- 서버 4xx 는 비용/보안/데이터 무결성을 지키는 마지막 안전망으로만 다루고, UI 가 같은 field-level 복구 안내로 렌더링할 수 있어야 합니다.
- 앞으로 이 repair-first UX 계약이 빠지면 패키지 테스트가 실패합니다.

## 0.6.17

이번 버전은 review 통과 후 다음 액션 안내가 `sfs report` 를 불필요하게 먼저 권하던 문제를 바로잡은 핫픽스입니다.

- 정상 마무리 경로는 `sfs retro` 하나입니다.
- `retro` 는 이미 `report.md` 를 확인하거나 만들고, `retro.md` 를 정리하고, sprint close 까지 이어갑니다.
- `sfs report` 는 보고서만 미리 보거나 과거 sprint 보고서를 다시 만들 때 쓰는 선택 명령으로 정리했습니다.
- review/tidy context 와 CPO review prompt 에서 `report -> retro` 안내가 다시 나오지 않도록 테스트를 추가했습니다.

## 0.6.16

이번 버전은 Gate 3 같은 계획 보고서에서 결정 질문이 너무 압축되어 보이던 문제를 바로잡은 핫픽스입니다.

- 보고서가 `Q1`, `D1`, `AC-1` 같은 식별자만 앞세워 사용자의 결정을 요구하지 않도록 했습니다.
- 결정이 필요할 때는 무엇을 결정하는지, 왜 지금 필요한지, 권장 기본값이 무엇인지, 각 선택지가 무엇을 바꾸는지 풀어서 설명해야 합니다.
- Gate 3 plan 이 아직 draft 인 경우에도 마지막 질문은 짧은 decision brief 로 남기도록 context 를 보강했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 보고서 명료성 규칙을 갖습니다.
- 앞으로 이 규칙이 빠지면 agent behavior guardrail 테스트가 실패합니다.

## 0.6.15

이번 버전은 릴리스 노트가 stable package 에 누락되던 배포 스크립트 문제를 바로잡은 핫픽스입니다.

- dev 에서는 0.6.13, 0.6.14 릴리스 노트가 최신이었지만 stable tag 와 설치본에는 `RELEASE-NOTES.md` 가 오래된 상태로 남을 수 있었습니다.
- `cut-release.sh` 가 이제 `RELEASE-NOTES.md` 를 stable 제품 저장소로 함께 동기화합니다.
- 앞으로 release cutter allowlist 에서 릴리스 노트가 빠지면 테스트가 실패하도록 막았습니다.

## 0.6.14

이번 버전은 실사용 중 발견된 review lens 이름 불일치를 바로잡은 핫픽스입니다.

- `sfs review --lens strategy-pm` 처럼 본부 이름을 넣어도 이제 `strategy` lens 로 정상 처리됩니다.
- `strategy_pm`, `design/frontend`, `infra`, `finance`, `accounting` 같은 자주 나오는 표현도 공개 lens 이름으로 정규화됩니다.
- `management-admin` 은 재무 기록, 경리, 세무/회계 질문, 현금 evidence 를 보는 review lens 로 직접 사용할 수 있습니다.
- 잘못된 lens 를 넣었을 때 오류 메시지가 alias 예시를 함께 보여줍니다. agent 가 엉뚱한 lens 로 오래 기다리는 일을 줄이기 위한 조치입니다.

## 0.6.13

이번 버전은 Claude, Codex, Gemini 를 팀처럼 쓰는 방식을 Solon 답게 얇게 반영한 릴리스입니다.

- 큰 조사나 마이그레이션 판단이 필요할 때 사용할 수 있는 read-only researcher 역할이 추가됐습니다.
- researcher 는 코드를 직접 고치거나 품질 승인을 하지 않습니다. 넓게 읽고, 필요한 사실과 근거만 작게 남깁니다.
- 모델 프로필에 `research_high` 단계가 추가되어 Gemini 처럼 긴 컨텍스트에 강한 도구를 조사 역할에 더 자연스럽게 배치할 수 있습니다.
- 구현은 여전히 작은 파일 범위와 명확한 작업 단위로 나눕니다. 여러 에이전트를 쓰더라도 프로젝트 표면이 커지지 않도록 했습니다.
- 리뷰는 작성자와 분리된 관점으로 보게 했습니다. 같은 agent 가 만든 코드를 같은 맥락에서 다시 승인하는 흐름은 위험 신호로 다룹니다.
- 도메인 용어가 sprint 를 넘어 오래 살아야 할 때는 `docs/solon/domain-map.md` 같은 짧은 공유 문서로 남기는 방향을 안내합니다.
- 사용자가 굳이 멀티 에이전트 구성을 몰라도 됩니다. 작업이 작으면 기존처럼 `sfs plan`, `sfs implement`, `sfs review` 흐름으로 충분합니다.

## 0.6.12

이번 버전은 AI 가 코딩이나 문서 작업을 할 때 자주 놓치는 안전장치를 SFS 흐름 안에 얇게 넣은 릴리스입니다.

- agent 는 구현 전에 중요한 가정과 선택지를 먼저 드러냅니다. 불명확한 부분이 있으면 추측하지 않고 작은 질문으로 멈춥니다.
- 구현은 최소 유용 단위로 시작합니다. 요청과 직접 관련된 파일과 줄만 조심스럽게 건드립니다.
- 실제 파일, diff, 에러 로그, 테스트 출력을 읽고 판단하도록 kernel 과 command context 를 강화했습니다.
- 완료 전에는 가능한 가장 작은 테스트, 빌드, smoke, review check 를 실행하고 그 결과를 보고하도록 명시했습니다.
- `checklist.md` 와 `context-notes.md` 를 루트에 강제로 만들지 않습니다. 대신 SFS sprint workbench 문서 안에 계획, checklist, context note 를 남기도록 정리했습니다.
- 한국어 응답의 문장 끝 콜론 금지와 Korean-first 프로젝트의 새 source file 역할 헤더 규칙도 kernel 에 들어갔습니다.
- Claude, Codex, Gemini adapter 는 긴 규칙을 복제하지 않고 routed SFS context 를 따르도록 짧게 연결됩니다.
- Mac 에서 `sfs upgrade` 가 본체 업데이트를 못 할 때는 `brew upgrade MJ-0701/solon-product/sfs` 를 먼저 실행하시면 됩니다. 짧은 `brew upgrade sfs` 가 기대대로 동작하지 않는 경우까지 README, GUIDE, BEGINNER-GUIDE 에 보강했습니다.

## 0.6.11

이번 버전은 Solon 전체에 "남겨야 될 것만 남긴다" 원칙을 적용한 정리 릴리스입니다.

- `.sfs-local/` 은 기본 비공개 작업 공간으로 gitignore 됩니다.
- `sfs start` 는 더 이상 빈 절차 문서를 한 번에 만들지 않습니다. 각 단계 명령이 필요한 문서만 생성합니다.
- `sfs adopt --apply` 는 기존 프로젝트를 요약해서 `docs/solon/<id>-adoption-summary.md` 하나를 공유 문서로 남깁니다.
- adopt 의 raw scan, 과거 sprint, archive evidence 는 `.sfs-local/archives/` 에 private cold archive 로 접습니다.
- 이미 0.6.11 인 프로젝트도 `sfs upgrade` 를 다시 실행하면 예전 `legacy-baseline` sprint 와 빈 단계 문서 잔여물을 더 접습니다.
- 새로 생성되는 sprint 문서 템플릿은 설명문을 줄이고 실제로 채워야 할 칸만 남겼습니다.
- 새 설치는 빈 `sprints/`, `decisions/`, `queue/` 디렉터리를 미리 만들지 않습니다.

## 0.6.10

이번 버전은 Solon report 의 보이는 표면을 다시 손봤습니다.

- report 가 긴 bullet dump 처럼 보이지 않도록 title/verdict strip, 상태 패널, action rail, 질문 queue 구조를 명시했습니다.
- Claude, Gemini, Codex adapter template 모두 같은 report-surface 규칙을 갖습니다.
- 내용은 계속 간결하게 유지하지만, 사용자가 지금 봐야 할 판단/다음 행동이 더 먼저 보이도록 했습니다.

## 0.6.9

이번 버전은 "설치됐는데 실제로 바로 쓰려니 막히는" 부분을 닫는 핫픽스입니다.

- `sfs adopt "문서 정리좀 해야될거 같은데."` 처럼 기존 프로젝트를 정리하려는 자연어 brief 를 이제 정상으로 받습니다.
- `adopt` 는 기본 dry-run 입니다. 실제 파일을 만들려면 `sfs adopt --apply "..."` 를 쓰면 됩니다.
- `sfs context path adopt`, `sfs context path start`, `sfs context path sprint`, `sfs context path intake` 같은 agent routing 경로가 정상화됐습니다.
- CLI discovery 진단이 실패를 성공처럼 보이지 않게 정리됐습니다.
- Claude/Gemini/Codex 연결 메타데이터와 한국어 사용자 문서를 0.6.9 기준으로 맞췄습니다.

이미 0.6.8 을 설치했다면 `brew reinstall MJ-0701/solon-product/sfs` 또는 `sfs upgrade` 로 받으면 됩니다.

## 0.6.1

이번 버전은 Solon 이 "필요한 기준만 조용히 꺼내 쓰는" 감각을 더 또렷하게 만드는 작은 패치입니다.

- backend, 전략/PM, QA, 디자인/frontend, infra/DevOps, 경영관리, taxonomy 지식팩이 빈 목록이 아니라 실제 가이드로 채워졌습니다.
- Solo Founder 에게 꼭 필요한 재무, 경리, 세무, 회계, 인보이스, 현금 흐름, 외주/급여 증빙 기준도 경영관리 지식팩에 포함했습니다.
- 사용자는 여전히 `sfs plan`, `sfs review` 처럼 익숙한 명령만 쓰면 됩니다. Solon 이 작업 성격을 보고 필요한 관점만 얇게 읽습니다.
- 작은 문서 수정에는 작은 기준을, 배포나 구조 변경처럼 위험이 큰 작업에는 더 단단한 기준을 적용하는 쪽으로 안내가 정리됐습니다.
- 새로 설치한 프로젝트와 이미 작업 중인 프로젝트가 같은 지식팩을 보도록 active context 와 패키지 템플릿을 맞췄습니다.
- README 는 큰 지도 역할만 유지하고, 버전별 변화는 이 릴리스 노트에서 따로 확인하도록 정리했습니다.

추가로 외워야 하는 명령은 없습니다. 업데이트 후 평소처럼 `sfs status` 로 시작하면 됩니다.

## 0.6.0

이번 버전의 방향은 "프로젝트 안을 덜 어지럽게 만들고, 첫 실행을 더 빨리 성공시키는 것"입니다.

- `brew install` / `scoop install` 한 번이면 Claude Code, Gemini CLI, Codex CLI 에서 모두 Solon 을 찾습니다.
- 새 프로젝트에는 운영에 필요한 얇은 연결 문서와 `.sfs-local/` 기록 공간만 남습니다.
- 앱 뼈대는 Solon 이 특정 프레임워크로 고정하지 않습니다. 사용자가 Next.js/Spring 같은 말을 몰라도, 대화 중 필요해 보이면 AI 가 "초기 프로젝트 구성해드릴까요?"라고 묻고, 동의 시 크기에 맞는 native 구성을 잡은 뒤 Solon 으로 돌아오는 흐름을 권장합니다.
- 설치/업데이트 직후 SFS discovery 를 우선순위 1로 올립니다. 그래서 Solon 작업은 먼저 SFS 로 들어가고, 사용자가 나중에 직접 바꾼 우선순위는 존중합니다.
- 오래 걸리는 작업은 `sfs measure --alive -- <command>` 로 조용히 멈춘 것처럼 보이지 않게 진행 신호를 남길 수 있습니다.
- `review` 는 줄바꿈이나 이름만 바뀐 일을 과하게 문제 삼기보다, 사용자가 실제로 영향을 받는 변화에 더 집중합니다.
- 버전 이름은 이제 보통의 `0.6.0` 형태를 씁니다. 예전 `-product` 표기는 과거 릴리스 기록에만 남습니다.

처음 설치하거나 업데이트하는 방법은 [README.md](./README.md) 와 [GUIDE.md](./GUIDE.md) 에서 확인하세요.
