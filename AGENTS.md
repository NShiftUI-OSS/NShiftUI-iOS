# NShiftUI — Agent Guide

NShiftUI is a **plugin-based SwiftUI runtime**: host apps register services, plugin views, and events via DI + macros (`registerPlugin` / `@NShiftPluginAssemble`), then render `NShiftPluginModel` trees through `NShiftView(model:)`. It is **not** a design system. Version: **0.2.0-beta.1** (`NShiftUIVersion.current`; branch `release/0.2.0-beta.1`). Platforms: iOS 15+ / macOS 14+ (SPM).

## Read order (progressive disclosure)

1. `Docs/Harness/INDEX.md` — what to open next
2. `Docs/Harness/Architecture.md` — layers + bootstrap/runtime
3. `Docs/Harness/Map.md` — module/file map
4. `Docs/Harness/API.md` — public surface (only when touching APIs)
5. `Docs/Harness/Conventions.md` / `Decisions.md` — style + known gaps

Do **not** dump all of `Sources/` into context. Open only the files the task needs.

## Commands

From this package root:

```bash
swift build
swift test
```

## Ecosystem

- **Sole SPM product:** `NShiftUI` (`import NShiftUI` re-exports Domain, DI, macros).
- External deps: `swift-syntax` (macros) + `rainbowparser` (`release/0.1.0-beta.1`) for Rainbow → `NShiftPluginModel`.
- Does **not** depend on `nshiftuikit`.
- Views: DI `registerPlugin` (AnyView at the store boundary). `NShiftView` roots are registered `NShiftPluginContainer` types.
- Plugin author DX: SwiftUI `var body` + `children()` / `slots(key)`; model field `children`; identity = optional server `id` + positional `renderId` (`r` / `r/c/i`).
- Validated host: NShiftAppPOC (Precision Lab — counter identity across `replaceChildren`).

## Operating principles

- Prefer scoped changes; match existing naming, DI, and macro patterns.
- Domain → DI → Macros → NShiftUI; do not invert dependencies.
- Verify with `swift test` after behavior changes.
- Never invent APIs; if unsure, mark a gap in `Docs/Harness/Decisions.md`.

## Update harness

After meaningful architecture/API/module changes, run the remapper:

→ `Agents/UpdateHarness/SKILL.md`

## Cross-tool

- **Canonical:** `AGENTS.md` (this file). `CLAUDE.md` → symlink to it.
- Cursor: `.cursor/rules/harness.mdc` + skill symlink under `.cursor/skills/`.
- Claude Code: `.claude/commands/update-harness.md` + skill symlink.
- Codex: `.agents/skills/update-harness` → same skill.
