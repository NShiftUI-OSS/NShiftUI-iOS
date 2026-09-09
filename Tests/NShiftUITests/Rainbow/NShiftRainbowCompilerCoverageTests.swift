import RainbowParser
import Testing
@testable import NShiftUI
@testable import NShiftUIDomain

private struct SampleTextMetadata: NShiftMetadata, Codable, Equatable {
    let text: String
    let size: Double
}

private func defaultCompiler(
    catalog: NShiftRegisteredVersionCatalog = NShiftRegisteredVersionCatalog(forTesting: ()),
    defaultVersion: NShiftVersion? = nil,
    slotMarkers: Set<String>? = nil
) -> NShiftRainbowCompiler {
    var configuration = NShiftRainbowCompileConfiguration(
        slotMarkers: slotMarkers ?? [
            "NavLeading",
            "NavCenter",
            "NavTrailing",
        ],
        defaultVersion: defaultVersion
    )
    configuration.catalog = catalog
    return NShiftRainbowCompiler(configuration: configuration)
}

@Test func rainbowCompilerCompilesDocumentAPI() throws {
    let source = """
    use Screen@1.0.0

    Screen()
    """
    let document = try RainbowParser().decode(source)
    let model = try defaultCompiler().compile(document: document)

    #expect(model.name.rawValue == "Screen")
    #expect(model.version.rawValue == "1.0.0")
}

@Test func rainbowCompilerCompileAllReturnsEveryRoot() throws {
    let source = """
    use Screen@1.0.0
    use Modal@1.0.0

    Screen()
    Modal()
    """
    let models = try defaultCompiler().compileAll(source: source)

    #expect(models.map(\.name.rawValue) == ["Screen", "Modal"])
}

@Test func rainbowCompilerCompileAllEmptyDocumentReturnsEmptyArray() throws {
    let models = try defaultCompiler().compileAll(document: RainbowDocument())

    #expect(models.isEmpty)
}

@Test func rainbowCompilerThrowsEmptyDocument() {
    #expect(throws: NShiftRainbowCompileError.emptyDocument) {
        try defaultCompiler().compile(document: RainbowDocument())
    }
}

@Test func rainbowCompilerThrowsInvalidPluginName() {
    let source = """
    use Screen@1.0.0

    screen()
    """

    #expect(throws: NShiftRainbowCompileError.invalidPluginName("screen")) {
        try defaultCompiler().compile(source: source)
    }
}

@Test func rainbowCompilerThrowsInvalidEventName() {
    let source = """
    use Button@1.0.0

    Button() {
      OnTap {
        show_toast()
      }
    }
    """

    #expect(throws: NShiftRainbowCompileError.invalidEventName("show_toast")) {
        try defaultCompiler(defaultVersion: "1.0.0").compile(source: source)
    }
}

@Test func rainbowCompilerThrowsInvalidSlotName() {
    let source = """
    use Screen@1.0.0
    use Icon@1.0.0

    Screen() {
      leading {
        Icon()
      }
    }
    """

    #expect(throws: NShiftRainbowCompileError.invalidSlotName("leading")) {
        try defaultCompiler(
            defaultVersion: "1.0.0",
            slotMarkers: ["leading"]
        ).compile(source: source)
    }
}

@Test func rainbowCompilerThrowsInvalidVersionFromUse() {
    let document = RainbowDocument(
        uses: [RainbowUseDeclaration(name: "Screen", version: "1.2")],
        nodes: [RainbowNode(name: "Screen")]
    )

    do {
        _ = try defaultCompiler().compile(document: document)
        Issue.record("Expected invalidVersion")
    } catch let error as NShiftRainbowCompileError {
        guard case .invalidVersion = error else {
            Issue.record("Expected invalidVersion, got \(error)")
            return
        }
    } catch {
        Issue.record("Unexpected error \(error)")
    }
}

@Test func rainbowCompilerThrowsMissingPluginVersion() {
    let source = """
    Screen()
    """

    #expect(throws: NShiftRainbowCompileError.missingVersion("Screen")) {
        try defaultCompiler().compile(source: source)
    }
}

@Test func rainbowCompilerThrowsMissingEventVersion() {
    let source = """
    use Button@1.0.0

    Button() {
      OnTap {
        ShowToast()
      }
    }
    """

    #expect(throws: NShiftRainbowCompileError.missingVersion("ShowToast")) {
        try defaultCompiler().compile(source: source)
    }
}

@Test func rainbowCompilerUsesCatalogLatestPluginWhenUnpinned() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerPlugin("Screen", version: "1.0.0")
    catalog.registerPlugin("Screen", version: "2.1.0")

    let source = """
    Screen()
    """
    let model = try defaultCompiler(catalog: catalog).compile(source: source)

    #expect(model.version.rawValue == "2.1.0")
}

@Test func rainbowCompilerUsesCatalogLatestEventWhenUnpinned() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerPlugin("Button", version: "1.0.0")
    catalog.registerEvent("ShowToast", version: "1.0.0")
    catalog.registerEvent("ShowToast", version: "3.0.0")

    let source = """
    Button() {
      OnTap {
        ShowToast()
      }
    }
    """
    let model = try defaultCompiler(catalog: catalog).compile(source: source)
    let event = try #require(model.events.first?.event)

    #expect(event.version.rawValue == "3.0.0")
}

@Test func rainbowCompilerPinWinsOverCatalog() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerPlugin("Button", version: "2.0.0")

    let source = """
    use Button@1.0.0

    Button()
    """
    let model = try defaultCompiler(catalog: catalog).compile(source: source)

    #expect(model.version.rawValue == "1.0.0")
}

@Test func rainbowCompilerCatalogWinsOverDefaultVersion() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerPlugin("Screen", version: "2.0.0")

    let source = """
    Screen()
    """
    let model = try defaultCompiler(
        catalog: catalog,
        defaultVersion: "1.0.0"
    ).compile(source: source)

    #expect(model.version.rawValue == "2.0.0")
}

@Test func rainbowCompilerFallsBackToDefaultVersion() throws {
    let source = """
    Screen()
    """
    let model = try defaultCompiler(defaultVersion: "1.4.0").compile(source: source)

    #expect(model.version.rawValue == "1.4.0")
}

@Test func rainbowCompilerThrowsMetadataDecodingFailed() {
    let source = """
    use Text@1.0.0

    Text(text: 1, size: "nope")
    """
    var configuration = NShiftRainbowCompileConfiguration(defaultVersion: "1.0.0")
    configuration.catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    configuration.registerMetadataDecoder(
        NShiftRainbowDecodableMetadataDecoder<SampleTextMetadata>(pluginName: "Text")
    )

    do {
        _ = try NShiftRainbowCompiler(configuration: configuration).compile(source: source)
        Issue.record("Expected metadataDecodingFailed")
    } catch let error as NShiftRainbowCompileError {
        guard case .metadataDecodingFailed(let plugin, _) = error else {
            Issue.record("Expected metadataDecodingFailed, got \(error)")
            return
        }
        #expect(plugin == "Text")
    } catch {
        Issue.record("Unexpected error \(error)")
    }
}

@Test func rainbowCompilerReadsIdParameter() throws {
    let source = """
    use Screen@1.0.0

    Screen(id: "home")
    """
    let model = try defaultCompiler().compile(source: source)

    #expect(model.id == "home")
}

@Test func rainbowCompilerReadsStyleSpacingDouble() throws {
    let source = """
    use VerticalStack@1.0.0

    VerticalStack(style: (spacing: 8.5))
    """
    let model = try defaultCompiler().compile(source: source)

    #expect(model.style.spacing == 8.5)
}

@Test func rainbowCompilerIgnoresNonObjectStyle() throws {
    let source = """
    use VerticalStack@1.0.0

    VerticalStack(style: 8)
    """
    let model = try defaultCompiler().compile(source: source)

    #expect(model.style == NShiftPluginStyle())
}

@Test func rainbowCompilerCompilesNestedTriggerEvents() throws {
    let source = """
    use Button@1.0.0
    use Navigate@1.0.0
    use Track@1.0.0

    Button() {
      OnTap {
        Navigate() {
          OnAppear {
            Track()
          }
        }
      }
    }
    """
    let model = try defaultCompiler(defaultVersion: "1.0.0").compile(source: source)
    let navigate = try #require(model.events.first?.event)
    let track = try #require(navigate.events.first)

    #expect(navigate.name.rawValue == "Navigate")
    #expect(navigate.trigger.rawValue == "onTap")
    #expect(track.name.rawValue == "Track")
    #expect(track.trigger.rawValue == "onAppear")
}

@Test func rainbowCompilerCompilesEventSlots() throws {
    let source = """
    use Button@1.0.0
    use Navigate@1.0.0
    use Icon@1.0.0

    Button() {
      OnTap {
        Navigate() {
          NavLeading {
            Icon()
          }
        }
      }
    }
    """
    let model = try defaultCompiler(defaultVersion: "1.0.0").compile(source: source)
    let event = try #require(model.events.first?.event)

    #expect(event.slots["NavLeading"]?.first?.name.rawValue == "Icon")
}

@Test func rainbowCompilerCompilesMultipleEventsUnderOneTrigger() throws {
    let source = """
    use Button@1.0.0
    use Navigate@1.0.0
    use ShowToast@1.0.0

    Button() {
      OnTap {
        Navigate()
        ShowToast()
      }
    }
    """
    let model = try defaultCompiler(defaultVersion: "1.0.0").compile(source: source)

    #expect(model.events.compactMap(\.event).map(\.name.rawValue) == ["Navigate", "ShowToast"])
}

@Test func rainbowCompilerTreatsInvalidOnPrefixAsPluginChild() throws {
    let source = """
    use Screen@1.0.0
    use Ontap@1.0.0

    Screen() {
      Ontap()
    }
    """
    let model = try defaultCompiler().compile(source: source)

    #expect(model.events.isEmpty)
    #expect(model.children.first?.name.rawValue == "Ontap")
}

@Test func rainbowCompilerHonorsCustomSlotMarkers() throws {
    let source = """
    use Screen@1.0.0
    use Icon@1.0.0

    Screen() {
      ToolbarLeading {
        Icon()
      }
    }
    """
    let model = try defaultCompiler(
        defaultVersion: "1.0.0",
        slotMarkers: ["ToolbarLeading"]
    ).compile(source: source)

    #expect(model.slots["ToolbarLeading"]?.first?.name.rawValue == "Icon")
    #expect(model.children.isEmpty)
}

@Test func rainbowCompileConfigurationRegisteringMetadataDecoderCopies() {
    let decoder = NShiftRainbowDecodableMetadataDecoder<SampleTextMetadata>(pluginName: "Text")
    let original = NShiftRainbowCompileConfiguration()
    let copy = original.registeringMetadataDecoder(decoder)

    #expect(original.metadataDecoders["Text"] == nil)
    #expect(copy.metadataDecoders["Text"] != nil)
}

@Test func rainbowCompileErrorDescriptionsMatchCases() {
    #expect(NShiftRainbowCompileError.emptyDocument.description == "Rainbow document has no root nodes")
    #expect(
        NShiftRainbowCompileError.invalidPluginName("x").description == "Invalid plugin name: x"
    )
    #expect(
        NShiftRainbowCompileError.invalidEventName("x").description == "Invalid event name: x"
    )
    #expect(
        NShiftRainbowCompileError.invalidSlotName("x").description == "Invalid slot name: x"
    )
    #expect(
        NShiftRainbowCompileError.invalidTriggerName("x").description == "Invalid trigger name: x"
    )
    #expect(
        NShiftRainbowCompileError.invalidVersion("1.2").description == "Invalid version: 1.2"
    )
    #expect(
        NShiftRainbowCompileError.missingVersion("Screen").description
            == "Missing version pin for Screen (add use Screen@x.y.z or register in catalog)"
    )
    #expect(
        NShiftRainbowCompileError.metadataDecodingFailed(plugin: "Text", message: "bad").description
            == "Failed to decode metadata for Text: bad"
    )
    #expect(
        NShiftRainbowCompileError.unsupportedTaggedValue("JSON").description
            == "Unsupported tagged value @JSON in Rainbow parameters"
    )
}
