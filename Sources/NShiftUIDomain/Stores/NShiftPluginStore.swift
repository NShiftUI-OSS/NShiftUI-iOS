import SwiftUI

@MainActor
public protocol NShiftPluginStore: Sendable {
    func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID
    ) -> AnyView?
}

public extension NShiftPluginStore {
    func resolve(_ plugin: NShiftPluginModel) -> AnyView? {
        resolve(plugin, renderID: .root)
    }
}

public struct NShiftEmptyPluginStore: NShiftPluginStore {
    public init() {}

    public func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID
    ) -> AnyView? {
        _ = plugin
        _ = renderID
        return nil
    }
}
