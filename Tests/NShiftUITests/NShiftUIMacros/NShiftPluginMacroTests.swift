import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(NShiftUIMacrosImplementation)
@testable import NShiftUIMacrosImplementation

private let nShiftPluginTestMacros: [String: Macro.Type] = [
    "NShiftPlugin": NShiftPluginMacro.self,
]
#endif

final class NShiftPluginMacroTests: XCTestCase {
    func testPluginMacroAddsPluginMetadataMembers() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton: NShiftPlugin {
                var body: some View {
                    EmptyView()
                }
            }
            """,
            expandedSource: """

struct PrimaryButton: NShiftPlugin {
    var body: some View {
        EmptyView()
    }

    static let name: NShiftUIDomain.NShiftPluginName = "PrimaryButton"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = PrimaryButtonMetadata.self

    private let metadata: PrimaryButtonMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: PrimaryButtonMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension PrimaryButton: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroAcceptsQualifiedPluginConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton: NShiftUIDomain.NShiftPlugin {
            }
            """,
            expandedSource: """

struct PrimaryButton: NShiftUIDomain.NShiftPlugin {

    static let name: NShiftUIDomain.NShiftPluginName = "PrimaryButton"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = PrimaryButtonMetadata.self

    private let metadata: PrimaryButtonMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: PrimaryButtonMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension PrimaryButton: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroDiagnosesAuthorInitializerAndStillEmitsCanonicalInit() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton: NShiftPlugin {
                init(
                    model: NShiftUIDomain.NShiftPluginModel,
                    viewModel: (any NShiftUIDomain.NShiftPluginViewModel)?,
                    resolver: any NShiftUIDomain.NShiftDependencyResolver,
                    eventHandler: any NShiftUIDomain.NShiftEventHandler,
                    engine: (any NShiftUIDomain.NShiftEngine)?,
                    renderID: NShiftUIDomain.NShiftRenderID
                ) {
                    self.metadata = model.metadata
                    self.style = model.style
                    self.pluginChildren = model.children
                    self.slots = model.slots
                    self.events = model.events
                    self.resolver = resolver
                    self.eventHandler = eventHandler
                    self.engine = engine
                    self.renderID = renderID
                }
            }
            """,
            expandedSource: """

struct PrimaryButton: NShiftPlugin {
    init(
        model: NShiftUIDomain.NShiftPluginModel,
        viewModel: (any NShiftUIDomain.NShiftPluginViewModel)?,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID
    ) {
        self.metadata = model.metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }

    static let name: NShiftUIDomain.NShiftPluginName = "PrimaryButton"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = PrimaryButtonMetadata.self

    private let metadata: PrimaryButtonMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: PrimaryButtonMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension PrimaryButton: NShiftPluginWithMetadata {
}
""",
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPlugin owns the canonical init?; remove the initializer from this struct",
                    line: 3,
                    column: 5
                ),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsAttributeWithoutArguments() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires name: and version:", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsEmptyArguments() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin()
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires name: UpperCamelCase ASCII letters only", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsNonUpperCamelCaseName() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "primaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires name: UpperCamelCase ASCII letters only", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsUTF8Name() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "Botão", version: "1.0.0", metadata: ButtonMetadata.self)
            struct Button: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct Button: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires name: UpperCamelCase ASCII letters only", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsNonStringName() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: 123, metadata: ButtonMetadata.self)
            struct Button: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct Button: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires name: UpperCamelCase ASCII letters only", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsInvalidVersion() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires version: SemVer MAJOR.MINOR.PATCH", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroOmitsMetadataTypeWhenMetadataArgumentIsMissing() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0")
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """

struct PrimaryButton: NShiftPlugin {

    static let name: NShiftUIDomain.NShiftPluginName = "PrimaryButton"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    private let metadata: NShiftUIDomain.AnyNShiftMetadata?

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        self.metadata = model.metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsMetadataArgumentWithoutSelf() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata)
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires metadata: SomeMetadata.self or omit the parameter", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsSlotsArgumentWithoutSelf() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "Toolbar", version: "1.0.0", slots: ToolbarSlots)
            struct Toolbar: NShiftPlugin {
            }
            """,
            expandedSource: """
            struct Toolbar: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@NShiftPlugin requires slots: SomeSlots.self or omit the parameter",
                    line: 1,
                    column: 1
                ),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsStructWithoutExplicitPluginConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            struct PrimaryButton {
            }
            """,
            expandedSource: """
            struct PrimaryButton {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires the struct to explicitly conform to NShiftPlugin or NShiftPluginContainer", line: 2, column: 8),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroAddsContainerMembersWhenViewModelIsStateObject() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "FormScreen", version: "1.0.0", metadata: FormScreenMetadata.self)
            struct FormScreen: NShiftPluginContainer {
                @StateObject private var viewModel: FormScreenViewModel

                var body: some View {
                    EmptyView()
                }
            }
            """,
            expandedSource: """

struct FormScreen: NShiftPluginContainer {
    @StateObject private var viewModel: FormScreenViewModel

    var body: some View {
        EmptyView()
    }

    static let name: NShiftUIDomain.NShiftPluginName = "FormScreen"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = FormScreenMetadata.self

    private let metadata: FormScreenMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: FormScreenMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
            guard let viewModel = resolver.resolve(FormScreenViewModel.self) else {
            return nil
            }
            self._viewModel = SwiftUI.StateObject(wrappedValue: viewModel)
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension FormScreen: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroAcceptsQualifiedContainerConformanceAndStateObject() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "FormScreen", version: "1.0.0", metadata: FormScreenMetadata.self)
            struct FormScreen: NShiftUIDomain.NShiftPluginContainer {
                @SwiftUI.StateObject private var viewModel: FormScreenViewModel
            }
            """,
            expandedSource: """

struct FormScreen: NShiftUIDomain.NShiftPluginContainer {
    @SwiftUI.StateObject private var viewModel: FormScreenViewModel

    static let name: NShiftUIDomain.NShiftPluginName = "FormScreen"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = FormScreenMetadata.self

    private let metadata: FormScreenMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: FormScreenMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
            guard let viewModel = resolver.resolve(FormScreenViewModel.self) else {
            return nil
            }
            self._viewModel = SwiftUI.StateObject(wrappedValue: viewModel)
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension FormScreen: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroAddsNormalViewModelStorageForPluginConformance() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "FormScreen", version: "1.0.0", metadata: FormScreenMetadata.self)
            struct FormScreen: NShiftPlugin {
            }
            """,
            expandedSource: """

struct FormScreen: NShiftPlugin {

    static let name: NShiftUIDomain.NShiftPluginName = "FormScreen"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = FormScreenMetadata.self

    private let metadata: FormScreenMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slots: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: FormScreenMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slots = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension FormScreen: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsContainerMissingStateObjectViewModel() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "FormScreen", version: "1.0.0", metadata: FormScreenMetadata.self)
            struct FormScreen: NShiftPluginContainer {
                private var viewModel = FormScreenViewModel()
            }
            """,
            expandedSource: """
            struct FormScreen: NShiftPluginContainer {
                private var viewModel = FormScreenViewModel()
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires NShiftPluginContainer structs to declare a @StateObject viewModel property", line: 2, column: 8),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsContainerViewModelWithoutExplicitType() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "FormScreen", version: "1.0.0", metadata: FormScreenMetadata.self)
            struct FormScreen: NShiftPluginContainer {
                @StateObject private var viewModel = FormScreenViewModel()
            }
            """,
            expandedSource: """
            struct FormScreen: NShiftPluginContainer {
                @StateObject private var viewModel = FormScreenViewModel()
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin requires NShiftPluginContainer viewModel to declare an explicit NShiftPluginViewModel type", line: 2, column: 8),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsNonStructDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            final class PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            final class PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin can only be attached to a struct", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsEnumDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            enum PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            enum PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin can only be attached to a struct", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroRejectsActorDeclaration() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "PrimaryButton", version: "1.0.0", metadata: PrimaryButtonMetadata.self)
            actor PrimaryButton: NShiftPlugin {
            }
            """,
            expandedSource: """
            actor PrimaryButton: NShiftPlugin {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@NShiftPlugin can only be attached to a struct", line: 1, column: 1),
            ],
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroGeneratesTypedSlotMapWhenSlotsArgumentIsProvided() {
        #if canImport(NShiftUIMacrosImplementation)
        assertMacroExpansion(
            """
            @NShiftPlugin(name: "Toolbar", version: "1.0.0", metadata: ToolbarMetadata.self, slots: ToolbarSlots.self)
            struct Toolbar: NShiftPlugin {
                var body: some View {
                    EmptyView()
                }
            }
            """,
            expandedSource: """

struct Toolbar: NShiftPlugin {
    var body: some View {
        EmptyView()
    }

    static let name: NShiftUIDomain.NShiftPluginName = "Toolbar"

    static let version: NShiftUIDomain.NShiftVersion = "1.0.0"

    static let metadataType: any NShiftUIDomain.NShiftMetadata.Type = ToolbarMetadata.self

    private let metadata: ToolbarMetadata

    private let style: NShiftUIDomain.NShiftPluginStyle

    private let pluginChildren: [NShiftUIDomain.NShiftPluginModel]

    private let slotsStorage: [NShiftUIDomain.NShiftSlotName: [NShiftUIDomain.NShiftPluginModel]]

    private var slotsMap: NShiftUIDomain.NShiftSlotMap<ToolbarSlots> {
        NShiftUIDomain.NShiftSlotMap(storage: slotsStorage)
    }

    private func slotModels(_ key: ToolbarSlots) -> [NShiftUIDomain.NShiftPluginModel] {
        slotsMap[key]
    }

    private let events: [NShiftUIDomain.AnyNShiftPluginEvent]

    private let resolver: any NShiftUIDomain.NShiftDependencyResolver

    private let eventHandler: any NShiftUIDomain.NShiftEventHandler

    private let engine: (any NShiftUIDomain.NShiftEngine)?

    private let renderID: NShiftUIDomain.NShiftRenderID

    private var engineTree: any NShiftUIDomain.NShiftEngineTree {
        guard let engineTree = engine as? any NShiftUIDomain.NShiftEngineTree else {
            preconditionFailure("NShiftPlugin children/slots require NShiftEngineTree.")
        }
        return engineTree
    }

    private var childrenAccessor: NShiftUI.NShiftChildrenAccessor {
        NShiftUI.NShiftChildrenAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    private var slotsAccessor: NShiftUI.NShiftSlotsAccessor<ToolbarSlots> {
        NShiftUI.NShiftSlotsAccessor(
            parentRenderID: renderID,
            engine: engineTree
        )
    }

    @SwiftUI.ViewBuilder
    private func slots(_ key: ToolbarSlots) -> some SwiftUI.View {
        slotsAccessor(key)
    }

    @SwiftUI.ViewBuilder
    private func slots<Content: SwiftUI.View>(
        _ key: ToolbarSlots,
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        slotsAccessor(key, transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func slots<Content: SwiftUI.View>(
        _ key: ToolbarSlots,
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        slotsAccessor(key) { _, view in
            transform(view)
        }
    }

    @SwiftUI.ViewBuilder
    private func children() -> some SwiftUI.View {
        childrenAccessor()
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (
            NShiftUIDomain.NShiftPluginModel,
            NShiftUI.NShiftNodeView
        ) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor(transform: transform)
    }

    @SwiftUI.ViewBuilder
    private func children<Content: SwiftUI.View>(
        @SwiftUI.ViewBuilder transform: @escaping (NShiftUI.NShiftNodeView) -> Content
    ) -> some SwiftUI.View {
        childrenAccessor { _, view in
            transform(view)
        }
    }

    init?(
        model: NShiftUIDomain.NShiftPluginModel,
        resolver: any NShiftUIDomain.NShiftDependencyResolver,
        eventHandler: any NShiftUIDomain.NShiftEventHandler,
        engine: (any NShiftUIDomain.NShiftEngine)?,
        renderID: NShiftUIDomain.NShiftRenderID = .root
    ) {
        guard let metadata = model.metadata?.unwrap(as: ToolbarMetadata.self) else {
        return nil
        }
        self.metadata = metadata
        self.style = model.style
        self.pluginChildren = model.children
        self.slotsStorage = model.slots
        self.events = model.events
        self.resolver = resolver
        self.eventHandler = eventHandler
        self.engine = engine
        self.renderID = renderID
    }
}

extension Toolbar: NShiftPluginWithMetadata {
}
""",
            macros: nShiftPluginTestMacros
        )
        #endif
    }

    func testPluginMacroDiagnosticsExposeStableIDsAndSeverity() {
        #if canImport(NShiftUIMacrosImplementation)
        for failure in NShiftPluginMacroFailure.allCases {
            let diagnostic = NShiftPluginMacroDiagnostic(failure: failure)

            _ = diagnostic.diagnosticID
            XCTAssertEqual(diagnostic.severity, .error)
            XCTAssertFalse(diagnostic.message.isEmpty)
        }
        #endif
    }

    func testCompilerPluginPublishesPluginMacro() {
        #if canImport(NShiftUIMacrosImplementation)
        let plugin = NShiftUIMacrosPlugin()

        XCTAssertEqual(plugin.providingMacros.count, 7)
        XCTAssertEqual(ObjectIdentifier(plugin.providingMacros.first!), ObjectIdentifier(NShiftPluginMacro.self))
        #endif
    }
}
