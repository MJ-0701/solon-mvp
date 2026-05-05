# Scoop 패키징

이 디렉터리는 Solon 제품 SFS runtime 의 Scoop manifest 템플릿을 담습니다.

## Manifest 계약

`sfs.json.template` 는 릴리스 시점에 아래 placeholder 를 치환합니다.

- `__VERSION__`: 앞의 `v` 를 뺀 버전. 예: `0.6.9`
- `__URL__`: archive URL. 보통 `https://github.com/MJ-0701/solon-product/archive/refs/tags/v__VERSION__.zip`
- `__SHA256__`: Scoop 이 실제로 내려받을 archive 의 SHA256
- `__EXTRACT_DIR__`: archive 내부 루트 디렉터리. GitHub source zip 기준 보통 `solon-product-__VERSION__`

manifest 는 `bin\\sfs.cmd` 를 통해 `sfs` 를 노출합니다. wrapper 는 Git for Windows Bash 를 찾고,
패키지 안의 bash entrypoint `bin/sfs` 로 위임합니다.

설치/업데이트 뒤에는 `bin\\sfs-scoop-post-install.ps1` 도 실행합니다. 초기화된 Solon 프로젝트에서
`scoop update sfs` 를 실행하면 이 hook 이 프로젝트 루트를 감지하고
`sfs.cmd upgrade --no-self-upgrade` 를 이어서 실행합니다. 그래서 runtime 과 프로젝트 표면이 함께
움직입니다.

사용자에게 안내할 결정적 명령은 여전히 `sfs.cmd update` 입니다. 이 명령은 `scoop update`,
`scoop update sfs`, 프로젝트 upgrade 를 한 번에 처리합니다. manifest hook 을 건너뛰려면
`SFS_SCOOP_PROJECT_UPGRADE=0` 을 설정합니다. `sfs.cmd update` / `sfs.cmd upgrade` 는 Scoop runtime 을
업데이트하는 동안 이 값을 내부에서 설정한 뒤, 프로젝트 upgrade 를 직접 수행합니다.

PowerShell/cmd 예시에서는 `sfs.cmd ...` 를 명시적으로 씁니다. Git Bash/WSL 사용자는 `sfs ...` 를
써도 됩니다.

## 로컬 Windows 설치 검증

GitHub Actions workflow 는 checkout 에서 로컬 source zip 을 만들고, `file:///` URL 을 가진 임시
bucket manifest 를 렌더링한 뒤 아래 흐름을 실행합니다.

```text
scoop bucket add solon <temporary-bucket-path>
scoop install sfs
sfs.cmd version
sfs.cmd --help
mkdir test-project
cd test-project
git init
sfs.cmd init --layout thin --yes
sfs.cmd status
sfs.cmd agent install all
scoop update sfs --force
```

thin layout 검증이 중요합니다. 사용자가 명시적으로 vendored layout 을 고르지 않는 한 프로젝트의
`.sfs-local/` 에 runtime `scripts/`, `sprint-templates/`, `personas/`, `decisions-template/`
디렉터리가 들어가면 안 됩니다.

## 실제 bucket 릴리스 흐름

실제 bucket 릴리스에서는 GitHub tag 가 생기고 다운로드 archive hash 를 확인한 뒤,
별도 Scoop bucket repo 의 `bucket/sfs.json` 을 렌더링합니다. 이후 아래처럼 테스트합니다.

```text
scoop bucket add solon https://github.com/MJ-0701/scoop-solon-product
scoop install sfs
sfs.cmd version --check
sfs.cmd update
```
