import NShiftUI
import Testing

private struct AssembledEventMetadata: NShiftMetadata {}

@NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: AssembledEventMetadata.self)
private struct AssembledShowToastEvent: NShiftEvent {
    func execute() async throws {}
}

private struct AssembledEventModuleAssembly: NShiftDependencyAssembly {
    @NShiftEventAssemble(AssembledShowToastEvent.self)
    func assembleEvents(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func eventAssembleMacroRegistersEventActionByTypeAndName() {
    let registry = NShiftDependencyRegistry()
    registry.apply(AssembledEventModuleAssembly())

    let action = registry.resolve(NShiftEventAction.self, name: "ShowToast@1.0.0")

    #expect(action != nil)
}
