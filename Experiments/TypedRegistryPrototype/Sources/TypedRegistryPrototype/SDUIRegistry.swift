import SwiftUI

@MainActor
public protocol SDUIRendering {
    func supports(_ node: SDUINode, context: SDUIContext) -> Bool
}

public struct SDUIPluginGroup<each Plugin: SDUIPlugin>: SDUIRendering {
    private let plugins: (repeat each Plugin)

    public init(_ plugins: repeat each Plugin) {
        self.plugins = (repeat each plugins)
    }

    public func supports(_ node: SDUINode, context: SDUIContext) -> Bool {
        for plugin in repeat each plugins {
            if isMatch(plugin, node: node, context: context) {
                return true
            }
        }
        return false
    }

    @ViewBuilder
    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        TupleView((repeat renderIfMatch(each plugins, node: node, context: context, children: children)))
    }

    private func isMatch<P: SDUIPlugin>(_ plugin: P, node: SDUINode, context: SDUIContext) -> Bool {
        P.componentType == node.type && plugin.canRender(node: node, context: context)
    }

    @ViewBuilder
    private func renderIfMatch<P: SDUIPlugin, Children: View>(
        _ plugin: P,
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        if isMatch(plugin, node: node, context: context) {
            renderPlugin(plugin, node: node, context: context, children: children)
        }
    }

    @ViewBuilder
    private func renderPlugin<P: SDUIPlugin, Children: View>(
        _ plugin: P,
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        if let plugin = plugin as? VStackPlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? HStackPlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? ScrollPlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? BannerPlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? TitlePlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? CartBadgePlugin {
            plugin.render(node: node, context: context, children: children)
        } else if let plugin = plugin as? SDUIConditionalPlugin<CartBadgePlugin> {
            plugin.base.render(node: node, context: context, children: children)
        }
    }
}

public struct SDUIRegistry<each Plugin: SDUIPlugin>: SDUIRendering {
    private let group: SDUIPluginGroup<repeat each Plugin>

    public init(_ plugins: repeat each Plugin) {
        self.group = SDUIPluginGroup(repeat each plugins)
    }

    public init(group: SDUIPluginGroup<repeat each Plugin>) {
        self.group = group
    }

    public func supports(_ node: SDUINode, context: SDUIContext) -> Bool {
        group.supports(node, context: context)
    }

    @ViewBuilder
    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        group.render(node: node, context: context, children: children)
    }
}
