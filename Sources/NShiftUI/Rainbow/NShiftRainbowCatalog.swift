import Foundation

public protocol NShiftJSONTaggedMetadata: NShiftMetadata {
    static var jsonTaggedParameters: Set<String> { get }
}

public final class NShiftRainbowCatalog: @unchecked Sendable {
    public static let shared = NShiftRainbowCatalog()

    private let lock = NSLock()
    private var decoders: [String: any NShiftRainbowMetadataDecoding] = [:]
    private var slotMarkers: Set<String> = []

    private init() {}

    public func register(_ decoder: some NShiftRainbowMetadataDecoding) {
        lock.lock()
        decoders[decoder.pluginName] = decoder
        lock.unlock()
    }

    public func addSlotMarkers(_ names: Set<String>) {
        lock.lock()
        slotMarkers.formUnion(names)
        lock.unlock()
    }

    public func adopt(_ type: Any.Type) {
        guard let registrant = type as? any NShiftRainbowRegistrant.Type else {
            return
        }
        registrant.registerNShiftRainbow()
    }

    public func registerIfDecodable<Metadata: NShiftMetadata>(
        _ type: Metadata.Type,
        name: String
    ) {
        _ = type
        _ = name
    }

    public func registerIfDecodable<Metadata: NShiftMetadata & Decodable>(
        _ type: Metadata.Type,
        name: String
    ) {
        register(NShiftRainbowDecodableMetadataDecoder<Metadata>(pluginName: name))
    }

    func decoder(named name: String) -> (any NShiftRainbowMetadataDecoding)? {
        lock.lock()
        defer { lock.unlock() }
        return decoders[name]
    }

    func containsSlot(_ name: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return slotMarkers.contains(name)
    }

    package func resetForTesting() {
        lock.lock()
        decoders.removeAll()
        slotMarkers.removeAll()
        lock.unlock()
    }
}
