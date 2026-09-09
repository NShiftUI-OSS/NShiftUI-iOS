import SwiftUI

@MainActor
public struct SDUINodeView<each Plugin: SDUIPlugin>: View {
    private let registry: SDUIRegistry<repeat each Plugin>
    private let node: SDUINode
    private let context: SDUIContext

    public init(
        registry: SDUIRegistry<repeat each Plugin>,
        node: SDUINode,
        context: SDUIContext
    ) {
        self.registry = registry
        self.node = node
        self.context = context
    }

    public var body: some View {
        Group {
            if registry.supports(node, context: context) {
                registry.render(
                    node: node,
                    context: context,
                    children: SDUIChildrenView(
                        registry: registry,
                        nodes: node.children,
                        context: context
                    )
                )
            } else {
                context.fallback.view(for: node)
            }
        }
    }
}

@MainActor
public struct SDUIChildrenView<each Plugin: SDUIPlugin>: View {
    private let registry: SDUIRegistry<repeat each Plugin>
    private let nodes: [SDUINode]
    private let context: SDUIContext

    public init(
        registry: SDUIRegistry<repeat each Plugin>,
        nodes: [SDUINode],
        context: SDUIContext
    ) {
        self.registry = registry
        self.nodes = nodes
        self.context = context
    }

    public var body: some View {
        ForEach(nodes) { child in
            SDUINodeView(registry: registry, node: child, context: context)
        }
    }
}

@MainActor
public struct SDUIScreenView<each Plugin: SDUIPlugin>: View {
    private let registry: SDUIRegistry<repeat each Plugin>
    private let screen: [SDUINode]
    private let context: SDUIContext

    public init(
        registry: SDUIRegistry<repeat each Plugin>,
        screen: [SDUINode],
        context: SDUIContext = SDUIContext()
    ) {
        self.registry = registry
        self.screen = screen
        self.context = context
    }

    public var body: some View {
        SDUIChildrenView(registry: registry, nodes: screen, context: context)
    }
}
