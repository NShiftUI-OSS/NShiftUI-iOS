@MainActor
package final class NShiftPluginContainerCatalog {
    package static let shared = NShiftPluginContainerCatalog()

    private var names: Set<NShiftPluginName> = []

    private init() {}

    package func register(_ name: NShiftPluginName) {
        names.insert(name)
    }

    package func contains(_ name: NShiftPluginName) -> Bool {
        names.contains(name)
    }

    package func resetForTesting() {
        names.removeAll()
    }
}
