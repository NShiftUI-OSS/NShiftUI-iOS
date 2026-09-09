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

    public init(pluginName: String) {
        self.pluginName = pluginName
    }

    public func decode(
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata? {
        if parameters.isEmpty {
            return nil
        }

        do {
            let metadata = try NShiftRainbowJSON.decode(
                Metadata.self,
                from: parameters
            )
            return AnyNShiftMetadata(metadata)
        } catch {
            throw NShiftRainbowCompileError.metadataDecodingFailed(
                plugin: pluginName,
                message: String(describing: error)
            )
        }
    }
}
