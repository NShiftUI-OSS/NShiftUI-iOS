import Foundation

public struct NShiftEventModel: Equatable, Hashable, Sendable {
    public let id: String
    public let name: NShiftEventName
    public let version: NShiftVersion
    public let metadata: AnyNShiftMetadata?
    public let trigger: NShiftTrigger
    public let slots: [NShiftSlotName: [NShiftPluginModel]]
    public let events: [NShiftEventModel]

    public init(
        id: String = UUID().uuidString,
        name: NShiftEventName,
        version: NShiftVersion,
        metadata: AnyNShiftMetadata? = nil,
        trigger: NShiftTrigger,
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:],
        events: [NShiftEventModel] = []
    ) {
        self.id = id
        self.name = name
        self.version = version
        self.metadata = metadata
        self.trigger = trigger
        self.slots = slots
        self.events = events
    }

    public init<Metadata: NShiftMetadata>(
        id: String = UUID().uuidString,
        name: NShiftEventName,
        version: NShiftVersion,
        metadata: Metadata,
        trigger: NShiftTrigger,
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:],
        events: [NShiftEventModel] = []
    ) {
        self.init(
            id: id,
            name: name,
            version: version,
            metadata: AnyNShiftMetadata(metadata),
            trigger: trigger,
            slots: slots,
            events: events
        )
    }

    public var registrationName: String {
        NShiftVersion.registrationName(event: name, version: version)
    }
}
