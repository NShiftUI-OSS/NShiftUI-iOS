import Foundation
import RainbowParser

public struct NShiftRainbowMetadataDecodingContext: Sendable {
    public let compilePlugins: @Sendable (String) throws -> [NShiftPluginModel]
    /// The plugin's children as a standalone Rainbow document (with the
    /// screen's `use` declarations). Template plugins such as a `ForEach` keep
    /// it and compile it later, once per data item.
    public let childrenSource: @Sendable () -> String

    public init(
        compilePlugins: @escaping @Sendable (String) throws -> [NShiftPluginModel],
        childrenSource: @escaping @Sendable () -> String = { "" }
    ) {
        self.compilePlugins = compilePlugins
        self.childrenSource = childrenSource
    }
}

public struct NShiftRainbowMetadataDecodeResult: Sendable {
    public let metadata: AnyNShiftMetadata?
    public let slots: [NShiftSlotName: [NShiftPluginModel]]
    /// When true the compiler does not compile the plugin's children: the
    /// plugin consumed them as a template through `childrenSource`.
    public let consumesChildren: Bool

    public init(
        metadata: AnyNShiftMetadata?,
        slots: [NShiftSlotName: [NShiftPluginModel]] = [:],
        consumesChildren: Bool = false
    ) {
        self.metadata = metadata
        self.slots = slots
        self.consumesChildren = consumesChildren
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
