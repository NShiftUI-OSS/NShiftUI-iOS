import NShiftUIDomain
import Testing

@Test func eventNameStoresValidUpperCamelCaseASCIIName() throws {
    let name = try NShiftEventName(validating: "ShowToast")

    #expect(name.rawValue == "ShowToast")
    #expect(name.description == "ShowToast")
}

@Test func eventNameCanBeCreatedFromStringLiteral() {
    let name: NShiftEventName = "ShowToast"

    #expect(name.rawValue == "ShowToast")
}

@Test func eventNameValidationAcceptsOnlyUpperCamelCaseASCIILetters() {
    #expect(NShiftEventName.isValid("ShowToast"))
    #expect(NShiftEventName.isValid("Navigate"))
    #expect(NShiftEventName.isValid("") == false)
    #expect(NShiftEventName.isValid("showToast") == false)
    #expect(NShiftEventName.isValid("Show_Toast") == false)
    #expect(NShiftEventName.isValid("Show1Toast") == false)
    #expect(NShiftEventName.isValid("Botao") == true)
    #expect(NShiftEventName.isValid("Botão") == false)
}

@Test func eventNameThrowsWhenNameIsInvalid() {
    #expect(throws: NShiftEventNameError.invalidName("showToast")) {
        try NShiftEventName(validating: "showToast")
    }
}
