import SwiftUI

@MainActor
public protocol NShiftPlugin: View {
    static var name: NShiftPluginName { get }
    static var version: NShiftVersion { get }

    init?(
        model: NShiftPluginModel,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    )

    static func make(
        model: NShiftPluginModel,
        viewModel: (any NShiftPluginViewModel)?,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    ) -> Self?
}

public extension NShiftPlugin {
    static func make(
        model: NShiftPluginModel,
        viewModel: (any NShiftPluginViewModel)?,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    ) -> Self? {
        _ = viewModel
        return Self(
            model: model,
            resolver: resolver,
            eventHandler: eventHandler,
            engine: engine,
            renderID: renderID
        )
    }
}

@MainActor
public protocol NShiftPluginWithViewModel: NShiftPlugin {
    var viewModel: (any NShiftPluginViewModel)? { get }

    init?(
        model: NShiftPluginModel,
        viewModel: (any NShiftPluginViewModel)?,
        resolver: any NShiftDependencyResolver,
        eventHandler: any NShiftEventHandler,
        engine: (any NShiftEngine)?,
        renderID: NShiftRenderID
    )
}

public extension NShiftPluginWithViewModel {
    func optionalViewModel<ViewModel: NShiftPluginViewModel>(
        as type: ViewModel.Type
    ) -> ViewModel? {
        _ = type
        return viewModel as? ViewModel
    }
}

public extension NShiftEngine {
    func optionalPluginViewModel<ViewModel: NShiftPluginViewModel>(
        as type: ViewModel.Type
    ) -> ViewModel? {
        _ = type
        return pluginViewModel as? ViewModel
    }
}

public protocol NShiftPluginWithMetadata: NShiftPlugin {
    static var metadataType: any NShiftMetadata.Type { get }
}
