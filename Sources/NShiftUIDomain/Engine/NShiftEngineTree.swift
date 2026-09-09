import SwiftUI

@MainActor
public protocol NShiftEngineTree: NShiftEngine {
    var root: NShiftPluginNode { get }

    func node(withID id: String) -> NShiftPluginNode?
    func node(withRenderID renderID: NShiftRenderID) -> NShiftPluginNode?
    func makeView(for node: NShiftPluginNode) -> AnyView?
}
