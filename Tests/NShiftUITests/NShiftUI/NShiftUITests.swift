import Testing
@testable import NShiftUI

@Test func versionMatchesCurrentBeta() {
    #expect(NShiftUIVersion.current == "1.0.0")
}
