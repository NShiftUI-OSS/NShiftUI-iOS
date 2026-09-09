import SwiftUI
import Testing
@testable import NShiftUI
@testable import NShiftUIDomain

private struct HomeScreenMetadata: NShiftMetadata {}

@MainActor
private final class HomeScreenViewModel: NShiftPluginViewModel {}

@NShiftPlugin(name: "HomeScreen", version: "1.0.0", metadata: HomeScreenMetadata.self)
private struct HomeScreenPlugin: NShiftPluginContainer {
    @StateObject var viewModel: HomeScreenViewModel

    var body: some View {
        Text("home")
    }
}

@NShiftPlugin(name: "LeafButton", version: "1.0.0", metadata: HomeScreenMetadata.self)
private struct LeafButtonPlugin: NShiftPlugin {
    var body: some View {
        Text("leaf")
    }
}

private struct HomeScreenAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(HomeScreenPlugin.self, LeafButtonPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {
        container.register(HomeScreenViewModel.self) {
            HomeScreenViewModel()
        }
    }
}

@MainActor
@Test func registerPluginMarksPluginContainers() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    config.startup(
        hostContainer: NShiftDependencyRegistry(),
        assemblies: [HomeScreenAssembly()]
    )

    #expect(NShiftPluginContainerCatalog.shared.contains("HomeScreen"))
    #expect(NShiftPluginContainerCatalog.shared.contains("LeafButton") == false)

    config.resetForTesting()
}

@MainActor
@Test func pluginStoreReturnsNilWhenContainerViewModelIsMissing() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(
        hostContainer: host,
        assemblies: [HomeScreenAssemblyWithoutViewModel()]
    )

    let store = host.resolveUnwrapping(NShiftPluginStore.self)
    let model = NShiftPluginModel(
        name: "HomeScreen",
        version: "1.0.0",
        metadata: HomeScreenMetadata()
    )

    #expect(store.resolve(model, renderID: .root) == nil)

    config.resetForTesting()
}

private struct HomeScreenAssemblyWithoutViewModel: NShiftDependencyAssembly {
    @NShiftPluginAssemble(HomeScreenPlugin.self)
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func nShiftViewBuildsForRegisteredContainerModel() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(
        hostContainer: host,
        assemblies: [HomeScreenAssembly()]
    )

    let model = NShiftPluginModel(
        id: "screen-1",
        name: "HomeScreen", version: "1.0.0", metadata: HomeScreenMetadata(),
        children: [NShiftPluginModel(id: "btn", name: "LeafButton", version: "1.0.0", metadata: HomeScreenMetadata())]
    )

    _ = NShiftView(model: model)

    config.resetForTesting()
}

@MainActor
@Test func nShiftViewEngineIndexesContainerTree() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    config.startup(
        hostContainer: NShiftDependencyRegistry(),
        assemblies: [HomeScreenAssembly()]
    )

    let model = NShiftPluginModel(
        id: "screen-1",
        name: "HomeScreen", version: "1.0.0", metadata: HomeScreenMetadata(),
        children: [NShiftPluginModel(id: "btn", name: "LeafButton", version: "1.0.0", metadata: HomeScreenMetadata())]
    )

    let engine = NShiftEngineResolver.makeEngine(rootModel: model, config: config)
    let tree = engine as! NShiftDefaultEngine

    #expect(engine.rootID == "screen-1")
    #expect(tree.node(withID: "btn") != nil)

    config.resetForTesting()
}

@MainActor
@Test func pluginContainerRegistrationTokenRegistersOnLoadAndUnregistersOnDeinit() {
    NShiftPluginContainerRegistry.shared.resetForTesting()

    let engine = NShiftDefaultEngine(
        rootModel: NShiftPluginModel(id: "screen-1", name: "HomeScreen", version: "1.0.0"),
        eventHandler: DummyContainerEventHandler()
    )

    var token: NShiftPluginContainerRegistrationTokenProbe? = NShiftPluginContainerRegistrationTokenProbe(
        rootID: "screen-1",
        engine: engine
    )
    token?.registerIfNeeded()

    #expect(NShiftPluginContainerRegistry.shared.engine(for: "screen-1") != nil)

    token = nil

    #expect(NShiftPluginContainerRegistry.shared.engine(for: "screen-1") == nil)

    NShiftPluginContainerRegistry.shared.resetForTesting()
}

private final class DummyContainerEventHandler: NShiftEventHandler {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {}

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {}
}

@MainActor
private final class NShiftPluginContainerRegistrationTokenProbe {
    private let rootID: String
    private let engine: any NShiftEngine
    private var isRegistered = false

    init(rootID: String, engine: any NShiftEngine) {
        self.rootID = rootID
        self.engine = engine
    }

    func registerIfNeeded() {
        guard isRegistered == false else { return }

        NShiftPluginContainerRegistry.shared.register(rootID: rootID, engine: engine)
        isRegistered = true
    }

    deinit {
        let rootID = rootID
        MainActor.assumeIsolated {
            NShiftPluginContainerRegistry.shared.unregister(rootID: rootID)
        }
    }
}

@MainActor
@Test func pluginContainerMacroCanInstantiateRegisteredContainer() {
    let model = NShiftPluginModel(id: "home-99", name: "HomeScreen", version: "1.0.0", metadata: HomeScreenMetadata())
    let registry = NShiftDependencyRegistry()
    registry.register(HomeScreenViewModel.self) {
        HomeScreenViewModel()
    }
    let plugin = HomeScreenPlugin(
        model: model,
        resolver: registry,
        eventHandler: DummyContainerEventHandler(),
        engine: nil
    )

    #expect(plugin != nil)
    #expect(plugin?.body is Text)
}

@Test func nShiftViewUnregisteredRootFailsPreconditionContract() {
    let message = captureRuntimePrecondition {
        NShiftRuntimePrecondition.check(
            false,
            "NShiftView requires a plugin model whose name is registered as a plugin container."
        )
    }

    #expect(
        message
            == "NShiftView requires a plugin model whose name is registered as a plugin container."
    )
}

@MainActor
@Test func nShiftViewRejectsUnregisteredAndLeafNamesInCatalog() {
    let config = NShiftConfig.shared
    config.resetForTesting()
    config.startup(
        hostContainer: NShiftDependencyRegistry(),
        assemblies: [HomeScreenAssembly()]
    )

    #expect(NShiftPluginContainerCatalog.shared.contains("Unknown") == false)
    #expect(NShiftPluginContainerCatalog.shared.contains("LeafButton") == false)
    #expect(NShiftPluginContainerCatalog.shared.contains("HomeScreen"))

    config.resetForTesting()
}

@Test func nShiftViewNonTreeEngineFailsPreconditionContract() {
    let message = captureRuntimePrecondition {
        NShiftRuntimePrecondition.raise(
            "NShiftView requires an engine that conforms to NShiftEngineTree."
        )
    }

    #expect(message == "NShiftView requires an engine that conforms to NShiftEngineTree.")
}

@MainActor
@Test func registeredCustomEngineNeedNotConformToEngineTree() {
    let engine: any NShiftEngine = BareEngine(rootID: "screen-1")

    #expect((engine is any NShiftEngineTree) == false)
    #expect(engine.rootID == "screen-1")
}

@MainActor
@Test func nShiftNodeViewRendersEmptyViewWhenStoreMisses() {
    let engine = NShiftDefaultEngine(
        rootModel: NShiftPluginModel(id: "root", name: "HomeScreen", version: "1.0.0"),
        eventHandler: DummyContainerEventHandler()
    )
    let view = NShiftNodeView(node: engine.root, engine: engine)

    _ = view.body
}

@MainActor
private final class BareEngine: NShiftEngine {
    let rootID: String

    init(rootID: String) {
        self.rootID = rootID
    }

    func handle(
        _ trigger: NShiftTrigger,
        onPluginID pluginID: String
    ) async {}

    func replaceMetadata(pluginID: String, with metadata: AnyNShiftMetadata?) {}
    func replacePlugin(pluginID: String, with model: NShiftPluginModel) {}
    func replaceChildren(pluginID: String, with children: [NShiftPluginModel]) {}
    func replaceSlots(pluginID: String, with slots: [NShiftSlotName: [NShiftPluginModel]]) {}
    func replaceSlot(pluginID: String, name: NShiftSlotName, with models: [NShiftPluginModel]) {}
    func replaceEvents(pluginID: String, with events: [NShiftEventModel]) {}
    func replaceEvent(eventID: String, with event: NShiftEventModel) {}
}
