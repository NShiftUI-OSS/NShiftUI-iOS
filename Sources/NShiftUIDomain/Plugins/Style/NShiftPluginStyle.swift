import CoreGraphics

public struct NShiftPluginStyle: Equatable, Hashable, Sendable {
    public let frame: NShiftPluginFrame
    public let alignment: NShiftPluginAlignment
    public let spacing: CGFloat

    public init(
        frame: NShiftPluginFrame = NShiftPluginFrame(),
        alignment: NShiftPluginAlignment = .center,
        spacing: CGFloat = 0
    ) {
        self.frame = frame
        self.alignment = alignment
        self.spacing = spacing
    }
}
