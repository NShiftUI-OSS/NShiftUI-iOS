enum NShiftSemVerValidation {

    static func isValid(_ value: String) -> Bool {
        let parts = value.split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3 else { return false }
        return parts.allSatisfy(isValidNumericIdentifier)
    }

    private static func isValidNumericIdentifier<S: StringProtocol>(_ value: S) -> Bool {
        guard !value.isEmpty,
              value.unicodeScalars.allSatisfy({ (48...57).contains($0.value) }) else {
            return false
        }

        if value.count > 1, value.first == "0" {
            return false
        }

        return true
    }
}
