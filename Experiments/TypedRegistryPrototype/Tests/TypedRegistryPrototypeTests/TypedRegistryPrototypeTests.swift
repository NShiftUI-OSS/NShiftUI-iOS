import SwiftUI
import Testing
@testable import TypedRegistryPrototype

private struct SpyAnalytics: AnalyticsService {
    func track(_ event: String) {}
}

private struct FixedCart: CartService {
    let itemCount: Int
}

@MainActor
private func makeRegistry(
    checkoutEnabled: Bool
) -> SDUIRegistry<
    VStackPlugin,
    HStackPlugin,
    ScrollPlugin,
    BannerPlugin,
    TitlePlugin,
    SDUIConditionalPlugin<CartBadgePlugin>
> {
    let layout = LayoutSDUIComponents.makePlugins()
    let home = HomeSDUIComponents.makePlugins(
        dependencies: HomeDependencies(analytics: SpyAnalytics())
    )
    let checkout = CheckoutSDUIComponents.makePlugins(
        dependencies: CheckoutDependencies(
            cartService: FixedCart(itemCount: 3),
            checkoutEnabled: { checkoutEnabled }
        )
    )
    return SDUIRegistry(
        layout.0,
        layout.1,
        layout.2,
        home.0,
        home.1,
        checkout
    )
}

@MainActor
@Test func registrySupportsKnownTypesAndRejectsUnknown() {
    let registry = makeRegistry(checkoutEnabled: true)
    let context = SDUIContext()

    #expect(registry.supports(SDUINode(id: "0", type: "vstack"), context: context))
    #expect(registry.supports(SDUINode(id: "1", type: "banner"), context: context))
    #expect(registry.supports(SDUINode(id: "2", type: "title"), context: context))
    #expect(registry.supports(SDUINode(id: "3", type: "cartBadge"), context: context))
    #expect(registry.supports(SDUINode(id: "4", type: "mystery"), context: context) == false)
}

@MainActor
@Test func featureFlagGatesAvailabilityWithoutChangingRegistryType() {
    let enabled = makeRegistry(checkoutEnabled: true)
    let disabled = makeRegistry(checkoutEnabled: false)
    let node = SDUINode(id: "1", type: "cartBadge")
    let context = SDUIContext()

    #expect(type(of: enabled) == type(of: disabled))
    #expect(enabled.supports(node, context: context))
    #expect(disabled.supports(node, context: context) == false)
}

@MainActor
@Test func screenViewComposesWithoutAnyView() {
    let registry = makeRegistry(checkoutEnabled: true)
    let screen = [
        SDUINode(
            id: "root",
            type: "vstack",
            properties: ["spacing": "8"],
            children: [
                SDUINode(id: "t", type: "title", properties: ["text": "Hello"]),
                SDUINode(id: "b", type: "banner", properties: ["title": "Offer"]),
                SDUINode(id: "c", type: "cartBadge"),
                SDUINode(id: "u", type: "unknownFromNewerBackend"),
            ]
        ),
    ]

    let view = SDUIScreenView(registry: registry, screen: screen)
    let typeName = String(describing: type(of: view))

    #expect(typeName.contains("SDUIScreenView"))
    #expect(typeName.contains("AnyView") == false)
    #expect(registry.supports(screen[0], context: SDUIContext()))
}
