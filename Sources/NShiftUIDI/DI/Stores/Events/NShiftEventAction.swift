import NShiftUIDomain

public struct NShiftEventAction: Sendable {
    private let executeHandler: @Sendable (NShiftEventModel) async throws -> Void

    public init(
        _ executeHandler: @escaping @Sendable (NShiftEventModel) async -> Void
    ) {
        self.executeHandler = { event in
            await executeHandler(event)
        }
    }

    public init(
        throwing executeHandler: @escaping @Sendable (NShiftEventModel) async throws -> Void
    ) {
        self.executeHandler = executeHandler
    }

    public func execute(_ event: NShiftEventModel) async throws {
        try await executeHandler(event)
    }
}
