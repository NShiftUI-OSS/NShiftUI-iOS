import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftTokenMetadataTestMacros: [String: Macro.Type] = [
    "NShiftTokenMetadata": NShiftTokenMetadataMacro.self,
]
#endif

final class NShiftTokenMetadataMacroTests: XCTestCase {
    func testTokenMetadataMacroSynthesizesRawRepresentableAndCaseIterable() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            enum HorizontalStackAlignment: NShiftTokenMetadata {
                case top
                case center
                case bottom
            }
            """,
            expandedSource: """
            enum HorizontalStackAlignment: NShiftTokenMetadata {
                case top
                case center
                case bottom
            }

            extension HorizontalStackAlignment: Hashable, Sendable, CaseIterable, RawRepresentable {
                public typealias RawValue = String

                public var rawValue: String {
                    switch self {
                    case .top:
                        return "top"
                    case .center:
                        return "center"
                    case .bottom:
                        return "bottom"
                    }
                }

                public init?(rawValue: String) {
                    switch rawValue {
                    case "top":
                        self = .top
                    case "center":
                        self = .center
                    case "bottom":
                        self = .bottom
                    default:
                        return nil
                    }
                }

                public static var allCases: [HorizontalStackAlignment] {
                    [.top, .center, .bottom]
                }
            }
            """,
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testTokenMetadataMacroRejectsNonEnum() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            struct HorizontalStackAlignment: NShiftTokenMetadata {
            }
            """,
            expandedSource: """
            struct HorizontalStackAlignment: NShiftTokenMetadata {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftTokenMetadata can only be attached to an enum",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testTokenMetadataMacroRejectsMissingProtocolConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            enum HorizontalStackAlignment {
                case top
            }
            """,
            expandedSource: """
            enum HorizontalStackAlignment {
                case top
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftTokenMetadata requires the enum to explicitly conform to NShiftTokenMetadata",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testTokenMetadataMacroRejectsRedundantString() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            enum HorizontalStackAlignment: String, NShiftTokenMetadata {
                case top
            }
            """,
            expandedSource: """
            enum HorizontalStackAlignment: String, NShiftTokenMetadata {
                case top
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftTokenMetadata already synthesizes String (RawRepresentable), CaseIterable, Hashable, and Sendable — declare only NShiftTokenMetadata",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testTokenMetadataMacroRejectsEmptyEnum() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            enum HorizontalStackAlignment: NShiftTokenMetadata {
            }
            """,
            expandedSource: """
            enum HorizontalStackAlignment: NShiftTokenMetadata {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftTokenMetadata requires at least one enum case",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testTokenMetadataMacroRejectsAssociatedValues() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftTokenMetadata
            enum HorizontalStackAlignment: NShiftTokenMetadata {
                case custom(String)
            }
            """,
            expandedSource: """
            enum HorizontalStackAlignment: NShiftTokenMetadata {
                case custom(String)
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftTokenMetadata does not support enum cases with associated values",
                    line: 2,
                    column: 6
                ),
            ],
            macros: nShiftTokenMetadataTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesTokenMetadataMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftTokenMetadataMacro.self }))
        #endif
    }
}
