import NShiftUI
import SwiftUI
import Testing

private actor EventRecorder {
    private var storage: [String] = []

    var values: [String] {
        storage
    }

    func record(_ value: String) {
        storage.append(value)
    }
}

private enum EventActionFailure: Error, CustomStringConvertible {
    case rejected

    var description: String {
        "rejected"
    }
}

private final class StoreNoOpEventHandler: NShiftEventHandler {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {}

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {}
}

@Test func dependencyEventStoreResolvesEventsMatchingTrigger() {
    let store = NShiftDependencyEventStore()
    let onTapEvents = [
        NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap"),
        NShiftEventModel(id: "analytics", name: "TrackTap", version: "1.0.0", trigger: "onTap"),
    ]
    let pluginEvents = onTapEvents.map(AnyNShiftPluginEvent.init) + [
        AnyNShiftPluginEvent(NShiftEventModel(id: "appear", name: "TrackAppear", version: "1.0.0", trigger: "onAppear")),
    ]

    #expect(store.resolve("onTap", events: pluginEvents) == onTapEvents)
    #expect(store.resolve("onAppear", events: pluginEvents) == [
        NShiftEventModel(id: "appear", name: "TrackAppear", version: "1.0.0", trigger: "onAppear"),
    ])
}

@Test func dependencyEventHandlerExecutesRegisteredEventActions() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let recorder = EventRecorder()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    await handler.handle("onTap", events: pluginEvents)

    #expect(await recorder.values == ["ShowToast"])
}

@Test func dependencyEventHandlerIgnoresMissingActionInNonThrowingHandle() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    await handler.handle("onTap", events: pluginEvents)

    #expect(eventStore.resolve("onTap", events: pluginEvents) == [event])
}

@Test func dependencyEventHandlerThrowsTypedErrorWhenActionIsMissing() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    do {
        try await handler.handleThrowing("onTap", events: pluginEvents)
        #expect(Bool(false), "Expected missing action to throw.")
    } catch {
        #expect(error == NShiftEventHandlingError(event: event, reason: .actionNotFound))
        #expect(error.description == "Failed to handle event 'ShowToast' (id: toast, trigger: onTap): event action was not registered")
    }
}

@Test func dependencyEventHandlerThrowsTypedErrorWhenActionFails() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
        NShiftEventAction(throwing: { _ in
            throw EventActionFailure.rejected
        })
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    do {
        try await handler.handleThrowing("onTap", events: pluginEvents)
        #expect(Bool(false), "Expected failing action to throw.")
    } catch {
        #expect(error == NShiftEventHandlingError(event: event, reason: .actionFailed("rejected")))
        #expect(error.description == "Failed to handle event 'ShowToast' (id: toast, trigger: onTap): event action failed with error: rejected")
    }
}

@Test func dependencyEventHandlerExecutesThrowingHandleWhenActionsSucceed() async throws {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let recorder = EventRecorder()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    try await handler.handleThrowing("onTap", events: pluginEvents)

    #expect(await recorder.values == ["ShowToast"])
}

@Test func dependencyEventHandlerOnlyExecutesEventsAttachedToPlugin() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let recorder = EventRecorder()
    let attachedEvent = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(attachedEvent)]
    registry.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    registry.register(NShiftEventAction.self, name: "Navigate@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    await handler.handle("onTap", events: pluginEvents)

    #expect(await recorder.values == ["ShowToast"])
}

@MainActor
private final class StoreEventViewModel: NShiftPluginViewModel {}

private actor ViewModelRecorder {
    private var didCaptureViewModel = false

    var capturedViewModel: Bool {
        didCaptureViewModel
    }

    func markCaptured() {
        didCaptureViewModel = true
    }
}

private struct StoreCapturingShowToastEvent: NShiftEvent {
    static let name: NShiftEventName = "ShowToast"
    static let version: NShiftVersion = "1.0.0"

    private let recorder: ViewModelRecorder
    private let viewModel: StoreEventViewModel

    init?(
        model: NShiftEventModel,
        resolver: any NShiftDependencyResolver
    ) {
        guard let viewModel = resolver.resolve(StoreEventViewModel.self) else {
            return nil
        }
        self.viewModel = viewModel
        self.recorder = resolver.resolveUnwrapping(ViewModelRecorder.self)
        _ = model
    }

    func execute() async throws {
        await recorder.markCaptured()
    }
}

@MainActor
@Test func dependencyEventHandlerThrowsWhenEventInitFails() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.registerEvent(StoreCapturingShowToastEvent.self, container: registry) { eventModel in
        StoreCapturingShowToastEvent(model: eventModel, resolver: registry)
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    do {
        try await handler.handleThrowing("onTap", events: pluginEvents)
        #expect(Bool(false), "Expected init? failure to throw.")
    } catch {
        #expect(error == NShiftEventHandlingError(event: event, reason: .initializationFailed))
        #expect(
            error.description
                == "Failed to handle event 'ShowToast' (id: toast, trigger: onTap): event init? returned nil"
        )
    }
}

@Test func dependencyEventHandlerSkipsExecuteWhenEventInitFails() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let recorder = ViewModelRecorder()
    registry.register(ViewModelRecorder.self) { recorder }
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.registerEvent(StoreCapturingShowToastEvent.self, container: registry) { eventModel in
        StoreCapturingShowToastEvent(model: eventModel, resolver: registry)
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    await handler.handle("onTap", events: pluginEvents)

    #expect(await recorder.capturedViewModel == false)
}

@Test func registerEventResolvesViewModelFromContainer() async {
    let registry = NShiftDependencyRegistry()
    let eventStore = NShiftDependencyEventStore()
    let recorder = ViewModelRecorder()
    registry.register(ViewModelRecorder.self) { recorder }
    registry.register(StoreEventViewModel.self) {
        StoreEventViewModel()
    }
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let pluginEvents = [AnyNShiftPluginEvent(event)]
    registry.registerEvent(StoreCapturingShowToastEvent.self, container: registry) { eventModel in
        StoreCapturingShowToastEvent(
            model: eventModel,
            resolver: registry
        )
    }
    let handler = NShiftDependencyEventHandler(eventStore: eventStore, resolver: registry)

    await handler.handle("onTap", events: pluginEvents)

    #expect(await recorder.capturedViewModel)
}
