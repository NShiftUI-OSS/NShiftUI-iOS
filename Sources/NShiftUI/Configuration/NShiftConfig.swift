import NShiftUIDI
import NShiftUIDomain

@MainActor
public final class NShiftConfig {
    public static let shared = NShiftConfig()

    public private(set) var hostContainer: (any NShiftDependencyContainer)?
    public private(set) var eventHandler: (any NShiftEventHandler)?
    public private(set) var eventStore: (any NShiftEventStore)?
    public private(set) var isStarted = false

    private init() {}

    public func startup(
        hostContainer: any NShiftDependencyContainer,
        assemblies: [any NShiftDependencyAssembly] = []
    ) {
        NShiftRuntimePrecondition.check(
            isStarted == false,
            "NShiftUI has already been started."
        )

        self.hostContainer = hostContainer

        let allAssemblies: [any NShiftDependencyAssembly] = [NShiftUIAssembly()] + assemblies
        allAssemblies.forEach { assembly in
            assembly.assemblePlugins(in: hostContainer)
            assembly.assembleEvents(in: hostContainer)
        }

        eventStore = hostContainer.resolve(NShiftEventStore.self)
        eventHandler = hostContainer.resolve(NShiftEventHandler.self)
        isStarted = true
    }

    package func resetForTesting() {
        hostContainer = nil
        eventHandler = nil
        eventStore = nil
        isStarted = false
        NShiftPluginContainerRegistry.shared.resetForTesting()
        NShiftPluginContainerCatalog.shared.resetForTesting()
        NShiftRegisteredVersionCatalog.shared.resetForTesting()
    }
}
