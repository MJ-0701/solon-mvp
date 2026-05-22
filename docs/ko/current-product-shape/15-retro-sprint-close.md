---
doc_id: sfs-current-product-shape-ko-15
title: "Retro 는 기본적으로 sprint close"
visibility: oss-public
doc_type: product-reference
language: ko
updated: 2026-05-22
parent: docs/ko/current-product-shape.md
summary: "Retro 는 기본적으로 sprint close"
load_when: "Read when docs/ko/current-product-shape.md routes to this section."
---
## Retro 는 기본적으로 sprint close

`sfs retro` 한 명령이 sprint 를 close 까지 마무리합니다.

```text
sfs retro
```

이 명령은 `report.md` 와 `retro.md` 를 정리하고, workbench 원문과 임시 review scratch 를 하나의
cold archive bundle 로 압축한 뒤, sprint close 상태와 local close commit 까지 연결합니다.
report 가 사용자 결정을 요구할 때는 `Q1` 같은 내부 번호만 남기지 않고, 결정의 의미와 선택지별
결과를 짧게 풀어 설명합니다.
초안만 열고 sprint 는 닫지 않고 싶을 때는 `sfs retro --draft` 를 씁니다.
예전 설치본에 남아 있던 loose sprint archive 나 별도 review-run archive 는 `sfs upgrade` 때
압축 migration 으로 정리됩니다. runtime upgrade / agent install / profile rollback 백업도
loose 파일 대신 `*.tar.gz` + `manifest.txt` bundle 로 남습니다.
`events.jsonl` 은 영구 히스토리가 아니라 현재 sprint 를 이어가기 위한 active ledger 입니다.
현재 sprint 가 없거나 오래된 sprint 이벤트만 남은 경우 upgrade/tidy 가 제거 또는 archive 합니다.
영구 인수인계는 `docs/solon/<domain>/<subdomain>/<feature>/<yyyyMMdd>/` 공유 문서와 git history 로 봅니다.
반복 cleanup evidence 도 바깥에 같은 날 timestamp 폴더를 여러 개 남기지 않고
`.sfs-local/archives/adopt/surface-cleanup/<yyyyMMdd>/manifest.txt` 와
`surface-cleanup.tar.gz` 로 날짜별 묶음 처리합니다.
thin layout 에서는 project-local `.claude/`, `.gemini/`, `.agents/` command/skill adapter 도
기본 표면에서 빠집니다. root adapter 문서가 global `sfs` runtime 을 안내하고, native
slash/skill 파일이 필요한 프로젝트만 `sfs agent install all` 로 opt-in 설치합니다.
global `sfs` / `sfs.cmd upgrade` 는 기존 vendored 프로젝트도 thin surface 로 승격합니다.
runtime 파일을 프로젝트 안에 계속 두려면 `sfs upgrade --layout vendored` 를 명시합니다.

