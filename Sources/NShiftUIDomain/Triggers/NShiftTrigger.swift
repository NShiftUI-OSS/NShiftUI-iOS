public struct NShiftTrigger: Equatable, Hashable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public var description: String {
        rawValue
    }

    public init(validating rawValue: String) throws(NShiftTriggerError) {
        guard Self.isValid(rawValue) else {
            throw .invalidTrigger(rawValue)
        }

        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self = try! Self(validating: value)
    }

    public static func isValid(_ value: String) -> Bool {
        guard value.count > 2,
              value.hasPrefix("on") else {
            return false
        }

        guard value.unicodeScalars.allSatisfy(isASCIILetter) else {
            return false
        }

        var index = value.index(value.startIndex, offsetBy: 2)

        while index < value.endIndex {
            guard isUppercaseASCIILetter(at: value, index: index) else {
                return false
            }

            index = value.index(after: index)

            while index < value.endIndex,
                  isLowercaseASCIILetter(at: value, index: index) {
                index = value.index(after: index)
            }
        }

        return true
    }

    private static func isASCIILetter(_ scalar: UnicodeScalar) -> Bool {
        isUppercaseASCIILetter(scalar) || isLowercaseASCIILetter(scalar)
    }

    private static func isUppercaseASCIILetter(_ scalar: UnicodeScalar) -> Bool {
        (65...90).contains(scalar.value)
    }

    private static func isLowercaseASCIILetter(_ scalar: UnicodeScalar) -> Bool {
        (97...122).contains(scalar.value)
    }

    private static func isUppercaseASCIILetter(at value: String, index: String.Index) -> Bool {
        guard let scalar = value[index].unicodeScalars.first else {
            return false
        }

        return isUppercaseASCIILetter(scalar)
    }

    private static func isLowercaseASCIILetter(at value: String, index: String.Index) -> Bool {
        guard let scalar = value[index].unicodeScalars.first else {
            return false
        }

        return isLowercaseASCIILetter(scalar)
    }
}

public enum NShiftTriggerError: Error, Equatable, Sendable {
    case invalidTrigger(String)
}
