public enum NShiftVersionResolutionError: Error, Equatable, Sendable {
    case pluginNotRegistered(NShiftPluginName)
    case eventNotRegistered(NShiftEventName)
    case pluginVersionNotRegistered(NShiftPluginName, NShiftVersion)
    case eventVersionNotRegistered(NShiftEventName, NShiftVersion)
}

public enum NShiftVersionResolver {
    public static func resolvePlugin(
        named name: NShiftPluginName,
        pinned: NShiftVersion? = nil
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try resolvePlugin(named: name, pinned: pinned, catalog: .shared)
    }

    public static func resolveEvent(
        named name: NShiftEventName,
        pinned: NShiftVersion? = nil
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try resolveEvent(named: name, pinned: pinned, catalog: .shared)
    }

    package static func resolvePlugin(
        named name: NShiftPluginName,
        pinned: NShiftVersion? = nil,
        catalog: NShiftRegisteredVersionCatalog
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        if let pinned {
            guard catalog.versions(forPlugin: name).contains(pinned) else {
                throw .pluginVersionNotRegistered(name, pinned)
            }
            return pinned
        }

        guard let latest = catalog.latestPlugin(named: name) else {
            throw .pluginNotRegistered(name)
        }

        return latest
    }

    package static func resolveEvent(
        named name: NShiftEventName,
        pinned: NShiftVersion? = nil,
        catalog: NShiftRegisteredVersionCatalog
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        if let pinned {
            guard catalog.versions(forEvent: name).contains(pinned) else {
                throw .eventVersionNotRegistered(name, pinned)
            }
            return pinned
        }

        guard let latest = catalog.latestEvent(named: name) else {
            throw .eventNotRegistered(name)
        }

        return latest
    }
}
