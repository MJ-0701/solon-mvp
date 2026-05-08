# Solon SFS CLI 초보자 가이드

이 문서는 개발, 터미널, CLI 환경에 아직 익숙하지 않은 분들이 Solon SFS 를 처음 설치하고
첫 작업까지 가기 위한 안내서입니다. 모르는 용어를 하나씩 검색하지 않아도 되도록, 필요한 말과
명령을 차례대로 적었습니다.

목표는 하나입니다.

```text
내 프로젝트 폴더에서 Windows 는 sfs.cmd status, Mac/Git Bash 는 sfs status 가 실행되면 설치 성공입니다.
```

---

## 먼저 알아둘 말 7개

| 말 | 뜻 |
|---|---|
| Solon | AI 와 함께 제품 일을 진행하기 위한 로컬 운영 시스템 |
| SFS | Solo Founder System 의 줄임말 |
| PowerShell | Windows 에서 명령을 붙여넣는 검은/파란 창 |
| Terminal | Mac 에서 명령을 붙여넣는 창 |
| Git | 프로젝트 폴더의 변경 기록을 관리하는 도구 |
| Scoop | Windows 에서 Solon 을 설치하는 도구 |
| Homebrew | Mac 에서 Solon 을 설치하는 도구 |

Solon 은 Figma 나 Notion 처럼 앱 아이콘을 눌러 여는 제품이 아닙니다. 프로젝트 폴더 안에
작업 규칙과 기록 공간을 만들어 주고, Claude, Codex, Gemini 같은 AI 도구가 그 폴더를 읽고
같은 맥락으로 일하게 해주는 시스템입니다.

---

## 어떤 길을 선택하면 되나요?

| 내 환경 | 따라갈 섹션 |
|---|---|
| Windows 사용자 | Windows 설치 |
| Mac 사용자 | Mac 설치 |
| 이미 설치했는데 업데이트하고 싶음 | 업데이트 |
| 설치 중 막힘 | 막혔을 때 |

Windows 사용자는 Scoop 경로를 권장합니다. 다른 분께 안내하거나 화면 공유를 받을 때도 이
경로가 가장 설명하기 쉽습니다.

---

## Windows 설치

PowerShell 을 엽니다.

- 시작 메뉴에서 `PowerShell` 을 검색합니다.
- 관리자 권한으로 열 필요는 없습니다.
- 아래 명령을 한 줄씩 복사해서 붙여넣고 Enter 를 누릅니다.

### 1. Git Bash 설치

Solon 은 내부에서 bash 라는 실행 환경을 씁니다. Windows 에서는 Git for Windows 를 설치하면
같이 들어옵니다.

```powershell
winget install --id Git.Git -e --source winget
```

이미 설치되어 있다고 나오면 괜찮습니다. 다음 단계로 넘어가세요.

### 2. Scoop 설치

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

중간에 `Y` 를 누르라고 나오면 `Y` 를 입력하고 Enter 를 누릅니다.

### 3. Solon 설치

```powershell
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
```

이 한 줄이 끝나면 Claude Code (`/sfs`), Gemini CLI (`sfs`), Codex CLI
(`$sfs`) 세 곳 모두에서 Solon 명령을 찾을 수 있습니다. 별도의 plugin
install 명령을 따로 칠 필요가 없습니다.

설치는 아래 명령으로 확인합니다.

```powershell
sfs.cmd version --check
sfs.cmd doctor      # ✅ 세 줄 (Claude / Gemini / Codex) 모두 보이면 OK
```

성공하면 `sfs 0.6.45`, `status up-to-date` 같은 문장이 보입니다. Windows
PowerShell 이나 cmd 에서는 `sfs.cmd` 를 쓰고, Git Bash/WSL 에서는 `sfs` 를 쓰셔도 됩니다.

### 4. 테스트 프로젝트 폴더 만들기

처음에는 실제 중요한 폴더에서 바로 시작하지 말고 테스트 폴더에서 먼저 해보시는 것을 권장합니다.

```powershell
mkdir $HOME\Desktop\solon-test
cd $HOME\Desktop\solon-test
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

`sfs.cmd status` 가 현재 상태를 출력하면 설치 성공입니다.

---

## Mac 설치

Terminal 을 엽니다.

### 1. Homebrew 설치 여부 확인

```bash
brew --version
```

버전이 나오면 다음 단계로 갑니다. `command not found` 가 나오면 Homebrew 를 먼저 설치합니다.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Solon 설치

```bash
brew install MJ-0701/solon-product/sfs
sfs version --check
sfs doctor              # ✅ Claude / Gemini / Codex 세 줄 모두 보이면 OK
```

이 한 줄로 Claude Code (`/sfs`), Gemini CLI (`sfs`), Codex CLI (`$sfs`)
세 곳 모두에서 Solon 을 바로 찾을 수 있습니다.

### 3. 테스트 프로젝트 폴더 만들기

```bash
mkdir -p ~/Desktop/solon-test
cd ~/Desktop/solon-test
git init
sfs init --layout thin --yes
sfs status
```

`sfs status` 가 현재 상태를 출력하면 설치 성공입니다.

---

## 실제 프로젝트에 적용하기

테스트가 성공한 뒤 실제 프로젝트 폴더로 이동합니다.

Windows:

```powershell
cd C:\workspace\my-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
```

Mac:

```bash
cd ~/workspace/my-project
git init
sfs init --layout thin --yes
sfs status
```

이미 Git 이 있는 프로젝트라면 `git init` 은 다시 해도 보통 안전합니다. 그래도 불안하면
그 줄은 건너뛰고 Windows 는 `sfs.cmd init --layout thin --yes`, Mac/Git Bash 는
`sfs init --layout thin --yes` 부터 실행하세요.

설치 후 프로젝트 폴더에는 이런 파일이 생깁니다.

| 파일/폴더 | 뜻 |
|---|---|
| `SFS.md` | AI 가 읽는 프로젝트 운영 규칙 |
| `.sfs-local/` | git 에 올리지 않는 private 작업 공간 |
| `docs/solon/` | 공유할 요약/인계 문서가 생기는 곳 |
| `CLAUDE.md` | Claude 가 Solon 을 찾는 입구 |
| `AGENTS.md` | Codex 가 Solon 을 찾는 입구 |
| `GEMINI.md` | Gemini 가 Solon 을 찾는 입구 |

---

## AI 도구에서 처음 쓰기

Solon 은 혼자 일하지 않습니다. 프로젝트 폴더를 읽을 수 있는 AI 도구와 함께 씁니다.

Claude Code 에서는 아래처럼 입력합니다.

```text
/sfs status
/sfs guide
/sfs start "첫 번째 작업 목표"
```

Gemini CLI 에서는 아래처럼 입력합니다.

```text
sfs status
sfs guide
sfs start "첫 번째 작업 목표"
```

Codex CLI 에서는 아래처럼 입력합니다.

```text
$sfs status
$sfs guide
$sfs start "첫 번째 작업 목표"
```

Windows 의 Claude/Gemini/Codex 가 내부 명령을 실행할 때 Git Bash 시작 전에
`couldn't create signal pipe, Win32 error 5` 를 내면 실행 sandbox 가 Git Bash 를 막은
상태입니다. 0.6.30 부터 `sfs.cmd status`, `sfs.cmd version`,
`sfs.cmd context cat kernel`, `sfs.cmd context cat index` 는 Git Bash 없이 바로
읽을 수 있습니다. 그때는 AI 에게 "Windows 니까 내부 확인은 native read-only 인
`sfs.cmd status` 와 `sfs.cmd context cat ...` 로 해줘" 라고 말하면 됩니다.
0.6.35 부터 상태를 바꾸는 `sfs.cmd start "첫 번째 작업 목표"` 도 PowerShell bridge 를
거쳐 Bash runtime 으로 내려갑니다. 그래도 "성공"이라고 나왔는데 출력이 비어 있으면 성공으로
보지 말고, PowerShell 에서 같은 명령을 직접 실행한 뒤 `sfs.cmd status` 로 확인하세요.
0.6.37 부터는 `sfs.cmd upgrade` 도 실행 중인 batch 파일 안에서 직접 `scoop update sfs` 를
실행하지 않습니다. `TIVE_READONLY_DONE` 또는 `LF_UPGRADE_DONE` 같은 조각 문자열이 보이면
0.6.36 self-update 경로에서 발견된 문제이므로 `sfs.cmd update` 후 다시 확인하세요.
0.6.45 기준으로는 `sfs.cmd` 를 call-label dispatch 없는 thin PowerShell trampoline 으로 줄이고, 받은 인자를
`SFS_NATIVE_ARGC` / `SFS_NATIVE_ARG_N` 번호 환경 변수로 `sfs.ps1` 에 넘깁니다. `sfs.ps1` 이
그 값이 비어 있으면 `CMDCMDLINE` 원본 명령행을 마지막 fallback 으로 읽습니다. `sfs.ps1` 이
`version`, `status`, `guide`, `context`, 업데이트, Bash 실행을 맡습니다. 그래서
`sfs.cmd context cat ...` 이나 `sfs.cmd start ...` 가 인자를 잃고 usage 만 출력하던 Windows
PowerShell/Scoop 문제를 막습니다. `e` 또는 `*` 같은 짧은 조각 문자열이 보이던 self-update 잔여
문제도 이 경로에서 막았습니다.
만약 이미 설치된 0.6.43 이하 wrapper 때문에 `sfs.cmd update` 도 usage 만 출력하면, PowerShell 에서
`scoop update sfs` 를 먼저 실행하고, 그 다음 프로젝트 폴더에서
`sfs.cmd upgrade --no-self-upgrade` 를 실행하면 됩니다.

처음 AI 에게 이렇게 말해도 됩니다.

```text
나는 개발자가 아니고 Solon SFS 를 처음 써.
이 프로젝트에서 Windows 라면 sfs.cmd status, Mac/Git Bash 라면 sfs status 를 먼저 확인하고,
지금 상태를 쉬운 말로 설명해줘.
그 다음 내가 무엇을 입력해야 하는지 한 단계씩 안내해줘.
```

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
Gemini 는 `gemini-3.1-pro-preview` 를 기본 advisor/review/facilitator 로 씁니다. Gemini
helper-grade fallback 은 `gemini-3-flash-preview` 이며 2.5 fallback 은 쓰지 않습니다. Codex 쪽
구현 worker 는 `gpt-5.3-codex` 가 기본이고, `gpt-5.3-codex-spark` 는 빠른 정리나 포맷 같은
helper 용도입니다. 위험한 구조 변경이나 보안/데이터 손실 위험이 있으면 Solon 이 더 강한 판단
모델로 올리는 흐름을 권장합니다.

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

## 업데이트

새 버전이 나왔을 때는 삭제 후 재설치하지 않으셔도 됩니다. 프로젝트 폴더에서 실행해 주세요.

Windows PowerShell/cmd:

```powershell
sfs.cmd update
```

Scoop 을 쓰는 Windows 에서는 `sfs.cmd update` 가 한 방 명령입니다. Solon 본체를
최신화하고, 현재 프로젝트에 필요한 정리까지 이어갑니다.

Mac/Git Bash:

```bash
sfs upgrade
```

Mac 에서 `sfs` 명령이 너무 오래됐거나 업데이트가 잘 안 되면 Homebrew 런타임을
먼저 올린 뒤 다시 프로젝트 업데이트를 실행해 주세요.
아래처럼 tap 이름까지 적으면 `sfs` 라는 짧은 이름이 안 잡힌 상태에서도 안전합니다.

```bash
brew upgrade MJ-0701/solon-product/sfs
sfs upgrade
sfs version --check
```

Windows Scoop 설치본은 프로젝트 폴더에서 `sfs.cmd update` 를 실행하면 Solon 본체와 현재
프로젝트 파일 갱신이 이어집니다.
Mac Homebrew 설치본도 같은 방식으로 Solon 본체를 먼저 최신화합니다.

---

## 막혔을 때

### `sfs` 명령을 찾을 수 없다고 나올 때

터미널이나 PowerShell 을 닫았다가 새로 열고 다시 실행해 주세요.

```powershell
sfs.cmd version --check
```

그래도 안 되면 Windows 에서는 아래를 확인합니다.

```powershell
scoop list sfs
```

### `bash` 를 찾을 수 없다고 나올 때

Windows 에 Git for Windows 가 없거나 PATH 에 잡히지 않은 상태입니다.

```powershell
winget install --id Git.Git -e --source winget
```

설치 후 PowerShell 을 새로 열고 다시 시도해 주세요.

### PowerShell 에서 실행 정책 오류가 나올 때

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

그 다음 막혔던 명령을 다시 실행해 주세요.

### Git 이 없다고 나올 때

Windows:

```powershell
winget install --id Git.Git -e --source winget
```

Mac:

```bash
git --version
```

Mac 에서 설치 안내가 뜨면 안내에 따라 Xcode Command Line Tools 를 설치합니다.

### 프로젝트 폴더가 어딘지 모르겠을 때

처음에는 테스트 폴더를 사용해 주세요.

Windows:

```powershell
mkdir $HOME\Desktop\solon-test
cd $HOME\Desktop\solon-test
```

Mac:

```bash
mkdir -p ~/Desktop/solon-test
cd ~/Desktop/solon-test
```

---

## 도움 요청할 때 보내면 좋은 정보

막힌 화면 전체 스크린샷과 아래 명령 결과를 같이 보내주시면 해결이 빠릅니다.

Windows:

```powershell
sfs.cmd --help
sfs.cmd guide
sfs.cmd version --check
scoop list sfs
git --version
where sfs
where sfs.cmd
```

Mac:

```bash
sfs version --check
brew list --versions sfs
git --version
which sfs
```

보낼 때 이렇게 적으면 됩니다.

```text
나는 Windows/Mac 사용자이고, Solon 설치 중 여기서 막혔어.
아래는 내가 실행한 명령과 결과야.
내가 다음에 붙여넣을 명령을 한 줄씩 알려줘.
```

---

## 기억할 것

- 검색해서 추측하지 말고 이 문서의 순서대로 진행합니다.
- 설치 성공 기준은 Windows 에서는 `sfs.cmd status`, Mac/Git Bash 에서는 `sfs status` 가
  실행되는 것입니다.
- Solon 은 개발자만을 위한 도구가 아닙니다. 제품 목표, 화면 구조, 문구, 리서치,
  QA 체크리스트, 운영 문서도 모두 Solon 안에서 다룰 수 있습니다.
- 모르는 단어가 나오면 먼저 AI 에게 "이 단어를 터미널에 익숙하지 않은 사람도 이해할 수
  있게 설명해줘"라고 물어보세요.
