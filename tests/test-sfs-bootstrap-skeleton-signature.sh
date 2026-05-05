#!/usr/bin/env bash
# tests/test-sfs-bootstrap-skeleton-signature.sh — R-C AC-func-5 + AC-rev-2 test.
#
# Skeleton (zero-feature, only boilerplate Application.kt + ApplicationTests.kt) → exit 0.
# Featured project (controller annotation present) → exit 1.
# Invalid arg → exit 2.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SCRIPT="${DIST_DIR}/scripts/sfs-bootstrap-skeleton-signature.sh"

[[ -x "${SCRIPT}" ]] || { echo "missing: ${SCRIPT}" >&2; exit 1; }

tmp="$(mktemp -d)"
cleanup() { rm -rf "${tmp}"; }
trap cleanup EXIT

cd "${tmp}"

# === Skeleton case (boilerplate-only) ===
mkdir -p skeleton/src/main/kotlin/com/example/demo
mkdir -p skeleton/src/main/resources
mkdir -p skeleton/src/test/kotlin/com/example/demo

cat > skeleton/src/main/kotlin/com/example/demo/Application.kt <<'EOF'
package com.example.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class Application

fun main(args: Array<String>) {
    runApplication<Application>(*args)
}
EOF

cat > skeleton/src/test/kotlin/com/example/demo/ApplicationTests.kt <<'EOF'
package com.example.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class ApplicationTests {

    @Test
    fun contextLoads() {
    }
}
EOF

# AC-func-5: skeleton dir → exit 0.
if ! bash "${SCRIPT}" skeleton; then
  echo "FAIL: skeleton dir should detect as skeleton (exit 0)" >&2
  exit 1
fi

# === Featured case (controller endpoint present) ===
mkdir -p featured/src/main/kotlin/com/example/demo
mkdir -p featured/src/test/kotlin/com/example/demo

cat > featured/src/main/kotlin/com/example/demo/Application.kt <<'EOF'
package com.example.demo

import org.springframework.boot.autoconfigure.SpringBootApplication

@SpringBootApplication
class Application
EOF

cat > featured/src/main/kotlin/com/example/demo/HelloController.kt <<'EOF'
package com.example.demo

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class HelloController {
    @GetMapping("/hello")
    fun hello() = "world"
}
EOF

cat > featured/src/test/kotlin/com/example/demo/ApplicationTests.kt <<'EOF'
package com.example.demo

import org.junit.jupiter.api.Test

class ApplicationTests {

    @Test
    fun contextLoads() {
    }
}
EOF

# AC-rev-2: featured project (HelloController + @GetMapping) → exit 1 (normal review path).
set +e
bash "${SCRIPT}" featured
rc=$?
set -e
[[ "${rc}" == "1" ]] || { echo "FAIL: featured dir should detect as featured (exit 1), got rc=${rc}" >&2; exit 1; }

# === Featured by extra test (real @Test beyond contextLoads) ===
mkdir -p featured-with-extra-test/src/main/kotlin/com/example/demo
mkdir -p featured-with-extra-test/src/test/kotlin/com/example/demo

cat > featured-with-extra-test/src/main/kotlin/com/example/demo/Application.kt <<'EOF'
package com.example.demo
@org.springframework.boot.autoconfigure.SpringBootApplication
class Application
EOF

cat > featured-with-extra-test/src/test/kotlin/com/example/demo/ApplicationTests.kt <<'EOF'
package com.example.demo
import org.junit.jupiter.api.Test
class ApplicationTests {
    @Test fun contextLoads() {}
    @Test fun realFeatureTest() {}
}
EOF

set +e
bash "${SCRIPT}" featured-with-extra-test
rc=$?
set -e
[[ "${rc}" == "1" ]] || { echo "FAIL: extra-test dir should detect as featured (exit 1), got rc=${rc}" >&2; exit 1; }

# === Invalid arg (no positional) ===
set +e
bash "${SCRIPT}" 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: missing arg should exit 2, got rc=${rc}" >&2; exit 1; }

# === Invalid arg (nonexistent dir) ===
set +e
bash "${SCRIPT}" /nonexistent-skeleton-dir 2>/dev/null
rc=$?
set -e
[[ "${rc}" == "2" ]] || { echo "FAIL: nonexistent dir should exit 2, got rc=${rc}" >&2; exit 1; }

echo "test-sfs-bootstrap-skeleton-signature: OK"
