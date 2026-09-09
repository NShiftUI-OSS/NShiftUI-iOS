import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftEventAssembleTestMacros: [String: Macro.Type] = [
    "NShiftEventAssemble": NShiftEventAssembleMacro.self,
]
#endif

final class NShiftEventAssembleMacroTests: XCTestCase {
    func testEventAssembleMacroGeneratesEventRegistration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                @NShiftEventAssemble(ShowToastEvent.self)
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                    container.registerEvent(ShowToastEvent.self, container: container) { eventModel in
                        ShowToastEvent(
                            model: eventModel,
                            resolver: container
                        )
                    }
                }
            }
            """,
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroGeneratesMultipleEventRegistrations() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                @NShiftEventAssemble(ShowToastEvent.self, NavigateEvent.self)
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                    container.registerEvent(ShowToastEvent.self, container: container) { eventModel in
                        ShowToastEvent(
                            model: eventModel,
                            resolver: container
                        )
                    }
                    container.registerEvent(NavigateEvent.self, container: container) { eventModel in
                        NavigateEvent(
                            model: eventModel,
                            resolver: container
                        )
                    }
                }
            }
            """,
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroAcceptsQualifiedAssemblyConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftUIDI.NShiftDependencyAssembly {
                @NShiftEventAssemble(ShowToastEvent.self)
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftUIDI.NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                    container.registerEvent(ShowToastEvent.self, container: container) { eventModel in
                        ShowToastEvent(
                            model: eventModel,
                            resolver: container
                        )
                    }
                }
            }
            """,
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroRejectsNonAssembleEventsFunction() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                @NShiftEventAssemble(ShowToastEvent.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEventAssemble can only be attached to assembleEvents(in:)",
                    line: 3,
                    column: 10
                ),
            ],
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroRejectsTypeWithoutAssemblyConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly {
                @NShiftEventAssemble(ShowToastEvent.self)
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEventAssemble requires the enclosing type to conform to NShiftDependencyAssembly",
                    line: 3,
                    column: 10
                ),
            ],
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroRejectsMissingEventTypes() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                @NShiftEventAssemble
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEventAssemble requires at least one event type (for example: ShowToastEvent.self)",
                    line: 2,
                    column: 5
                ),
            ],
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testEventAssembleMacroRejectsInvalidEventType() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                @NShiftEventAssemble("ShowToastEvent")
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct EventModuleAssembly: NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftEventAssemble arguments must be event types (for example: ShowToastEvent.self)",
                    line: 2,
                    column: 26
                ),
            ],
            macros: nShiftEventAssembleTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesEventAssembleMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftEventAssembleMacro.self }))
        #endif
    }
}
