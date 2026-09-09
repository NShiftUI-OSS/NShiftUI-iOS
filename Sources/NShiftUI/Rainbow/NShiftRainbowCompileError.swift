import RainbowParser

public enum NShiftRainbowCompileError: Error, Equatable, Sendable {
    case emptyDocument
    case invalidPluginName(String)
    case invalidEventName(String)
    case invalidSlotName(String)
    case invalidTriggerName(String)
    case invalidVersion(String)
    case missingVersion(String)
    case metadataDecodingFailed(plugin: String, message: String)
    case unsupportedTaggedValue(String)
}

extension NShiftRainbowCompileError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emptyDocument:
            "Rainbow document has no root nodes"
        case .invalidPluginName(let name):
            "Invalid plugin name: \(name)"
        case .invalidEventName(let name):
            "Invalid event name: \(name)"
        case .invalidSlotName(let name):
            "Invalid slot name: \(name)"
        case .invalidTriggerName(let name):
            "Invalid trigger name: \(name)"
        case .invalidVersion(let version):
            "Invalid version: \(version)"
        case .missingVersion(let name):
            "Missing version pin for \(name) (add use \(name)@x.y.z or register in catalog)"
        case .metadataDecodingFailed(let plugin, let message):
            "Failed to decode metadata for \(plugin): \(message)"
        case .unsupportedTaggedValue(let language):
            "Unsupported tagged value @\(language) in Rainbow parameters"
        }
    }
}
