# Handoff — Scoop bucket 0.6.8 publish

**To**: Codex
**From**: 직전 Claude session (0.6.1 → 0.6.8 cascade hotfix 마무리 직후)
**Status**: brew 측 완료, **Scoop 측만 남음**.

## Mission (한 줄)

`MJ-0701/solon-product` 의 v0.6.8 을 Windows 사용자가 `scoop install sfs` /
`scoop update sfs` 로 받을 수 있도록 **scoop manifest 의 url / hash / version /
extract_dir 4 필드를 0.6.8 로 갱신**한다. brew tap 갱신과 동일한 패턴.

## 끝낸 일 (참고 — 다시 하지 말 것)

| 항목 | 상태 | 위치 |
|---|---|---|
| solon-product main 에 0.6.8 commit + tag push | ✅ | HEAD `73ca907`, tag `v0.6.8` |
| brew tap (`MJ-0701/homebrew-solon-product`) 의 `Formula/sfs.rb` 갱신 + push | ✅ | url v0.6.8, sha256 (.tar.gz) `65dacad7de65452abfc1a6dfff633849cf89c2d045e82e4a67b967ab264b7a1a` |
| `brew info sfs` 가 `0.6.1 → stable 0.6.8` 표시 확인 | ✅ | local mac |

## 절대 하지 말 것

- ❌ `~/agent_architect/2026-04-19-sfs-v0.4/scripts/cut-release.sh --apply` —
  본 스크립트는 dev staging 의 옛날 버전으로 stable repo 의 9 개 hotfix 파일
  (`bin/sfs`, `sfs-loop.sh`, `sfs-migrate-artifacts.sh`,
  `sfs-release-sequence.sh`, `test-release-suffixless-hard-cut.sh`,
  `test-sfs-archive-branch-sync.sh`, `homebrew/sfs.rb`,
  `homebrew/sfs.rb.template`, `docs/{ko,en}/index.md`) 를 덮어써서 0.6.2~0.6.8
  cascade fix 가 통째로 revert 됨. 별도 sprint 에서 backport 후 사용.
- ❌ `packaging/scoop/sfs.json` (solon-product 본 repo 안) 을 직접 수정 + push
  — bucket repo 가 별도면 그건 source-of-truth 가 아닐 수 있음. 먼저 bucket
  위치 확인 후 결정.

## 해야 할 일 (순서대로)

### 1. scoop bucket repo 위치 확인

후보 두 개 — 둘 중 어느 모델인지 확인:

**(a) 별도 bucket repo 모델** (brew tap 과 동일 패턴 — 가장 가능성 큼)

```bash
gh repo list MJ-0701 --json name,description --limit 50 | grep -iE 'scoop|bucket'
```

또는 GitHub 웹에서 `MJ-0701/scoop-*` / `MJ-0701/*-bucket` 검색.
typical 이름: `MJ-0701/scoop-solon-product`, `MJ-0701/scoop-bucket`,
`MJ-0701/solon-bucket`.

찾으면 clone:

```bash
cd ~/tmp
git clone https://github.com/MJ-0701/<bucket-repo-name>.git
cd <bucket-repo-name>
ls -la   # sfs.json 또는 bucket/sfs.json 위치 확인
```

**(b) `MJ-0701/solon-product` 의 `packaging/scoop/sfs.json` 직접 노출 모델**

scoop 의 `bucket add` 가 `MJ-0701/solon-product` 를 직접 가리키면 본 repo
안의 manifest 가 곧 published manifest. 그럼 1-(a) 의 별도 bucket 없음.

확인 방법: 본인 또는 사용자가 어떻게 install 했는지 — 보통 README 나
docs 에 `scoop bucket add solon-product https://github.com/...` 기록.

```bash
grep -rE 'scoop bucket add|scoop install sfs' ~/tmp/solon-product/README.md \
  ~/tmp/solon-product/docs ~/tmp/solon-product/BEGINNER-GUIDE.md 2>/dev/null
```

### 2. v0.6.8 zip tarball 의 sha256 계산

scoop 은 `.zip` 사용 (brew 와 다름). 새로 계산해야 함:

```bash
curl -fsSL https://github.com/MJ-0701/solon-product/archive/refs/tags/v0.6.8.zip -o /tmp/sfs-0.6.8.zip
shasum -a 256 /tmp/sfs-0.6.8.zip
```

64자 hex 출력. 다음 단계에서 `<ZIP_SHA256>` 자리에 씀.

### 3. manifest 갱신

**`packaging/scoop/sfs.json` 의 현재 상태** (sandbox 확인):

```json
{
  "version": "0.6.0",
  "architecture": {
    "64bit": {
      "url": "https://github.com/MJ-0701/solon-product/archive/refs/tags/v0.6.0.zip",
      "hash": "__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__",
      "extract_dir": "solon-product-0.6.0"
    }
  }
  ...
}
```

**바꿀 4 필드**:

| 필드 | 현재 | 0.6.8 |
|---|---|---|
| `version` | `0.6.0` | `0.6.8` |
| `url` | `.../v0.6.0.zip` | `.../v0.6.8.zip` |
| `hash` | `__SHA256_PLACEHOLDER_FOR_RELEASE_CUT__` | `<ZIP_SHA256>` (step 2) |
| `extract_dir` | `solon-product-0.6.0` | `solon-product-0.6.8` |

**bucket repo 모델 (1-a)** 인 경우 — bucket repo 의 `sfs.json` 에 적용:

```bash
cd ~/tmp/<bucket-repo-name>
sed -i.bak \
  -e 's|"version": "[0-9.]*"|"version": "0.6.8"|' \
  -e 's|/v[0-9.]*\.zip|/v0.6.8.zip|' \
  -e 's|"hash": "[^"]*"|"hash": "<ZIP_SHA256>"|' \
  -e 's|"extract_dir": "solon-product-[0-9.]*"|"extract_dir": "solon-product-0.6.8"|' \
  sfs.json
diff sfs.json.bak sfs.json   # 4 줄만 바뀌어야 정상
rm sfs.json.bak
git add sfs.json && git commit -m "sfs 0.6.8" && git push origin main
```

**solon-product 직접 모델 (1-b)** 인 경우 — `~/tmp/solon-product/packaging/scoop/sfs.json` 에 적용:

```bash
cd ~/tmp/solon-product
sed -i.bak \
  -e 's|"version": "[0-9.]*"|"version": "0.6.8"|' \
  -e 's|/v[0-9.]*\.zip|/v0.6.8.zip|' \
  -e 's|"hash": "[^"]*"|"hash": "<ZIP_SHA256>"|' \
  -e 's|"extract_dir": "solon-product-[0-9.]*"|"extract_dir": "solon-product-0.6.8"|' \
  packaging/scoop/sfs.json
diff packaging/scoop/sfs.json.bak packaging/scoop/sfs.json
rm packaging/scoop/sfs.json.bak
```

이 경우 0.6.9 hotfix 로 처리하는 게 정합:

```bash
echo "0.6.9" > VERSION
# CHANGELOG.md 에 [0.6.9] entry 추가 (Fixed: scoop manifest pinned to v0.6.8)
git add VERSION CHANGELOG.md packaging/scoop/sfs.json
git commit -m "release: 0.6.9 — scoop manifest pinned to v0.6.8 (catch-up after brew tap)"
git tag v0.6.9
git push origin main
git push origin v0.6.9
```

### 4. 검증

**Windows 사용자 또는 Windows VM 에서**:

```powershell
scoop update
scoop info sfs   # 0.6.8 보여야 정상
scoop install sfs   # 또는 scoop update sfs
sfs version       # sfs 0.6.8 출력
```

**또는 GitHub Actions `Windows Scoop Smoke` 워크플로우**:

본 push 직후 자동 trigger. 결과 GREEN 떠야 정상. 이전 `Windows Scoop Smoke
#62` 가 hang 처럼 보였던 건 단지 길어진 step 일 가능성 — 최신 run 결과 확인.

## 데이터 참고

- **solon-product v0.6.8 tag commit**: `73ca907`
- **.tar.gz sha256 (brew)**: `65dacad7de65452abfc1a6dfff633849cf89c2d045e82e4a67b967ab264b7a1a`
- **.zip sha256 (scoop)**: 계산 필요 (step 2)
- **brew tap repo**: `MJ-0701/homebrew-solon-product` (이미 갱신 완료)
- **scoop bucket repo**: TBD — step 1 에서 확정

## 본 cascade 의 컨텍스트 (참고만)

0.6.1 → 0.6.8 동안 일어난 일:
- 0.6.2: macOS bash 3.2 + `set -u` 의 `dep_args[@]` unbound variable crash fix
- 0.6.3: `brew audit --new-formula` deprecation 우회
- 0.6.4: `brew audit [path]` disable 우회 → `brew style` 로 교체
- 0.6.5: brew style placeholder skip + formula template style 보강
- 0.6.6: macOS bash 3.2 CI workflow 추가 → 0.6.8 에서 scope-creep 으로 제거
- 0.6.7: pre-existing 4 fail 정리 (.gitattributes / archive-branch-sync /
  migrate-quoted-paths / suffixless skip)
- 0.6.8: .gitattributes extensionless 보강 + 0.6.6 workflow revert

자세한 narrative + 4 receipts cascade analysis: `docs/ko/cross-review-principle.md`
(`docs/en/cross-review-principle.md` mirror).

## 다음 sprint candidates (이 handoff 범위 밖)

- dev staging (`~/agent_architect/2026-04-19-sfs-v0.4/solon-mvp-dist/`) 의 9
  파일에 0.6.2~0.6.8 hotfix backport. 그래야 다음 release 부터 cut-release.sh
  가 정상 동작 (dev → stable sync 모델 복구).
- `Windows Scoop Smoke` 워크플로의 `Smoke thin project in PowerShell` step
  소요 시간이 정상인지 / 어느 명령에서 길어지는지 markers 박아 진단.

## 끝났을 때 알려줄 것

- bucket repo 가 (a) 별도냐 (b) solon-product 직접이냐 → 어느 모델로 갱신했는지
- 새로 commit 한 sha (bucket repo 측) 또는 0.6.9 release 여부 (solon-product 측)
- `scoop info sfs` 또는 Windows Scoop Smoke 워크플로의 GREEN 결과 캡쳐
