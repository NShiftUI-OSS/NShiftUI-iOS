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
        if isStarted {
            resetForTesting()
        }

        self.hostContainer = hostContainer
        NShiftCatalogHooks.shared.hook = NShiftRainbowCatalogHook()

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
        NShiftCatalogHooks.shared.hook = nil
        NShiftRainbowCatalog.shared.resetForTesting()
        NShiftPluginContainerRegistry.shared.resetForTesting()
        NShiftPluginContainerCatalog.shared.resetForTesting()
        NShiftRegisteredVersionCatalog.shared.resetForTesting()
    }
}

private final class NShiftRainbowCatalogHook: NShiftCatalogHook {
    func typeRegistered(_ type: Any.Type) {
        NShiftRainbowCatalog.shared.adopt(type)
    }
}
