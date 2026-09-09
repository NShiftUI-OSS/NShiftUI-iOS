import NShiftUI
import NShiftUIDomain
import SwiftUI
import Testing

private struct RegistryHeroMetadata: NShiftMetadata {
    var title: String = "hero"
}

@NShiftPlugin(name: "RegistryHero", version: "1.0.0", metadata: RegistryHeroMetadata.self)
private struct RegistryHeroPlugin: NShiftPlugin {
    var body: some View {
        Text(metadata.title)
    }
}

@NShiftPlugin(name: "RegistryCard", version: "2.0.0")
private struct RegistryCardPlugin: NShiftPlugin {
    var body: some View {
        Text("card")
    }
}

private struct RegistryHeroAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(RegistryHeroPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

private struct RegistryCardAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(RegistryCardPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func pluginStoreResolvesExactNameAndVersion() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(
        hostContainer: host,
        assemblies: [RegistryHeroAssembly(), RegistryCardAssembly()]
    )

    let store = host.resolveUnwrapping(NShiftPluginStore.self)

    #expect(
        store.resolve(NShiftPluginModel(name: "RegistryHero", version: "1.0.0", metadata: RegistryHeroMetadata()), renderID: .root) != nil
    )
    #expect(
        store.resolve(NShiftPluginModel(name: "RegistryCard", version: "2.0.0"), renderID: .root) != nil
    )
    #expect(
        store.resolve(NShiftPluginModel(name: "RegistryHero", version: "1.0.0"), renderID: .root) == nil
    )
    #expect(
        store.resolve(NShiftPluginModel(name: "RegistryHero", version: "9.9.9"), renderID: .root) == nil
    )
    #expect(
        store.resolve(NShiftPluginModel(name: "Unknown", version: "1.0.0"), renderID: .root) == nil
    )

    config.resetForTesting()
}

@MainActor
@Test func emptyPluginStoreAlwaysReturnsNil() {
    let store = NShiftEmptyPluginStore()

    #expect(
        store.resolve(NShiftPluginModel(name: "Anything", version: "1.0.0"), renderID: .root) == nil
    )
}
