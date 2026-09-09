public struct NShiftPluginFrame: Equatable, Hashable, Sendable {
    public let width: Double?
    public let height: Double?
    public let minWidth: Double?
    public let maxWidth: Double?
    public let minHeight: Double?
    public let maxHeight: Double?

    public init() {
        self.width = nil
        self.height = nil
        self.minWidth = nil
        self.maxWidth = nil
        self.minHeight = nil
        self.maxHeight = nil
    }

    public init(
        width: Double? = nil,
        height: Double? = nil,
        minWidth: NShiftPluginDimension? = nil,
        maxWidth: NShiftPluginDimension? = nil,
        minHeight: NShiftPluginDimension? = nil,
        maxHeight: NShiftPluginDimension? = nil
    ) throws(NShiftPluginFrameError) {
        try Self.validate(
            width: width,
            height: height,
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight
        )

        self.width = width
        self.height = height
        self.minWidth = minWidth?.doubleValue
        self.maxWidth = maxWidth?.doubleValue
        self.minHeight = minHeight?.doubleValue
        self.maxHeight = maxHeight?.doubleValue
    }

    public var hasFixedWidth: Bool {
        width != nil
    }

    public var hasFixedHeight: Bool {
        height != nil
    }

    public var hasFlexibleWidth: Bool {
        minWidth != nil || maxWidth != nil
    }

    public var hasFlexibleHeight: Bool {
        minHeight != nil || maxHeight != nil
    }

    private static func validate(
        width: Double?,
        height: Double?,
        minWidth: NShiftPluginDimension?,
        maxWidth: NShiftPluginDimension?,
        minHeight: NShiftPluginDimension?,
        maxHeight: NShiftPluginDimension?
    ) throws(NShiftPluginFrameError) {
        if width != nil, minWidth != nil || maxWidth != nil {
            throw .fixedWidthConflictsWithFlexibleConstraints
        }

        if height != nil, minHeight != nil || maxHeight != nil {
            throw .fixedHeightConflictsWithFlexibleConstraints
        }

        if minWidth == .fill {
            throw .fillNotAllowedForMinWidth
        }

        if minHeight == .fill {
            throw .fillNotAllowedForMinHeight
        }

        if case let .value(minimum) = minWidth, case let .value(maximum) = maxWidth, minimum > maximum {
            throw .contradictoryWidthConstraints
        }

        if case let .value(minimum) = minHeight, case let .value(maximum) = maxHeight, minimum > maximum {
            throw .contradictoryHeightConstraints
        }
    }
}

public enum NShiftPluginFrameError: Error, Equatable, Sendable {
    case fixedWidthConflictsWithFlexibleConstraints
    case fixedHeightConflictsWithFlexibleConstraints
    case fillNotAllowedForMinWidth
    case fillNotAllowedForMinHeight
    case contradictoryWidthConstraints
    case contradictoryHeightConstraints
}
