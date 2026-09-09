import SwiftUI

public protocol AnalyticsService: Sendable {
    func track(_ event: String)
}

public protocol CartService: Sendable {
    var itemCount: Int { get }
}

public struct VStackPlugin: SDUIPlugin {
    public static let componentType = "vstack"

    public init() {}

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        VStack(spacing: spacing(from: node)) {
            children
        }
    }
}

public struct HStackPlugin: SDUIPlugin {
    public static let componentType = "hstack"

    public init() {}

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        HStack(spacing: spacing(from: node)) {
            children
        }
    }
}

public struct ScrollPlugin: SDUIPlugin {
    public static let componentType = "scroll"

    public init() {}

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        ScrollView {
            children
        }
    }
}

public enum LayoutSDUIComponents {
    @MainActor
    public static func makePlugins() -> (
        VStackPlugin,
        HStackPlugin,
        ScrollPlugin
    ) {
        (VStackPlugin(), HStackPlugin(), ScrollPlugin())
    }
}

private func spacing(from node: SDUINode) -> CGFloat? {
    node.properties["spacing"].flatMap(Double.init).map { CGFloat($0) }
}

public struct HomeDependencies: Sendable {
    public let analytics: any AnalyticsService

    public init(analytics: any AnalyticsService) {
        self.analytics = analytics
    }
}

public struct BannerPlugin: SDUIPlugin {
    public static let componentType = "banner"

    private let analytics: any AnalyticsService

    public init(analytics: any AnalyticsService) {
        self.analytics = analytics
    }

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        Button {
            analytics.track("banner_tapped")
        } label: {
            Text(node.properties["title"] ?? "")
        }
    }
}

public struct TitlePlugin: SDUIPlugin {
    public static let componentType = "title"

    public init() {}

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        Text(node.properties["text"] ?? "")
            .font(.title)
    }
}

public enum HomeSDUIComponents {
    @MainActor
    public static func makePlugins(
        dependencies: HomeDependencies
    ) -> (BannerPlugin, TitlePlugin) {
        (
            BannerPlugin(analytics: dependencies.analytics),
            TitlePlugin()
        )
    }
}

public struct CheckoutDependencies: Sendable {
    public let cartService: any CartService
    public let checkoutEnabled: @MainActor () -> Bool

    public init(
        cartService: any CartService,
        checkoutEnabled: @escaping @MainActor () -> Bool
    ) {
        self.cartService = cartService
        self.checkoutEnabled = checkoutEnabled
    }
}

public struct CartBadgePlugin: SDUIPlugin {
    public static let componentType = "cartBadge"

    private let cartService: any CartService

    public init(cartService: any CartService) {
        self.cartService = cartService
    }

    public func render<Children: View>(
        node: SDUINode,
        context: SDUIContext,
        children: Children
    ) -> some View {
        Label("\(cartService.itemCount)", systemImage: "cart")
    }
}

public enum CheckoutSDUIComponents {
    @MainActor
    public static func makePlugins(
        dependencies: CheckoutDependencies
    ) -> SDUIConditionalPlugin<CartBadgePlugin> {
        SDUIConditionalPlugin(
            CartBadgePlugin(cartService: dependencies.cartService),
            isEnabled: dependencies.checkoutEnabled
        )
    }
}
