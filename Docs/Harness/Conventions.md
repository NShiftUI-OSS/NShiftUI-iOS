# Conventions

## Naming

- Prefixo `NShift` em tipos públicos.
- Plugins: `NShiftPluginName` (string tipada); events: `NShiftEventName`.
- **Namespace único:** o mesmo UpperCamelCase não pode ser plugin **e** evento.
  `NShiftRegisteredVersionCatalog` (`package`) fatal se `registerPlugin` / `registerEvent` conflitar.
  O DI de Views chama `registerPlugin` no catalog (além do store). Hosts não acessam o catalog.
- Triggers: `on` + PascalCase ASCII (`onTap`, `onAppear`) — validação em `NShiftTrigger`.
- `NShiftRenderID` paths: `r` root; `/c/<i>` children; `/s/<SlotName>/<i>` slot.
- Arquivos espelham o tipo principal; pastas por domínio (`Plugins/`, `Events/`, `Stores/`).

## Layers / imports

- Domain não importa UI runtime nem macros (pode importar SwiftUI para `NShiftPlugin` / `NShiftPluginStore` / `AnyView`).
- DI depende só de Domain.
- MacrosImplementation: só swift-syntax (+ diagnostics); gera código que referencia Domain/DI/UI qualificados.
- NShiftUI importa Domain + DI + Macros e é o único product.

## Macros

- **Attach targets (obrigatório):**
  - `@NShiftPlugin` / `@NShiftEvent` → só **`struct`** (+ conformidade explícita).
  - `@NShiftMetadata` → só **`struct`** (compartilhado por plugins e events).
  - `@NShiftTokenMetadata` → só **`enum`** (+ `NShiftTokenMetadata`; RawValue `String`).
  - `@NShiftSlotKey` → só **`enum`** (+ `NShiftSlotKey`).
- `@NShiftPlugin` / `@NShiftEvent`: **MemberMacro** — `name`, `version` (SemVer `MAJOR.MINOR.PATCH`) obrigatórios.
- `NShiftPlugin` / `NShiftPluginContainer` requerem `init?`: `model`, `resolver`, `eventHandler`, `engine`, `renderID`. **Sem** `viewModel:` / `renderer:`. Autor não declara init.
- Plugin macro: accessors reais `children`/`slots` no autor (`NShiftChildrenAccessor` / `NShiftSlotsAccessor<Key>`). Sem `NShiftContent` / `nshiftMake`.
- Event `init?`: `(model:resolver:)` — sem `viewModel:` / `slotContent`. Autor não declara init.
- `NShiftPluginContainer` exige `@StateObject` viewModel tipado resolvido via `resolver.resolve(T.self)` (folha `NShiftPlugin` não).
- `@NShiftPluginAssemble`: **BodyMacro** em `assemblePlugins(in:)` → `container.registerPlugin`; factory `(model, container, renderID) -> Plugin?`; **preserva** o body do autor.
- `@NShiftEventAssemble`: **BodyMacro** — factory `(model) -> Event?` via `init?(model:resolver:)`.
- Compiler plugin: **7** macros (sem `@NShiftMainPluginRegister`).
- Registro DI de plugins/events: chave `Name@1.2.3`. Sem pin → **latest** via catalog.

## DI

- Container = `NShiftDependencyRegistering` + `NShiftDependencyResolver`.
- Scopes: `transient` | `singleton`.
- Views entram no container via `registerPlugin` (factory `AnyView` + `NShiftRegisteredPluginView`).
- Container: serviços do host + plugins + events + engine (opcional) + stores default do core.
- Preferir overloads tipados / `resolveUnwrapping` a `[Any]` cru.
- `NShiftConfig.startup` sempre inclui `NShiftUIAssembly` primeiro.

## Concurrency / UI

- Swift 6 language mode.
- Views/engine/config/registry: `@MainActor` onde tocam SwiftUI/estado de UI.
- Modelos Domain: `Sendable` / `Hashable` quando dados.
- Type erasures de metadata: `@unchecked Sendable` onde necessário.
- Registry DI: `@unchecked Sendable` + `NSLock`.
- `AnyView` só na fronteira do `NShiftPluginStore` / `engine.makeView`. Accessors e `NShiftNodeView` não são genéricos em Registry.
- Identidade SwiftUI: `plugin.id(renderID)` e `ForEach(..., id: \.renderId)`.

## Visibility

- `public` = API de host/kit.
- `package` = compartilhado entre targets do package (ex.: `NShiftPluginContainerRegistry`, `NShiftPluginContainerCatalog`).
- Evitar expandir `public` sem necessidade; documentar em `API.md` se expandir.

## Tests

- **Swift Testing** (`#expect`) para domínio/engine/DI/integração.
- **XCTest** + `SwiftSyntaxMacrosTestSupport` só para *expansion* de macros (`assertMacroExpansion`).
- Espelhar pastas de Sources; fixtures Domain: `NShiftUIDomainFixtures.swift`.
- Após mudanças de comportamento: `swift test` na raiz.

## Escopo de mudança

- Mudança em Domain → verificar DI + Macros + NShiftUI + testes.
- Não adicionar deps SPM além de swift-syntax sem decisão explícita.
- Não acoplar a nshiftuikit neste package.
- Experimento legado (não product): `Experiments/TypedRegistryPrototype`.
