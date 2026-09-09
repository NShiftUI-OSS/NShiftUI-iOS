public extension NShiftPluginModel {
    func replacingMetadata(_ metadata: AnyNShiftMetadata?) -> NShiftPluginModel {
        NShiftPluginModel(
            id: id,
            name: name,
            version: version,
            metadata: metadata,
            style: style,
            children: children,
            slots: slots,
            events: events.compactMap(\.event)
        )
    }

    func replacingEvents(_ events: [NShiftEventModel]) -> NShiftPluginModel {
        NShiftPluginModel(
            id: id,
            name: name,
            version: version,
            metadata: metadata,
            style: style,
            children: children,
            slots: slots,
            events: events
        )
    }

    func replacingChildren(_ children: [NShiftPluginModel]) -> NShiftPluginModel {
        NShiftPluginModel(
            id: id,
            name: name,
            version: version,
            metadata: metadata,
            style: style,
            children: children,
            slots: slots,
            events: events.compactMap(\.event)
        )
    }

    func replacingSlots(_ slots: [NShiftSlotName: [NShiftPluginModel]]) -> NShiftPluginModel {
        NShiftPluginModel(
            id: id,
            name: name,
            version: version,
            metadata: metadata,
            style: style,
            children: children,
            slots: slots,
            events: events.compactMap(\.event)
        )
    }

    func replacingSlot(
        _ name: NShiftSlotName,
        with models: [NShiftPluginModel]
    ) -> NShiftPluginModel {
        var next = slots
        next[name] = models
        return replacingSlots(next)
    }
}
