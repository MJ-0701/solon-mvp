---
doc_id: sfs-windows-wrapper-incident-0-6-56-ko-8
title: "Windows 확인 명령"
visibility: oss-public
doc_type: incident-report
language: ko
updated: 2026-05-22
parent: docs/ko/windows-wrapper-incident-0.6.56.md
summary: "Windows 확인 명령"
load_when: "Read when docs/ko/windows-wrapper-incident-0.6.56.md routes to this section."
---
## Windows 확인 명령

Windows PowerShell/cmd 에서는 아래 명령이 usage-only 로 떨어지면 안 됩니다.

```powershell
sfs.cmd version --check
sfs.cmd status
sfs.cmd context cat kernel
sfs.cmd start "이미지 프롬프트 고도화"
sfs.cmd status
```

`start` 이후 sprint 디렉터리가 비어 있어도 그 자체로 실패는 아닙니다. 하지만 출력이 비어 있거나
`status` / `context cat` 이 usage 만 출력하면 실패로 보고 `sfs.cmd update` 후 다시 확인합니다.
이미 설치된 0.6.49 이하 wrapper 때문에 `sfs.cmd update` 자체가 usage 만 출력하면, 최초 1회는
PowerShell 에서 `scoop update` 후 `scoop update sfs` 를 직접 실행한 뒤 프로젝트 폴더에서
`sfs.cmd upgrade --no-self-upgrade` 를 실행합니다.

