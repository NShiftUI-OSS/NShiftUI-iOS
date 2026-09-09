import SwiftUI
import Testing
@testable import NShiftUI

private struct TestClient: Equatable, Sendable {
    let value: String
}

private struct ButtonPluginMetadata: NShiftMetadata {}

@NShiftPlugin(name: "Button", version: "1.0.0", metadata: ButtonPluginMetadata.self)
private struct ButtonPlugin: NShiftPlugin {
    var body: some View {
        Text("Button")
    }
}

@NShiftPlugin(name: "Text", version: "1.0.0", metadata: ButtonPluginMetadata.self)
private struct TextPlugin: NShiftPlugin {
    var body: some View {
        Text("Text")
    }
}

private struct TestClientAssembly: NShiftDependencyAssembly {
    func assemblePlugins(in container: any NShiftDependencyContainer) {
        container.register(TestClient.self) {
            TestClient(value: "assembled")
        }
    }
}

private struct NamedTestClientAssembly: NShiftDependencyAssembly {
    let name: String
    let value: String

    func assemblePlugins(in container: any NShiftDependencyContainer) {
        container.register(TestClient.self, name: name) {
            TestClient(value: value)
        }
    }
}

private struct ButtonPluginAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(ButtonPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

private struct ShowToastEventAssembly: NShiftDependencyAssembly {
    func assembleEvents(in container: any NShiftDependencyContainer) {
        container.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
            NShiftEventAction { _ in }
        }
    }
}

private struct FullModuleAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(TextPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}

    func assembleEvents(in container: any NShiftDependencyContainer) {
        container.register(NShiftEventAction.self, name: "Navigate@1.0.0") {
            NShiftEventAction { _ in }
        }
    }
}

@MainActor
@Test func assemblyRegistersDependenciesWhenAppliedToRegistry() {
    let registry = NShiftDependencyRegistry()
    registry.apply(TestClientAssembly())

    #expect(registry.resolve(TestClient.self) == TestClient(value: "assembled"))
}

@MainActor
@Test func registryAppliesMultipleAssembliesInOrder() {
    let registry = NShiftDependencyRegistry()
    registry.apply([
        NamedTestClientAssembly(name: "primary", value: "primary"),
        NamedTestClientAssembly(name: "secondary", value: "secondary"),
    ])

    #expect(registry.resolve(TestClient.self, name: "primary") == TestClient(value: "primary"))
    #expect(registry.resolve(TestClient.self, name: "secondary") == TestClient(value: "secondary"))
}

@MainActor
@Test func moduleAssemblyCanRegisterPluginViews() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let registry = NShiftDependencyRegistry()
    config.startup(hostContainer: registry, assemblies: [ButtonPluginAssembly()])

    let store = registry.resolveUnwrapping(NShiftPluginStore.self)

    #expect(store.resolve(NShiftPluginModel(name: "Button", version: "1.0.0", metadata: ButtonPluginMetadata()), renderID: .root) != nil)

    config.resetForTesting()
}

@MainActor
@Test func moduleAssemblyCanRegisterEventActions() {
    let registry = NShiftDependencyRegistry()
    registry.apply(ShowToastEventAssembly())

    let action = registry.resolve(NShiftEventAction.self, name: "ShowToast@1.0.0")

    #expect(action != nil)
}

@MainActor
@Test func assemblyApplyRegistersPluginsAndEventsFromSameModule() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let registry = NShiftDependencyRegistry()
    config.startup(hostContainer: registry, assemblies: [FullModuleAssembly()])

    let store = registry.resolveUnwrapping(NShiftPluginStore.self)
    let action = registry.resolve(NShiftEventAction.self, name: "Navigate@1.0.0")

    #expect(store.resolve(NShiftPluginModel(name: "Text", version: "1.0.0", metadata: ButtonPluginMetadata()), renderID: .root) != nil)
    #expect(action != nil)

    config.resetForTesting()
}
