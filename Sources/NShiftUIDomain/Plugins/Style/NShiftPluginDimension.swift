public enum NShiftPluginDimension: Equatable, Hashable, Sendable {
    case fill
    case value(Double)

    public var doubleValue: Double {
        switch self {
        case .fill:
            .infinity
        case .value(let value):
            value
        }
    }
}

extension NShiftPluginDimension: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .value(Double(value))
    }
}

extension NShiftPluginDimension: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .value(value)
    }
}
