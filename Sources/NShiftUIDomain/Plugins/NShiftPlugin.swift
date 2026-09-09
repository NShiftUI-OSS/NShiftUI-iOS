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
}

public protocol NShiftPluginWithMetadata: NShiftPlugin {
    static var metadataType: any NShiftMetadata.Type { get }
}
