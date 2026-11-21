import CoreGraphics

public struct NShiftSafeAreaEdges: OptionSet, Hashable, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = NShiftSafeAreaEdges(rawValue: 1 << 0)
    public static let bottom = NShiftSafeAreaEdges(rawValue: 1 << 1)
    public static let leading = NShiftSafeAreaEdges(rawValue: 1 << 2)
    public static let trailing = NShiftSafeAreaEdges(rawValue: 1 << 3)
    public static let all: NShiftSafeAreaEdges = [.top, .bottom, .leading, .trailing]

    public static func parse(_ tokens: [String]) -> NShiftSafeAreaEdges {
        let names = tokens.map { $0.hasPrefix(".") ? String($0.dropFirst()) : $0 }
        if names.contains("all") {
            return .all
        }
        var edges = NShiftSafeAreaEdges()
        for name in names {
            switch name {
            case "top":
                edges.insert(.top)
            case "bottom":
                edges.insert(.bottom)
            case "leading":
                edges.insert(.leading)
            case "trailing":
                edges.insert(.trailing)
            default:
                break
            }
        }
        return edges
    }
}

public struct NShiftPluginPadding: Equatable, Hashable, Sendable {
    public var top: Int?
    public var leading: Int?
    public var trailing: Int?
    public var horizontal: Int?
    public var vertical: Int?
    public var bottom: Int?

    public init(
        top: Int? = nil,
        leading: Int? = nil,
        trailing: Int? = nil,
        horizontal: Int? = nil,
        vertical: Int? = nil,
        bottom: Int? = nil
    ) {
        self.top = top
        self.leading = leading
        self.trailing = trailing
        self.horizontal = horizontal
        self.vertical = vertical
        self.bottom = bottom
    }

    public static let zero = NShiftPluginPadding()

    public var resolvedTop: Int { top ?? vertical ?? 0 }
    public var resolvedBottom: Int { bottom ?? vertical ?? 0 }
    public var resolvedLeading: Int { leading ?? horizontal ?? 0 }
    public var resolvedTrailing: Int { trailing ?? horizontal ?? 0 }

    public var isZero: Bool {
        resolvedTop == 0 && resolvedBottom == 0 && resolvedLeading == 0 && resolvedTrailing == 0
    }
}

public struct NShiftPluginOffset: Equatable, Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    public static let zero = NShiftPluginOffset()
}

public struct NShiftPluginBackground: Equatable, Hashable, Sendable {
    public var color: String?
    public var ignoreSafeArea: NShiftSafeAreaEdges

    public init(
        color: String? = nil,
        ignoreSafeArea: NShiftSafeAreaEdges = []
    ) {
        self.color = color
        self.ignoreSafeArea = ignoreSafeArea
    }
}

public enum NShiftAnimationCurve: String, CaseIterable, Equatable, Hashable, Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

public struct NShiftPluginAnimation: Equatable, Hashable, Sendable {
    public var isEnabled: Bool
    public var durationMillis: Int
    public var delayMillis: Int
    public var curve: NShiftAnimationCurve

    public init(
        isEnabled: Bool = false,
        durationMillis: Int = 300,
        delayMillis: Int = 0,
        curve: NShiftAnimationCurve = .easeInOut
    ) {
        self.isEnabled = isEnabled
        self.durationMillis = durationMillis
        self.delayMillis = delayMillis
        self.curve = curve
    }
}

public struct NShiftPluginStyle: Equatable, Hashable, Sendable {
    public let frame: NShiftPluginFrame
    public let background: NShiftPluginBackground?
    public let padding: NShiftPluginPadding
    public let ignoreSafeArea: NShiftSafeAreaEdges
    public let offset: NShiftPluginOffset
    public let animation: NShiftPluginAnimation?

    public init(
        frame: NShiftPluginFrame = NShiftPluginFrame(),
        background: NShiftPluginBackground? = nil,
        padding: NShiftPluginPadding = .zero,
        ignoreSafeArea: NShiftSafeAreaEdges = [],
        offset: NShiftPluginOffset = .zero,
        animation: NShiftPluginAnimation? = nil
    ) {
        self.frame = frame
        self.background = background
        self.padding = padding
        self.ignoreSafeArea = ignoreSafeArea
        self.offset = offset
        self.animation = animation
    }
}
