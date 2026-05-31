#!/usr/bin/env bash
# tests/test-find-bsd-portability.sh — bash-compat 회귀 잠금 (0.8.3).
#
# release-policy #1 (Bash 호환): 출하 bash (`bin/`, `templates/`, `scripts/`)
# 는 macOS zsh/BSD · Linux GNU · WSL 모두에서 동작해야 한다. `find` 의 일부
# primary 는 GNU 전용이며 macOS BSD-find 에는 없어 무음 실패(빈 출력)한다.
#
# 배경: 0.8.2 까지 `sfs context list` 가 `find ... -printf '%f\n'` 를 써서
# Linux 에선 PASS, macOS 에선 빈 출력 → test-context-list-command 가
# macOS 에서만 fail 하는 "139/1" chip 이 여러 WU 에 걸쳐 반복됐다. 0.8.3 이
# 이를 `find ... | sed 's#.*/##'` 로 교체했고, 본 테스트는 GNU 전용 find
# primary 가 출하 bash 에 다시 들어오면 fail 시키는 음성잠금이다.
#
# 이 테스트는 실제 macOS 가 없어도 (Linux CI 에서도) 결함을 잡는다 —
# 플랫폼 의존이 아니라 정적 grep 이므로 macOS-only green 위험을 차단한다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

fail() { echo "FAIL: $*" >&2; exit 1; }

# GNU 전용 find primary 들 (BSD-find 미지원). 필요 시 확장.
GNU_ONLY_FIND_FLAGS=(-printf -regextype)

# 스캔 대상: 출하되는 bash 트리.
SCAN_DIRS=(bin templates scripts)

cd "${DIST_DIR}"

violations=0
for flag in "${GNU_ONLY_FIND_FLAGS[@]}"; do
  # 주석 줄(공백 후 #)은 제외하고 실제 코드에서의 사용만 본다.
  # grep -rn 출력: <path>:<lineno>:<content>
  while IFS= read -r hit; do
    [[ -z "${hit}" ]] && continue
    # content = 3번째 콜론 이후. 주석(첫 비공백이 #)이면 skip.
    content="${hit#*:}"; content="${content#*:}"
    trimmed="${content#"${content%%[![:space:]]*}"}"
    [[ "${trimmed}" == \#* ]] && continue
    echo "  GNU-only find flag '${flag}' in: ${hit}" >&2
    violations=$((violations + 1))
  done < <(grep -rn -- "${flag}" "${SCAN_DIRS[@]}" 2>/dev/null || true)
done

[[ "${violations}" -eq 0 ]] \
  || fail "${violations} GNU-only find primary 사용 발견 — BSD-find(macOS)에서 무음 실패한다. portable 대안(예: find ... | sed 's#.*/##')으로 교체하라."

echo "test-find-bsd-portability: OK"
