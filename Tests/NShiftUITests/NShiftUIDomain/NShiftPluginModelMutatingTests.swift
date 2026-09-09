import Testing
@testable import NShiftUIDomain

@Test func pluginModelReplacingHelpersCopyIdentityAndSwapPayload() {
    let child = NShiftPluginModel(id: "old", name: "Label", version: "1.0.0")
    let slotChild = NShiftPluginModel(id: "slot-old", name: "Icon", version: "1.0.0")
    let event = NShiftEventModel(id: "tap", name: "Tap", version: "1.0.0", trigger: "onTap")
    let original = NShiftPluginModel(
        id: "root",
        name: "Screen", version: "1.0.0",
        metadata: NShiftEmptyMetadata(),
        children: [child],
        slots: ["Footer": [slotChild]],
        events: [event]
    )
    let newMetadata = AnyNShiftMetadata(NShiftEmptyMetadata())
    let newChild = NShiftPluginModel(id: "new", name: "Image", version: "1.0.0")
    let newSlot = NShiftPluginModel(id: "slot-new", name: "Button", version: "1.0.0")
    let newEvent = NShiftEventModel(id: "appear", name: "Appear", version: "1.0.0", trigger: "onAppear")

    let withMetadata = original.replacingMetadata(newMetadata)
    let withEvents = original.replacingEvents([newEvent])
    let withChildren = original.replacingChildren([newChild])
    let withSlots = original.replacingSlots(["Leading": [newSlot]])
    let withSlot = original.replacingSlot("Footer", with: [newSlot])

    #expect(withMetadata.id == "root")
    #expect(withMetadata.metadata == newMetadata)
    #expect(withEvents.events.compactMap(\.event).map(\.id) == ["appear"])
    #expect(withChildren.children.map(\.id) == [Optional("new")])
    #expect(withSlots.slots["Leading"]?.first?.id == "slot-new")
    #expect(withSlots.slots["Footer"] == nil)
    #expect(withSlot.slots["Footer"]?.first?.id == "slot-new")
    #expect(original.children.first?.id == "old")
}
