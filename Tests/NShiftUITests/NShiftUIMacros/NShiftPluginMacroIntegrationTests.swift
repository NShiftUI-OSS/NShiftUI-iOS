import NShiftUI
import SwiftUI
import Testing

private struct IntegratedPluginMetadata: NShiftMetadata {}

@MainActor
private final class IntegratedPluginViewModel: NShiftPluginViewModel {
    let title = "plugin"
}

@MainActor
private final class IntegratedContainerViewModel: NShiftPluginViewModel {
    let title = "container"
}

private final class IntegratedEventHandler: NShiftEventHandler {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {}

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {}
}

private final class IntegratedResolver: NShiftDependencyResolver {
    func resolve<Service>(
        _ serviceType: Service.Type,
        name: String?,
        argumentTypes: [Any.Type],
        arguments: [Any]
    ) -> Service? {
        if Service.self == IntegratedContainerViewModel.self {
            return IntegratedContainerViewModel() as? Service
        }
        return nil
    }
}

@NShiftPlugin(name: "IntegratedPlugin", version: "1.0.0", metadata: IntegratedPluginMetadata.self)
private struct IntegratedPlugin: NShiftPlugin {
    var body: some View {
        Text(pluginChildren.count.description)
    }
}

@NShiftPlugin(name: "IntegratedContainer", version: "1.0.0", metadata: IntegratedPluginMetadata.self)
private struct IntegratedContainer: NShiftPluginContainer {
    @StateObject var viewModel: IntegratedContainerViewModel

    var body: some View {
        Text("\(viewModel.title)-\(pluginChildren.count)")
    }
}

@MainActor
@Test func pluginMacroCanBeUsedFromPublicMacrosModule() {
    let model = NShiftPluginModel(
        id: "integrated",
        name: "IntegratedPlugin", version: "1.0.0",
        metadata: IntegratedPluginMetadata(),
        style: NShiftPluginStyle(alignment: .center),
        children: [NShiftPluginModel(id: "title", name: "Text", version: "1.0.0")]
    )
    let plugin = IntegratedPlugin(
        model: model,
        resolver: IntegratedResolver(),
        eventHandler: IntegratedEventHandler(),
        engine: nil
    )

    #expect(plugin != nil)
    #expect(IntegratedPlugin.name == "IntegratedPlugin")
    #expect(ObjectIdentifier(IntegratedPlugin.metadataType) == ObjectIdentifier(IntegratedPluginMetadata.self))
    #expect(plugin?.body is Text)
}

@MainActor
@Test func pluginMacroCanBeUsedWithContainerFromPublicMacrosModule() {
    let model = NShiftPluginModel(
        id: "integrated-container",
        name: "IntegratedContainer", version: "1.0.0",
        metadata: IntegratedPluginMetadata(),
        style: NShiftPluginStyle(alignment: .center),
        children: [NShiftPluginModel(id: "title", name: "Text", version: "1.0.0")]
    )
    let plugin = IntegratedContainer(
        model: model,
        resolver: IntegratedResolver(),
        eventHandler: IntegratedEventHandler(),
        engine: nil
    )

    #expect(plugin != nil)
    #expect(IntegratedContainer.name == "IntegratedContainer")
    #expect(ObjectIdentifier(IntegratedContainer.metadataType) == ObjectIdentifier(IntegratedPluginMetadata.self))
    #expect(plugin?.body is Text)
}
