import NShiftUIDI
import NShiftUIDomain

@attached(
    member,
    names:
        named(name),
        named(version),
        named(metadataType),
        named(metadata),
        named(style),
        named(pluginChildren),
        named(slots),
        named(slotsMap),
        named(slotsStorage),
        named(slotModels),
        named(events),
        named(viewModel),
        named(resolver),
        named(eventHandler),
        named(engine),
        named(renderID),
        named(engineTree),
        named(childrenAccessor),
        named(slotsAccessor),
        named(children),
        named(init)
)
@attached(extension, conformances: NShiftPluginWithMetadata)
public macro NShiftPlugin(
    name: NShiftPluginName,
    version: NShiftVersion,
    metadata: (any NShiftMetadata.Type)? = nil,
    slots: (any NShiftSlotKey.Type)? = nil
) = #externalMacro(module: "NShiftUIMacrosImplementation", type: "NShiftPluginMacro")

@attached(
    member,
    names:
        named(name),
        named(version),
        named(metadataType),
        named(metadata),
        named(slots),
        named(slotsStorage),
        named(slotModels),
        named(events),
        named(viewModel),
        named(eventHandler),
        named(resolver),
        named(engine),
        named(init)
)
@attached(extension, conformances: NShiftEventWithMetadata)
public macro NShiftEvent(
    name: NShiftEventName,
    version: NShiftVersion,
    metadata: (any NShiftMetadata.Type)? = nil,
    slots: (any NShiftSlotKey.Type)? = nil
) = #externalMacro(module: "NShiftUIMacrosImplementation", type: "NShiftEventMacro")

@attached(extension, conformances: CaseIterable, RawRepresentable, names: named(RawValue), named(rawValue), named(init), named(allCases))
public macro NShiftSlotKey() = #externalMacro(
    module: "NShiftUIMacrosImplementation",
    type: "NShiftSlotKeyMacro"
)

@attached(extension, conformances: Hashable, Sendable)
public macro NShiftMetadata() = #externalMacro(
    module: "NShiftUIMacrosImplementation",
    type: "NShiftMetadataMacro"
)

@attached(
    extension,
    conformances: Hashable, Sendable, CaseIterable, RawRepresentable,
    names: named(RawValue), named(rawValue), named(init), named(allCases)
)
public macro NShiftTokenMetadata() = #externalMacro(
    module: "NShiftUIMacrosImplementation",
    type: "NShiftTokenMetadataMacro"
)

@attached(body)
public macro NShiftPluginAssemble(_ plugins: Any.Type...) = #externalMacro(
    module: "NShiftUIMacrosImplementation",
    type: "NShiftPluginAssembleMacro"
)

@attached(body)
public macro NShiftEventAssemble(_ events: Any.Type...) = #externalMacro(
    module: "NShiftUIMacrosImplementation",
    type: "NShiftEventAssembleMacro"
)
