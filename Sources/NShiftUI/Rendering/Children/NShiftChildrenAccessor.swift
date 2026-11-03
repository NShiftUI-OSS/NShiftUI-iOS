import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftChildrenAccessor {
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
    public func callAsFunction() -> some View {
        callAsFunction { _, view in
            view
        }
    }

    @ViewBuilder
    public func callAsFunction<Content: View>(
        @ViewBuilder transform: @escaping (
            NShiftPluginModel,
            NShiftNodeView
        ) -> Content
    ) -> some View {
        if let parent = engine.node(withRenderID: parentRenderID) {
            ForEach(parent.children, id: \.renderId) { child in
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
