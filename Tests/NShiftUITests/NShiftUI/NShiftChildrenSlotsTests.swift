import NShiftUIDomain
import SwiftUI
import Testing
@testable import NShiftUI

@NShiftSlotKey
private enum ChildrenScreenSlots: NShiftSlotKey {
    case leading
}

@NShiftPlugin(name: "ChildrenLeaf", version: "1.0.0")
private struct ChildrenLeafPlugin: NShiftPlugin {
    var body: some View {
        Text("leaf")
    }
}

@NShiftPlugin(name: "ChildrenScreen", version: "1.0.0")
private struct ChildrenScreenPlugin: NShiftPlugin {
    var body: some View {
        VStack {
            children()
            children { view in
                view.opacity(0.9)
            }
            children { _, view in
                view
            }
        }
    }
}

@NShiftPlugin(name: "SlotsScreen", version: "1.0.0", slots: ChildrenScreenSlots.self)
private struct SlotsScreenPlugin: NShiftPlugin {
    var body: some View {
        HStack {
            slots(.leading)
            slots(.leading) { view in
                view
            }
            slots(.leading) { _, view in
                view
            }
        }
    }
}

private struct ChildrenSlotsAssembly: NShiftDependencyAssembly {
    @NShiftPluginAssemble(
        ChildrenScreenPlugin.self,
        ChildrenLeafPlugin.self,
        SlotsScreenPlugin.self
    )
    func assemblePlugins(in container: any NShiftDependencyContainer) {}
}

@MainActor
@Test func pluginChildrenRendersSubtreeKeyedByRenderId() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(hostContainer: host, assemblies: [ChildrenSlotsAssembly()])

    let rootModel = NShiftPluginModel(
        id: "screen",
        name: "ChildrenScreen", version: "1.0.0",
        children: [NShiftPluginModel(id: "leaf", name: "ChildrenLeaf", version: "1.0.0")]
    )
    let engine = NShiftEngineResolver.makeEngine(rootModel: rootModel, config: config)
    let tree = engine as! NShiftDefaultEngine
    let view = tree.makeView(for: tree.root)

    #expect(tree.node(withID: "leaf")?.renderId.rawValue == "r/c/0")
    #expect(view != nil)

    config.resetForTesting()
}

@MainActor
@Test func pluginSlotsRendersSubtreeKeyedByRenderId() {
    let config = NShiftConfig.shared
    config.resetForTesting()

    let host = NShiftDependencyRegistry()
    config.startup(hostContainer: host, assemblies: [ChildrenSlotsAssembly()])

    let rootModel = NShiftPluginModel(
        id: "screen",
        name: "SlotsScreen", version: "1.0.0",
        slots: [
            "Leading": [NShiftPluginModel(id: "leaf", name: "ChildrenLeaf", version: "1.0.0")],
        ]
    )
    let engine = NShiftEngineResolver.makeEngine(rootModel: rootModel, config: config)
    let tree = engine as! NShiftDefaultEngine
    let view = tree.makeView(for: tree.root)

    #expect(tree.node(withID: "leaf")?.renderId.rawValue == "r/s/Leading/0")
    #expect(view != nil)

    config.resetForTesting()
}
