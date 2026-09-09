public struct NShiftEventName: Equatable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public var description: String {
        rawValue
    }

    public init(validating rawValue: String) throws(NShiftEventNameError) {
        guard Self.isValid(rawValue) else {
            throw .invalidName(rawValue)
        }

        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self = try! Self(validating: value)
    }

    public static func isValid(_ value: String) -> Bool {
        guard let first = value.unicodeScalars.first,
              isUppercaseASCIILetter(first) else {
            return false
        }

        return value.unicodeScalars.allSatisfy(isASCIILetter)
    }

    private static func isASCIILetter(_ scalar: UnicodeScalar) -> Bool {
        isUppercaseASCIILetter(scalar) || (97...122).contains(scalar.value)
    }

    private static func isUppercaseASCIILetter(_ scalar: UnicodeScalar) -> Bool {
        (65...90).contains(scalar.value)
    }
}

public enum NShiftEventNameError: Error, Equatable, Sendable {
    case invalidName(String)
}
