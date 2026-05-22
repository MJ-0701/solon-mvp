---
doc_id: sfs-beginner-guide-ko-8
title: "업데이트"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "업데이트"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
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

