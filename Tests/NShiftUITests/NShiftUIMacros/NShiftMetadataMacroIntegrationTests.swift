import NShiftUI
import Testing

@NShiftMetadata
private struct IntegratedPluginMetadata: NShiftMetadata {
    var title: String = ""
}

@NShiftMetadata
private struct IntegratedEventMetadata: NShiftMetadata {
    var message: String = ""
}

@Test func pluginAndEventMetadataMacrosCanBeUsedFromPublicMacrosModule() {
    let plugin = IntegratedPluginMetadata(title: "OK")
    let event = IntegratedEventMetadata(message: "Hi")

    #expect(plugin.title == "OK")
    #expect(event.message == "Hi")
    #expect(AnyNShiftMetadata(plugin).unwrap(as: IntegratedPluginMetadata.self)?.title == "OK")
    #expect(AnyNShiftMetadata(event).unwrap(as: IntegratedEventMetadata.self)?.message == "Hi")
}
