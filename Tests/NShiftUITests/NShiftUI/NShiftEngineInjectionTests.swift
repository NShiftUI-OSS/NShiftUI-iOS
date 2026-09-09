import Testing
@testable import NShiftUI

private struct EngineProbeMetadata: NShiftMetadata {}

private actor EngineProbeSink {
    static let shared = EngineProbeSink()
    private(set) var sawEngine = false

    func record(_ value: Bool) {
        sawEngine = value
    }

    func reset() {
        sawEngine = false
    }
}

@NShiftEvent(name: "EngineProbe", version: "1.0.0", metadata: EngineProbeMetadata.self)
private struct EngineProbeEvent: NShiftEvent {
    func execute() async throws {
        await EngineProbeSink.shared.record(engine != nil)
    }
}

private struct EngineProbeAssembly: NShiftDependencyAssembly {
    @NShiftEventAssemble(EngineProbeEvent.self)
    func assembleEvents(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func engineIsRegisteredInContainerAndInjectedIntoEventsViaMacro() async {
    await EngineProbeSink.shared.reset()

    let config = NShiftConfig.shared
    config.resetForTesting()
    config.startup(
        hostContainer: NShiftDependencyRegistry(),
        assemblies: [EngineProbeAssembly()]
    )

    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        events: [NShiftEventModel(name: "EngineProbe", version: "1.0.0", metadata: EngineProbeMetadata(), trigger: "onTap")]
    )
    let engine = NShiftEngineResolver.makeEngine(rootModel: root, config: config)

    await engine.handle("onTap", onPluginID: engine.rootID)

    #expect(await EngineProbeSink.shared.sawEngine)

    config.resetForTesting()
}
