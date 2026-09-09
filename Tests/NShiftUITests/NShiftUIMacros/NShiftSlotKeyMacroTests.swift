import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftSlotKeyTestMacros: [String: Macro.Type] = [
    "NShiftSlotKey": NShiftSlotKeyMacro.self,
]
#endif

final class NShiftSlotKeyMacroTests: XCTestCase {
    func testSlotKeyMacroSynthesizesStringRawRepresentableAndCaseIterable() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            enum ToolbarSlots: NShiftSlotKey {
                case leading
                case trailing
                case topTrailing
            }
            """,
            expandedSource: """
            enum ToolbarSlots: NShiftSlotKey {
                case leading
                case trailing
                case topTrailing
            }

            extension ToolbarSlots: CaseIterable, RawRepresentable {
                public typealias RawValue = String

                public var rawValue: String {
                    switch self {
                    case .leading:
                        return "leading"
                    case .trailing:
                        return "trailing"
                    case .topTrailing:
                        return "topTrailing"
                    }
                }

                public init?(rawValue: String) {
                    switch rawValue {
                    case "leading":
                        self = .leading
                    case "trailing":
                        self = .trailing
                    case "topTrailing":
                        self = .topTrailing
                    default:
                        return nil
                    }
                }

                public static var allCases: [ToolbarSlots] {
                    [.leading, .trailing, .topTrailing]
                }
            }
            """,
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testSlotKeyMacroRejectsMissingNShiftSlotKeyConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            enum ToolbarSlots {
                case leading
            }
            """,
            expandedSource: """
            enum ToolbarSlots {
                case leading
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftSlotKey requires the enum to explicitly conform to NShiftSlotKey",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testSlotKeyMacroRejectsRedundantStringConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            enum ToolbarSlots: String, NShiftSlotKey {
                case leading
            }
            """,
            expandedSource: """
            enum ToolbarSlots: String, NShiftSlotKey {
                case leading
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftSlotKey already synthesizes String (RawRepresentable) and CaseIterable — declare only NShiftSlotKey",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testSlotKeyMacroRejectsNonEnum() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            struct ToolbarSlots: NShiftSlotKey {
            }
            """,
            expandedSource: """
            struct ToolbarSlots: NShiftSlotKey {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftSlotKey can only be attached to an enum",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testSlotKeyMacroRejectsEmptyEnum() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            enum ToolbarSlots: NShiftSlotKey {
            }
            """,
            expandedSource: """
            enum ToolbarSlots: NShiftSlotKey {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftSlotKey requires at least one enum case",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testSlotKeyMacroRejectsAssociatedValues() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftSlotKey
            enum ToolbarSlots: NShiftSlotKey {
                case custom(String)
            }
            """,
            expandedSource: """
            enum ToolbarSlots: NShiftSlotKey {
                case custom(String)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftSlotKey does not support enum cases with associated values",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftSlotKeyTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesSlotKeyMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftSlotKeyMacro.self }))
        #endif
    }
}
