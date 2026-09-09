import NShiftUIDomain
import SwiftUI

public extension View {
    func nShiftPluginStyle(_ style: NShiftPluginStyle) -> some View {
        modifier(NShiftPluginStyleModifier(style: style))
    }
}

public struct NShiftPluginStyleModifier: ViewModifier {
    private let style: NShiftPluginStyle

    public init(style: NShiftPluginStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        let frame = style.frame
        let alignment = style.alignment.swiftUIAlignment

        content
            .modifier(
                NShiftPluginFixedFrameModifier(
                    width: frame.width.map { CGFloat($0) },
                    height: frame.height.map { CGFloat($0) },
                    alignment: alignment,
                    enabled: frame.hasFixedWidth || frame.hasFixedHeight
                )
            )
            .modifier(
                NShiftPluginFlexibleFrameModifier(
                    minWidth: frame.minWidth.map { CGFloat($0) },
                    maxWidth: frame.maxWidth.map { CGFloat($0) },
                    minHeight: frame.minHeight.map { CGFloat($0) },
                    maxHeight: frame.maxHeight.map { CGFloat($0) },
                    alignment: alignment,
                    enabled: frame.hasFlexibleWidth || frame.hasFlexibleHeight
                )
            )
    }
}

private struct NShiftPluginFixedFrameModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    let alignment: Alignment
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.frame(width: width, height: height, alignment: alignment)
        } else {
            content
        }
    }
}

private struct NShiftPluginFlexibleFrameModifier: ViewModifier {
    let minWidth: CGFloat?
    let maxWidth: CGFloat?
    let minHeight: CGFloat?
    let maxHeight: CGFloat?
    let alignment: Alignment
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.frame(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
                alignment: alignment
            )
        } else {
            content
        }
    }
}
