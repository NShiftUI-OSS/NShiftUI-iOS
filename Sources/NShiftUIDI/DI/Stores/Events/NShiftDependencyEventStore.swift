import NShiftUIDomain

public final class NShiftDependencyEventStore: Sendable, NShiftEventStore {
    public init() {}

    public func resolve(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) -> [NShiftEventModel] {
        events.compactMap(\.event)
            .filter { $0.trigger == trigger }
    }
}
