import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftSlotsAccessor<Key: NShiftSlotKey> {
    private let parentRenderID: NShiftRenderID
    private let engine: any NShiftEngineTree
    private let viewModel: (any NShiftPluginViewModel)?

    public init(
        parentRenderID: NShiftRenderID,
        engine: any NShiftEngineTree,
        viewModel: (any NShiftPluginViewModel)?
    ) {
        self.parentRenderID = parentRenderID
        self.engine = engine
        self.viewModel = viewModel
    }

    @ViewBuilder
    public func callAsFunction(_ key: Key) -> some View {
        callAsFunction(key) { _, view in
            view
        }
    }

    @ViewBuilder
    public func callAsFunction<Content: View>(
        _ key: Key,
        @ViewBuilder transform: @escaping (
            NShiftPluginModel,
            NShiftNodeView
        ) -> Content
    ) -> some View {
        if let parent = engine.node(withRenderID: parentRenderID) {
            let nodes = parent.slotChildren[key.slotName] ?? []
            ForEach(nodes, id: \.renderId) { child in
                transform(
                    child.model,
                    NShiftNodeView(
                        node: child,
                        engine: engine,
                        viewModel: viewModel
                    )
                )
            }
        }
    }
}
