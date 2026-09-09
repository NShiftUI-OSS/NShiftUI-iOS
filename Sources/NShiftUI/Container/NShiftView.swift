import NShiftUIDomain
import SwiftUI

@MainActor
public struct NShiftView: View {
    private let model: NShiftPluginModel

    public init(model: NShiftPluginModel) {
        self.model = model
    }

    public var body: some View {
        NShiftPluginContainerHost(model: model)
    }
}
