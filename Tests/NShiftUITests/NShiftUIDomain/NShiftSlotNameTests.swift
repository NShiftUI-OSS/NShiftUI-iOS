import NShiftUIDomain
import SwiftUI
import Testing

@Test func slotNameStoresValidPascalCaseASCIIName() throws {
    let name = try NShiftSlotName(validating: "TopTrailing")

    #expect(name.rawValue == "TopTrailing")
    #expect(name.description == "TopTrailing")
}

@Test func slotNameCanBeCreatedFromStringLiteral() {
    let name: NShiftSlotName = "Leading"

    #expect(name.rawValue == "Leading")
}

@Test func slotNameValidationAcceptsOnlyPascalCaseASCIILetters() {
    #expect(NShiftSlotName.isValid("Leading"))
    #expect(NShiftSlotName.isValid("TopTrailing"))
    #expect(NShiftSlotName.isValid("Right"))
    #expect(NShiftSlotName.isValid("") == false)
    #expect(NShiftSlotName.isValid("leading") == false)
    #expect(NShiftSlotName.isValid("Top_Trailing") == false)
    #expect(NShiftSlotName.isValid("Slot1") == false)
    #expect(NShiftSlotName.isValid("Top-Trailing") == false)
    #expect(NShiftSlotName.isValid("Botão") == false)
}

@Test func slotNameThrowsWhenNameIsInvalid() {
    #expect(throws: NShiftSlotNameError.invalidName("leading")) {
        try NShiftSlotName(validating: "leading")
    }
}

private enum ToolbarSlots: String, CaseIterable, NShiftSlotKey {
    case leading
    case trailing
    case topTrailing
}

@Test func slotKeyMapsCamelCaseCasesToPascalCaseSlotNames() {
    #expect(ToolbarSlots.leading.slotName.rawValue == "Leading")
    #expect(ToolbarSlots.trailing.slotName.rawValue == "Trailing")
    #expect(ToolbarSlots.topTrailing.slotName.rawValue == "TopTrailing")
}

@Test func slotMapReturnsPluginsForTypedKeys() {
    let icon = NShiftPluginModel(id: "icon", name: "Icon", version: "1.0.0")
    let button = NShiftPluginModel(id: "button", name: "Button", version: "1.0.0")
    let map = NShiftSlotMap<ToolbarSlots>(storage: [
        "Leading": [icon],
        "Trailing": [button],
    ])

    #expect(map[.leading].map(\.id) == [Optional("icon")])
    #expect(map[.trailing].map(\.id) == [Optional("button")])
    #expect(map[.topTrailing].isEmpty)
}

@Test func slotMapUntypedRoundTripsStorage() {
    let icon = NShiftPluginModel(id: "icon", name: "Icon", version: "1.0.0")
    let map = NShiftSlotMap<ToolbarSlots>(storage: ["Leading": [icon]])

    #expect(map.untyped["Leading"]?.first?.id == "icon")
    #expect(map[.trailing].isEmpty)
}
