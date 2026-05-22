---
doc_id: sfs-beginner-guide-ko-3
title: "Windows 설치"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "Windows 설치"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
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

성공하면 `sfs 0.6.57`, `status up-to-date` 같은 문장이 보입니다. Windows
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

