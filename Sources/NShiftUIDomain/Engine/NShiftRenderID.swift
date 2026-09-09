public struct NShiftRenderID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var description: String {
        rawValue
    }

    public static let root = NShiftRenderID(rawValue: "r")

    public func appendingChild(at index: Int) -> NShiftRenderID {
        NShiftRenderID(rawValue: "\(rawValue)/c/\(index)")
    }

    public func appendingSlot(_ name: NShiftSlotName, at index: Int) -> NShiftRenderID {
        NShiftRenderID(rawValue: "\(rawValue)/s/\(name.rawValue)/\(index)")
    }
}
