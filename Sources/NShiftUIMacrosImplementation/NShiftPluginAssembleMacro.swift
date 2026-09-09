import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftPluginAssembleMacro: BodyMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        NShiftPluginAssembleExpansion.expand(
            node: node,
            declaration: declaration,
            context: context
        )
    }
}

enum NShiftPluginAssembleMacroFailure: String, CaseIterable {
    case requiresAssemblePluginsFunction
    case requiresNShiftDependencyAssemblyConformance
    case missingPluginTypes
    case invalidPluginType
}

private enum NShiftPluginAssembleExpansion {
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
                    message: NShiftPluginAssembleMacroDiagnostic(failure: .requiresAssemblePluginsFunction)
                )
            )
            return []
        }

        guard functionDeclaration.name.text == "assemblePlugins" else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(functionDeclaration.name),
                    message: NShiftPluginAssembleMacroDiagnostic(failure: .requiresAssemblePluginsFunction)
                )
            )
            return []
        }

        guard enclosingDeclGroups(from: context).contains(where: { declaresNShiftDependencyAssemblyConformance($0) }) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(functionDeclaration.name),
                    message: NShiftPluginAssembleMacroDiagnostic(failure: .requiresNShiftDependencyAssemblyConformance)
                )
            )
            return []
        }

        guard let arguments = node.argumentList, arguments.isEmpty == false else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(node),
                    message: NShiftPluginAssembleMacroDiagnostic(failure: .missingPluginTypes)
                )
            )
            return []
        }

        var items: [CodeBlockItemSyntax] = []

        for argument in arguments {
            guard let pluginType = pluginTypeName(from: argument.expression) else {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(argument.expression),
                        message: NShiftPluginAssembleMacroDiagnostic(failure: .invalidPluginType)
                    )
                )
                continue
            }

            items.append(
                """
                container.registerPlugin(\(raw: pluginType).self, container: container) { model, container, renderID in
                    \(raw: pluginType)(
                        model: model,
                        resolver: container,
                        eventHandler: container.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self),
                        engine: container.resolve(NShiftUIDomain.NShiftEngine.self),
                        renderID: renderID
                    )
                }
                """
            )
        }

        if let body = functionDeclaration.body {
            items.append(contentsOf: Array(body.statements))
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

    private static func pluginTypeName(from expression: ExprSyntax) -> String? {
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

struct NShiftPluginAssembleMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftPluginAssembleMacroFailure

    var message: String {
        switch failure {
        case .requiresAssemblePluginsFunction:
            return "@NShiftPluginAssemble can only be attached to assemblePlugins(in:)"
        case .requiresNShiftDependencyAssemblyConformance:
            return "@NShiftPluginAssemble requires the enclosing type to conform to NShiftDependencyAssembly"
        case .missingPluginTypes:
            return "@NShiftPluginAssemble requires at least one plugin type (for example: PrimaryButton.self)"
        case .invalidPluginType:
            return "@NShiftPluginAssemble arguments must be plugin types (for example: PrimaryButton.self)"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: failure.rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
