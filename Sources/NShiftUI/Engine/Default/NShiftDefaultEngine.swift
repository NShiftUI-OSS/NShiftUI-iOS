import NShiftUIDI
import NShiftUIDomain
import SwiftUI

@MainActor
open class NShiftDefaultEngine: NShiftEngineTree {
    public let root: NShiftPluginNode

    private let pluginStore: any NShiftPluginStore
    private let eventHandler: any NShiftEventHandler

    private var nodesByServerID: [String: NShiftPluginNode] = [:]
    private var nodesByRenderID: [NShiftRenderID: NShiftPluginNode] = [:]
    private var eventsByID: [String: NShiftEventLocation] = [:]

    public var rootID: String {
        root.model.id ?? root.renderId.rawValue
    }

    public required init(
        rootModel: NShiftPluginModel,
        eventHandler: any NShiftEventHandler,
        pluginStore: any NShiftPluginStore = NShiftEmptyPluginStore()
    ) {
        self.pluginStore = pluginStore
        self.eventHandler = eventHandler
        self.root = NShiftPluginNode(model: rootModel)
        indexSubtree(root)
    }

    public func makeView(for node: NShiftPluginNode) -> AnyView? {
        pluginStore.resolve(node.model, renderID: node.renderId)
    }

    public func node(withID id: String) -> NShiftPluginNode? {
        nodesByServerID[id] ?? nodesByRenderID[NShiftRenderID(rawValue: id)]
    }

    public func node(withRenderID renderID: NShiftRenderID) -> NShiftPluginNode? {
        nodesByRenderID[renderID]
    }

    func eventLocation(withID id: String) -> NShiftEventLocation? {
        eventsByID[id]
    }

    public func handle(
        _ trigger: NShiftTrigger,
        onPluginID pluginID: String
    ) async {
        guard let node = node(withID: pluginID) else { return }
        await eventHandler.handle(trigger, events: node.model.events)
    }

    open func replaceMetadata(pluginID: String, with metadata: AnyNShiftMetadata?) {
        guard let node = node(withID: pluginID) else { return }
        node.model = node.model.replacingMetadata(metadata)
    }

    open func replacePlugin(pluginID: String, with model: NShiftPluginModel) {
        guard let node = node(withID: pluginID) else { return }

        deindexSubtree(node)

        node.model = model
        node.replaceChildren(with: model.children)
        node.replaceAllSlotChildren(with: model.slots)

        indexSubtree(node)
    }

    open func replaceChildren(pluginID: String, with children: [NShiftPluginModel]) {
        guard let node = node(withID: pluginID) else { return }

        node.children.forEach(deindexSubtree)
        node.model = node.model.replacingChildren(children)
        node.replaceChildren(with: children)
        node.children.forEach(indexSubtree)
    }

    open func replaceSlots(
        pluginID: String,
        with slots: [NShiftSlotName: [NShiftPluginModel]]
    ) {
        guard let node = node(withID: pluginID) else { return }

        node.slotChildren.values.flatMap { $0 }.forEach(deindexSubtree)
        node.model = node.model.replacingSlots(slots)
        node.replaceAllSlotChildren(with: slots)
        node.slotChildren.values.flatMap { $0 }.forEach(indexSubtree)
    }

    open func replaceSlot(
        pluginID: String,
        name: NShiftSlotName,
        with models: [NShiftPluginModel]
    ) {
        guard let node = node(withID: pluginID) else { return }

        node.slotChildren[name]?.forEach(deindexSubtree)
        node.model = node.model.replacingSlot(name, with: models)
        node.replaceSlotChildren(name, with: models)
        node.slotChildren[name]?.forEach(indexSubtree)
    }

    open func replaceEvents(pluginID: String, with events: [NShiftEventModel]) {
        guard let node = node(withID: pluginID) else { return }

        removeEvents(ownerRenderID: node.renderId)
        node.model = node.model.replacingEvents(events)
        indexEvents(of: node)
    }

    open func replaceEvent(eventID: String, with event: NShiftEventModel) {
        guard let location = eventsByID[eventID],
              let node = nodesByRenderID[NShiftRenderID(rawValue: location.ownerNodeID)] else {
            return
        }

        var forest = node.model.events.compactMap(\.event)
        guard replaceEvent(in: &forest, path: location.path, with: event) else { return }

        removeEvents(ownerRenderID: node.renderId)
        node.model = node.model.replacingEvents(forest)
        indexEvents(of: node)
    }

    private func indexSubtree(_ node: NShiftPluginNode) {
        nodesByRenderID[node.renderId] = node
        if let serverID = node.model.id {
            nodesByServerID[serverID] = node
        }
        indexEvents(of: node)
        node.children.forEach(indexSubtree)
        node.slotChildren.values
            .flatMap { $0 }
            .forEach(indexSubtree)
    }

    private func deindexSubtree(_ node: NShiftPluginNode) {
        nodesByRenderID[node.renderId] = nil
        if let serverID = node.model.id {
            nodesByServerID[serverID] = nil
        }
        removeEvents(ownerRenderID: node.renderId)
        node.children.forEach(deindexSubtree)
        node.slotChildren.values
            .flatMap { $0 }
            .forEach(deindexSubtree)
    }

    private func indexEvents(of node: NShiftPluginNode) {
        func walk(_ models: [NShiftEventModel], path: [Int]) {
            for (offset, model) in models.enumerated() {
                let childPath = path + [offset]
                eventsByID[model.id] = NShiftEventLocation(
                    ownerNodeID: node.renderId.rawValue,
                    path: childPath
                )
                walk(model.events, path: childPath)
            }
        }

        walk(node.model.events.compactMap(\.event), path: [])
    }

    private func removeEvents(ownerRenderID: NShiftRenderID) {
        let owner = ownerRenderID.rawValue
        eventsByID = eventsByID.filter { $0.value.ownerNodeID != owner }
    }

    private func replaceEvent(
        in forest: inout [NShiftEventModel],
        path: [Int],
        with event: NShiftEventModel
    ) -> Bool {
        guard let first = path.first, forest.indices.contains(first) else { return false }

        if path.count == 1 {
            forest[first] = event
            return true
        }

        var children = forest[first].events
        guard replaceEvent(in: &children, path: Array(path.dropFirst()), with: event) else {
            return false
        }

        let current = forest[first]
        forest[first] = NShiftEventModel(
            id: current.id,
            name: current.name,
            version: current.version,
            metadata: current.metadata,
            trigger: current.trigger,
            slots: current.slots,
            events: children
        )
        return true
    }
}
