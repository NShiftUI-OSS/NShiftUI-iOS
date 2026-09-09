import NShiftUI
import RainbowParser
import XCTest

private struct SampleTextMetadata: NShiftMetadata, Codable, Equatable {
    let text: String
    let size: Double

    init(
        text: String = "",
        size: Double = 16
    ) {
        self.text = text
        self.size = size
    }
}

final class NShiftRainbowCompilerTests: XCTestCase {
    func testCompilesSlotsChildrenAndMetadata() throws {
        let source = """
        use Screen@1.0.0
        use Text@1.0.0
        use Icon@1.0.0
        use Scroll@1.0.0

        Screen(
          backgroundColor: "#FFFFFF",
          navigationBar: (
            isHidden: false,
            isTranslucent: true,
            title: (text: "Home", size: 17)
          )
        ) {
          NavLeading {
            Icon(name: back, size: 22)
          }
          NavTrailing {
            Icon(name: settings, size: 22)
          }
          Scroll {
            Text(text: "Hello", size: 16)
          }
        }
        """

        var configuration = NShiftRainbowCompileConfiguration(
            defaultVersion: NShiftVersion(major: 1, minor: 0, patch: 0)
        )
        configuration.registerMetadataDecoder(
            NShiftRainbowDecodableMetadataDecoder<SampleTextMetadata>(pluginName: "Text")
        )

        let compiler = NShiftRainbowCompiler(configuration: configuration)
        let model = try compiler.compile(source: source)

        XCTAssertEqual(model.name.rawValue, "Screen")
        XCTAssertEqual(model.version.rawValue, "1.0.0")
        XCTAssertEqual(model.children.count, 1)
        XCTAssertEqual(model.children[0].name.rawValue, "Scroll")
        XCTAssertEqual(model.slots["NavLeading"]?.count, 1)
        XCTAssertEqual(model.slots["NavLeading"]?[0].name.rawValue, "Icon")
        XCTAssertEqual(model.slots["NavTrailing"]?.count, 1)

        let text = model.children[0].children[0]
        XCTAssertEqual(text.name.rawValue, "Text")
        let metadata = text.metadata?.unwrap(as: SampleTextMetadata.self)
        XCTAssertEqual(metadata?.text, "Hello")
        XCTAssertEqual(metadata?.size, 16)
    }

    func testCompilesTriggerEvents() throws {
        let source = """
        use Button@1.0.0
        use Navigate@1.0.0

        Button(title: "Go") {
          OnTap {
            Navigate(to: "Home")
          }
        }
        """

        let configuration = NShiftRainbowCompileConfiguration(
            defaultVersion: NShiftVersion(major: 1, minor: 0, patch: 0)
        )
        let compiler = NShiftRainbowCompiler(configuration: configuration)
        let model = try compiler.compile(source: source)

        XCTAssertEqual(model.events.count, 1)
        let event = try XCTUnwrap(model.events[0].event)
        XCTAssertEqual(event.name.rawValue, "Navigate")
        XCTAssertEqual(event.trigger.rawValue, "onTap")
        XCTAssertTrue(model.children.isEmpty)
    }

    func testStyleSpacingParameter() throws {
        let source = """
        use VerticalStack@1.0.0
        use Text@1.0.0

        VerticalStack(style: (spacing: 8)) {
          Text(text: "A", size: 12)
        }
        """

        let configuration = NShiftRainbowCompileConfiguration(
            defaultVersion: NShiftVersion(major: 1, minor: 0, patch: 0)
        )
        let compiler = NShiftRainbowCompiler(configuration: configuration)
        let model = try compiler.compile(source: source)
        XCTAssertEqual(model.style.spacing, 8)
    }
}
