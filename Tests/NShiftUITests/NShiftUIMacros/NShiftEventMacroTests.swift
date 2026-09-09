import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftEventTestMacros: [String: Macro.Type] = [
    "NShiftEvent": NShiftEventMacro.self,
]
#endif

final class NShiftEventMacroTests: XCTestCase {
    func testEventMacroAddsEventMetadataMembers() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }

                static let name: NShiftUIDomain.NShiftEventName = "ShowToast"

                static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

                static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = ShowToastMetadata.self

                private let metadata: ShowToastMetadata

                private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

                private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

                private let eventHandler: any NShiftUIDomain.NShiftEventHandler

                private let resolver: any NShiftUIDomain.NShiftDependencyResolver

                private let engine: (any NShiftUIDomain.NShiftEngine)?

                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    guard let metadata = model.metadata?.unwrap(as: ShowToastMetadata.self) else {
                        return nil
                        }
                        self.metadata = metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }
            }

            extension ShowToastEvent: NShiftEventWithMetadata {
            }
            """,
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroAcceptsQualifiedEventConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "Navigate", version: "1.0.0", metadata: NavigateMetadata.self)
            struct NavigateEvent: NShiftUIDomain.NShiftEvent {
                func execute() async throws {
                }
            }
            """,
            expandedSource: """
            struct NavigateEvent: NShiftUIDomain.NShiftEvent {
                func execute() async throws {
                }

                static let name: NShiftUIDomain.NShiftEventName = "Navigate"

                static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

                static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = NavigateMetadata.self

                private let metadata: NavigateMetadata

                private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

                private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

                private let eventHandler: any NShiftUIDomain.NShiftEventHandler

                private let resolver: any NShiftUIDomain.NShiftDependencyResolver

                private let engine: (any NShiftUIDomain.NShiftEngine)?

                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    guard let metadata = model.metadata?.unwrap(as: NavigateMetadata.self) else {
                        return nil
                        }
                        self.metadata = metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }
            }

            extension NavigateEvent: NShiftEventWithMetadata {
            }
            """,
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroDiagnosesAuthorInitializerAndStillEmitsCanonicalInit() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            struct ShowToastEvent: NShiftEvent {
                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    self.metadata = model.metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }

                func execute() async throws {
                }
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    self.metadata = model.metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }

                func execute() async throws {
                }

                static let name: NShiftUIDomain.NShiftEventName = "ShowToast"

                static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

                static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = ShowToastMetadata.self

                private let metadata: ShowToastMetadata

                private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

                private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

                private let eventHandler: any NShiftUIDomain.NShiftEventHandler

                private let resolver: any NShiftUIDomain.NShiftDependencyResolver

                private let engine: (any NShiftUIDomain.NShiftEngine)?

                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    guard let metadata = model.metadata?.unwrap(as: ShowToastMetadata.self) else {
                        return nil
                        }
                        self.metadata = metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }
            }

            extension ShowToastEvent: NShiftEventWithMetadata {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent owns the canonical init?; remove the initializer from this struct",
                    line: 3,
                    column: 5
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsStructWithoutNShiftEventConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            struct ShowToastEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires the struct to explicitly conform to NShiftEvent",
                    line: 2,
                    column: 8
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsInvalidEventName() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "show_toast", version: "1.0.0", metadata: ShowToastMetadata.self)
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires name: UpperCamelCase ASCII letters only",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroOmitsMetadataTypeWhenMetadataArgumentIsMissing() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0")
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }

                static let name: NShiftUIDomain.NShiftEventName = "ShowToast"

                static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

                private let metadata: NShiftUIDomain.AnyNShiftMetadata?

                private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

                private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

                private let eventHandler: any NShiftUIDomain.NShiftEventHandler

                private let resolver: any NShiftUIDomain.NShiftDependencyResolver

                private let engine: (any NShiftUIDomain.NShiftEngine)?

                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    self.metadata = model.metadata
                    self.slots = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }
            }
            """,
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsNonStructDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            final class ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            final class ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent can only be attached to a struct",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsEnumDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            enum ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            enum ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent can only be attached to a struct",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsActorDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata.self)
            actor ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            actor ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent can only be attached to a struct",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesEventMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftEventMacro.self }))
        #endif
    }

    func testEventMacroRejectsAttributeWithoutArguments() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires name: and version:",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsInvalidVersion() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.2")
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires version: SemVer MAJOR.MINOR.PATCH",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsMetadataArgumentWithoutSelf() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", metadata: ShowToastMetadata)
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires metadata: SomeMetadata.self or omit the parameter",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroRejectsSlotsArgumentWithoutSelf() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", slots: ToastSlots)
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEvent requires slots: SomeSlots.self or omit the parameter",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftEventTestMacros
        )
        #endif
    }

    func testEventMacroGeneratesTypedSlotMapWhenSlotsArgumentIsProvided() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftEvent(name: "ShowToast", version: "1.0.0", slots: ToastSlots.self)
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }
            }
            """,
            expandedSource: """
            struct ShowToastEvent: NShiftEvent {
                func execute() async throws {
                }

                static let name: NShiftUIDomain.NShiftEventName = "ShowToast"

                static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

                private let metadata: NShiftUIDomain.AnyNShiftMetadata?

                private let slotsStorage: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

                private var slots: NShiftUIDomain.NShiftSlotMap<ToastSlots> {
                    NShiftUIDomain.NShiftSlotMap(storage: slotsStorage)
                }

                private func slotModels(_ key: ToastSlots) -> [NShiftUIDomain.NShiftPluginModel] {
                    slots[key]
                }

                private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

                private let eventHandler: any NShiftUIDomain.NShiftEventHandler

                private let resolver: any NShiftUIDomain.NShiftDependencyResolver

                private let engine: (any NShiftUIDomain.NShiftEngine)?

                init?(
                    model: NShiftUIDomain.NShiftEventModel,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver
                ) {
                    self.metadata = model.metadata
                    self.slotsStorage = model.slots
                    self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)
                    self.resolver = resolver
                    self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                    self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
                }
            }
            """,
            macros: nShiftEventTestMacros
        )
        #endif
    }
}
