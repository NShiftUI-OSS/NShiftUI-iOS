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
        renderID: NShiftRenderID,
        viewModel: (any NShiftPluginViewModel)?
    ) -> AnyView? {
        let registered = resolver.resolve(
            NShiftRegisteredPluginView.self,
            name: plugin.registrationName,
            plugin,
            renderID,
            NShiftPluginViewModelArgument(viewModel)
        )

        return registered?.makeView(plugin, renderID)
    }
}

struct NShiftPluginViewModelArgument: @unchecked Sendable {
    let viewModel: (any NShiftPluginViewModel)?

    init(_ viewModel: (any NShiftPluginViewModel)?) {
        self.viewModel = viewModel
    }
}
