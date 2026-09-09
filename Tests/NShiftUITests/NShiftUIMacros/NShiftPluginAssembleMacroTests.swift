import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftPluginAssembleTestMacros: [String: Macro.Type] = [
    "NShiftPluginAssemble": NShiftPluginAssembleMacro.self,
]
#endif

final class NShiftPluginAssembleMacroTests: XCTestCase {
    func testPluginAssembleMacroGeneratesPluginRegistration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble(PrimaryButton.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                    container.registerPlugin(PrimaryButton.self, container: container) { model, container, renderID in
                        PrimaryButton(
                            model: model,
                            resolver: container,
                            eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                            engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                            renderID: renderID
                        )
                    }
                }
            }
            """,
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroGeneratesMultiplePluginRegistrations() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble(PrimaryButton.self, IconButton.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                    container.registerPlugin(PrimaryButton.self, container: container) { model, container, renderID in
                        PrimaryButton(
                            model: model,
                            resolver: container,
                            eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                            engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                            renderID: renderID
                        )
                    }
                    container.registerPlugin(IconButton.self, container: container) { model, container, renderID in
                        IconButton(
                            model: model,
                            resolver: container,
                            eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                            engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                            renderID: renderID
                        )
                    }
                }
            }
            """,
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroPreservesAuthorBody() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble(PrimaryButton.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                    container.register(Analytics.self) {
                        HostAnalytics()
                    }
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                    container.registerPlugin(PrimaryButton.self, container: container) { model, container, renderID in
                        PrimaryButton(
                            model: model,
                            resolver: container,
                            eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                            engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                            renderID: renderID
                        )
                    }
                    container.register(Analytics.self) {
                                HostAnalytics()
                            }
                }
            }
            """,
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroAcceptsQualifiedAssemblyConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftUIDI.NShiftDependencyAssembly {
                @NShiftPluginAssemble(PrimaryButton.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftUIDI.NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                    container.registerPlugin(PrimaryButton.self, container: container) { model, container, renderID in
                        PrimaryButton(
                            model: model,
                            resolver: container,
                            eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                            engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                            renderID: renderID
                        )
                    }
                }
            }
            """,
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroRejectsNonAssemblePluginsFunction() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble(PrimaryButton.self)
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assembleEvents(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPluginAssemble can only be attached to assemblePlugins(in:)",
                    line: 3,
                    column: 10
                ),
            ],
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroRejectsTypeWithoutAssemblyConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly {
                @NShiftPluginAssemble(PrimaryButton.self)
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPluginAssemble requires the enclosing type to conform to NShiftDependencyAssembly",
                    line: 3,
                    column: 10
                ),
            ],
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroRejectsMissingPluginTypes() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPluginAssemble requires at least one plugin type (for example: PrimaryButton.self)",
                    line: 2,
                    column: 5
                ),
            ],
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testPluginAssembleMacroRejectsInvalidPluginType() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                @NShiftPluginAssemble("PrimaryButton")
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            expandedSource: """
            struct ButtonModuleAssembly: NShiftDependencyAssembly {
                func assemblePlugins(in container: any NShiftDependencyContainer) {
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPluginAssemble arguments must be plugin types (for example: PrimaryButton.self)",
                    line: 2,
                    column: 27
                ),
            ],
            macros: nShiftPluginAssembleTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesPluginAssembleMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftPluginAssembleMacro.self }))
        #endif
    }
}
