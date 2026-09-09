import NShiftUIDomain
import Testing

@Test func pluginStyleStoresFrameAndAlignment() throws {
    let frame = try NShiftPluginFrame(width: 320, height: nil)
    let style = NShiftPluginStyle(frame: frame, alignment: .topLeading)

    #expect(style.frame == frame)
    #expect(style.alignment == .topLeading)
}

@Test func pluginStyleDefaultsToFlexibleFrameCenterAlignmentAndZeroSpacing() {
    let style = NShiftPluginStyle()

    #expect(style.frame == NShiftPluginFrame())
    #expect(style.alignment == .center)
    #expect(style.spacing == 0)
}

@Test func pluginStyleStoresSpacing() {
    let style = NShiftPluginStyle(spacing: 16)

    #expect(style.spacing == 16)
}

@Test func pluginFrameDefaultsToFlexibleDimensions() {
    let frame = NShiftPluginFrame()

    #expect(frame.width == nil)
    #expect(frame.minWidth == nil)
    #expect(frame.maxWidth == nil)
    #expect(frame.height == nil)
    #expect(frame.minHeight == nil)
    #expect(frame.maxHeight == nil)
}

@Test func pluginFrameAcceptsFixedDimensions() throws {
    let frame = try NShiftPluginFrame(width: 120, height: 48)

    #expect(frame.width == 120)
    #expect(frame.height == 48)
    #expect(frame.hasFixedWidth)
    #expect(frame.hasFixedHeight)
    #expect(frame.hasFlexibleWidth == false)
    #expect(frame.hasFlexibleHeight == false)
}

@Test func pluginFrameAcceptsFlexibleDimensionsWithFill() throws {
    let frame = try NShiftPluginFrame(minWidth: 44, maxWidth: .fill, maxHeight: .fill)

    #expect(frame.minWidth == 44)
    #expect(frame.maxWidth == .infinity)
    #expect(frame.maxHeight == .infinity)
}

@Test func pluginFrameAcceptsFixedWidthWithFlexibleHeight() throws {
    let frame = try NShiftPluginFrame(width: 100, minHeight: 40, maxHeight: 80)

    #expect(frame.width == 100)
    #expect(frame.minHeight == 40)
    #expect(frame.maxHeight == 80)
}

@Test func pluginFrameRejectsFixedWidthWithFlexibleWidthConstraints() {
    #expect(throws: NShiftPluginFrameError.fixedWidthConflictsWithFlexibleConstraints) {
        try NShiftPluginFrame(width: 100, maxWidth: .fill)
    }
}

@Test func pluginFrameRejectsFixedHeightWithFlexibleHeightConstraints() {
    #expect(throws: NShiftPluginFrameError.fixedHeightConflictsWithFlexibleConstraints) {
        try NShiftPluginFrame(height: 50, minHeight: 20)
    }
}

@Test func pluginFrameRejectsFillForMinWidth() {
    #expect(throws: NShiftPluginFrameError.fillNotAllowedForMinWidth) {
        try NShiftPluginFrame(minWidth: .fill)
    }
}

@Test func pluginFrameRejectsFillForMinHeight() {
    #expect(throws: NShiftPluginFrameError.fillNotAllowedForMinHeight) {
        try NShiftPluginFrame(minHeight: .fill)
    }
}

@Test func pluginFrameRejectsContradictoryWidthConstraints() {
    #expect(throws: NShiftPluginFrameError.contradictoryWidthConstraints) {
        try NShiftPluginFrame(minWidth: 200, maxWidth: 100)
    }
}

@Test func pluginFrameRejectsContradictoryHeightConstraints() {
    #expect(throws: NShiftPluginFrameError.contradictoryHeightConstraints) {
        try NShiftPluginFrame(minHeight: 80, maxHeight: 40)
    }
}

@Test func pluginDimensionLiteralsProduceValues() {
    let integer: NShiftPluginDimension = 44
    let floating: NShiftPluginDimension = 12.5

    #expect(integer == .value(44))
    #expect(floating == .value(12.5))
    #expect(NShiftPluginDimension.fill.doubleValue == .infinity)
}

@Test func pluginAlignmentIncludesCommonPositions() {
    #expect(NShiftPluginAlignment.allCases == [
        .topLeading,
        .top,
        .topTrailing,
        .leading,
        .center,
        .trailing,
        .bottomLeading,
        .bottom,
        .bottomTrailing,
    ])
}
