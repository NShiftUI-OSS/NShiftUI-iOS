import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftNodeView: View {
    @ObservedObject private var node: NShiftPluginNode
    private let engine: any NShiftEngineTree
    private let viewModel: (any NShiftPluginViewModel)?

    public init(
        node: NShiftPluginNode,
        engine: any NShiftEngineTree,
        viewModel: (any NShiftPluginViewModel)? = nil
    ) {
        self.node = node
        self.engine = engine
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if let view = engine.makeView(for: node, viewModel: viewModel) {
                view
            } else {
                EmptyView()
            }
        }
    }
}
