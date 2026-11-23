#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/helpers.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ci_banner "job test"
cd "$REPO_ROOT"
ci_overlay_versioned_source
require_cmd swift xcodebuild
log_step "toolchain"
xcodebuild -version
swift --version
# Tests reset shared registries and temporarily replace a global precondition handler.
log_step "swift test --no-parallel"
swift test --no-parallel
log_ok "tests passed"
