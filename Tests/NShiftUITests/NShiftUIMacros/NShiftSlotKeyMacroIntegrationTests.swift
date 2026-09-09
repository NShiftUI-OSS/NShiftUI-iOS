import NShiftUI
import Testing

@NShiftSlotKey
private enum IntegratedToolbarSlots: NShiftSlotKey {
    case leading
    case trailing
    case topTrailing
}

@Test func slotKeyMacroCanBeUsedFromPublicMacrosModule() {
    #expect(IntegratedToolbarSlots.leading.rawValue == "leading")
    #expect(IntegratedToolbarSlots.topTrailing.slotName.rawValue == "TopTrailing")
    #expect(IntegratedToolbarSlots.allCases.count == 3)
}
