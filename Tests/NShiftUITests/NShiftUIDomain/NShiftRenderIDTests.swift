import Testing
@testable import NShiftUIDomain

@Test func renderIDRootAndAppendedPathsMatchPositionalContract() {
    let root = NShiftRenderID.root
    let child = root.appendingChild(at: 0)
    let slot = child.appendingSlot("Footer", at: 1)

    #expect(root.rawValue == "r")
    #expect(root.description == "r")
    #expect(child.rawValue == "r/c/0")
    #expect(slot.rawValue == "r/c/0/s/Footer/1")
    #expect(NShiftRenderID(rawValue: "r/c/2").rawValue == "r/c/2")
}
