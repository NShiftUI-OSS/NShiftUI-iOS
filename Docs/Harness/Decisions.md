# Decisions & known gaps

Decisões duráveis e lacunas verificadas no código. **Não inventar** APIs para preencher gaps — documentar aqui.

## Decisões

1. **Runtime, não design system** — NShiftUI orquestra plugins/events; UI concreta vive em hosts/kits (POC, demo TCC, nshiftuikit).
2. **Grafo Domain → DI → Macros → NShiftUI** — **único product SPM:** `NShiftUI` (macros via `@_exported`).
   Hosts usam `import NShiftUI`.
3. **DI próprio** — `NShiftDependencyRegistry`; sem Swinject/Factory externos.
4. **Macros via swift-syntax** — única dependência remota de syntax; pin típico `603.0.1` quando `Package.resolved` existe.
5. **Container obrigatório para `NShiftView`** — só `NShiftPluginContainer` registrados em `NShiftPluginContainerCatalog` passam no precondition do host.
6. **Engine default open** — `NShiftDefaultEngine` é `open`; custom via `registerEngine` quando resolvido no container.
7. **Children/slots no modelo** — `NShiftPluginModel.children` / `slots`; node espelha em `children` / `slotChildren`.
8. **Views via DI** — `@NShiftPluginAssemble` emite `registerPlugin`; store resolve `AnyView`. Sem `pluginRegister()` / `@NShiftMainPluginRegister`.
9. **Versão** — `NShiftUIVersion.current` = `0.2.0-beta.1`; branch `release/0.2.0-beta.1`.
10. **Platforms SPM** — iOS 15 / macOS 14.
11. **Init canónico failable** — `NShiftPlugin` / container: `init?(model:resolver:eventHandler:engine:renderID:)` (uma firma). Event: `init?(model:resolver:)`. Autor não sobrescreve. Metadata tipada e ViewModel (`resolve(T.self)`) falham para `nil` → skip render/execute. `eventHandler`/`engine` continuam unwrap/precondition.
12. **Identidade dual** — `id?` (busca / replace* / events); `renderId` posicional (`r` / `r/c/i` / `r/s/Name/i`) para ForEach / `.id`. Não misturar; não reviver UUID-como-View-id.
13. **Sem explosão de generics no View path** — `NShiftView` / `NShiftNodeView` / `NShiftChildrenAccessor` não são genéricos; `NShiftSlotsAccessor` só em `Key: NShiftSlotKey`.
14. **Author DX** — SwiftUI `var body` + `children()` / `slots(key)` no próprio plugin; modelo `children`.
15. **AnyView na fronteira do store** — meio para o recorte de generics, não objetivo de design. `engine.makeView` → `pluginStore.resolve` → `AnyView(plugin.id(renderID))`.
16. **Author members no plugin** — `@State` / helpers / computed ficam no struct do autor (sem wrapper `NShiftContent`).
17. **Metadata unificado** — um protocolo `NShiftMetadata` (+ `NShiftEmptyMetadata` / `AnyNShiftMetadata` / macro `@NShiftMetadata`) para plugins **e** events; removidos `NShiftPluginMetadata` / `NShiftEventMetadata`.
18. **Tokens CMS** — `NShiftTokenMetadata` + `@NShiftTokenMetadata`: **somente enum**, `RawValue == String`, sem associated values; sintetiza RawRepresentable / CaseIterable / Hashable / Sendable.
19. **Rainbow** — NShiftUI depende de `rainbowparser` (sintaxe). Semântica em `NShiftRainbowCompiler`: `()` → params/metadata/style; `{}` → children; nós marcadores (`NavLeading`…) → slots; `OnTap`… → trigger + events. Metadata tipada via `NShiftRainbowMetadataDecoding` (host registra Decodable por plugin).
20. **Macros em lote** — `providingMacros` tem **7** tipos. Corte parcial quebra expansão e hosts; Plugin + Assemble + (apagado MainRegister) + Event + EventAssemble + SlotKey + Metadata + Token viajam juntos.
21. **Sem CI GitLab** — `.gitlab-ci.yml` só com `workflow: when: never` (sem SAST / secret-detection / `swift test` no runner). Testes no host: `swift test`.

## Known gaps

| Gap | Evidência | Impacto |
|-----|-----------|---------|
| **nshiftuikit** | Kit irmão ainda pode estar em API antiga. | Migrar para `children()`/`slots` + `registerPlugin` / `@NShiftPluginAssemble` se for consumir 0.2. |
| **Rainbow style completo** | Compiler só mapeia `style.spacing` hoje. | Expandir frame/alignment quando o host precisar. |
| **README template** | Ainda template GitLab. | Não usar como fonte de arquitetura. |
| **Package.resolved no .gitignore** | Pin local pode divergir. | Remap lê resolved se presente. |

## Unknowns (não especular)

- Escopo exato do app de demonstração do TCC (fora deste package).
- Roadmap de API estável pós-beta — tratar `0.2.0-beta.1` como pré-estável.

## Ao remapear

Se um gap for fechado no código, **remover** da tabela acima e atualizar `Architecture.md` / `API.md`. Se surgir API nova sem certeza de estabilidade, listar como gap ou “provisional” aqui — nunca documentar como pública sem `public` no source.
