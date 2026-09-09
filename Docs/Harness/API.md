# Public API surface

Somente o que é `public` (ou macros exportadas). Tipos `package`/`internal` não são API estável para hosts.

## Products

| Import | Uso típico |
|--------|------------|
| `import NShiftUI` | **Único product SPM e único import recomendado** — UI + Domain + DI + macros (`Exports.swift`) |

`NShiftUIDomain`, `NShiftUIDI`, `NShiftUIMacros` são **targets**, não products. Macros chegam via re-export de `NShiftUI`.

## NShiftUI

| Símbolo | Notas |
|---------|--------|
| `NShiftView` | `@MainActor` `View`; `init(model:)`; exige container no `NShiftPluginContainerCatalog` |
| `NShiftNodeView` | `@MainActor` `View`; render de um `NShiftPluginNode` via `engine.makeView` |
| `NShiftChildrenAccessor` | Bridge `model.children` → `NShiftNodeView` (`ForEach` por `renderId`) |
| `NShiftSlotsAccessor<Key>` | Bridge slots → `NShiftNodeView` |
| `NShiftConfig` | `shared`; `startup(hostContainer:assemblies:)`; stores resolvidos pós-startup |
| `NShiftDefaultEngine` | `open class`; `NShiftEngineTree`; `pluginStore:` default empty; replace* + `handle` + `makeView` |
| `NShiftPluginStyleModifier` / `.nShiftPluginStyle` | SwiftUI |
| `NShiftUIVersion.current` | `"0.2.0-beta.1"` |
| `NShiftRainbowCompiler` | Rainbow source/document → `NShiftPluginModel` |
| `NShiftRainbowCompileConfiguration` | slot markers, defaultVersion, metadata decoders |
| `NShiftRainbowMetadataDecoding` / `NShiftRainbowDecodableMetadataDecoder` | decode params → `AnyNShiftMetadata` |
| `NShiftRainbowJSON` | Rainbow parameters → JSON → `Decodable` |
| `NShiftRainbowCompileError` | erros tipados do compile |

`NShiftUIAssembly`, `NShiftPluginContainerHost` → **não** públicos.

## Macros (via `import NShiftUI`)

```swift
@NShiftPlugin(name:version:metadata:slots:)        // MemberMacro — só struct; SemVer obrigatório
@NShiftEvent(name:version:metadata:slots:)         // MemberMacro — só struct; SemVer obrigatório
@NShiftMetadata()                                  // ExtensionMacro — só struct (plugin ou event)
@NShiftTokenMetadata()                             // ExtensionMacro — só enum (+ RawValue String)
@NShiftSlotKey()                                   // ExtensionMacro — só enum (+ NShiftSlotKey)
@NShiftPluginAssemble(_ plugins:)                  // BodyMacro em assemblePlugins → registerPlugin
@NShiftEventAssemble(_ events:)                    // BodyMacro em assembleEvents (factory fina)
```

Sete macros em `NShiftUIMacrosPlugin.providingMacros`. **Removido:** `@NShiftMainPluginRegister`.

Macro de plugin gera (entre outros):
- storage (`pluginChildren`, slots tipados ou untyped, `renderID`, …);
- accessors reais `children()` / `slots(key)` (+ overloads ViewBuilder) no tipo do autor;
- init canónico `init?` **sempre** gerado; o autor **não** declara init (diagnóstico).
- `NShiftPlugin` / `NShiftPluginContainer`: `init?(model:resolver:eventHandler:engine:renderID:)` — **sem** `viewModel:`.
- ViewModel só se o tipo declara: `resolver.resolve(T.self)` (container `@StateObject`). Falha → `nil`.
- Metadata tipada: `guard let … unwrap` (acaba o `?? T()`). Falha → `nil`.
- Event: `init?(model:resolver:)`. Sem `viewModel:`.
- `nil` → store não devolve view (`EmptyView` no node); evento não executa (`handleThrowing` → `.initializationFailed`).

## NShiftUIDomain (via `import NShiftUI`)

**Metadata (shared):** `NShiftMetadata`, `NShiftEmptyMetadata`, `AnyNShiftMetadata`, `NShiftTokenMetadata`

**Plugins:** `NShiftPlugin`, `NShiftPluginWithMetadata`, `NShiftPluginContainer`, `NShiftPluginModel` (`id: String?`, `children:`), `NShiftPluginName`, `NShiftPluginViewModel`, `NShiftPluginStyle`, `NShiftPluginFrame`, `NShiftPluginAlignment`, `NShiftPluginDimension`

**Plugin store:** `NShiftPluginStore` (`resolve(..., renderID:) -> AnyView?`), `NShiftEmptyPluginStore`

**Slots:** `NShiftSlotKey`, `NShiftSlotName`, `NShiftSlotMap`

**Identity / tree:** `NShiftRenderID` (`appendingChild` → `/c/`), `NShiftPluginNode`, `NShiftEngineTree` (`makeView(for:) -> AnyView?`)

**Events:** `NShiftEvent` (`init?(model:resolver:)`), `NShiftEventWithMetadata`, `NShiftEventModel`, `NShiftEventName`, `AnyNShiftPluginEvent`

**Engine / stores:** `NShiftEngine` (`replaceChildren` / `replaceSlots` / `replaceSlot` + demais replace* + `handle`), `NShiftEventStore`, `NShiftEventHandler`, `NShiftEventHandlingError`, `NShiftEventHandlingFailureReason` (incl. `.initializationFailed`)

**Version:** `NShiftVersion`, `NShiftVersionResolver`, `NShiftDSLVersionPins`

**Triggers / DI protocol:** `NShiftTrigger`, `NShiftDependencyResolver`

Não público: `NShiftPluginContainerRegistry`, `NShiftPluginContainerCatalog`, `NShiftRegisteredVersionCatalog` (`package`).

## NShiftUIDI (via re-export)

| Símbolo | Notas |
|---------|--------|
| `NShiftDependencyRegistry` | Container concreto |
| `NShiftDependencyContainer` | `Resolver & Registering` |
| `NShiftDependencyScope` | `.transient` / `.singleton` |
| `register` / `resolve` / `resolveUnwrapping` | Overloads tipados |
| `registerPlugin` / `registerEvent` / `registerEngine` | Extensões dedicadas |
| `NShiftDependencyAssembly` | `assemblePlugins` / `assembleEvents` |
| `NShiftDependencyPluginStore` | `NShiftPluginStore` concreto |
| `NShiftRegisteredPluginView` | Factory `AnyView` registrada no container |
| `NShiftEventAction` | Ação tipada no store de events |

`registerPlugin` também marca containers e versão nos catalogs `package` (`NShiftPluginContainerCatalog`, `NShiftRegisteredVersionCatalog`).

**Removido:** packs, `pluginRegister()`, `NShiftRendering`, `NShiftAnyRendering`, `NShiftEmptyRenderer`, `NShiftSlotContent`.

## MacrosImplementation

Tipos `public` dos macros existem para o compiler plugin; hosts **não** importam `NShiftUIMacrosImplementation` diretamente (exceto testes do package).
