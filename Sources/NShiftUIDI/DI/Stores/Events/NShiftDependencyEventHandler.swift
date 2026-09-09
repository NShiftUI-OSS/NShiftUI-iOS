import NShiftUIDomain

public final class NShiftDependencyEventHandler: Sendable, NShiftEventHandler {
    private let eventStore: any NShiftEventStore
    private let resolver: any NShiftDependencyResolver

    public init(
        eventStore: any NShiftEventStore,
        resolver: any NShiftDependencyResolver
    ) {
        self.eventStore = eventStore
        self.resolver = resolver
    }

    public func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {
        let resolvedEvents = eventStore.resolve(trigger, events: events)

        for event in resolvedEvents {
            let action = resolveAction(for: event)
            try? await action?.execute(event)
        }
    }

    public func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {
        let resolvedEvents = eventStore.resolve(trigger, events: events)

        for event in resolvedEvents {
            guard let action = resolveAction(for: event) else {
                throw NShiftEventHandlingError(event: event, reason: .actionNotFound)
            }

            do {
                try await action.execute(event)
            } catch is NShiftEventInitializationError {
                throw NShiftEventHandlingError(event: event, reason: .initializationFailed)
            } catch {
                throw NShiftEventHandlingError(
                    event: event,
                    reason: .actionFailed(String(describing: error))
                )
            }
        }
    }

    private func resolveAction(for event: NShiftEventModel) -> NShiftEventAction? {
        resolver.resolve(NShiftEventAction.self, name: event.registrationName)
    }
}
