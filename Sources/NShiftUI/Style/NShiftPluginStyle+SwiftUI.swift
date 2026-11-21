import NShiftUIDomain
import SwiftUI

public struct NShiftColorLookup: @unchecked Sendable {
    public var resolve: (String) -> Color

    public init(resolve: @escaping (String) -> Color) {
        self.resolve = resolve
    }

    public static func hex(_ token: String) -> Color? {
        var hex = token.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }
        guard hex.count == 6 || hex.count == 8, let value = UInt64(hex, radix: 16) else {
            return nil
        }
        let hasAlpha = hex.count == 8
        let red = Double((value >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
        let green = Double((value >> (hasAlpha ? 16 : 8)) & 0xFF) / 255
        let blue = Double((value >> (hasAlpha ? 8 : 0)) & 0xFF) / 255
        let alpha = hasAlpha ? Double(value & 0xFF) / 255 : 1
        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }

    public static let hexOrClear = NShiftColorLookup { token in
        hex(token) ?? .clear
    }
}

private struct NShiftColorLookupKey: EnvironmentKey {
    static let defaultValue = NShiftColorLookup.hexOrClear
}

public extension EnvironmentValues {
    var nShiftColors: NShiftColorLookup {
        get { self[NShiftColorLookupKey.self] }
        set { self[NShiftColorLookupKey.self] = newValue }
    }
}

public extension View {
    func nShiftPluginStyle(_ style: NShiftPluginStyle) -> some View {
        modifier(NShiftPluginStyleModifier(style: style))
    }
}

public struct NShiftPluginStyleModifier: ViewModifier {
    @Environment(\.nShiftColors) private var colors
    private let style: NShiftPluginStyle

    public init(style: NShiftPluginStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        let frame = style.frame
        let styled = content
            .modifier(
                NShiftPluginFixedFrameModifier(
                    width: frame.width.map { CGFloat($0) },
                    height: frame.height.map { CGFloat($0) },
                    enabled: frame.hasFixedWidth || frame.hasFixedHeight
                )
            )
            .modifier(
                NShiftPluginFlexibleFrameModifier(
                    minWidth: frame.minWidth.map { CGFloat($0) },
                    maxWidth: frame.maxWidth.map { CGFloat($0) },
                    minHeight: frame.minHeight.map { CGFloat($0) },
                    maxHeight: frame.maxHeight.map { CGFloat($0) },
                    enabled: frame.hasFlexibleWidth || frame.hasFlexibleHeight
                )
            )
            .modifier(NShiftPluginBackgroundModifier(background: style.background, colors: colors))
            .offset(x: CGFloat(style.offset.x), y: CGFloat(style.offset.y))
            .modifier(NShiftPluginSafeAreaModifier(edges: style.ignoreSafeArea))

        if let animation = style.animation?.swiftUI {
            styled.animation(animation, value: style)
        } else {
            styled
        }
    }
}

extension NShiftSafeAreaEdges {
    var edgeSet: Edge.Set {
        if contains(.all) || self == .all {
            return .all
        }
        var edges = Edge.Set()
        if contains(.top) {
            edges.insert(.top)
        }
        if contains(.bottom) {
            edges.insert(.bottom)
        }
        if contains(.leading) {
            edges.insert(.leading)
        }
        if contains(.trailing) {
            edges.insert(.trailing)
        }
        return edges
    }
}

extension NShiftPluginAnimation {
    var swiftUI: Animation? {
        guard isEnabled else { return nil }
        let duration = Double(durationMillis) / 1000
        let base: Animation
        switch curve {
        case .linear:
            base = .linear(duration: duration)
        case .easeIn:
            base = .easeIn(duration: duration)
        case .easeOut:
            base = .easeOut(duration: duration)
        case .easeInOut:
            base = .easeInOut(duration: duration)
        }
        guard delayMillis > 0 else { return base }
        return base.delay(Double(delayMillis) / 1000)
    }
}

private struct NShiftPluginBackgroundModifier: ViewModifier {
    let background: NShiftPluginBackground?
    let colors: NShiftColorLookup

    func body(content: Content) -> some View {
        if let colorName = background?.color, !colorName.isEmpty {
            let color = colors.resolve(colorName)
            let edges = background?.ignoreSafeArea.edgeSet ?? []
            if edges.isEmpty {
                content.background(color)
            } else {
                content.background(color.ignoresSafeArea(edges: edges))
            }
        } else {
            content
        }
    }
}

private struct NShiftPluginSafeAreaModifier: ViewModifier {
    let edges: NShiftSafeAreaEdges

    func body(content: Content) -> some View {
        if edges.isEmpty {
            content
        } else {
            content.ignoresSafeArea(edges: edges.edgeSet)
        }
    }
}

private struct NShiftPluginFixedFrameModifier: ViewModifier {
    let width: CGFloat?
    let height: CGFloat?
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.frame(width: width, height: height, alignment: .center)
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
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.frame(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
                alignment: .center
            )
        } else {
            content
        }
    }
}
