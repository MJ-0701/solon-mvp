---
doc_id: sfs-beginner-guide-ko-4
title: "Mac 설치"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "Mac 설치"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
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

