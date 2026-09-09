import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NShiftEventMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        NShiftEventMemberExpansion.expand(
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
        try NShiftEventExtensionExpansion.expand(
            node: node,
            declaration: declaration,
            type: type,
            context: context
        )
    }
}

enum NShiftEventMacroFailure: String, CaseIterable, Error {
    case invalidArguments
    case invalidEventName
    case invalidEventVersion
    case invalidMetadata
    case invalidSlots
    case requiresNShiftEventConformance
    case requiresStruct
    case authorMustNotDeclareInitializer
}

enum NShiftEventMacroMetadataArgument {
    case omitted
    case invalid
    case type(String)
}

private enum NShiftEventMemberExpansion {
    static let eventProtocolNames: Set<String> = [
        "NShiftEvent",
        "NShiftUIDomain.NShiftEvent",
    ]

    static func expand(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) -> [DeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .requiresStruct)))
            return []
        }

        guard structDeclaration.conformsToNShiftEvent else {
            context.diagnose(Diagnostic(node: Syntax(structDeclaration.name), message: NShiftEventMacroDiagnostic(failure: .requiresNShiftEventConformance)))
            return []
        }

        guard let arguments = node.argumentList else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .invalidArguments)))
            return []
        }

        guard let name = eventName(from: arguments) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .invalidEventName)))
            return []
        }

        guard let version = eventVersion(from: arguments) else {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .invalidEventVersion)))
            return []
        }

        let metadataArgument = metadataType(from: arguments)
        if case .invalid = metadataArgument {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .invalidMetadata)))
            return []
        }

        let slotsKeyType: String?
        do {
            slotsKeyType = try slotsType(from: arguments)
        } catch {
            context.diagnose(Diagnostic(node: Syntax(node), message: NShiftEventMacroDiagnostic(failure: .invalidSlots)))
            return []
        }

        let typedMetadataType: String?
        if case let .type(metadataType) = metadataArgument {
            typedMetadataType = metadataType
        } else {
            typedMetadataType = nil
        }

        var members: [DeclSyntax] = [
            "static let name: NShiftUIDomain.NShiftEventName = \(literal: name)",
            "static let version: NShiftUIDomain.NShiftVersion = \(literal: version)",
        ]

        if let typedMetadataType {
            members.append(
                "static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = \(raw: typedMetadataType).self"
            )
            members.append("private let metadata: \(raw: typedMetadataType)")
        } else {
            members.append("private let metadata: NShiftUIDomain.AnyNShiftMetadata?")
        }

        let slotsAssignment: String
        if let slotsKeyType {
            members.append(contentsOf: [
                "private let slotsStorage: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]",
                """
                private var slots: NShiftUIDomain.NShiftSlotMap<\(raw: slotsKeyType)> {
                    NShiftUIDomain.NShiftSlotMap(storage: slotsStorage)
                }
                """,
                """
                private func slotModels(_ key: \(raw: slotsKeyType)) -> [NShiftUIDomain.NShiftPluginModel] {
                    slots[key]
                }
                """,
            ])
            slotsAssignment = "self.slotsStorage = model.slots"
        } else {
            members.append(
                "private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]"
            )
            slotsAssignment = "self.slots = model.slots"
        }

        members.append("private let events: [NShiftUIDomain.AnyNShiftPluginEvent]")

        let declaredViewModelType = structDeclaration.declaredViewModelType
        if let declaredViewModelType, structDeclaration.declaresViewModel == false {
            members.append("private let viewModel: \(raw: declaredViewModelType)")
        }

        members.append(contentsOf: [
            "private let eventHandler: any NShiftUIDomain.NShiftEventHandler",
            "private let resolver: any NShiftUIDomain.NShiftDependencyResolver",
            "private let engine: (any NShiftUIDomain.NShiftEngine)?",
        ])

        let metadataBlock: String
        if let typedMetadataType {
            metadataBlock = "guard let metadata = model.metadata?.unwrap(as: \(typedMetadataType).self) else {\n        return nil\n        }\n        self.metadata = metadata"
        } else {
            metadataBlock = "self.metadata = model.metadata"
        }

        let viewModelInsertion: String
        if let declaredViewModelType {
            viewModelInsertion = "\n        guard let viewModel = resolver.resolve(\(declaredViewModelType).self) else {\n        return nil\n        }\n        self.viewModel = viewModel"
        } else {
            viewModelInsertion = ""
        }

        if structDeclaration.hasInitializer {
            if let initializer = structDeclaration.memberBlock.members
                .compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
                .first {
                context.diagnose(
                    Diagnostic(
                        node: Syntax(initializer),
                        message: NShiftEventMacroDiagnostic(failure: .authorMustNotDeclareInitializer)
                    )
                )
            }
        }

        let initializer = """
            init?(
                model: NShiftUIDomain.NShiftEventModel,
                resolver: any NShiftUIDomain.NShiftDependencyResolver
            ) {
                \(metadataBlock)
                \(slotsAssignment)
                self.events = model.events.map(NShiftUIDomain.AnyNShiftPluginEvent.init)\(viewModelInsertion)
                self.resolver = resolver
                self.eventHandler = resolver.resolveUnwrapping(NShiftUIDomain.NShiftEventHandler.self)
                self.engine = resolver.resolve(NShiftUIDomain.NShiftEngine.self)
            }
            """
        members.append(DeclSyntax(stringLiteral: initializer))

        return members
    }

    static func eventName(from arguments: LabeledExprListSyntax) -> String? {
        guard let expression = arguments.first(where: { $0.label?.text == "name" })?.expression,
              let literal = expression.as(StringLiteralExprSyntax.self),
              literal.segments.count == 1,
              let segment = literal.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let name = segment.content.text
        return isValidEventName(name) ? name : nil
    }

    static func eventVersion(from arguments: LabeledExprListSyntax) -> String? {
        guard let expression = arguments.first(where: { $0.label?.text == "version" })?.expression,
              let literal = expression.as(StringLiteralExprSyntax.self),
              literal.segments.count == 1,
              let segment = literal.segments.first?.as(StringSegmentSyntax.self) else {
            return nil
        }

        let version = segment.content.text
        return NShiftSemVerValidation.isValid(version) ? version : nil
    }

    static func metadataType(from arguments: LabeledExprListSyntax) -> NShiftEventMacroMetadataArgument {
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
            throw NShiftEventMacroFailure.invalidSlots
        }

        return String(slotsExpression.dropLast(5))
    }

    private static func isValidEventName(_ name: String) -> Bool {
        guard let first = name.unicodeScalars.first,
              (65...90).contains(first.value) else {
            return false
        }

        return name.unicodeScalars.allSatisfy { scalar in
            (65...90).contains(scalar.value) || (97...122).contains(scalar.value)
        }
    }
}

private enum NShiftEventExtensionExpansion {
    static func expand(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let structDeclaration = declaration.as(StructDeclSyntax.self),
              structDeclaration.conformsToNShiftEvent,
              let arguments = node.argumentList,
              case .type = NShiftEventMemberExpansion.metadataType(from: arguments),
              NShiftEventMemberExpansion.eventName(from: arguments) != nil,
              NShiftEventMemberExpansion.eventVersion(from: arguments) != nil else {
            return []
        }

        do {
            _ = try NShiftEventMemberExpansion.slotsType(from: arguments)
        } catch {
            return []
        }

        let typeName = type.trimmedDescription
        return [
            try ExtensionDeclSyntax(
                """
                extension \(raw: typeName): NShiftEventWithMetadata {
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
    var conformsToNShiftEvent: Bool {
        let inheritedTypeNames = inheritanceClause?.inheritedTypes.map {
            $0.type.trimmedDescription
        } ?? []

        return inheritedTypeNames.contains(where: NShiftEventMemberExpansion.eventProtocolNames.contains)
    }

    var hasInitializer: Bool {
        memberBlock.members.contains { member in
            member.decl.is(InitializerDeclSyntax.self)
        }
    }

    var declaredViewModelType: String? {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .first { variable in
                variable.bindings.contains { binding in
                    binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "viewModel"
                }
            }?
            .bindings.first?.typeAnnotation?.type.trimmedDescription
    }

    var declaresViewModel: Bool {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .contains { variable in
                variable.bindings.contains { binding in
                    binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "viewModel"
                }
            }
    }
}

struct NShiftEventMacroDiagnostic: DiagnosticMessage {
    let failure: NShiftEventMacroFailure

    var message: String {
        switch failure {
        case .invalidArguments:
            return "@NShiftEvent requires name: and version:"
        case .invalidEventName:
            return "@NShiftEvent requires name: UpperCamelCase ASCII letters only"
        case .invalidEventVersion:
            return "@NShiftEvent requires version: SemVer MAJOR.MINOR.PATCH"
        case .invalidMetadata:
            return "@NShiftEvent requires metadata: SomeMetadata.self or omit the parameter"
        case .invalidSlots:
            return "@NShiftEvent requires slots: SomeSlots.self or omit the parameter"
        case .requiresNShiftEventConformance:
            return "@NShiftEvent requires the struct to explicitly conform to NShiftEvent"
        case .requiresStruct:
            return "@NShiftEvent can only be attached to a struct"
        case .authorMustNotDeclareInitializer:
            return "@NShiftEvent owns the canonical init?; remove the initializer from this struct"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "NShiftUIMacros", id: failure.rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
