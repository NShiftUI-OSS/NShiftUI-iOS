public struct AnyNShiftPluginEvent: Equatable, Hashable, @unchecked Sendable {
    private let storage: AnyHashable

    public init(_ event: NShiftEventModel) {
        self.storage = AnyHashable(event)
    }

    public var event: NShiftEventModel? {
        storage.base as? NShiftEventModel
    }
}
