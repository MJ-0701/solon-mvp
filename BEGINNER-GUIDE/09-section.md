---
doc_id: sfs-beginner-guide-ko-9
title: "막혔을 때"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "막혔을 때"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
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

