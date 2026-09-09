import Testing
@testable import NShiftUIDomain

@MainActor
@Test func pluginNodeBuildsChildrenAndSlotRenderIDs() {
    let root = NShiftPluginNode(
        model: NShiftPluginModel(
            id: "root",
            name: "Screen", version: "1.0.0",
            children: [NShiftPluginModel(id: "child", name: "Label", version: "1.0.0")],
            slots: [
                "Footer": [NShiftPluginModel(id: "footer", name: "Button", version: "1.0.0")],
            ]
        )
    )

    #expect(root.renderId == .root)
    #expect(root.children.first?.renderId.rawValue == "r/c/0")
    #expect(root.children.first?.parent === root)
    #expect(root.slotChildren["Footer"]?.first?.renderId.rawValue == "r/s/Footer/0")
}

@MainActor
@Test func pluginNodeReplaceHelpersRebuildRenderIDs() {
    let root = NShiftPluginNode(
        model: NShiftPluginModel(
            id: "root",
            name: "Screen", version: "1.0.0",
            children: [NShiftPluginModel(id: "old", name: "Label", version: "1.0.0")],
            slots: [
                "Footer": [NShiftPluginModel(id: "old-footer", name: "Button", version: "1.0.0")],
            ]
        )
    )

    root.replaceChildren(with: [NShiftPluginModel(id: "new", name: "Image", version: "1.0.0")])
    root.replaceSlotChildren(
        "Footer",
        with: [NShiftPluginModel(id: "new-footer", name: "Icon", version: "1.0.0")]
    )
    root.replaceAllSlotChildren(
        with: [
            "Header": [NShiftPluginModel(id: "header", name: "Text", version: "1.0.0")],
        ]
    )

    #expect(root.children.first?.model.id == "new")
    #expect(root.children.first?.renderId.rawValue == "r/c/0")
    #expect(root.slotChildren["Footer"] == nil)
    #expect(root.slotChildren["Header"]?.first?.renderId.rawValue == "r/s/Header/0")
}
