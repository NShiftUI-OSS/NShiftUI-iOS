public protocol NShiftEventStore: Sendable {
    func resolve(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) -> [NShiftEventModel]
}
