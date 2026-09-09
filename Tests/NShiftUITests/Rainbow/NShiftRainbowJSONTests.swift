import Foundation
import RainbowParser
import Testing
@testable import NShiftUI

@Test func rainbowJSONMapsScalarArrayAndObjectValues() throws {
    let parameters = [
        RainbowParameter(name: "title", value: .string("Hello")),
        RainbowParameter(name: "count", value: .int(3)),
        RainbowParameter(name: "ratio", value: .double(1.5)),
        RainbowParameter(name: "enabled", value: .bool(true)),
        RainbowParameter(name: "empty", value: .null),
        RainbowParameter(name: "token", value: .identifier("back")),
        RainbowParameter(name: "tags", value: .array([.string("a"), .string("b")])),
        RainbowParameter(
            name: "nested",
            value: .object([RainbowObjectEntry(key: "inner", value: .int(1))])
        ),
        RainbowParameter(name: "id", value: .string("skip-me")),
        RainbowParameter(name: "style", value: .object([])),
    ]

    let object = try NShiftRainbowJSON.dictionary(from: parameters)

    #expect(object["title"] as? String == "Hello")
    #expect(object["count"] as? Int == 3)
    #expect(object["ratio"] as? Double == 1.5)
    #expect(object["enabled"] as? Bool == true)
    #expect(object["empty"] is NSNull)
    #expect(object["token"] as? String == "back")
    #expect(object["tags"] as? [String] == ["a", "b"])
    #expect((object["nested"] as? [String: Any])?["inner"] as? Int == 1)
    #expect(object["id"] == nil)
    #expect(object["style"] == nil)
}

@Test func rainbowJSONThrowsUnsupportedTaggedValue() {
    let range = RainbowSourceRange(
        start: RainbowSourceLocation(offset: 0, line: 1, column: 1),
        end: RainbowSourceLocation(offset: 1, line: 1, column: 2)
    )

    #expect(throws: NShiftRainbowCompileError.unsupportedTaggedValue("JSON")) {
        try NShiftRainbowJSON.jsonValue(
            .tagged(language: .json, body: .text("{}"), bodyRange: range)
        )
    }
}

@Test func rainbowJSONDecodeSkipsEmptyParameters() throws {
    struct Payload: Decodable, Equatable {
        let title: String
    }

    let decoded = try NShiftRainbowJSON.decode(
        Payload.self,
        from: [RainbowParameter(name: "title", value: .string("Home"))]
    )

    #expect(decoded == Payload(title: "Home"))
}

@Test func rainbowMetadataDecoderReturnsNilForEmptyParameters() throws {
    let decoder = NShiftRainbowDecodableMetadataDecoder<EmptyDecodableMetadata>(pluginName: "Text")

    #expect(try decoder.decode(parameters: []) == nil)
}

private struct EmptyDecodableMetadata: NShiftMetadata, Codable {}
