---
doc_id: sfs-beginner-guide-ko-10
title: "도움 요청할 때 보내면 좋은 정보"
visibility: oss-public
doc_type: beginner-guide
language: ko
updated: 2026-05-22
parent: BEGINNER-GUIDE.md
summary: "도움 요청할 때 보내면 좋은 정보"
load_when: "Read when BEGINNER-GUIDE.md routes to this section."
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

