import SwiftUI

@MainActor
public protocol NShiftPluginStore: Sendable {
    func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID,
        viewModel: (any NShiftPluginViewModel)?
    ) -> AnyView?
}

public extension NShiftPluginStore {
    func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID
    ) -> AnyView? {
        resolve(plugin, renderID: renderID, viewModel: nil)
    }

    func resolve(_ plugin: NShiftPluginModel) -> AnyView? {
        resolve(plugin, renderID: .root, viewModel: nil)
    }
}

public struct NShiftEmptyPluginStore: NShiftPluginStore {
    public init() {}

    public func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID,
        viewModel: (any NShiftPluginViewModel)?
    ) -> AnyView? {
        _ = plugin
        _ = renderID
        _ = viewModel
        return nil
    }
}
