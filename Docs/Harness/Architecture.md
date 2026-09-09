# Architecture

## Identity

NShiftUI = runtime SwiftUI orientado a **plugins** e **events**, com DI próprio e macros de assembly. Não é design system.

Versão: `0.2.0-beta.1` (`NShiftUIVersion.current`). Branch: `release/0.2.0-beta.1`.  
Platforms: iOS 15+, macOS 14+ (piso SPM). Swift 6 (`swiftLanguageModes: [.v6]`). Tools: 6.3.

## Target graph

```
NShiftUIDomain          (modelos, protocols, engine, PluginStore, slots, identity)
    ↑
NShiftUIDI              (registry DI, event store/handler, PluginStore concreto, registerPlugin)
    ↑
NShiftUIMacrosImplementation  (macro target; dep: swift-syntax)
    ↑
NShiftUIMacros          (declarações públicas das macros; target interno)
    ↑
NShiftUI                (único product SPM; Exports.swift @_exported Domain+DI+Macros;
                         config, engine default, NShiftView, children/slots accessors, NShiftNodeView)
```

**Products (SPM):**

| Product | Targets |
|---------|---------|
| `NShiftUI` | `NShiftUI` (+ transitivos Domain, DI, Macros, Implementation) |

Não há product separado `NShiftUIMacros` — macros entram via `import NShiftUI`.

**Dependências externas:** `swiftlang/swift-syntax` (`from: "603.0.0-latest"`) + `rainbowparser` (branch `release/0.1.0-beta.1`).

**Não depende de:** `nshiftuikit`. É consumido por apps/kits (ex.: POC host, futuro demo TCC).

**Rainbow:** `NShiftRainbowCompiler` (em `NShiftUI`) faz `RainbowDocument` → `NShiftPluginModel` (slots marcadores, triggers `On*`, metadata via decoders registrados).

**Experimento:** `Experiments/TypedRegistryPrototype` — packs + `render(children:)`; **não** é product SPM (fóssil do recorte de generics).

## Bootstrap

1. Host cria `NShiftDependencyRegistry` (ou outro `NShiftDependencyContainer`).
2. Host chama `NShiftConfig.shared.startup(hostContainer:assemblies:)`.
3. `startup` roda `[NShiftUIAssembly()] + assemblies`:
   - `assemblePlugins` → core registra `NShiftPluginStore` (`NShiftDependencyPluginStore`); host/`@NShiftPluginAssemble` chamam `registerPlugin`
   - `assembleEvents` → core registra `NShiftEventStore` + `NShiftEventHandler`; host/`@NShiftEventAssemble` registram events
4. `isStarted = true`. Segunda chamada → `precondition` failure.

Host típico:

```swift
NShiftConfig.shared.startup(hostContainer: container, assemblies: [HomeAssembly(), CheckoutAssembly()])
NShiftView(model: root)
```

`NShiftEngineResolver`: se `registerEngine` resolve `NShiftEngine` para o `rootModel`, usa custom; senão `NShiftDefaultEngine` com o `NShiftPluginStore` do container (fallback `NShiftEmptyPluginStore`).

## Runtime (render)

```
NShiftView(model:)
  → precondition: NShiftPluginContainerCatalog.shared.contains(model.name)
  → NShiftPluginContainerHost
       → NShiftEngineResolver.makeEngine(rootModel:)
            → NShiftDefaultEngine(pluginStore:) — árvore/events/mutação + makeView
            → registra NShiftEngine no container (.singleton)
       → NShiftNodeView(node:engine:)
            → engine.makeView(for:) → pluginStore.resolve(..., renderID:)
                 → factory Plugin? → AnyView(plugin.id(renderID)) ou nil
```

`NShiftView` / `NShiftNodeView` **não** são genéricos. `AnyView` vive na fronteira do `NShiftPluginStore` para não explodir generics no caminho de View.

- Raiz: só `NShiftPluginContainer` registrado; `registerPlugin` grava o nome em `NShiftPluginContainerCatalog` quando o tipo é container.
- `NShiftPluginContainerRegistry` associa `rootID` (`model.id ?? "r"`) ↔ engine (modifier de registration).
- Árvore: `NShiftPluginNode` espelha `model.children` → `children` e `model.slots` → `slotChildren`; cada node tem `renderId` posicional.
- Engine indexa por `renderId` e por `id` de servidor (quando presente); `handle(trigger:onPluginID:)` delega ao `NShiftEventHandler`.
- `init?` canónico: unwrap de metadata tipada ou `resolver.resolve(ViewModel)` falha → plugin não renderiza (`EmptyView`); evento não executa (`handleThrowing` → `.initializationFailed`). ViewModel só via DI, nunca parâmetro da factory.
- Mutações públicas do engine: `replaceMetadata`, `replacePlugin`, `replaceChildren`, `replaceSlots`, `replaceSlot`, `replaceEvents`, `replaceEvent`.
- Composição: assemblies + `@NShiftPluginAssemble` → `container.registerPlugin`.

## Children / slots

- Autor escreve `var body` + `children()` / `slots(key)` (+ overloads com ViewBuilder).
- Plugin struct **não** é genérico; fica `View` com accessors reais gerados no próprio tipo (`NShiftChildrenAccessor` / `NShiftSlotsAccessor<Key>`).
- Bridge: accessors → `NShiftNodeView` por `renderId`; `ForEach` usa `id: \.renderId`.
- Events: só `slotModels`; sem `slotContent` / renderer.
- Removidos: `NShiftRendering`, `NShiftContent`, `nshiftMake`, `pluginRegister()`, `@NShiftMainPluginRegister`, `NShiftAnyRendering`, `NShiftEmptyRenderer`, `NShiftSlotContent`.

## Identidade

- `NShiftPluginModel.id: String?` — opcional; só busca na árvore (`node(withID:)`), `replaceMetadata` / `replace*` / events.
- `NShiftRenderID` — obrigatório, path posicional (`r`, `r/c/0`, `r/s/Footer/0`, …); identidade SwiftUI/`ForEach` / `.id` no AnyView.
- Os dois **não** se misturam. Não voltar UUID-como-View-id (bug 0.1).
- `replaceChildren` / `replaceSlot(s)` preservam `renderId` nos índices estáveis.

## Layers (responsabilidades)

| Layer | Responsabilidade |
|-------|------------------|
| Domain | Models, events, triggers, `NShiftEngine`, `NShiftRenderID`, `NShiftPluginStore`, slots, version catalog, `NShiftPluginContainerCatalog` |
| DI | Registry, scopes, `registerPlugin` / `registerEvent` / `registerEngine`, event stores + `NShiftDependencyPluginStore` |
| Macros | Members Plugin/Event; accessors `children`/`slots` no struct do autor; Body assemble → `registerPlugin` / `registerEvent`; SlotKey/Metadata/Token (7 macros) |
| NShiftUI | Startup, default engine, `NShiftView`, `NShiftNodeView`, children/slots accessors, style SwiftUI, Rainbow |
