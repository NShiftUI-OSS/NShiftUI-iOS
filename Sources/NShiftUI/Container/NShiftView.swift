import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftView: View {
    private enum Source {
        case model(NShiftPluginModel)
        case engine(any NShiftEngine)
    }

    private let source: Source

    public init(model: NShiftPluginModel) {
        self.source = .model(model)
    }

    /// Renders an engine created with `NShiftView.makeEngine(for:)`, keeping
    /// its current tree. Hosts use it to retain a screen's live state (appended
    /// children, view model) while the view itself is recreated.
    public init(engine: any NShiftEngine) {
        self.source = .engine(engine)
    }

    public static func makeEngine(for model: NShiftPluginModel) -> any NShiftEngine {
        NShiftRuntimePrecondition.check(
            NShiftPluginContainerCatalog.shared.contains(model.name),
            "NShiftView requires a plugin model whose name is registered as a plugin container."
        )
        return NShiftEngineResolver.makeEngine(rootModel: model)
    }

    public var body: some View {
        switch source {
        case .model(let model):
            NShiftPluginContainerHost(model: model)
        case .engine(let engine):
            NShiftPluginContainerHost(engine: engine)
        }
    }
}
