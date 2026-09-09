---
name: update-harness
description: Remaps this repository's AI harness (AGENTS.md + Docs/Harness) from the live codebase. Use after architecture/API/module changes, or when the user asks to update/refresh/remap the harness.
---

# update-harness

Remapeia o harness de IA deste package a partir do código real. Fonte canônica deste skill: `Agents/UpdateHarness/SKILL.md` (bridges Cursor/Claude/Codex são symlinks).

## Escopo

- **Escrever apenas** dentro da raiz deste package (`nshiftui`).
- Atualizar: `AGENTS.md`, `Docs/Harness/*`, bridges/symlinks se quebrados.
- **Não** alterar `Sources/` ou `Tests/` salvo se o harness exigir (quase nunca).
- **Não** commit/push a menos que o usuário peça.

## Procedimento

1. **Re-scan**
   - `Package.swift` (products, targets, deps, platforms, swift tools/language)
   - `Package.resolved` se existir (pin de swift-syntax)
   - Árvore `Sources/**` e `Tests/**`
   - `NShiftUIVersion` / branch git se disponível
   - `README.md`, `.gitlab-ci.yml` (gaps de docs/CI)
   - Grep de `public` para superfície de API

2. **Diff** contra `Docs/Harness/Architecture.md`, `Map.md`, `API.md`, `Conventions.md`, `Decisions.md`, `INDEX.md`

3. **Atualizar docs** com fatos verificados:
   - Grafo Domain → DI → Macros → NShiftUI
   - Products `NShiftUI` + `NShiftUIMacros`
   - Bootstrap (`NShiftConfig.startup`) e runtime (`NShiftView` → engine → node)
   - Mapa de arquivos denso
   - API pública real (sem inventar)
   - Convenções (macros, DI, MainActor, Sendable, testes)
   - Gaps em `Decisions.md` (ex.: children auto-render, README template, CI sem swift test)

4. **AGENTS.md**
   - Manter curto (ideal ≤120 linhas)
   - Refresh só fatos que mudaram (versão, deps, read order, comandos)
   - Preservar ponteiro para este skill e nota cross-tool

5. **Symlinks / bridges** — verificar e recriar se necessário:
   ```bash
   ln -sfn AGENTS.md CLAUDE.md
   ln -sfn ../../Agents/UpdateHarness .cursor/skills/update-harness
   ln -sfn ../../Agents/UpdateHarness .claude/skills/update-harness
   ln -sfn ../../Agents/UpdateHarness .agents/skills/update-harness
   ```
   - `.cursor/rules/harness.mdc` e `.claude/commands/update-harness.md` devem continuar apontando para AGENTS/INDEX e este skill

6. **Regras de verdade**
   - Nunca inventar APIs ou fluxos
   - Desconhecido → gap em `Decisions.md`
   - Sem placeholders “TODO fill later”
   - Seguir contrato em `Docs/Harness/Update.md`

7. **Saída** — changelog curto do que foi remapeado + status dos symlinks + gaps novos/removidos

## Referência rápida

Ver `Docs/Harness/Update.md` para checklist e output contract.
