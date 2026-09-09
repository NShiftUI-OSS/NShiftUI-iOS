import SwiftUI

@MainActor
public protocol SDUIPlugin {
    static var componentType: String { get }

    func canRender(node: SDUINode, context: SDUIContext) -> Bool
}

public extension SDUIPlugin {
    func canRender(node: SDUINode, context: SDUIContext) -> Bool {
        true
    }
}

public struct SDUIConditionalPlugin<Base: SDUIPlugin>: SDUIPlugin {
    public static var componentType: String { Base.componentType }

    let base: Base
    private let isEnabled: @MainActor () -> Bool

    public init(_ base: Base, isEnabled: @escaping @MainActor () -> Bool) {
        self.base = base
        self.isEnabled = isEnabled
    }

    public func canRender(node: SDUINode, context: SDUIContext) -> Bool {
        isEnabled() && base.canRender(node: node, context: context)
    }
}
