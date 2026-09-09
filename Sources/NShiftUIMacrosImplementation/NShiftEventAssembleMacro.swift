import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftEventAssembleMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        NShiftEventAssembleExpansion.expand(
            node: node,
            declaration: declaration,
            context: context
        )
    }
}

enum NShiftEventAssembleMacroFailure: String, CaseIterable {
    case requiresAssembleEventsFunction
    case requiresNShiftDependencyAssemblyConformance
    case missingEventTypes
    case invalidEventType
}

private enum NShiftEventAssembleExpansion {
    private static let assemblyProtocolNames: Set<String> = [
        "NShiftDependencyAssembly",
        "NShiftUIDI.NShiftDependencyAssembly",
    ]

    static func expand(
        node: AttributeSyntax,
        declaration: some DeclSyntaxProtocol,
        context: some MacroExpansionContext
    ) -> [CodeBlockItemSyntax] {
        guard let functionDeclaration = declaration.as(FunctionDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: NShiftEventAssembleMacroDiagnostic(failure: .requiresAssembleEventsFunction)
                )
            )
            return []
        }

        guard functionDeclaration.name.text == "assembleEvents" else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(functionDeclaration.name),
                    message: NShiftEventAssembleMacroDiagnostic(failure: .requiresAssembleEventsFunction)
                )
            )
            return []
        }

        guard enclosingDeclGroups(from: context).contains(where: { declaresNShiftDependencyAssemblyConformance($0) }) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(functionDeclaration.name),
                    message: NShiftEventAssembleMacroDiagnostic(failure: .requiresNShiftDependencyAssemblyConformance)
                )
            )
            return []
        }

        guard let arguments = node.argumentList, arguments.isEmpty == false else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: NShiftEventAssembleMacroDiagnostic(failure: .missingEventTypes)
                )
            )
            return []
        }

        var items: [CodeBlockItemSyntax] = []

        for argument in arguments {
            guard let eventType = eventTypeName(from: argument.expression) else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(argument.expression),
                        message: NShiftEventAssembleMacroDiagnostic(failure: .invalidEventType)
                    )
                )
                continue
            }

            items.append(
                """
                container.registerEvent(\(raw: eventType).self, container: container) { eventModel in
                    \(raw: eventType)(
                        model: eventModel,
                        resolver: container
                    )
                }
                """
            )
        }

        return items
    }

    private static func enclosingDeclGroups(from context: some MacroExpansionContext) -> [any DeclGroupSyntax] {
        context.lexicalContext.compactMap { syntax in
            if let structDeclaration = syntax.as(StructDeclSyntax.self) {
                return structDeclaration
            }

            if let classDeclaration = syntax.as(ClassDeclSyntax.self) {
                return classDeclaration
            }

            if let enumDeclaration = syntax.as(EnumDeclSyntax.self) {
                return enumDeclaration
            }

            if let extensionDeclaration = syntax.as(ExtensionDeclSyntax.self) {
                return extensionDeclaration
            }

            return nil
        }
    }

    private static func declaresNShiftDependencyAssemblyConformance(_ declGroup: some DeclGroupSyntax) -> Bool {
        let inheritedTypeNames = declGroup.inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []

        return inheritedTypeNames.contains(where: assemblyProtocolNames.contains)
    }

    private static func eventTypeName(from expression: ExprSyntax) -> String? {
        let description = expression.trimmedDescription
        guard description.hasSuffix(".self") else {
            return nil
        }

        return String(description.dropLast(5))
    }
}

private extension AttributeSyntax {
    var argumentList: LabeledExprListSyntax? {
        guard case let .argumentList(arguments) = arguments else {
            return nil
        }

        return arguments
    }
}

struct NShiftEventAssembleMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftEventAssembleMacroFailure

    var message: String {
        switch failure {
        case .requiresAssembleEventsFunction:
            return "@NShiftEventAssemble can only be attached to assembleEvents(in:)"
        case .requiresNShiftDependencyAssemblyConformance:
            return "@NShiftEventAssemble requires the enclosing type to conform to NShiftDependencyAssembly"
        case .missingEventTypes:
            return "@NShiftEventAssemble requires at least one event type (for example: ShowToastEvent.self)"
        case .invalidEventType:
            return "@NShiftEventAssemble arguments must be event types (for example: ShowToastEvent.self)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: failure.rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
