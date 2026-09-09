import NShiftUIDomain
import SwiftUI

@MainActor
struct NShiftPluginContainerRegistrationModifier: ViewModifier {
    @StateObject private var token: Token

    init(rootID: String, engine: any NShiftEngine) {
        _token = StateObject(wrappedValue: Token(rootID: rootID, engine: engine))
    }

    func body(content: Content) -> some View {
        content.onAppear {
            token.registerIfNeeded()
        }
    }
}

private extension NShiftPluginContainerRegistrationModifier {
    @MainActor
    final class Token: ObservableObject {
        private let rootID: String
        private let engine: any NShiftEngine
        private var isRegistered = false

        init(rootID: String, engine: any NShiftEngine) {
            self.rootID = rootID
            self.engine = engine
        }

        func registerIfNeeded() {
            guard isRegistered == false else { return }

            NShiftPluginContainerRegistry.shared.register(rootID: rootID, engine: engine)
            isRegistered = true
        }

        deinit {
            let rootID = rootID
            MainActor.assumeIsolated {
                NShiftPluginContainerRegistry.shared.unregister(rootID: rootID)
            }
        }
    }
}

extension View {
    func nShiftPluginContainerRegistration(rootID: String, engine: any NShiftEngine) -> some View {
        modifier(NShiftPluginContainerRegistrationModifier(rootID: rootID, engine: engine))
    }
}
