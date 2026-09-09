import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftMetadataMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: NShiftMetadataMacroDiagnostic(failure: .requiresStruct)
                )
            )
            return []
        }

        let inherited = structDeclaration.inheritedTypeNames
        let protocolNames: Set<String> = [
            "NShiftMetadata",
            "NShiftUIDomain.NShiftMetadata"
        ]

        guard inherited.contains(where: protocolNames.contains) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(structDeclaration.name),
                    message: NShiftMetadataMacroDiagnostic(failure: .requiresProtocolConformance)
                )
            )
            return []
        }

        if inherited.contains(where: { $0 == "Hashable" || $0 == "Swift.Hashable" })
            || inherited.contains(where: { $0 == "Sendable" || $0 == "Swift.Sendable" }) {
            context.diagnose(
                Diagnostic(
                    node: Syntax(structDeclaration.name),
                    message: NShiftMetadataMacroDiagnostic(failure: .redundantHashableOrSendable)
                )
            )
            return []
        }

        let typeName = type.trimmedDescription
        return [
            try ExtensionDeclSyntax(
                """
                extension \(raw: typeName): Hashable, Sendable {
                }
                """
            )
        ]
    }
}

enum NShiftMetadataMacroFailure: String, CaseIterable, Error {
    case requiresStruct
    case requiresProtocolConformance
    case redundantHashableOrSendable
}

struct NShiftMetadataMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftMetadataMacroFailure

    var message: String {
        switch failure {
        case .requiresStruct:
            return "@NShiftMetadata can only be attached to a struct"
        case .requiresProtocolConformance:
            return "@NShiftMetadata requires the struct to explicitly conform to NShiftMetadata"
        case .redundantHashableOrSendable:
            return "@NShiftMetadata already synthesizes Hashable and Sendable — declare only NShiftMetadata"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: "NShiftMetadata.\(failure.rawValue)")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

private extension StructDeclSyntax {
    var inheritedTypeNames: [String] {
        inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []
    }
}
