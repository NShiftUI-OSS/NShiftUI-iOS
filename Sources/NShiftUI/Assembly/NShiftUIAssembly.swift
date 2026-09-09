import NShiftUIDI
import NShiftUIDomain

struct NShiftUIAssembly: NShiftDependencyAssembly {
    func assemblePlugins(in container: any NShiftDependencyContainer) {
        container.register(NShiftPluginStore.self) {
            NShiftDependencyPluginStore(resolver: container)
        }
    }

    func assembleEvents(in container: any NShiftDependencyContainer) {
        let eventStore = NShiftDependencyEventStore()
        container.register(NShiftEventStore.self) {
            eventStore
        }

        let eventHandler = NShiftDependencyEventHandler(
            eventStore: eventStore,
            resolver: container
        )
        container.register(NShiftEventHandler.self) {
            eventHandler
        }
    }
}
