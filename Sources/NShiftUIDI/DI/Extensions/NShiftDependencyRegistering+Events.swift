import NShiftUIDomain

public extension NShiftDependencyRegistering {
    func registerEvent<Event>(
        _ eventType: Event.Type,
        container: any NShiftDependencyContainer,
        factory: @escaping @Sendable (
            NShiftEventModel
        ) async throws -> Event?
    ) where Event: NShiftEvent {
        let registrationName = NShiftVersion.registrationName(
            event: eventType.name,
            version: eventType.version
        )

        NShiftRegisteredVersionCatalog.shared.registerEvent(eventType.name, version: eventType.version)

        let makeEvent = NShiftEventFactoryBox(factory)

        register(NShiftEventAction.self, name: registrationName) {
            NShiftEventAction(throwing: { eventModel in
                try await makeEvent(eventModel)
            })
        }
    }
}

private struct NShiftEventFactoryBox: @unchecked Sendable {
    private let execute: (NShiftEventModel) async throws -> Void

    init<Event: NShiftEvent>(
        _ factory: @escaping @Sendable (
            NShiftEventModel
        ) async throws -> Event?
    ) {
        execute = { model in
            guard let event = try await factory(model) else {
                throw NShiftEventInitializationError()
            }
            try await event.execute()
        }
    }

    func callAsFunction(_ model: NShiftEventModel) async throws {
        try await execute(model)
    }
}
