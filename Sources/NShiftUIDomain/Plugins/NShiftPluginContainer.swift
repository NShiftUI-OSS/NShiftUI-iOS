import SwiftUI

@MainActor
public protocol NShiftPluginContainer: NShiftPlugin {
    associatedtype ViewModel: NShiftPluginViewModel

    var viewModel: ViewModel { get }
}
