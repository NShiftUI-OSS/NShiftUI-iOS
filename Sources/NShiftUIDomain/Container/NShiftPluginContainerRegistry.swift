@MainActor
package final class NShiftPluginContainerRegistry {
    package static let shared = NShiftPluginContainerRegistry()

    private var engines: [String: any NShiftEngine] = [:]

    private init() {}

    package func register(rootID: String, engine: any NShiftEngine) {
        engines[rootID] = engine
    }

    package func unregister(rootID: String) {
        engines.removeValue(forKey: rootID)
    }

    package func engine(for rootID: String) -> (any NShiftEngine)? {
        engines[rootID]
    }

    package func resetForTesting() {
        engines.removeAll()
    }
}
