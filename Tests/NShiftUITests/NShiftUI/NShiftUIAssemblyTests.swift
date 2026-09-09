import Testing
@testable import NShiftUI

@MainActor
@Test func nShiftUIAssemblyRegistersEngineRuntime() {
    let registry = NShiftDependencyRegistry()

    registry.apply(NShiftUIAssembly())

    #expect(registry.resolve(NShiftEventStore.self) != nil)
    #expect(registry.resolve(NShiftEventHandler.self) != nil)
}
