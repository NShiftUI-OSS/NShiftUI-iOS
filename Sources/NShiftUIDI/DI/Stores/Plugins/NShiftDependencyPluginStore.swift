import NShiftUIDomain
import SwiftUI

@MainActor
public final class NShiftDependencyPluginStore: NShiftPluginStore {
    nonisolated private let resolver: any NShiftDependencyResolver

    nonisolated public init(resolver: any NShiftDependencyResolver) {
        self.resolver = resolver
    }

    public func resolve(
        _ plugin: NShiftPluginModel,
        renderID: NShiftRenderID
    ) -> AnyView? {
        let registered = resolver.resolve(
            NShiftRegisteredPluginView.self,
            name: plugin.registrationName,
            plugin,
            renderID
        )

        return registered?.makeView(plugin, renderID)
    }
}
