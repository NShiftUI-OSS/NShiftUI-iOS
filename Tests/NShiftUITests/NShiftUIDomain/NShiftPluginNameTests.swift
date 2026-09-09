import NShiftUIDomain
import Testing

@Test func pluginNameStoresValidUpperCamelCaseASCIIName() throws {
    let name = try NShiftPluginName(validating: "PrimaryButton")

    #expect(name.rawValue == "PrimaryButton")
    #expect(name.description == "PrimaryButton")
}

@Test func pluginNameCanBeCreatedFromStringLiteral() {
    let name: NShiftPluginName = "PrimaryButton"

    #expect(name.rawValue == "PrimaryButton")
}

@Test func pluginNameValidationAcceptsOnlyUpperCamelCaseASCIILetters() {
    #expect(NShiftPluginName.isValid("PrimaryButton"))
    #expect(NShiftPluginName.isValid("Button"))
    #expect(NShiftPluginName.isValid("") == false)
    #expect(NShiftPluginName.isValid("primaryButton") == false)
    #expect(NShiftPluginName.isValid("Primary_Button") == false)
    #expect(NShiftPluginName.isValid("Primary1Button") == false)
    #expect(NShiftPluginName.isValid("Botao") == true)
    #expect(NShiftPluginName.isValid("Botão") == false)
}

@Test func pluginNameThrowsWhenNameIsInvalid() {
    #expect(throws: NShiftPluginNameError.invalidName("primaryButton")) {
        try NShiftPluginName(validating: "primaryButton")
    }
}
