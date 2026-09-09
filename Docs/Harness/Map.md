# Module / file map

Densidade alta. Paths relativos à raiz do package.

## Products → targets

- **Product SPM:** `NShiftUI` → `Sources/NShiftUI` (+ transitivos)
- Targets internos (não products): `NShiftUIDomain`, `NShiftUIDI`, `NShiftUIMacros`, `NShiftUIMacrosImplementation`
- Tests: `Tests/NShiftUITests` → target `NShiftUITests`
- Experimento (não product): `Experiments/TypedRegistryPrototype`

## Sources/NShiftUIDomain

```
DI/
  NShiftDependencyResolver.swift    # protocol (Domain; DI implementa)
Container/
  NShiftPluginContainerRegistry.swift  # package: rootID → engine
  NShiftPluginContainerCatalog.swift   # package: nomes de containers registrados
Engine/
  NShiftEngine.swift                # public protocol (+ replaceChildren/Slot(s))
  NShiftEngineTree.swift            # public: root/node lookup + makeView → AnyView?
  NShiftPluginNode.swift            # public ObservableObject tree + renderId
  NShiftRenderID.swift              # path posicional (r, r/c/i, r/s/Name/i)
Metadata/
  NShiftMetadata.swift              # protocol + NShiftEmptyMetadata (plugins e events)
  NShiftTokenMetadata.swift         # protocol para tokens CMS (enum + RawValue String)
  TypeErasure/AnyNShiftMetadata.swift
Events/
  NShiftEvent.swift                 # protocol + init?(model:resolver:) + execute()
  NShiftEventModel.swift
  NShiftEventName.swift
  TypeErasure/AnyNShiftPluginEvent.swift
Plugins/
  NShiftPlugin.swift                # View + init?(model:resolver:eventHandler:engine:renderID:)
  NShiftPluginContainer.swift
  NShiftPluginModel.swift           # id: String?; name/metadata/style/children/slots/events
  NShiftPluginName.swift
  NShiftPluginViewModel.swift
  NShiftPluginModel+Mutating.swift  # replacingChildren / replacingSlot
  Style/NShiftPluginStyle|Frame|Alignment|Dimension.swift
Slots/
  NShiftSlotKey.swift               # + slotName PascalCase
  NShiftSlotName.swift
  NShiftSlotMap.swift               # subscript tipado + untyped
Stores/
  NShiftPluginStore.swift           # resolve → AnyView?; NShiftEmptyPluginStore
  NShiftEventStore.swift
  NShiftEventHandler.swift
  NShiftEventHandlingError.swift
Triggers/
  NShiftTrigger.swift
Version/
  NShiftVersion.swift
  NShiftVersionResolver.swift
  NShiftDSLVersionPins.swift
  NShiftRegisteredVersionCatalog.swift  # package: registerPlugin + registerEvent
```

Removidos: `NShiftRendering`, `NShiftAnyRendering`, `NShiftEmptyRenderer`, `NShiftSlotContent`.

## Sources/NShiftUIDI

```
Exports.swift
DI/
  Assembly/
    NShiftDependencyAssembly.swift
    NShiftDependencyAssembly+Assemble.swift
  Protocols/
    NShiftDependencyContainer.swift   # Resolver & Registering
    NShiftDependencyRegistering.swift
  Registry/
    NShiftDependencyRegistry.swift
    NShiftDependencyKey|Factory|Scope.swift
    NShiftDependencyRegistry+Assembly.swift
  Extensions/
    +Plugins / +Events / +Engine / +Overloads
    NShiftDependencyResolver+Overloads|Unwrapping.swift
  Stores/
    Plugins/NShiftDependencyPluginStore.swift
            NShiftRegisteredPluginView.swift
    Events/NShiftDependencyEventStore|Handler.swift
           NShiftEventAction.swift
  Support/NShiftDependencyResolutionSupport.swift
          NShiftFatalError.swift
```

`registerPlugin` atualiza `NShiftPluginContainerCatalog` (só containers) + `NShiftRegisteredVersionCatalog` (ambos `package`) e registra factory `Plugin?` → `AnyView` (nil da factory → store `nil`).

## Sources/NShiftUIMacros + Implementation

```
NShiftUIMacros/NShiftUIMacros.swift
  # NShiftPlugin, NShiftEvent, NShiftPluginAssemble, NShiftEventAssemble,
  # NShiftMetadata, NShiftTokenMetadata, NShiftSlotKey
  # (7 macros; sem NShiftMainPluginRegister)

NShiftUIMacrosImplementation/
  NShiftPluginMacro.swift           # MemberMacro + @main CompilerPlugin (providingMacros: 7)
                                    # accessors children/slots no struct do autor
  NShiftEventMacro.swift            # sem slotContent / renderer
  NShiftPluginAssembleMacro.swift   # BodyMacro → registerPlugin (preserva body do autor)
  NShiftEventAssembleMacro.swift    # BodyMacro → registerEvent
  NShiftMetadataMacro.swift
  NShiftTokenMetadataMacro.swift
  NShiftSlotKeyMacro.swift
  NShiftSemVerValidation.swift
```

Removidos: `NShiftMainPluginRegisterMacro.swift`.

## Sources/NShiftUI

```
Exports.swift                         # @_exported Domain + DI + Macros
Assembly/NShiftUIAssembly.swift       # PluginStore + EventStore/Handler
Configuration/NShiftConfig.swift
Engine/Default/NShiftDefaultEngine.swift
      Indexing/NShiftEventLocation.swift
      Resolver/NShiftEngineResolver.swift
Container/NShiftView.swift            # non-generic; init(model:)
          NShiftPluginContainerHost.swift
          NShiftPluginContainerRegistrationModifier.swift
Rendering/Node/NShiftNodeView.swift   # public; engine.makeView + renderId
          Children/NShiftChildrenAccessor.swift
                   NShiftSlotsAccessor.swift  # generic só em Key: NShiftSlotKey
Style/NShiftPluginStyle+SwiftUI.swift       # .nShiftPluginStyle
      NShiftPluginAlignment+SwiftUI.swift
Version/NShiftUIVersion.swift               # "0.2.0-beta.1"
Support/NShiftRuntimePrecondition.swift     # package test hook for startup/view traps
Rainbow/NShiftRainbowCompiler.swift
        NShiftRainbowCompileConfiguration.swift
        NShiftRainbowCompileError.swift
        NShiftRainbowJSON.swift
        NShiftRainbowMetadataDecoding.swift
```

## Tests/NShiftUITests

```
NShiftUI/          Config, Engine, EngineInjection, Assembly, View, PluginRegistry,
                   ChildrenSlots, Style SwiftUI, Rainbow/*, smoke
NShiftUIDI/        Assembly, Registry, Stores
NShiftUIDomain/    Plugin, Event, Names, Style, Trigger, SlotName, Version, RenderID,
                   PluginNode, Model mutating + Fixtures
NShiftUIMacros/    *MacroTests (XCTest + SwiftSyntaxMacrosTestSupport)
                   *MacroIntegrationTests (Swift Testing)
Support/           precondition capture harness
```

Deps do test target: NShiftUI, Domain, DI, Macros, MacrosImplementation, SwiftSyntaxMacrosTestSupport.
