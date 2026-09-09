public protocol NShiftMetadata: Hashable, Sendable {}

public struct NShiftEmptyMetadata: NShiftMetadata {
    public init() {}
}
