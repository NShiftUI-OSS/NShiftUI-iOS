import Foundation

public struct NShiftRainbowCompileConfiguration: Sendable {
    public var slotMarkers: Set<String>
    public var defaultVersion: NShiftVersion?
    public var metadataDecoders: [String: any NShiftRainbowMetadataDecoding]
    package var catalog: NShiftRegisteredVersionCatalog

    public static var `default`: NShiftRainbowCompileConfiguration {
        NShiftRainbowCompileConfiguration()
    }

    public init(
        slotMarkers: Set<String> = [
            "NavLeading",
            "NavCenter",
            "NavTrailing",
        ],
        defaultVersion: NShiftVersion? = nil,
        metadataDecoders: [String: any NShiftRainbowMetadataDecoding] = [:]
    ) {
        self.slotMarkers = slotMarkers
        self.defaultVersion = defaultVersion
        self.metadataDecoders = metadataDecoders
        self.catalog = .shared
    }

    public mutating func registerMetadataDecoder(
        _ decoder: some NShiftRainbowMetadataDecoding
    ) {
        metadataDecoders[decoder.pluginName] = decoder
    }

    public func registeringMetadataDecoder(
        _ decoder: some NShiftRainbowMetadataDecoding
    ) -> NShiftRainbowCompileConfiguration {
        var copy = self
        copy.registerMetadataDecoder(decoder)
        return copy
    }
}
