import NShiftUIDomain
import Testing

@Test func eventStoresIdentityTypeMetadataTriggerAndChildEvents() {
    let childEvents = [
        TestEvent(name: "Navigate", version: "1.0.0", trigger: "onSuccess"),
        TestEvent(name: "ShowToast", version: "1.0.0", trigger: "onError"),
    ]
    let slots: [NShiftSlotName: [NShiftPluginModel]] = [
        "Content": [TestPlugin(id: "sheet-title", name: "Text", version: "1.0.0")],
        "Footer": [TestPlugin(id: "dismiss-button", name: "Button", version: "1.0.0")],
    ]
    let metadata = NShiftEmptyMetadata()
    let event = TestEvent(
        id: "loginRequest",
        name: "SendHTTPRequest", version: "1.0.0",
        metadata: metadata,
        trigger: "onTap",
        slots: slots,
        events: childEvents
    )

    #expect(event.id == "loginRequest")
    #expect(event.name == "SendHTTPRequest")
    #expect(event.metadata == AnyNShiftMetadata(metadata))
    #expect(event.trigger == "onTap")
    #expect(event.slots == slots)
    #expect(event.events == childEvents)
}

@Test func eventDefaultsToGeneratedIdNoMetadataNoSlotsAndNoChildEvents() {
    let event = TestEvent(name: "Navigate", version: "1.0.0", trigger: "onTap")

    #expect(event.id.isEmpty == false)
    #expect(event.name == "Navigate")
    #expect(event.metadata == nil)
    #expect(event.trigger == "onTap")
    #expect(event.slots == [:])
    #expect(event.events == [])
}

@Test func eventsAreHashable() {
    let events: Set<TestEvent> = [
        TestEvent(id: "navigateHome", name: "Navigate", version: "1.0.0", trigger: "onSuccess"),
        TestEvent(id: "navigateHome", name: "Navigate", version: "1.0.0", trigger: "onSuccess"),
        TestEvent(id: "loginRequest", name: "SendHTTPRequest", version: "1.0.0", trigger: "onTap"),
    ]

    #expect(events.count == 2)
}

@Test func eventHandlingErrorDescriptionsMatchReasons() {
    let event = NShiftEventModel(id: "toast", name: "ShowToast", version: "1.0.0", trigger: "onTap")
    let missing = NShiftEventHandlingError(event: event, reason: .actionNotFound)
    let failed = NShiftEventHandlingError(event: event, reason: .actionFailed("boom"))
    let initFailed = NShiftEventHandlingError(event: event, reason: .initializationFailed)

    #expect(NShiftEventHandlingFailureReason.actionNotFound.description == "event action was not registered")
    #expect(
        NShiftEventHandlingFailureReason.actionFailed("boom").description
            == "event action failed with error: boom"
    )
    #expect(NShiftEventHandlingFailureReason.initializationFailed.description == "event init? returned nil")
    #expect(
        missing.description
            == "Failed to handle event 'ShowToast' (id: toast, trigger: onTap): event action was not registered"
    )
    #expect(
        initFailed.description
            == "Failed to handle event 'ShowToast' (id: toast, trigger: onTap): event init? returned nil"
    )
}
