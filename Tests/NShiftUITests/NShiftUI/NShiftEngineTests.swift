import SwiftUI
import Testing
@testable import NShiftUI

private struct EngineMetadata: NShiftMetadata {
    let value: String
}

private struct EngineNewMetadata: NShiftMetadata {
    let value: String
}

private final class NoopEventHandler: NShiftEventHandler {
    func handle(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async {}

    func handleThrowing(
        _ trigger: NShiftTrigger,
        events: [AnyNShiftPluginEvent]
    ) async throws(NShiftEventHandlingError) {}
}

private actor EngineEventRecorder {
    private(set) var values: [String] = []

    func record(_ value: String) {
        values.append(value)
    }
}

private final class CustomEngine: NShiftDefaultEngine {}

@MainActor
private func makeEngine(
    root: NShiftPluginModel,
    eventHandler: any NShiftEventHandler = NoopEventHandler()
) -> NShiftDefaultEngine {
    NShiftDefaultEngine(rootModel: root, eventHandler: eventHandler)
}

@MainActor
@Test func engineIndexesEveryPluginAndEventInTheTree() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [
            NShiftPluginModel(
                id: "card",
                name: "Card", version: "1.0.0",
                slots: [
                    "Leading": [
                        NShiftPluginModel(
                            id: "card-icon",
                            name: "Icon", version: "1.0.0",
                            events: [NShiftEventModel(id: "icon-tap", name: "Tap", version: "1.0.0", trigger: "onTap")]
                        ),
                    ],
                ],
                events: [NShiftEventModel(id: "card-tap", name: "Tap", version: "1.0.0", trigger: "onTap")]
            ),
        ],
        events: [NShiftEventModel(id: "root-appear", name: "Appear", version: "1.0.0", trigger: "onAppear")]
    )
    let engine = makeEngine(root: root)

    #expect(engine.node(withID: "root") != nil)
    #expect(engine.node(withID: "card") != nil)
    #expect(engine.node(withID: "card-icon") != nil)
    #expect(engine.eventLocation(withID: "root-appear") != nil)
    #expect(engine.eventLocation(withID: "card-tap") != nil)
    #expect(engine.eventLocation(withID: "icon-tap") != nil)
    #expect(engine.node(withID: "missing") == nil)
}

@MainActor
@Test func engineIndexesNestedEvents() {
    let nested = NShiftEventModel(id: "nested", name: "Nested", version: "1.0.0", trigger: "onTap")
    let parent = NShiftEventModel(id: "parent", name: "Parent", version: "1.0.0", trigger: "onTap", events: [nested])
    let root = NShiftPluginModel(id: "root", name: "Root", version: "1.0.0", events: [parent])
    let engine = makeEngine(root: root)

    #expect(engine.eventLocation(withID: "parent") == NShiftEventLocation(ownerNodeID: "r", path: [0]))
    #expect(engine.eventLocation(withID: "nested") == NShiftEventLocation(ownerNodeID: "r", path: [0, 0]))
}

@MainActor
@Test func replaceMetadataMutatesOnlyTheTargetNode() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [NShiftPluginModel(id: "target", name: "Card", version: "1.0.0", metadata: EngineMetadata(value: "old"))]
    )
    let engine = makeEngine(root: root)
    let newMetadata = AnyNShiftMetadata(EngineNewMetadata(value: "new"))

    engine.replaceMetadata(pluginID: "target", with: newMetadata)

    #expect(engine.node(withID: "target")?.model.metadata == newMetadata)
    #expect(engine.node(withID: "target") != nil)
}

@MainActor
@Test func replacePluginRebuildsSubtreeAndReindexes() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [
            NShiftPluginModel(
                id: "target",
                name: "Card", version: "1.0.0",
                children: [NShiftPluginModel(id: "old-child", name: "Label", version: "1.0.0")],
                slots: [
                    "Leading": [NShiftPluginModel(id: "old-slot-child", name: "Icon", version: "1.0.0")],
                ]
            ),
        ]
    )
    let engine = makeEngine(root: root)
    #expect(engine.node(withID: "old-child") != nil)
    #expect(engine.node(withID: "old-slot-child") != nil)

    let replacement = NShiftPluginModel(
        id: "target",
        name: "Banner", version: "1.0.0",
        children: [NShiftPluginModel(id: "new-child", name: "Image", version: "1.0.0")],
        slots: [
            "Trailing": [NShiftPluginModel(id: "new-slot-child", name: "Button", version: "1.0.0")],
        ]
    )
    engine.replacePlugin(pluginID: "target", with: replacement)

    #expect(engine.node(withID: "target")?.model.name == "Banner")
    #expect(engine.node(withID: "old-child") == nil)
    #expect(engine.node(withID: "old-slot-child") == nil)
    #expect(engine.node(withID: "new-child") != nil)
    #expect(engine.node(withID: "new-slot-child") != nil)
    #expect(engine.node(withID: "target")?.children.first?.model.id == "new-child")
    #expect(engine.node(withID: "target")?.slotChildren["Trailing"]?.first?.model.id == "new-slot-child")
    #expect(engine.node(withID: "target")?.children.first?.renderId.rawValue == "r/c/0/c/0")
    #expect(engine.node(withID: "target")?.slotChildren["Trailing"]?.first?.renderId.rawValue == "r/c/0/s/Trailing/0")
}

@MainActor
@Test func replaceEventsSwapsAndReindexesNodeEvents() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        events: [NShiftEventModel(id: "old", name: "Tap", version: "1.0.0", trigger: "onTap")]
    )
    let engine = makeEngine(root: root)

    engine.replaceEvents(pluginID: "root", with: [NShiftEventModel(id: "new", name: "Swipe", version: "1.0.0", trigger: "onTap")])

    #expect(engine.eventLocation(withID: "old") == nil)
    #expect(engine.eventLocation(withID: "new") != nil)
    #expect(engine.node(withID: "root")?.model.events.compactMap(\.event).first?.name == "Swipe")
}

@MainActor
@Test func replaceEventSwapsNestedEventByID() {
    let nested = NShiftEventModel(id: "nested", name: "Nested", version: "1.0.0", trigger: "onTap")
    let parent = NShiftEventModel(id: "parent", name: "Parent", version: "1.0.0", trigger: "onTap", events: [nested])
    let root = NShiftPluginModel(id: "root", name: "Root", version: "1.0.0", events: [parent])
    let engine = makeEngine(root: root)

    engine.replaceEvent(eventID: "nested", with: NShiftEventModel(id: "nested", name: "Updated", version: "1.0.0", trigger: "onTap"))

    let forest = engine.node(withID: "root")?.model.events.compactMap(\.event)
    #expect(forest?.first?.events.first?.name == "Updated")
    #expect(engine.eventLocation(withID: "nested") != nil)
}

@MainActor
@Test func replaceEventPreservesEventSlotsWhenReplacingNestedChildren() {
    let slot = NShiftPluginModel(id: "sheet-title", name: "Text", version: "1.0.0")
    let nested = NShiftEventModel(id: "nested", name: "Nested", version: "1.0.0", trigger: "onTap")
    let parent = NShiftEventModel(
        id: "parent",
        name: "Parent", version: "1.0.0",
        trigger: "onTap",
        slots: ["Content": [slot]],
        events: [nested]
    )
    let root = NShiftPluginModel(id: "root", name: "Root", version: "1.0.0", events: [parent])
    let engine = makeEngine(root: root)

    engine.replaceEvent(eventID: "nested", with: NShiftEventModel(id: "nested", name: "Updated", version: "1.0.0", trigger: "onTap"))

    let forest = engine.node(withID: "root")?.model.events.compactMap(\.event)

    #expect(forest?.first?.slots == ["Content": [slot]])
}

@MainActor
@Test func handleForwardsNodeEventsToEventHandler() async {
    let registry = NShiftDependencyRegistry()
    let recorder = EngineEventRecorder()
    registry.register(NShiftEventAction.self, name: "Track@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: NShiftDependencyEventStore(), resolver: registry)
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        events: [NShiftEventModel(id: "evt", name: "Track", version: "1.0.0", trigger: "onTap")]
    )
    let engine = makeEngine(root: root, eventHandler: handler)

    await engine.handle("onTap", onPluginID: engine.rootID)

    #expect(await recorder.values == ["Track"])
}

@MainActor
@Test func configUsesCustomEngineWhenRegistered() {
    let config = NShiftConfig.shared
    config.resetForTesting()
    let host = NShiftDependencyRegistry()
    config.startup(hostContainer: host)

    host.registerEngine { rootModel in
        CustomEngine(
            rootModel: rootModel,
            eventHandler: host.resolveUnwrapping(NShiftEventHandler.self)
        )
    }

    let engine = NShiftEngineResolver.makeEngine(
        rootModel: NShiftPluginModel(id: "root", name: "Root", version: "1.0.0"),
        config: config
    )

    #expect(engine is CustomEngine)

    config.resetForTesting()
}

@MainActor
@Test func configFallsBackToDefaultEngineWhenCustomResolutionFails() {
    let config = NShiftConfig.shared
    config.resetForTesting()
    config.startup(hostContainer: NShiftDependencyRegistry())

    let engine = NShiftEngineResolver.makeEngine(
        rootModel: NShiftPluginModel(id: "root", name: "Root", version: "1.0.0"),
        config: config
    )

    #expect((engine is CustomEngine) == false)

    config.resetForTesting()
}

@MainActor
@Test func engineAssignsStableRenderIDsByPath() {
    let root = NShiftPluginModel(
        name: "Root", version: "1.0.0",
        children: [
            NShiftPluginModel(
                name: "Card", version: "1.0.0",
                slots: [
                    "Footer": [NShiftPluginModel(name: "Button", version: "1.0.0")],
                ]
            ),
        ]
    )
    let engine = makeEngine(root: root)

    #expect(engine.root.renderId == .root)
    #expect(engine.rootID == "r")
    #expect(engine.node(withRenderID: .root) != nil)
    #expect(engine.root.children.first?.renderId.rawValue == "r/c/0")
    #expect(engine.root.children.first?.slotChildren["Footer"]?.first?.renderId.rawValue == "r/c/0/s/Footer/0")
    #expect(engine.node(withID: "missing") == nil)
}

@MainActor
@Test func replaceMetadataPreservesRenderID() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [NShiftPluginModel(id: "target", name: "Card", version: "1.0.0", metadata: EngineMetadata(value: "old"))]
    )
    let engine = makeEngine(root: root)
    let before = engine.node(withID: "target")?.renderId

    engine.replaceMetadata(
        pluginID: "target",
        with: AnyNShiftMetadata(EngineNewMetadata(value: "new"))
    )

    #expect(engine.node(withID: "target")?.renderId == before)
    #expect(before?.rawValue == "r/c/0")
}

@MainActor
@Test func replaceChildrenRebuildsOnlyChildrenAndKeepsRenderIDsAtSameIndexes() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [
            NShiftPluginModel(id: "old-a", name: "Label", version: "1.0.0"),
            NShiftPluginModel(id: "old-b", name: "Label", version: "1.0.0"),
        ],
        slots: [
            "Footer": [NShiftPluginModel(id: "footer", name: "Button", version: "1.0.0")],
        ]
    )
    let engine = makeEngine(root: root)
    let footerRenderID = engine.node(withID: "footer")?.renderId

    engine.replaceChildren(
        pluginID: "root",
        with: [
            NShiftPluginModel(id: "new-a", name: "Image", version: "1.0.0"),
            NShiftPluginModel(id: "new-b", name: "Image", version: "1.0.0"),
        ]
    )

    #expect(engine.node(withID: "old-a") == nil)
    #expect(engine.node(withID: "new-a")?.renderId.rawValue == "r/c/0")
    #expect(engine.node(withID: "new-b")?.renderId.rawValue == "r/c/1")
    #expect(engine.node(withID: "footer")?.renderId == footerRenderID)
}

@MainActor
@Test func replaceSlotRebuildsOnlyThatSlot() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [NShiftPluginModel(id: "child", name: "Label", version: "1.0.0")],
        slots: [
            "Footer": [NShiftPluginModel(id: "old-footer", name: "Button", version: "1.0.0")],
            "Header": [NShiftPluginModel(id: "header", name: "Text", version: "1.0.0")],
        ]
    )
    let engine = makeEngine(root: root)
    let childRenderID = engine.node(withID: "child")?.renderId
    let headerRenderID = engine.node(withID: "header")?.renderId

    engine.replaceSlot(
        pluginID: "root",
        name: "Footer",
        with: [NShiftPluginModel(id: "new-footer", name: "Icon", version: "1.0.0")]
    )

    #expect(engine.node(withID: "old-footer") == nil)
    #expect(engine.node(withID: "new-footer")?.renderId.rawValue == "r/s/Footer/0")
    #expect(engine.node(withID: "child")?.renderId == childRenderID)
    #expect(engine.node(withID: "header")?.renderId == headerRenderID)
}

@MainActor
@Test func replaceSlotsRebuildsEverySlotAndReindexes() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        slots: [
            "Footer": [NShiftPluginModel(id: "old-footer", name: "Button", version: "1.0.0")],
            "Header": [NShiftPluginModel(id: "old-header", name: "Text", version: "1.0.0")],
        ]
    )
    let engine = makeEngine(root: root)

    engine.replaceSlots(
        pluginID: "root",
        with: [
            "Leading": [NShiftPluginModel(id: "new-leading", name: "Icon", version: "1.0.0")],
        ]
    )

    #expect(engine.node(withID: "old-footer") == nil)
    #expect(engine.node(withID: "old-header") == nil)
    #expect(engine.node(withID: "new-leading")?.renderId.rawValue == "r/s/Leading/0")
    #expect(engine.root.slotChildren["Footer"] == nil || engine.root.slotChildren["Footer"]?.isEmpty == true)
}

@MainActor
@Test func replaceMutationsNoOpWhenPluginIDIsMissing() {
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        children: [NShiftPluginModel(id: "child", name: "Label", version: "1.0.0")],
        slots: [
            "Footer": [NShiftPluginModel(id: "footer", name: "Button", version: "1.0.0")],
        ],
        events: [NShiftEventModel(id: "old", name: "Tap", version: "1.0.0", trigger: "onTap")]
    )
    let engine = makeEngine(root: root)
    let before = engine.node(withID: "root")?.model

    engine.replaceMetadata(pluginID: "missing", with: AnyNShiftMetadata(EngineNewMetadata(value: "x")))
    engine.replaceChildren(pluginID: "missing", with: [])
    engine.replaceSlot(pluginID: "missing", name: "Footer", with: [])
    engine.replaceSlots(pluginID: "missing", with: [:])
    engine.replaceEvents(pluginID: "missing", with: [])
    engine.replacePlugin(pluginID: "missing", with: NShiftPluginModel(id: "other", name: "Other", version: "1.0.0"))
    engine.replaceEvent(eventID: "missing", with: NShiftEventModel(id: "new", name: "Tap", version: "1.0.0", trigger: "onTap"))

    #expect(engine.node(withID: "root")?.model == before)
    #expect(engine.node(withID: "child") != nil)
    #expect(engine.eventLocation(withID: "old") != nil)
}

@MainActor
@Test func handleNoOpsWhenPluginIDIsMissing() async {
    let recorder = EngineEventRecorder()
    let registry = NShiftDependencyRegistry()
    registry.register(NShiftEventAction.self, name: "Track@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: NShiftDependencyEventStore(), resolver: registry)
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        events: [NShiftEventModel(id: "evt", name: "Track", version: "1.0.0", trigger: "onTap")]
    )
    let engine = makeEngine(root: root, eventHandler: handler)

    await engine.handle("onTap", onPluginID: "missing")

    #expect(await recorder.values.isEmpty)
}

@MainActor
@Test func handleOverloadWithoutViewModelForwardsEvents() async {
    let registry = NShiftDependencyRegistry()
    let recorder = EngineEventRecorder()
    registry.register(NShiftEventAction.self, name: "Track@1.0.0") {
        NShiftEventAction { event in
            await recorder.record(event.name.rawValue)
        }
    }
    let handler = NShiftDependencyEventHandler(eventStore: NShiftDependencyEventStore(), resolver: registry)
    let root = NShiftPluginModel(
        id: "root",
        name: "Root", version: "1.0.0",
        events: [NShiftEventModel(id: "evt", name: "Track", version: "1.0.0", trigger: "onTap")]
    )
    let engine = makeEngine(root: root, eventHandler: handler)

    await engine.handle("onTap", onPluginID: "root")

    #expect(await recorder.values == ["Track"])
}

@MainActor
@Test func engineLooksUpNodeByRenderIDAndServerIDFallback() {
    let root = NShiftPluginModel(
        name: "Root", version: "1.0.0",
        children: [NShiftPluginModel(name: "Card", version: "1.0.0")]
    )
    let engine = makeEngine(root: root)
    let childID = NShiftRenderID(rawValue: "r/c/0")

    #expect(engine.node(withRenderID: childID)?.model.name.rawValue == "Card")
    #expect(engine.node(withID: "r/c/0")?.model.name.rawValue == "Card")
    #expect(engine.rootID == "r")
}

@MainActor
@Test func makeViewReturnsNilForEmptyPluginStore() {
    let engine = NShiftDefaultEngine(
        rootModel: NShiftPluginModel(id: "root", name: "Root", version: "1.0.0"),
        eventHandler: NoopEventHandler()
    )

    #expect(engine.makeView(for: engine.root) == nil)
}

@Test func engineResolverNotStartedFailsPreconditionContract() {
    let message = captureRuntimePrecondition {
        NShiftRuntimePrecondition.raise(
            "NShiftUI must be started before creating an engine."
        )
    }

    #expect(message == "NShiftUI must be started before creating an engine.")
}

@MainActor
@Test func engineResolverRequiresStartedConfig() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    #expect(config.hostContainer == nil)
    #expect(config.eventHandler == nil)
}
