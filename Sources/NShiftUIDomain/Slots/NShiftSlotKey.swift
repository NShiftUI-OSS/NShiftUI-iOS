

public protocol NShiftSlotKey: Hashable, CaseIterable, RawRepresentable where RawValue == String {
    var slotName: NShiftSlotName { get }
}

public extension NShiftSlotKey {
    var slotName: NShiftSlotName {
        let pascal = Self.pascalCase(fromCamelCase: rawValue)
        return try! NShiftSlotName(validating: pascal)
    }

    static func pascalCase(fromCamelCase value: String) -> String {
        guard let first = value.first else {
            return value
        }

        return String(first).uppercased() + value.dropFirst()
    }
}
