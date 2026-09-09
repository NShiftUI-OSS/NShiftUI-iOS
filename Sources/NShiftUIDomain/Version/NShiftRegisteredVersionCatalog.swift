import Foundation

package final class NShiftRegisteredVersionCatalog: @unchecked Sendable {
    package static let shared = NShiftRegisteredVersionCatalog()

    private let lock = NSLock()
    private var pluginVersions: [String: Set<NShiftVersion>] = [:]
    private var eventVersions: [String: Set<NShiftVersion>] = [:]

    private init() {}

    package init(forTesting: Void = ()) {}

    package func registerPlugin(_ name: NShiftPluginName, version: NShiftVersion) {
        lock.lock()

        if eventVersions[name.rawValue] != nil {
            lock.unlock()
            NShiftRegisteredVersionCatalogFailure.raise(
                "Plugin name \"\(name.rawValue)\" conflicts with a registered event of the same name"
            )
        }

        pluginVersions[name.rawValue, default: []].insert(version)
        lock.unlock()
    }

    package func registerEvent(_ name: NShiftEventName, version: NShiftVersion) {
        lock.lock()

        if pluginVersions[name.rawValue] != nil {
            lock.unlock()
            NShiftRegisteredVersionCatalogFailure.raise(
                "Event name \"\(name.rawValue)\" conflicts with a registered plugin of the same name"
            )
        }

        eventVersions[name.rawValue, default: []].insert(version)
        lock.unlock()
    }

    package func latestPlugin(named name: NShiftPluginName) -> NShiftVersion? {
        lock.lock()
        defer { lock.unlock() }
        return pluginVersions[name.rawValue]?.max()
    }

    package func latestEvent(named name: NShiftEventName) -> NShiftVersion? {
        lock.lock()
        defer { lock.unlock() }
        return eventVersions[name.rawValue]?.max()
    }

    package func versions(forPlugin name: NShiftPluginName) -> Set<NShiftVersion> {
        lock.lock()
        defer { lock.unlock() }
        return pluginVersions[name.rawValue] ?? []
    }

    package func versions(forEvent name: NShiftEventName) -> Set<NShiftVersion> {
        lock.lock()
        defer { lock.unlock() }
        return eventVersions[name.rawValue] ?? []
    }

    package func resetForTesting() {
        lock.lock()
        defer { lock.unlock() }
        pluginVersions.removeAll()
        eventVersions.removeAll()
    }
}

enum NShiftRegisteredVersionCatalogFailure {
    nonisolated(unsafe) private static var handler: (String) -> Never = { message in
        Swift.fatalError(message)
    }

    static func replace(with replacement: @escaping (String) -> Never) {
        handler = replacement
    }

    static func restore() {
        handler = { message in
            Swift.fatalError(message)
        }
    }

    static func raise(_ message: String) -> Never {
        handler(message)
    }
}
