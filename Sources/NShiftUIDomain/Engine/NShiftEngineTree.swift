import SwiftUI

@MainActor
public protocol NShiftEngineTree: NShiftEngine {
    var root: NShiftPluginNode { get }

    func node(withID id: String) -> NShiftPluginNode?
    func node(withRenderID renderID: NShiftRenderID) -> NShiftPluginNode?
    func makeView(
        for node: NShiftPluginNode,
        viewModel: (any NShiftPluginViewModel)?
    ) -> AnyView?

    /// Inserts `children` at `index` keeping the existing sibling nodes before
    /// the insertion point, so their rendered views are preserved.
    func insertChildren(pluginID: String, at index: Int, with children: [NShiftPluginModel])

    /// Appends `models` to the slot `name` keeping the existing slot nodes.
    func appendSlot(pluginID: String, name: NShiftSlotName, with models: [NShiftPluginModel])
}

public extension NShiftEngineTree {
    func makeView(for node: NShiftPluginNode) -> AnyView? {
        makeView(for: node, viewModel: nil)
    }

    func insertChildren(pluginID: String, at index: Int, with children: [NShiftPluginModel]) {
        guard let node = node(withID: pluginID) else { return }
        var next = node.model.children
        next.insert(contentsOf: children, at: min(max(index, 0), next.count))
        replaceChildren(pluginID: pluginID, with: next)
    }

    func appendSlot(pluginID: String, name: NShiftSlotName, with models: [NShiftPluginModel]) {
        guard let node = node(withID: pluginID) else { return }
        replaceSlot(pluginID: pluginID, name: name, with: (node.model.slots[name] ?? []) + models)
    }
}
