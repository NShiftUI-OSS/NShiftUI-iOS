import Foundation

public struct NShiftPluginModel: Equatable, Hashable, Sendable {
    public let id: String?
    public let name: NShiftPluginName
    public let version: NShiftVersion
    public let metadata: AnyNShiftMetadata?
    public let style: NShiftPluginStyle
    public let children: [NShiftPluginModel]
    public let slots: [NShiftSlotName: [NShiftPluginModel]]
    public let events: [AnyNShiftPluginEvent]

    public init(
        id: String? = nil,
        name: NShiftPluginName,
        version: NShiftVersion,
        metadata: AnyNShiftMetadata? = nil,
        style: NShiftPluginStyle = NShiftPluginStyle(),
        children: [NShiftPluginModel] = [],
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:],
        events: [NShiftEventModel] = []
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.metadata = metadata
        self.style = style
        self.children = children
        self.slots = slots
        self.events = events.map(AnyNShiftPluginEvent.init)
    }

    public init<Metadata: NShiftMetadata>(
        id: String? = nil,
        name: NShiftPluginName,
        version: NShiftVersion,
        metadata: Metadata,
        style: NShiftPluginStyle = NShiftPluginStyle(),
        children: [NShiftPluginModel] = [],
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:],
        events: [NShiftEventModel] = []
    ) {
        self.init(
            id: id,
            name: name,
            version: version,
            metadata: AnyNShiftMetadata(metadata),
            style: style,
            children: children,
            slots: slots,
            events: events
        )
    }

    public var registrationName: String {
        NShiftVersion.registrationName(plugin: name, version: version)
    }
}
