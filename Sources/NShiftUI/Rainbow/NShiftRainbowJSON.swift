import Foundation
import RainbowParser

public enum NShiftRainbowJSON {
    public static func decode<T: Decodable>(
        _ type: T.Type,
        from parameters: [RainbowParameter]
    ) throws -> T {
        let object = try dictionary(from: parameters)
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: []
        )
        return try JSONDecoder().decode(type, from: data)
    }

    public static func dictionary(
        from parameters: [RainbowParameter]
    ) throws -> [String: Any] {
        var result: [String: Any] = [:]
        for parameter in parameters {
            if parameter.name == "id" || parameter.name == "style" {
                continue
            }
            result[parameter.name] = try jsonValue(parameter.value)
        }
        return result
    }

    public static func jsonValue(
        _ value: RainbowValue
    ) throws -> Any {
        switch value {
        case .string(let string):
            return string
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .bool(let bool):
            return bool
        case .identifier(let identifier):
            return identifier
        case .null:
            return NSNull()
        case .array(let values):
            return try values.map(jsonValue)
        case .object(let entries):
            var object: [String: Any] = [:]
            for entry in entries {
                object[entry.key] = try jsonValue(entry.value)
            }
            return object
        case .tagged(let language, _, _):
            throw NShiftRainbowCompileError.unsupportedTaggedValue(language.rawValue)
        }
    }
}
