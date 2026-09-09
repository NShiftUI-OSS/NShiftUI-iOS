import NShiftUIDomain
import SwiftUI
import Testing

private struct TestViewPlugin: NShiftPluginWithMetadata {
    static let name: NShiftPluginName = "TestViewPlugin"
    static let version: NShiftVersion = "1.0.0"
    static let metadataType: any NShiftMetadata.Type = NShiftEmptyMetadata.self

    init?(
        model: NShiftPluginModel,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    ) {
        _ = (model, resolver, eventHandler, engine, renderID)
    }

    init() {}

    var body: some View {
        EmptyView()
    }
}

@MainActor
private final class TestViewPluginContainerViewModel: NShiftPluginViewModel {
    let marker = "container"
}

@MainActor
private struct TestViewPluginContainer: NShiftPluginContainer, NShiftPluginWithMetadata {
    static let name: NShiftPluginName = "TestViewPluginContainer"
    static let version: NShiftVersion = "1.0.0"
    static let metadataType: any NShiftMetadata.Type = NShiftEmptyMetadata.self

    let viewModel = TestViewPluginContainerViewModel()

    init?(
        model: NShiftPluginModel,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    ) {
        _ = (model, resolver, eventHandler, engine, renderID)
    }

    init() {}

    var body: some View {
        EmptyView()
    }
}

@Test func pluginStoresIdentityTypeMetadataStyleChildrenAndEvents() throws {
    let children = [
        TestPlugin(id: "label", name: "Text", version: "1.0.0"),
        TestPlugin(id: "icon", name: "Icon", version: "1.0.0"),
    ]
    let events = [
        TestEvent(name: "Navigate", version: "1.0.0", trigger: "onTap"),
        TestEvent(name: "ShowToast", version: "1.0.0", trigger: "onSuccess"),
    ]
    let slots: [NShiftSlotName: [NShiftPluginModel]] = [
        "Leading": [TestPlugin(id: "leading-icon", name: "Icon", version: "1.0.0")],
        "Trailing": [TestPlugin(id: "trailing-action", name: "Button", version: "1.0.0")],
    ]
    let style = NShiftPluginStyle(
        frame: try NShiftPluginFrame(width: 120, height: 48),
        alignment: .center
    )
    let metadata = TestPluginMetadata()
    let plugin = TestPlugin(
        id: "loginButton",
        name: "Button", version: "1.0.0",
        metadata: metadata,
        style: style,
        children: children,
        slots: slots,
        events: events
    )

    #expect(plugin.id == "loginButton")
    #expect(plugin.name == "Button")
    #expect(plugin.metadata == AnyNShiftMetadata(metadata))
    #expect(plugin.style == style)
    #expect(plugin.children == children)
    #expect(plugin.slots == slots)
    #expect(plugin.events == events.map(AnyNShiftPluginEvent.init))
}

@Test func pluginDefaultsToNoMetadataEmptyStyleChildrenSlotsAndEvents() {
    let plugin = TestPlugin(id: "title", name: "Text", version: "1.0.0")

    #expect(plugin.metadata == nil)
    #expect(plugin.style == NShiftPluginStyle())
    #expect(plugin.children == [])
    #expect(plugin.slots == [:])
    #expect(plugin.events == [])
}

@Test func pluginIdentifierIsOptionalByDefault() {
    let plugin = TestPlugin(name: "Text", version: "1.0.0")

    #expect(plugin.id == nil)
}

@Test func pluginsAreHashable() {
    let plugins: Set<TestPlugin> = [
        TestPlugin(id: "loginButton", name: "Button", version: "1.0.0"),
        TestPlugin(id: "loginButton", name: "Button", version: "1.0.0"),
        TestPlugin(id: "title", name: "Text", version: "1.0.0"),
    ]

    #expect(plugins.count == 2)
}

@Test func emptyPluginMetadataCanBeWrapped() {
    let metadata = NShiftEmptyMetadata()

    #expect(AnyNShiftMetadata(metadata) == AnyNShiftMetadata(metadata))
}

@Test func anyMetadataUnwrapReturnsNilForMismatchedType() {
    struct TitleMetadata: NShiftMetadata {
        let title: String
    }
    struct OtherMetadata: NShiftMetadata {
        let value: Int
    }

    let wrapped = AnyNShiftMetadata(TitleMetadata(title: "Home"))

    #expect(wrapped.unwrap(as: TitleMetadata.self)?.title == "Home")
    #expect(wrapped.unwrap(as: OtherMetadata.self) == nil)
    #expect(wrapped.base is TitleMetadata)
}

@MainActor
@Test func pluginProtocolCanBeImplementedBySwiftUIView() {
    let plugin = TestViewPlugin()

    #expect(plugin.body is EmptyView)
    #expect(TestViewPlugin.name == "TestViewPlugin")
    #expect(ObjectIdentifier(TestViewPlugin.metadataType) == ObjectIdentifier(NShiftEmptyMetadata.self))
}

@MainActor
@Test func pluginContainerProtocolCanBeImplementedBySwiftUIView() {
    let plugin = TestViewPluginContainer()

    #expect(plugin.body is EmptyView)
    #expect(plugin.viewModel.marker == "container")
    #expect(TestViewPluginContainer.name == "TestViewPluginContainer")
    #expect(ObjectIdentifier(TestViewPluginContainer.metadataType) == ObjectIdentifier(NShiftEmptyMetadata.self))
}
