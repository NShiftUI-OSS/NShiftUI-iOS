import NShiftUI
import SwiftUI
import Testing

private struct AssembledPluginMetadata: NShiftMetadata {}

@NShiftPlugin(name: "AssembledButton", version: "1.0.0", metadata: AssembledPluginMetadata.self)
private struct AssembledButtonPlugin: NShiftPlugin {
    var body: some View {
        Text(pluginChildren.count.description)
    }
}

private struct AssembledButtonModuleAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(AssembledButtonPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func pluginAssembleMacroRegistersPluginInContainer() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(hostContainer: host, assemblies: [AssembledButtonModuleAssembly()])

    let store = host.resolve(NShiftPluginStore.self)
    let view = store?.resolve(
        NShiftPluginModel(name: "AssembledButton", version: "1.0.0", metadata: AssembledPluginMetadata()),
        renderID: .root
    )

    #expect(store != nil)
    #expect(view != nil)

    config.resetForTesting()
}
