import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftSlotKeyMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(node: Syntax(node), message: NShiftSlotKeyMacroDiagnostic(failure: .requiresEnum))
            )
            return []
        }

        guard enumDeclaration.conformsToNShiftSlotKey else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftSlotKeyMacroDiagnostic(failure: .requiresNShiftSlotKeyConformance)
                )
            )
            return []
        }

        let inherited = enumDeclaration.inheritedTypeNames
        if inherited.contains(where: { $0 == "String" || $0 == "Swift.String" })
            || inherited.contains(where: { $0 == "CaseIterable" || $0 == "Swift.CaseIterable" })
            || inherited.contains(where: { $0 == "RawRepresentable" || $0 == "Swift.RawRepresentable" }) {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftSlotKeyMacroDiagnostic(failure: .redundantStringOrCaseIterable)
                )
            )
            return []
        }

        let cases = enumDeclaration.simpleCaseElements
        guard cases.isEmpty == false else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftSlotKeyMacroDiagnostic(failure: .requiresAtLeastOneCase)
                )
            )
            return []
        }

        if enumDeclaration.hasAssociatedValueCases {
            context.diagnose(
                Diagnostic(
                    node: Syntax(enumDeclaration.name),
                    message: NShiftSlotKeyMacroDiagnostic(failure: .associatedValuesNotSupported)
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
                extension \(raw: typeName): CaseIterable, RawRepresentable {
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

enum NShiftSlotKeyMacroFailure: String, CaseIterable, Error {
    case requiresEnum
    case requiresNShiftSlotKeyConformance
    case requiresAtLeastOneCase
    case associatedValuesNotSupported
    case redundantStringOrCaseIterable
}

struct NShiftSlotKeyMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftSlotKeyMacroFailure

    var message: String {
        switch failure {
        case .requiresEnum:
            return "@NShiftSlotKey can only be attached to an enum"
        case .requiresNShiftSlotKeyConformance:
            return "@NShiftSlotKey requires the enum to explicitly conform to NShiftSlotKey"
        case .requiresAtLeastOneCase:
            return "@NShiftSlotKey requires at least one enum case"
        case .associatedValuesNotSupported:
            return "@NShiftSlotKey does not support enum cases with associated values"
        case .redundantStringOrCaseIterable:
            return "@NShiftSlotKey already synthesizes String (RawRepresentable) and CaseIterable — declare only NShiftSlotKey"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: failure.rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

private extension EnumDeclSyntax {
    static let slotKeyProtocolNames: Set<String> = [
        "NShiftSlotKey",
        "NShiftUIDomain.NShiftSlotKey",
    ]

    var inheritedTypeNames: [String] {
        inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []
    }

    var conformsToNShiftSlotKey: Bool {
        inheritedTypeNames.contains(where: Self.slotKeyProtocolNames.contains)
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
