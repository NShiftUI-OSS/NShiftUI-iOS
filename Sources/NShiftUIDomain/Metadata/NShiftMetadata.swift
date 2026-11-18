public protocol NShiftMetadata: Hashable, Sendable {}

public protocol NShiftRainbowRegistrant: Sendable {
    nonisolated static func registerNShiftRainbow()
}

public struct NShiftEmptyMetadata: NShiftMetadata {
    public init() {}
}
