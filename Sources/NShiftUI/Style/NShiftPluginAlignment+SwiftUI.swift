import NShiftUIDomain
import SwiftUI

public extension NShiftPluginAlignment {
    var swiftUIAlignment: Alignment {
        switch self {
        case .topLeading:
            .topLeading
        case .top:
            .top
        case .topTrailing:
            .topTrailing
        case .leading:
            .leading
        case .center:
            .center
        case .trailing:
            .trailing
        case .bottomLeading:
            .bottomLeading
        case .bottom:
            .bottom
        case .bottomTrailing:
            .bottomTrailing
        }
    }
}
