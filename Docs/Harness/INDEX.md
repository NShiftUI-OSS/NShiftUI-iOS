# Harness INDEX — progressive disclosure

Leia só o necessário. Ordem sugerida:

| Quando | Arquivo | Conteúdo |
|--------|---------|----------|
| Sempre (entrada) | `AGENTS.md` | Identidade, comandos, princípios |
| Orientação | **este INDEX** | Mapa de leitura |
| Entender o sistema | `Architecture.md` | Grafo de targets, bootstrap, runtime |
| Achar arquivos | `Map.md` | Árvore Sources/Tests densa |
| Mudar API pública | `API.md` | Product + tipos públicos |
| Estilo / macros / DI | `Conventions.md` | Naming, MainActor, Sendable, testes |
| Gaps / decisões | `Decisions.md` | Lacunas conhecidas, não inventar |
| Remapear docs | `Update.md` | Checklist do `update-harness` |

## Atalhos por tarefa

- **Novo plugin/evento no host:** `Architecture.md` → `API.md` (macros + `registerPlugin` / `@NShiftPluginAssemble`) → `Conventions.md`
- **Multi-módulo / assemblies:** `Architecture.md` + `API.md` (`NShiftConfig.startup` + `registerPlugin`)
- **Children/slots + `renderId` + replace fino:** `Architecture.md` + `Rendering/Children/` + `NShiftRenderID` / `NShiftEngine`
- **NShiftView / raiz:** `Architecture.md` — só `NShiftPluginContainer` registrado
- **DI (services + plugins + events):** `Map.md` (NShiftUIDI) → `NShiftDependencyRegistry`
- **Macro expansion:** `NShiftPluginMacro.swift` + `Tests/.../NShiftUIMacros/*MacroTests.swift` (XCTest)
- **Author children/slots / `@State` no plugin:** macro gera accessors no struct do autor

## Anti-padrões de contexto

- Não carregar `.build/` nem checkouts de `swift-syntax`.
- Não ler todos os testes de macro de uma vez; abra o arquivo do macro sob teste.
- README na raiz ainda é template GitLab — não use como fonte de verdade.
- Não tratar `Experiments/TypedRegistryPrototype` como API do product.
