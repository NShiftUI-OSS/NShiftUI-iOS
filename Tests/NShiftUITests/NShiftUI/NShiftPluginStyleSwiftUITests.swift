import SwiftUI
import Testing
@testable import NShiftUI
@testable import NShiftUIDomain

@Test func pluginAlignmentMapsToSwiftUIAlignment() {
    #expect(NShiftPluginAlignment.topLeading.swiftUIAlignment == .topLeading)
    #expect(NShiftPluginAlignment.top.swiftUIAlignment == .top)
    #expect(NShiftPluginAlignment.topTrailing.swiftUIAlignment == .topTrailing)
    #expect(NShiftPluginAlignment.leading.swiftUIAlignment == .leading)
    #expect(NShiftPluginAlignment.center.swiftUIAlignment == .center)
    #expect(NShiftPluginAlignment.trailing.swiftUIAlignment == .trailing)
    #expect(NShiftPluginAlignment.bottomLeading.swiftUIAlignment == .bottomLeading)
    #expect(NShiftPluginAlignment.bottom.swiftUIAlignment == .bottom)
    #expect(NShiftPluginAlignment.bottomTrailing.swiftUIAlignment == .bottomTrailing)
}

@MainActor
@Test func nShiftPluginStyleModifierCanBeApplied() {
    let styled = Text("x").nShiftPluginStyle(
        NShiftPluginStyle(
            frame: NShiftPluginFrame(),
            alignment: .topLeading,
            spacing: 8
        )
    )

    _ = styled
}
