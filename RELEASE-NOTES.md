# Solon 제품 릴리스 노트

**언어**: 한국어 / 영어 문서 예정

이 문서는 사용자가 새 버전에서 무엇을 체감하게 되는지 짧게 정리합니다.
세부 구현 기록은 [CHANGELOG.md](./CHANGELOG.md) 에 따로 둡니다.

---

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
