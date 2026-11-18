import NShiftUIDomain

public struct NShiftEventAction: Sendable {
    private let executeHandler: @Sendable (NShiftEventModel, (any NShiftPluginViewModel)?) async throws -> Void

    public init(
        _ executeHandler: @escaping @Sendable (NShiftEventModel, (any NShiftPluginViewModel)?) async -> Void
    ) {
        self.executeHandler = { event, viewModel in
            await executeHandler(event, viewModel)
        }
    }

    public init(
        throwing executeHandler: @escaping @Sendable (NShiftEventModel, (any NShiftPluginViewModel)?) async throws -> Void
    ) {
        self.executeHandler = executeHandler
    }

    public func execute(
        _ event: NShiftEventModel,
        viewModel: (any NShiftPluginViewModel)?
    ) async throws {
        try await executeHandler(event, viewModel)
    }
}
