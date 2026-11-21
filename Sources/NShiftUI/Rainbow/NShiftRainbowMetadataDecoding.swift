import Foundation
import RainbowParser

public protocol NShiftRainbowMetadataDecoding: Sendable {
    var pluginName: String { get }

    func decode(
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata?
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
        do {
            let declaredTags = (Metadata.self as? any NShiftJSONTaggedMetadata.Type)?
                .jsonTaggedParameters ?? []
            let metadata = try NShiftRainbowJSON.decode(
                Metadata.self,
                from: parameters,
                jsonTaggedParameters: jsonTaggedParameters.union(declaredTags)
            )
            return AnyNShiftMetadata(metadata)
        } catch let error as NShiftRainbowCompileError {
            if parameters.isEmpty {
                return nil
            }
            throw error
        } catch {
            if parameters.isEmpty {
                return nil
            }
            throw NShiftRainbowCompileError.metadataDecodingFailed(
                plugin: pluginName,
                message: String(describing: error)
            )
        }
    }
}
