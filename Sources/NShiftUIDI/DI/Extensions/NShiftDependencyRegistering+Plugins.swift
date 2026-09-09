import NShiftUIDomain
import SwiftUI

@MainActor
public extension NShiftDependencyRegistering {
    func registerPlugin<Plugin>(
        _ pluginType: Plugin.Type,
        container: any NShiftDependencyContainer,
        factory: @escaping @MainActor (
            NShiftPluginModel,
            any NShiftDependencyContainer,
            NShiftRenderID
        ) -> Plugin?
    ) where Plugin: NShiftPlugin {
        let registrationName = NShiftVersion.registrationName(
            plugin: pluginType.name,
            version: pluginType.version
        )

        if pluginType is any NShiftPluginContainer.Type {
            NShiftPluginContainerCatalog.shared.register(pluginType.name)
        }
        NShiftRegisteredVersionCatalog.shared.registerPlugin(pluginType.name, version: pluginType.version)

        register(
            NShiftRegisteredPluginView.self,
            name: registrationName,
            argumentTypes: [NShiftPluginModel.self, NShiftRenderID.self]
        ) { arguments in
            guard arguments.count == 2,
                  let model = arguments[0] as? NShiftPluginModel,
                  let renderID = arguments[1] as? NShiftRenderID else {
                return nil
            }
            return MainActor.assumeIsolated {
                guard let plugin = factory(model, container, renderID) else {
                    return nil
                }
                return NShiftRegisteredPluginView { _, _ in
                    AnyView(plugin.id(renderID))
                }
            }
        }
    }
}
