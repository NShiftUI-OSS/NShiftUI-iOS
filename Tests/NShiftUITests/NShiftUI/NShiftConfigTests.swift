import SwiftUI
import Testing
@testable import NShiftUI

private struct ConfigHostClient: Equatable, Sendable {
    let value: String
}

private struct ConfigPluginMetadata: NShiftMetadata {}

@NShiftPlugin(name: "ConfigButton", version: "1.0.0", metadata: ConfigPluginMetadata.self)
private struct ConfigButtonPlugin: NShiftPlugin {
    var body: some View {
        Text("Button")
    }
}

private struct ConfigButtonAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(ConfigButtonPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

private struct ConfigEventAssembly: NShiftDependencyAssembly {
    func assembleEvents(in container: any NShiftDependencyContainer) {
        container.register(NShiftEventAction.self, name: "ShowToast@1.0.0") {
            NShiftEventAction { _ in }
        }
    }
}

@MainActor
@Test func configStartupRegistersAssembliesInHostContainer() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let hostContainer = NShiftDependencyRegistry()
    hostContainer.register(ConfigHostClient.self) {
        ConfigHostClient(value: "host")
    }

    config.startup(
        hostContainer: hostContainer,
        assemblies: [ConfigButtonAssembly(), ConfigEventAssembly()]
    )

    let store = config.hostContainer?.resolve(NShiftPluginStore.self)
    let eventAction = config.eventHandler
    let hostClient = config.hostContainer?.resolve(ConfigHostClient.self)

    #expect(config.isStarted)
    #expect(store?.resolve(NShiftPluginModel(name: "ConfigButton", version: "1.0.0", metadata: ConfigPluginMetadata()), renderID: .root) != nil)
    #expect(eventAction != nil)
    #expect(hostClient == ConfigHostClient(value: "host"))
    #expect(config.eventStore != nil)

    config.resetForTesting()
}

@MainActor
@Test func configReportsStartedAfterStartup() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    config.startup(hostContainer: NShiftDependencyRegistry())

    #expect(config.isStarted)

    config.resetForTesting()
}

@MainActor
@Test func configResolvesEventActionsFromHostContainer() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(hostContainer: host, assemblies: [ConfigEventAssembly()])

    #expect(host.resolve(NShiftEventAction.self, name: "ShowToast@1.0.0") != nil)

    config.resetForTesting()
}

@Test func configSecondStartupFailsPreconditionContract() {
    let message = captureRuntimePrecondition {
        NShiftRuntimePrecondition.check(
            false,
            "NShiftUI has already been started."
        )
    }

    #expect(message == "NShiftUI has already been started.")
}

@MainActor
@Test func configReportsNotStartedAfterReset() {
    let config = NShiftConfig.shared
    config.resetForTesting()
    config.startup(hostContainer: NShiftDependencyRegistry())
    #expect(config.isStarted)

    config.resetForTesting()
    #expect(config.isStarted == false)
}

@MainActor
@Test func configResetForTestingClearsRegisteredVersionCatalog() {
    let config = NShiftConfig.shared
    config.resetForTesting()
    config.startup(
        hostContainer: NShiftDependencyRegistry(),
        assemblies: [ConfigButtonAssembly()]
    )

    #expect(NShiftRegisteredVersionCatalog.shared.latestPlugin(named: "ConfigButton") != nil)

    config.resetForTesting()

    #expect(NShiftRegisteredVersionCatalog.shared.latestPlugin(named: "ConfigButton") == nil)
}
