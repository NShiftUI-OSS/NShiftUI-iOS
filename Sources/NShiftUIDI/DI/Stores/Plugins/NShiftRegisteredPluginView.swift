import NShiftUIDomain
import SwiftUI

public struct NShiftRegisteredPluginView: Sendable {
    public let makeView: @MainActor @Sendable (NShiftPluginModel, NShiftRenderID) -> AnyView

    public init(
        makeView: @escaping @MainActor @Sendable (NShiftPluginModel, NShiftRenderID) -> AnyView
    ) {
        self.makeView = makeView
    }
}
