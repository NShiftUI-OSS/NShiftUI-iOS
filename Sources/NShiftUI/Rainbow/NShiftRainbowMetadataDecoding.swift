import Foundation
import RainbowParser

public struct NShiftRainbowMetadataDecodingContext: Sendable {
    public let compilePlugins: @Sendable (String) throws -> [NShiftPluginModel]

    public init(
        compilePlugins: @escaping @Sendable (String) throws -> [NShiftPluginModel]
    ) {
        self.compilePlugins = compilePlugins
    }
}

public struct NShiftRainbowMetadataDecodeResult: Sendable {
    public let metadata: AnyNShiftMetadata?
    public let slots: [NShiftSlotName: [NShiftPluginModel]]

    public init(
        metadata: AnyNShiftMetadata?,
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:]
    ) {
        self.metadata = metadata
        self.slots = slots
    }
}

public protocol NShiftRainbowPluginMetadata: NShiftMetadata {
    func decodeRainbowMetadata(
        with context: NShiftRainbowMetadataDecodingContext
    ) throws -> NShiftRainbowMetadataDecodeResult
}

public protocol NShiftRainbowMetadataDecoding: Sendable {
    var pluginName: String { get }

    func decode(
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata?

    func decode(
        parameters: [RainbowParameter],
        context: NShiftRainbowMetadataDecodingContext
    ) throws -> NShiftRainbowMetadataDecodeResult
}

public extension NShiftRainbowMetadataDecoding {
    func decode(
        parameters: [RainbowParameter],
        context: NShiftRainbowMetadataDecodingContext
    ) throws -> NShiftRainbowMetadataDecodeResult {
        NShiftRainbowMetadataDecodeResult(
            metadata: try decode(parameters: parameters)
        )
    }
}

public struct NShiftRainbowDecodableMetadataDecoder<
    Metadata: NShiftMetadata & Decodable
>: NShiftRainbowMetadataDecoding {
    public let pluginName: String
    public let jsonTaggedParameters: Set<String>

    public init(
        pluginName: String,
        jsonTaggedParameters: Set<String> = []
    ) {
        self.pluginName = pluginName
        self.jsonTaggedParameters = jsonTaggedParameters
    }

    public func decode(
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata? {
        try decode(
            parameters: parameters,
            context: NShiftRainbowMetadataDecodingContext { _ in [] }
        ).metadata
    }

    public func decode(
        parameters: [RainbowParameter],
        context: NShiftRainbowMetadataDecodingContext
    ) throws -> NShiftRainbowMetadataDecodeResult {
        do {
            let declaredTags = (Metadata.self as? any NShiftJSONTaggedMetadata.Type)?
                .jsonTaggedParameters ?? []
            let metadata = try NShiftRainbowJSON.decode(
                Metadata.self,
                from: parameters,
                jsonTaggedParameters: jsonTaggedParameters.union(declaredTags)
            )
            if let pluginMetadata = metadata as? any NShiftRainbowPluginMetadata {
                return try pluginMetadata.decodeRainbowMetadata(with: context)
            }
            return NShiftRainbowMetadataDecodeResult(
                metadata: AnyNShiftMetadata(metadata)
            )
        } catch let error as NShiftRainbowCompileError {
            if parameters.isEmpty {
                return NShiftRainbowMetadataDecodeResult(metadata: nil)
            }
            throw error
        } catch {
            if parameters.isEmpty {
                return NShiftRainbowMetadataDecodeResult(metadata: nil)
            }
            throw NShiftRainbowCompileError.metadataDecodingFailed(
                plugin: pluginName,
                message: String(describing: error)
            )
        }
    }
}
