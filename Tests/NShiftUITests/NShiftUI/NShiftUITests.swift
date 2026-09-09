import Testing
@testable import NShiftUI

@Test func versionMatchesCurrentBeta() {
    #expect(NShiftUIVersion.current == "0.2.0-beta.1")
}
