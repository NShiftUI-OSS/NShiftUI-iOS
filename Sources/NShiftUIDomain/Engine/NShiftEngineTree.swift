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
}

public extension NShiftEngineTree {
    func makeView(for node: NShiftPluginNode) -> AnyView? {
        makeView(for: node, viewModel: nil)
    }
}
