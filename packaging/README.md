---
doc_id: sfs-packaging-channel-map
title: "패키징 채널 지도"
visibility: oss-public
doc_type: packaging-doc
language: ko
updated: 2026-05-26
summary: "제품 repo packaging fixture 와 실제 Homebrew/Scoop 배포 채널의 권위 경계를 설명한다."
load_when: "Read when changing Homebrew/Scoop packaging, release cut, or channel verification."
---
# 패키징 채널 지도

`packaging/` 은 제품 repo 안의 패키징 fixture 와 template 을 담습니다. 실제 사용자 배포 채널의
권위본은 외부 repo 입니다.

- Homebrew tap: `MJ-0701/homebrew-solon-product`
- Scoop bucket: `MJ-0701/scoop-solon-product`

## 권위 경계

`packaging/homebrew/sfs.rb.template` 와 `packaging/scoop/sfs.json.template` 는 릴리스 렌더링의 입력입니다.
`packaging/homebrew/sfs.rb` 와 `packaging/scoop/sfs.json` 은 style/schema/smoke 를 위한 source-side
fixture 입니다. 이 두 fixture 는 예전 버전이나 `__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__` 를 담을 수
있으며, 최신 배포 채널의 SoT 가 아닙니다.

현재 설치/배포 상태는 아래 중 하나로 확인합니다.

- `sfs version --check`
- external Homebrew tap 의 `Formula/sfs.rb`
- external Scoop bucket 의 `bucket/sfs.json`
- `scripts/verify-product-release.sh --version <version>`

## 변경 규칙

template, fixture, 실제 channel repo 중 하나를 바꾸면 나머지 경계가 헷갈리지 않도록 함께 확인합니다.
최소 확인은 `test-homebrew-formula-style.sh`, `scoop-manifest-validate.sh`,
`test-release-sequence.sh`, `test-release-verifier-quiet-smokes.sh` 입니다.
