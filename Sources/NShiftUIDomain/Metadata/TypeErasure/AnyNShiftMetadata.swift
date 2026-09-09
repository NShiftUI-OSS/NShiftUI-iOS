public struct AnyNShiftMetadata: Equatable, Hashable, @unchecked Sendable {
    private let storage: AnyHashable

    public init<Metadata: NShiftMetadata>(_ metadata: Metadata) {
        self.storage = AnyHashable(metadata)
    }

    public var base: Any {
        storage.base
    }

    public func unwrap<Metadata>(as type: Metadata.Type = Metadata.self) -> Metadata? {
        storage.base as? Metadata
    }
}
