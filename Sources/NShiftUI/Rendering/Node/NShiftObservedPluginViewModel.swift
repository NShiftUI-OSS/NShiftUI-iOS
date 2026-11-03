import NShiftUIDomain
import SwiftUI

@MainActor
public final class NShiftObservedPluginViewModel: ObservableObject {
    public let base: any NShiftPluginViewModel

    public init(base: any NShiftPluginViewModel) {
        self.base = base
    }
}

@MainActor
public enum NShiftPluginViewModelCascade {
    private static var storage: [ObjectIdentifier: any NShiftPluginViewModel] = [:]

    public static func install(
        _ viewModel: any NShiftPluginViewModel,
        on engine: any NShiftEngine
    ) {
        storage[ObjectIdentifier(engine)] = viewModel
    }

    public static func viewModel(
        on engine: any NShiftEngine
    ) -> (any NShiftPluginViewModel)? {
        storage[ObjectIdentifier(engine)]
    }
}
