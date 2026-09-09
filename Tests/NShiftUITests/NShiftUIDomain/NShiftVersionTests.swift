import Foundation
@testable import NShiftUIDomain
import Testing

@Test func versionAcceptsStrictSemVerCore() throws {
    let version = try NShiftVersion(validating: "1.2.3")
    #expect(version.major == 1)
    #expect(version.minor == 2)
    #expect(version.patch == 3)
    #expect(version.rawValue == "1.2.3")
}

@Test func versionRejectsInvalidSemVer() {
    #expect(throws: NShiftVersionError.invalidVersion("1.2")) {
        try NShiftVersion(validating: "1.2")
    }
    #expect(throws: NShiftVersionError.invalidVersion("01.0.0")) {
        try NShiftVersion(validating: "01.0.0")
    }
    #expect(throws: NShiftVersionError.invalidVersion("1.0.0-beta")) {
        try NShiftVersion(validating: "1.0.0-beta")
    }
}

@Test func versionComparesForLatestSelection() throws {
    let older = try NShiftVersion(validating: "1.2.0")
    let newer = try NShiftVersion(validating: "1.10.0")
    let major = try NShiftVersion(validating: "2.0.0")
    #expect(older < newer)
    #expect(newer < major)
}

@Test func registeredVersionCatalogReturnsLatest() {
    let catalog = NShiftRegisteredVersionCatalog.shared
    catalog.resetForTesting()
    defer { catalog.resetForTesting() }

    catalog.registerPlugin("Button", version: "1.0.0")
    catalog.registerPlugin("Button", version: "1.2.0")
    catalog.registerPlugin("Button", version: "1.10.0")

    #expect(catalog.latestPlugin(named: "Button") == NShiftVersion(major: 1, minor: 10, patch: 0))
}

@Test func versionResolverUsesLatestWhenUnpinned() throws {
    let catalog = NShiftRegisteredVersionCatalog.shared
    catalog.resetForTesting()
    defer { catalog.resetForTesting() }

    catalog.registerEvent("ShowToast", version: "1.0.0")
    catalog.registerEvent("ShowToast", version: "2.1.0")

    let pins = NShiftDSLVersionPins()
    let resolved = try pins.resolveEvent(named: "ShowToast", catalog: catalog)
    #expect(resolved == NShiftVersion(major: 2, minor: 1, patch: 0))
}

@Test func versionResolverHonorsUsePin() throws {
    let catalog = NShiftRegisteredVersionCatalog.shared
    catalog.resetForTesting()
    defer { catalog.resetForTesting() }

    catalog.registerPlugin("Screen", version: "1.0.0")
    catalog.registerPlugin("Screen", version: "2.0.0")

    let pins = try NShiftDSLVersionPins(uses: [(name: "Screen", version: "1.0.0")])
    let resolved = try pins.resolvePlugin(named: "Screen", catalog: catalog)
    #expect(resolved == NShiftVersion(major: 1, minor: 0, patch: 0))
}

@Test func registrationNameJoinsNameAndVersion() {
    #expect(
        NShiftVersion.registrationName(plugin: "Button", version: "1.2.3") == "Button@1.2.3"
    )
    #expect(
        NShiftVersion.registrationName(event: "ShowToast", version: "0.1.0") == "ShowToast@0.1.0"
    )
}

@Test func registeredVersionCatalogRejectsCrossKindNameConflicts() {
    defer { NShiftRegisteredVersionCatalogFailure.restore() }

    let pluginConflict = captureCatalogFailure {
        let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
        catalog.registerEvent("Navigate", version: "1.0.0")
        catalog.registerPlugin("Navigate", version: "1.0.0")
    }
    #expect(
        pluginConflict
            == "Plugin name \"Navigate\" conflicts with a registered event of the same name"
    )

    let eventConflict = captureCatalogFailure {
        let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
        catalog.registerPlugin("Screen", version: "1.0.0")
        catalog.registerEvent("Screen", version: "1.0.0")
    }
    #expect(
        eventConflict
            == "Event name \"Screen\" conflicts with a registered plugin of the same name"
    )
}

@Test func versionIsValidRejectsNonCoreSemVer() {
    #expect(NShiftVersion.isValid("1.2.3"))
    #expect(NShiftVersion.isValid("0.0.0"))
    #expect(NShiftVersion.isValid("1.2") == false)
    #expect(NShiftVersion.isValid("01.0.0") == false)
}

@Test func versionResolverThrowsWhenPluginIsMissingOrUnregisteredVersion() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerPlugin("Screen", version: "1.0.0")

    #expect(throws: NShiftVersionResolutionError.pluginNotRegistered("Missing")) {
        try NShiftVersionResolver.resolvePlugin(named: "Missing", catalog: catalog)
    }
    #expect(throws: NShiftVersionResolutionError.pluginVersionNotRegistered("Screen", "9.0.0")) {
        try NShiftVersionResolver.resolvePlugin(named: "Screen", pinned: "9.0.0", catalog: catalog)
    }
}

@Test func versionResolverThrowsWhenEventIsMissingOrUnregisteredVersion() throws {
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())
    catalog.registerEvent("ShowToast", version: "1.0.0")

    #expect(throws: NShiftVersionResolutionError.eventNotRegistered("Missing")) {
        try NShiftVersionResolver.resolveEvent(named: "Missing", catalog: catalog)
    }
    #expect(throws: NShiftVersionResolutionError.eventVersionNotRegistered("ShowToast", "9.0.0")) {
        try NShiftVersionResolver.resolveEvent(named: "ShowToast", pinned: "9.0.0", catalog: catalog)
    }
}

@Test func dslVersionPinsDictionaryInitAndEmptyCatalogLookups() throws {
    let pins = NShiftDSLVersionPins(["Screen": NShiftVersion(major: 1, minor: 0, patch: 0)])
    let catalog = NShiftRegisteredVersionCatalog(forTesting: ())

    #expect(pins.pinnedVersion(forPlugin: "Screen") == NShiftVersion(major: 1, minor: 0, patch: 0))
    #expect(catalog.versions(forPlugin: "Screen").isEmpty)
    #expect(catalog.latestPlugin(named: "Screen") == nil)
    #expect(catalog.versions(forEvent: "ShowToast").isEmpty)
    #expect(catalog.latestEvent(named: "ShowToast") == nil)
}

private func captureCatalogFailure(_ body: @escaping @Sendable () -> Void) -> String? {
    let capture = CatalogFatalErrorCapture()
    let semaphore = DispatchSemaphore(value: 0)

    NShiftRegisteredVersionCatalogFailure.replace { message in
        capture.store(message)
        semaphore.signal()
        Thread.exit()

        while true {
            Thread.sleep(forTimeInterval: 1)
        }
    }

    Thread(block: body).start()

    let result = semaphore.wait(timeout: .now() + 2)
    NShiftRegisteredVersionCatalogFailure.restore()

    guard result == .success else {
        return nil
    }
    return capture.message
}

private final class CatalogFatalErrorCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: String?

    var message: String? {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }

    func store(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        stored = message
    }
}
