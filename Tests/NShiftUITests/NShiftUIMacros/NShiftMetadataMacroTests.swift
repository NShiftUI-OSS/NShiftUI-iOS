import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftMetadataTestMacros: [String: Macro.Type] = [
    "NShiftMetadata": NShiftMetadataMacro.self,
]
#endif

final class NShiftMetadataMacroTests: XCTestCase {
    func testMetadataMacroSynthesizesHashableAndSendable() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftMetadata
            struct PrimaryButtonMetadata: NShiftMetadata {
                var title: String
            }
            """,
            expandedSource: """
            struct PrimaryButtonMetadata: NShiftMetadata {
                var title: String
            }

            extension PrimaryButtonMetadata: Hashable, Sendable {
            }
            """,
            macros: nShiftMetadataTestMacros
        )
        #endif
    }

    func testMetadataMacroRejectsMissingProtocolConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftMetadata
            struct PrimaryButtonMetadata {
                var title: String
            }
            """,
            expandedSource: """
            struct PrimaryButtonMetadata {
                var title: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftMetadata requires the struct to explicitly conform to NShiftMetadata",
                    line: 2,
                    column: 8
                ),
            ],
            macros: nShiftMetadataTestMacros
        )
        #endif
    }

    func testMetadataMacroRejectsNonStruct() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftMetadata
            enum PrimaryButtonMetadata: NShiftMetadata {
                case title
            }
            """,
            expandedSource: """
            enum PrimaryButtonMetadata: NShiftMetadata {
                case title
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftMetadata can only be attached to a struct",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftMetadataTestMacros
        )
        #endif
    }

    func testMetadataMacroRejectsRedundantHashable() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftMetadata
            struct PrimaryButtonMetadata: NShiftMetadata, Hashable {
                var title: String
            }
            """,
            expandedSource: """
            struct PrimaryButtonMetadata: NShiftMetadata, Hashable {
                var title: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftMetadata already synthesizes Hashable and Sendable — declare only NShiftMetadata",
                    line: 2,
                    column: 8
                ),
            ],
            macros: nShiftMetadataTestMacros
        )
        #endif
    }

    func testCompilerPluginPublishesMetadataMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertTrue(plugin.providingMacros.contains(where: { $0 == NShiftMetadataMacro.self }))
        #endif
    }
}
