import NShiftUI
import Testing

private struct IntegratedEventMetadata: NShiftMetadata {}

@MainActor
private final class IntegratedEventViewModel: NShiftPluginViewModel {}

private final class IntegratedEventHandler: NShiftEventHandler {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {}

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {}
}

@NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: IntegratedEventMetadata.self)
private struct IntegratedShowToastEvent: NShiftEvent {
    func execute() async throws {}
}

@MainActor
@Test func eventMacroCanBeUsedFromPublicMacrosModule() async throws {
    let registry = NShiftDependencyRegistry()
    registry.register(NShiftEventHandler.self) {
        IntegratedEventHandler()
    }
    let childEvents = [
        NShiftEventModel(name: "TrackTap", version: "1.0.0", trigger: "onTap"),
    ]
    let model = NShiftEventModel(
        id: "toast",
        name: "ShowToast", version: "1.0.0",
        metadata: IntegratedEventMetadata(),
        trigger: "onTap",
        events: childEvents
    )
    let event = IntegratedShowToastEvent(
        model: model,
        resolver: registry
    )

    #expect(event != nil)
    #expect(IntegratedShowToastEvent.name == "ShowToast")
    #expect(ObjectIdentifier(IntegratedShowToastEvent.metadataType) == ObjectIdentifier(IntegratedEventMetadata.self))

    try await event?.execute()
}
