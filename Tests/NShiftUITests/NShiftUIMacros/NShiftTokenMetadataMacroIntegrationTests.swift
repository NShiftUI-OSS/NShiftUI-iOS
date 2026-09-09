import NShiftUI
import Testing

@NShiftTokenMetadata
private enum IntegratedStackAlignment: NShiftTokenMetadata {
    case top
    case center
    case bottom
}

@Test func tokenMetadataMacroCanBeUsedFromPublicMacrosModule() {
    #expect(IntegratedStackAlignment.top.rawValue == "top")
    #expect(IntegratedStackAlignment(rawValue: "center") == .center)
    #expect(IntegratedStackAlignment.allCases.count == 3)
}
