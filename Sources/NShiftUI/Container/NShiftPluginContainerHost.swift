import NShiftUIDomain
import SwiftUI

@MainActor
struct NShiftPluginContainerHost: View {
    @StateObject private var holder: Holder
    private let rootID: String

    init(model: NShiftPluginModel) {
        NShiftRuntimePrecondition.check(
            NShiftPluginContainerCatalog.shared.contains(model.name),
            "NShiftView requires a plugin model whose name is registered as a plugin container."
        )
        self.rootID = model.id ?? NShiftRenderID.root.rawValue
        self._holder = StateObject(wrappedValue: Holder(model: model))
    }

    var body: some View {
        NShiftNodeView(
            node: engineTree.root,
            engine: engineTree
        )
        .nShiftPluginContainerRegistration(rootID: rootID, engine: holder.engine)
    }

    private var engineTree: any NShiftEngineTree {
        guard let engineTree = holder.engine as? any NShiftEngineTree else {
            NShiftRuntimePrecondition.raise(
                "NShiftView requires an engine that conforms to NShiftEngineTree."
            )
        }
        return engineTree
    }
}

private extension NShiftPluginContainerHost {
    @MainActor
    final class Holder: ObservableObject {
        let engine: any NShiftEngine

        init(model: NShiftPluginModel) {
            self.engine = NShiftEngineResolver.makeEngine(rootModel: model)
        }
    }
}
