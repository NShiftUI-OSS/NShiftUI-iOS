import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftTokenMetadataMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: NShiftTokenMetadataMacroDiagnostic(failure: .requiresEnum)
                )
            )
            return []
        }

        guard enumDeclaration.conformsToNShiftTokenMetadata else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftTokenMetadataMacroDiagnostic(failure: .requiresProtocolConformance)
                )
            )
            return []
        }

        let inherited = enumDeclaration.inheritedTypeNames
        if inherited.contains(where: { $0 == "String" || $0 == "Swift.String" })
            || inherited.contains(where: { $0 == "CaseIterable" || $0 == "Swift.CaseIterable" })
            || inherited.contains(where: { $0 == "RawRepresentable" || $0 == "Swift.RawRepresentable" })
            || inherited.contains(where: { $0 == "Hashable" || $0 == "Swift.Hashable" })
            || inherited.contains(where: { $0 == "Sendable" || $0 == "Swift.Sendable" }) {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftTokenMetadataMacroDiagnostic(failure: .redundantInheritedTypes)
                )
            )
            return []
        }

        let cases = enumDeclaration.simpleCaseElements
        guard cases.isEmpty == false else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftTokenMetadataMacroDiagnostic(failure: .requiresAtLeastOneCase)
                )
            )
            return []
        }

        if enumDeclaration.hasAssociatedValueCases {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftTokenMetadataMacroDiagnostic(failure: .associatedValuesNotSupported)
                )
            )
            return []
        }

        let typeName = type.trimmedDescription

        let rawValueSwitchArms = cases.map { caseName in
            "        case .\(caseName): return \"\(caseName)\""
        }.joined(separator: "\n")

        let initSwitchArms = cases.map { caseName in
            "        case \"\(caseName)\": self = .\(caseName)"
        }.joined(separator: "\n")

        let allCasesList = cases.map { ".\($0)" }.joined(separator: ", ")

        return [
            try ExtensionDeclSyntax(
                """
                extension \(raw: typeName): Hashable, Sendable, CaseIterable, RawRepresentable {
                    public typealias RawValue = String

                    public var rawValue: String {
                        switch self {
                \(raw: rawValueSwitchArms)
                        }
                    }

                    public init?(rawValue: String) {
                        switch rawValue {
                \(raw: initSwitchArms)
                        default:
                            return nil
                        }
                    }

                    public static var allCases: [\(raw: typeName)] {
                        [\(raw: allCasesList)]
                    }
                }
                """
            )
        ]
    }
}

enum NShiftTokenMetadataMacroFailure: String, CaseIterable, Error {
    case requiresEnum
    case requiresProtocolConformance
    case requiresAtLeastOneCase
    case associatedValuesNotSupported
    case redundantInheritedTypes
}

struct NShiftTokenMetadataMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftTokenMetadataMacroFailure

    var message: String {
        switch failure {
        case .requiresEnum:
            return "@NShiftTokenMetadata can only be attached to an enum"
        case .requiresProtocolConformance:
            return "@NShiftTokenMetadata requires the enum to explicitly conform to NShiftTokenMetadata"
        case .requiresAtLeastOneCase:
            return "@NShiftTokenMetadata requires at least one enum case"
        case .associatedValuesNotSupported:
            return "@NShiftTokenMetadata does not support enum cases with associated values"
        case .redundantInheritedTypes:
            return "@NShiftTokenMetadata already synthesizes String (RawRepresentable), CaseIterable, Hashable, and Sendable — declare only NShiftTokenMetadata"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: "NShiftTokenMetadata.\(failure.rawValue)")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

private extension EnumDeclSyntax {
    static let tokenMetadataProtocolNames: Set<String> = [
        "NShiftTokenMetadata",
        "NShiftUIDomain.NShiftTokenMetadata",
    ]

    var inheritedTypeNames: [String] {
        inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []
    }

    var conformsToNShiftTokenMetadata: Bool {
        inheritedTypeNames.contains(where: Self.tokenMetadataProtocolNames.contains)
    }

    var simpleCaseElements: [String] {
        memberBlock.members.compactMap { member -> [String]? in
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                return nil
            }

            return caseDecl.elements.map(\.name.text)
        }.flatMap { $0 }
    }

    var hasAssociatedValueCases: Bool {
        memberBlock.members.contains { member in
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                return false
            }

            return caseDecl.elements.contains { element in
                element.parameterClause != nil
            }
        }
    }
}
