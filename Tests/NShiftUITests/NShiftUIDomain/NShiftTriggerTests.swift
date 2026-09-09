import NShiftUIDomain
import Testing

@Test func triggerStoresValidOnPrefixedCamelCaseName() throws {
    let trigger = try NShiftTrigger(validating: "onTap")

    #expect(trigger.rawValue == "onTap")
    #expect(trigger.description == "onTap")
}

@Test func triggerCanBeCreatedFromStringLiteral() {
    let trigger: NShiftTrigger = "onClick"

    #expect(trigger.rawValue == "onClick")
}

@Test func triggerValidationAcceptsOnlyOnPrefixedCamelCaseASCIILetters() {
    #expect(NShiftTrigger.isValid("onTap"))
    #expect(NShiftTrigger.isValid("onClick"))
    #expect(NShiftTrigger.isValid("onSwipe"))
    #expect(NShiftTrigger.isValid("onLongPress"))
    #expect(NShiftTrigger.isValid("onSuccess"))
    #expect(NShiftTrigger.isValid("onAppear"))
    #expect(NShiftTrigger.isValid("") == false)
    #expect(NShiftTrigger.isValid("on") == false)
    #expect(NShiftTrigger.isValid("OnTap") == false)
    #expect(NShiftTrigger.isValid("ontap") == false)
    #expect(NShiftTrigger.isValid("on_tap") == false)
    #expect(NShiftTrigger.isValid("onTap1") == false)
    #expect(NShiftTrigger.isValid("tapOn") == false)
    #expect(NShiftTrigger.isValid("onToque") == true)
    #expect(NShiftTrigger.isValid("onTapé") == false)
}

@Test func triggerThrowsWhenNameIsInvalid() {
    #expect(throws: NShiftTriggerError.invalidTrigger("OnTap")) {
        try NShiftTrigger(validating: "OnTap")
    }
}
