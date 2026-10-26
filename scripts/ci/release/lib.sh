#!/usr/bin/env bash
# Shared by test/assemble/commit (not a GitHub job).
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/helpers.sh"

ci_overlay_versioned_source() {
  log_step "overlay versioned-source"
  local src=".ci-version"
  if [[ ! -d "$src" ]]; then
    log_info "no versioned-source overlay; using checkout as-is"
    return 0
  fi
  [[ -f "${src}/NShiftUIVersion.swift" ]] || ci_die "missing ${src}/NShiftUIVersion.swift"
  [[ -f "${src}/NShiftUITests.swift" ]] || ci_die "missing ${src}/NShiftUITests.swift"
  cp "${src}/NShiftUIVersion.swift" Sources/NShiftUI/Version/NShiftUIVersion.swift
  cp "${src}/NShiftUITests.swift" Tests/NShiftUITests/NShiftUI/NShiftUITests.swift
  log_ok "overlaid version files onto checkout"
}
