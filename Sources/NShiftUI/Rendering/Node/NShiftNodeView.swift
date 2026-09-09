import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftNodeView: View {
    @ObservedObject private var node: NShiftPluginNode
    private let engine: any NShiftEngineTree

    public init(
        node: NShiftPluginNode,
        engine: any NShiftEngineTree
    ) {
        self.node = node
        self.engine = engine
    }

    public var body: some View {
        Group {
            if let view = engine.makeView(for: node) {
                view
            } else {
                EmptyView()
            }
        }
    }
}
