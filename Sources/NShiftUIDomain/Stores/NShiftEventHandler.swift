public protocol NShiftEventHandler: Sendable {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent],
        viewModel: (any NShiftPluginViewModel)?
    ) async

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent],
        viewModel: (any NShiftPluginViewModel)?
    ) async throws(NShiftEventHandlingError)
}
