public struct NShiftVersion: Equatable, Hashable, Sendable, Comparable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public var rawValue: String {
        "\(major).\(minor).\(patch)"
    }

    public var description: String {
        rawValue
    }

    public init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public init(validating rawValue: String) throws(NShiftVersionError) {
        guard let parsed = Self.parse(rawValue) else {
            throw .invalidVersion(rawValue)
        }

        self = parsed
    }

    public init(stringLiteral value: String) {
        self = try! Self(validating: value)
    }

    public static func isValid(_ value: String) -> Bool {
        parse(value) != nil
    }

    public static func < (lhs: NShiftVersion, rhs: NShiftVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }

    public static func registrationName(plugin name: NShiftPluginName, version: NShiftVersion) -> String {
        "\(name.rawValue)@\(version.rawValue)"
    }

    public static func registrationName(event name: NShiftEventName, version: NShiftVersion) -> String {
        "\(name.rawValue)@\(version.rawValue)"
    }

    private static func parse(_ value: String) -> NShiftVersion? {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3,
              let major = parseNumericIdentifier(parts[0]),
              let minor = parseNumericIdentifier(parts[1]),
              let patch = parseNumericIdentifier(parts[2]) else {
            return nil
        }

        return NShiftVersion(major: major, minor: minor, patch: patch)
    }

    private static func parseNumericIdentifier<S: StringProtocol>(_ value: S) -> Int? {
        guard !value.isEmpty,
              value.unicodeScalars.allSatisfy(isASCIIDigit) else {
            return nil
        }

        if value.count > 1, value.first == "0" {
            return nil
        }

        return Int(value)
    }

    private static func isASCIIDigit(_ scalar: UnicodeScalar) -> Bool {
        (48...57).contains(scalar.value)
    }
}

public enum NShiftVersionError: Error, Equatable, Sendable {
    case invalidVersion(String)
}
