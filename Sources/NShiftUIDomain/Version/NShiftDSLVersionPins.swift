
public struct NShiftDSLVersionPins: Equatable, Sendable {
    private let pins: [String: NShiftVersion]

    public init(_ pins: [String: NShiftVersion] = [:]) {
        self.pins = pins
    }

    public init(uses: [(name: String, version: String)]) throws(NShiftVersionError) {
        var parsed: [String: NShiftVersion] = [:]
        for use in uses {
            parsed[use.name] = try NShiftVersion(validating: use.version)
        }
        self.pins = parsed
    }

    public func pinnedVersion(forPlugin name: NShiftPluginName) -> NShiftVersion? {
        pins[name.rawValue]
    }

    public func pinnedVersion(forEvent name: NShiftEventName) -> NShiftVersion? {
        pins[name.rawValue]
    }

    public func resolvePlugin(
        named name: NShiftPluginName
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try resolvePlugin(named: name, catalog: .shared)
    }

    public func resolveEvent(
        named name: NShiftEventName
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try resolveEvent(named: name, catalog: .shared)
    }

    package func resolvePlugin(
        named name: NShiftPluginName,
        catalog: NShiftRegisteredVersionCatalog
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try NShiftVersionResolver.resolvePlugin(
            named: name,
            pinned: pinnedVersion(forPlugin: name),
            catalog: catalog
        )
    }

    package func resolveEvent(
        named name: NShiftEventName,
        catalog: NShiftRegisteredVersionCatalog
    ) throws(NShiftVersionResolutionError) -> NShiftVersion {
        try NShiftVersionResolver.resolveEvent(
            named: name,
            pinned: pinnedVersion(forEvent: name),
            catalog: catalog
        )
    }
}
