import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftPluginMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        NShiftPluginMemberExpansion.expand(
            node: node,
            declaration: declaration,
            context: context
        )
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        try NShiftPluginExtensionExpansion.expand(
            node: node,
            declaration: declaration,
            type: type,
            context: context
        )
    }
}

enum NShiftPluginMacroRole: String, CaseIterable {
    case plugin
    case container

    var protocolName: String {
        switch self {
        case .plugin:
            "NShiftPlugin"
        case .container:
            "NShiftPluginContainer"
        }
    }

    var protocolNames: Set<String> {
        [
            protocolName,
            "NShiftUIDomain.\(protocolName)",
        ]
    }

    func initializerDeclarations(
        viewModelType: String?,
        usesStateObject: Bool,
        typedSlots: Bool,
        metadataType: String?
    ) -> [DeclSyntax] {
        let slotsAssignment = typedSlots
            ? "self.slotsStorage = model.slots"
            : "self.slots = model.slots"
        let metadataBlock: String
        if let metadataType {
            metadataBlock = """
                guard let metadata = model.metadata?.unwrap(as: \(metadataType).self) else {
                    return nil
                }
                self.metadata = metadata
                """
        } else {
            metadataBlock = "self.metadata = model.metadata"
        }

        let viewModelInsertion: String
        if let viewModelType, usesStateObject {
            viewModelInsertion = "\n        guard let viewModel = resolver.resolve(\(viewModelType).self) else {\n        return nil\n        }\n        self._viewModel = SwiftUI.StateObject(wrappedValue: viewModel)"
        } else if let viewModelType {
            viewModelInsertion = "\n        guard let viewModel = resolver.resolve(\(viewModelType).self) else {\n        return nil\n        }\n        self.viewModel = viewModel"
        } else {
            viewModelInsertion = ""
        }

        return [
            """
            init?(
                model: NShiftUIDomain.NShiftPluginModel,
                resolver: any NShiftUIDomain.NShiftDependencyResolver,
                eventHandler: any NShiftUIDomain.NShiftEventHandler,
                engine: (any NShiftUIDomain.NShiftEngine)?,
                renderID: NShiftUIDomain.NShiftRenderID = .root
            ) {
                \(raw: metadataBlock)
                self.style = model.style
                self.pluginChildren = model.children
                \(raw: slotsAssignment)
                self.events = model.events\(raw: viewModelInsertion)
                self.resolver = resolver
                self.eventHandler = eventHandler
                self.engine = engine
                self.renderID = renderID
            }
            """,
        ]
    }
}

enum NShiftPluginMacroFailure: String, CaseIterable, Error {
    case invalidArguments
    case invalidMetadata
    case invalidSlots
    case invalidPluginName
    case invalidPluginVersion
    case missingExplicitViewModelType
    case missingStateObjectViewModel
    case requiresProtocolConformance
    case requiresStruct
    case authorMustNotDeclareInitializer
}

enum NShiftPluginMacroMetadataArgument {
    case omitted
    case invalid
    case type(String)
}

private enum NShiftPluginMemberExpansion {
    static func expand(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .requiresStruct)))
            return []
        }

        guard let role = structDeclaration.nShiftPluginRole else {
            context.diagnose(Diagnostic(node: Syntax(structDeclaration.name), message: NShiftPluginMacroDiagnostic(failure: .requiresProtocolConformance)))
            return []
        }

        guard let arguments = node.argumentList else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .invalidArguments)))
            return []
        }

        guard let name = pluginName(from: arguments) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .invalidPluginName)))
            return []
        }

        guard let version = pluginVersion(from: arguments) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .invalidPluginVersion)))
            return []
        }

        let metadataArgument = metadataType(from: arguments)
        if case .invalid = metadataArgument {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .invalidMetadata)))
            return []
        }

        let slotsKeyType: String?
        do {
            slotsKeyType = try slotsType(from: arguments)
        } catch {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftPluginMacroDiagnostic(failure: .invalidSlots)))
            return []
        }

        let resolvedViewModelType: String?
        let usesStateObject: Bool
        switch role {
        case .plugin:
            resolvedViewModelType = structDeclaration.declaredViewModelType
            usesStateObject = false
        case .container:
            guard structDeclaration.hasStateObjectViewModel else {
                context.diagnose(Diagnostic(node: Syntax(structDeclaration.name), message: NShiftPluginMacroDiagnostic(failure: .missingStateObjectViewModel)))
                return []
            }

            guard let stateObjectViewModelType = structDeclaration.stateObjectViewModelType else {
                context.diagnose(Diagnostic(node: Syntax(structDeclaration.name), message: NShiftPluginMacroDiagnostic(failure: .missingExplicitViewModelType)))
                return []
            }

            resolvedViewModelType = stateObjectViewModelType
            usesStateObject = true
        }

        let typedMetadataType: String?
        if case let .type(metadataType) = metadataArgument {
            typedMetadataType = metadataType
        } else {
            typedMetadataType = nil
        }

        var members: [DeclSyntax] = [
            "static let name: NShiftUIDomain.NShiftPluginName = \(literal: name)",
            "static let version: NShiftUIDomain.NShiftVersion = \(literal: version)",
        ]

        if let typedMetadataType {
            members.append(
                "static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = \(raw: typedMetadataType).self"
            )
        }

        if let typedMetadataType {
            members.append("private let metadata: \(raw: typedMetadataType)")
        } else {
            members.append("private let metadata: NShiftUIDomain.AnyNShiftMetadata?")
        }

        members.append(contentsOf: [
            "private let style: NShiftUIDomain.NShiftPluginStyle",
            "private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]",
        ])

        if let slotsKeyType {
            members.append(contentsOf: [
                "private let slotsStorage: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]",
                """
                private var slotsMap: NShiftUIDomain.NShiftSlotMap<\(raw: slotsKeyType)> {
                    NShiftUIDomain.NShiftSlotMap(storage: slotsStorage)
                }
                """,
                """
                private func slotModels(_ key: \(raw: slotsKeyType)) -> [NShiftUIDomain.NShiftPluginModel] {
                    slotsMap[key]
                }
                """,
            ])
        } else {
            members.append(
                "private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]"
            )
        }

        members.append("private let events: [NShiftUIDomain.AnyNShiftPluginEvent]")

        if role == .plugin, let resolvedViewModelType, structDeclaration.declaresViewModel == false {
            members.append("private let viewModel: \(raw: resolvedViewModelType)")
        }

        members.append(contentsOf: [
            "private let resolver: any NShiftUIDomain.NShiftDependencyResolver",
            "private let eventHandler: any NShiftUIDomain.NShiftEventHandler",
            "private let engine: (any NShiftUIDomain.NShiftEngine)?",
            "private let renderID: NShiftUIDomain.NShiftRenderID",
            """
            private var engineTree: any NShiftUIDomain.NShiftEngineTree {
                guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
                    preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
                }
                return engineTree
            }
            """,
            """
            private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
                NShiftUI.NShiftChildrenAccessor(
                    parentRenderID: renderID,
                    engine: engineTree
                )
            }
            """,
        ])

        if let slotsKeyType {
            members.append(contentsOf: [
                """
                private var slotsAccessor: NShiftUI.NShiftSlotsAccessor<\(raw: slotsKeyType)> {
                    NShiftUI.NShiftSlotsAccessor(
                        parentRenderID: renderID,
                        engine: engineTree
                    )
                }
                """,
                """
                @SwiftUI.ViewBuilder
                private func slots(_ key: \(raw: slotsKeyType)) -> some SwiftUI.View {
                    slotsAccessor(key)
                }
                """,
                """
                @SwiftUI.ViewBuilder
                private func slots<Content: SwiftUI.View>(
                    _ key: \(raw: slotsKeyType),
                    @SwiftUI.ViewBuilder transform: @escaping (
                        NShiftUIDomain.NShiftPluginModel,
                        NShiftUI.NShiftNodeView
                    ) -> Content
                ) -> some SwiftUI.View {
                    slotsAccessor(key, transform: transform)
                }
                """,
                """
                @SwiftUI.ViewBuilder
                private func slots<Content: SwiftUI.View>(
                    _ key: \(raw: slotsKeyType),
                    @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
                ) -> some SwiftUI.View {
                    slotsAccessor(key) { _, view in
                        transform(view)
                    }
                }
                """,
            ])
        }

        members.append(contentsOf: [
            """
            @SwiftUI.ViewBuilder
            private func children() -> some SwiftUI.View {
                childrenAccessor()
            }
            """,
            """
            @SwiftUI.ViewBuilder
            private func children<Content: SwiftUI.View>(
                @SwiftUI.ViewBuilder transform: @escaping (
                    NShiftUIDomain.NShiftPluginModel,
                    NShiftUI.NShiftNodeView
                ) -> Content
            ) -> some SwiftUI.View {
                childrenAccessor(transform: transform)
            }
            """,
            """
            @SwiftUI.ViewBuilder
            private func children<Content: SwiftUI.View>(
                @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
            ) -> some SwiftUI.View {
                childrenAccessor { _, view in
                    transform(view)
                }
            }
            """,
        ])

        if structDeclaration.hasInitializer {
            if let initializer = structDeclaration.memberBlock.members
                .compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
                .first {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(initializer),
                        message: NShiftPluginMacroDiagnostic(failure: .authorMustNotDeclareInitializer)
                    )
                )
            }
        }

        members.append(
            contentsOf: role.initializerDeclarations(
                viewModelType: resolvedViewModelType,
                usesStateObject: usesStateObject,
                typedSlots: slotsKeyType != nil,
                metadataType: typedMetadataType
            )
        )

        return members
    }

    static func pluginName(from arguments: LabeledExprListSyntax) -> String? {
        guard let expression = arguments.first(where: { $0.label?.text == "name" })?.expression,
              let literal = expression.as(StringLiteralExprSyntax.self),
              literal.segments.count == 1,
              let segment = literal.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let name = segment.content.text
        return isValidPluginName(name) ? name : nil
    }

    static func pluginVersion(from arguments: LabeledExprListSyntax) -> String? {
        guard let expression = arguments.first(where: { $0.label?.text == "version" })?.expression,
              let literal = expression.as(StringLiteralExprSyntax.self),
              literal.segments.count == 1,
              let segment = literal.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let version = segment.content.text
        return NShiftSemVerValidation.isValid(version) ? version : nil
    }

    static func metadataType(from arguments: LabeledExprListSyntax) -> NShiftPluginMacroMetadataArgument {
        guard let expression = arguments.first(where: { $0.label?.text == "metadata" })?.expression else {
            return .omitted
        }

        let metadataExpression = expression.trimmedDescription
        if metadataExpression == "nil" {
            return .omitted
        }

        guard metadataExpression.hasSuffix(".self") else {
            return .invalid
        }

        return .type(String(metadataExpression.dropLast(5)))
    }

    static func slotsType(from arguments: LabeledExprListSyntax) throws -> String? {
        guard let expression = arguments.first(where: { $0.label?.text == "slots" })?.expression else {
            return nil
        }

        let slotsExpression = expression.trimmedDescription
        if slotsExpression == "nil" {
            return nil
        }

        guard slotsExpression.hasSuffix(".self") else {
            throw NShiftPluginMacroFailure.invalidSlots
        }

        return String(slotsExpression.dropLast(5))
    }

    private static func isValidPluginName(_ name: String) -> Bool {
        guard let first = name.unicodeScalars.first,
              (65...90).contains(first.value) else {
            return false
        }

        return name.unicodeScalars.allSatisfy { scalar in
            (65...90).contains(scalar.value) || (97...122).contains(scalar.value)
        }
    }
}

private enum NShiftPluginExtensionExpansion {
    static func expand(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self),
              let role = structDeclaration.nShiftPluginRole,
              let arguments = node.argumentList,
              case .type = NShiftPluginMemberExpansion.metadataType(from: arguments),
              NShiftPluginMemberExpansion.pluginName(from: arguments) != nil,
              NShiftPluginMemberExpansion.pluginVersion(from: arguments) != nil else {
            return []
        }

        if case .container = role {
            guard structDeclaration.hasStateObjectViewModel,
                  structDeclaration.stateObjectViewModelType != nil else {
                return []
            }
        }

        do {
            _ = try NShiftPluginMemberExpansion.slotsType(from: arguments)
        } catch {
            return []
        }

        let typeName = type.trimmedDescription
        return [
            try ExtensionDeclSyntax(
                """
                extension \(raw: typeName): NShiftPluginWithMetadata {
                }
                """
            ),
        ]
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

private extension StructDeclSyntax {
    var nShiftPluginRole: NShiftPluginMacroRole? {
        let inheritedTypeNames = Set(inheritanceClause?.inheritedTypes.map { inheritedType in
            inheritedType.type.trimmedDescription
        } ?? [])

        if inheritedTypeNames.contains(where: NShiftPluginMacroRole.container.protocolNames.contains) {
            return .container
        }

        if inheritedTypeNames.contains(where: NShiftPluginMacroRole.plugin.protocolNames.contains) {
            return .plugin
        }

        return nil
    }

    var hasInitializer: Bool {
        memberBlock.members.contains { member in
            member.decl.is(InitializerDeclSyntax.self)
        }
    }

    var hasStateObjectViewModel: Bool {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .contains { variable in
                variable.definesViewModel && variable.hasStateObjectAttribute
            }
    }

    var stateObjectViewModelType: String? {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .first { variable in
                variable.definesViewModel && variable.hasStateObjectAttribute
            }?
            .viewModelType
    }

    var declaredViewModelType: String? {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .first { variable in
                variable.definesViewModel && variable.hasStateObjectAttribute == false
            }?
            .viewModelType
    }

    var declaresViewModel: Bool {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .contains { variable in
                variable.definesViewModel
            }
    }
}

private extension VariableDeclSyntax {
    var definesViewModel: Bool {
        bindings.contains { binding in
            binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "viewModel"
        }
    }

    var hasStateObjectAttribute: Bool {
        attributes
            .compactMap { $0.as(AttributeSyntax.self) }
            .contains { attributeSyntax in
                let name = attributeSyntax.attributeName.trimmedDescription
                return name == "StateObject" || name == "SwiftUI.StateObject"
            }
    }

    var viewModelType: String? {
        bindings.first?.typeAnnotation?.type.trimmedDescription
    }
}

struct NShiftPluginMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftPluginMacroFailure

    var message: String {
        switch failure {
        case .invalidArguments:
            return "@NShiftPlugin requires name: and version:"
        case .invalidMetadata:
            return "@NShiftPlugin requires metadata: SomeMetadata.self or omit the parameter"
        case .invalidSlots:
            return "@NShiftPlugin requires slots: SomeSlots.self or omit the parameter"
        case .invalidPluginName:
            return "@NShiftPlugin requires name: UpperCamelCase ASCII letters only"
        case .invalidPluginVersion:
            return "@NShiftPlugin requires version: SemVer MAJOR.MINOR.PATCH"
        case .missingExplicitViewModelType:
            return "@NShiftPlugin requires NShiftPluginContainer viewModel to declare an explicit NShiftPluginViewModel type"
        case .missingStateObjectViewModel:
            return "@NShiftPlugin requires NShiftPluginContainer structs to declare a @StateObject viewModel property"
        case .requiresProtocolConformance:
            return "@NShiftPlugin requires the struct to explicitly conform to NShiftPlugin or NShiftPluginContainer"
        case .requiresStruct:
            return "@NShiftPlugin can only be attached to a struct"
        case .authorMustNotDeclareInitializer:
            return "@NShiftPlugin owns the canonical init?; remove the initializer from this struct"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: failure.rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

@main
struct NShiftUIMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NShiftPluginMacro.self,
        NShiftEventMacro.self,
        NShiftPluginAssembleMacro.self,
        NShiftEventAssembleMacro.self,
        NShiftSlotKeyMacro.self,
        NShiftMetadataMacro.self,
        NShiftTokenMetadataMacro.self,
    ]
}
