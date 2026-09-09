import NShiftUIDI
import NShiftUIDomain

@MainActor
enum NShiftEngineResolver {
    static func makeEngine(
        rootModel: NShiftPluginModel,
        config: NShiftConfig = .shared
    ) -> any NShiftEngine {
        guard let hostContainer = config.hostContainer,
              let eventHandler = config.eventHandler else {
            NShiftRuntimePrecondition.raise(
                "NShiftUI must be started before creating an engine."
            )
        }

        let engine = resolveEngine(
            rootModel: rootModel,
            hostContainer: hostContainer,
            eventHandler: eventHandler
        )

        hostContainer.register(NShiftEngine.self, scope: .singleton) {
            engine
        }

        return engine
    }

    static func resolveEngine(
        rootModel: NShiftPluginModel,
        hostContainer: any NShiftDependencyContainer,
        eventHandler: any NShiftEventHandler
    ) -> any NShiftEngine {
        if let customEngine = hostContainer.resolve(NShiftEngine.self, rootModel),
           customEngine.rootID == (rootModel.id ?? NShiftRenderID.root.rawValue) {
            return customEngine
        }

        let pluginStore = hostContainer.resolve(NShiftPluginStore.self) ?? NShiftEmptyPluginStore()
        return NShiftDefaultEngine(
            rootModel: rootModel,
            eventHandler: eventHandler,
            pluginStore: pluginStore
        )
    }
}
