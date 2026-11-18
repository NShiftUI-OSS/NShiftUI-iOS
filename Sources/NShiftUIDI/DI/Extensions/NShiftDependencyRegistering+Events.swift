import NShiftUIDomain

public extension NShiftDependencyRegistering {
    func registerEvent<Event>(
        _ eventType: Event.Type,
        container: any NShiftDependencyContainer,
        factory: @escaping @Sendable (
            NShiftEventModel,
            (any NShiftPluginViewModel)?
        ) async throws -> Event?
    ) where Event: NShiftEvent {
        let registrationName = NShiftVersion.registrationName(
            event: eventType.name,
            version: eventType.version
        )

        NShiftRegisteredVersionCatalog.shared.registerEvent(eventType.name, version: eventType.version)
        NShiftCatalogHooks.shared.hook?.typeRegistered(eventType)

        let makeEvent = NShiftEventFactoryBox(factory)

        register(NShiftEventAction.self, name: registrationName) {
            NShiftEventAction(throwing: { eventModel, viewModel in
                try await makeEvent(eventModel, viewModel: viewModel)
            })
        }
    }
}

private struct NShiftEventFactoryBox: @unchecked Sendable {
    private let execute: (NShiftEventModel, (any NShiftPluginViewModel)?) async throws -> Void

    init<Event: NShiftEvent>(
        _ factory: @escaping @Sendable (
            NShiftEventModel,
            (any NShiftPluginViewModel)?
        ) async throws -> Event?
    ) {
        execute = { model, viewModel in
            guard let event = try await factory(model, viewModel) else {
                throw NShiftEventInitializationError()
            }
            try await event.execute()
        }
    }

    func callAsFunction(
        _ model: NShiftEventModel,
        viewModel: (any NShiftPluginViewModel)?
    ) async throws {
        try await execute(model, viewModel)
    }
}
