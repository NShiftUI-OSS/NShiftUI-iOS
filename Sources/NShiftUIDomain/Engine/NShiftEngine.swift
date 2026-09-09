import SwiftUI

@MainActor
public protocol NShiftEngine: AnyObject, Sendable {
    var rootID: String { get }

    func handle(
        _ trigger: NShiftTrigger,
        onPluginID pluginID: String
    ) async

    func replaceMetadata(pluginID: String, with metadata: AnyNShiftMetadata?)
    func replacePlugin(pluginID: String, with model: NShiftPluginModel)
    func replaceChildren(pluginID: String, with children: [NShiftPluginModel])
    func replaceSlots(pluginID: String, with slots: [NShiftSlotName: [NShiftPluginModel]])
    func replaceSlot(pluginID: String, name: NShiftSlotName, with models: [NShiftPluginModel])
    func replaceEvents(pluginID: String, with events: [NShiftEventModel])
    func replaceEvent(eventID: String, with event: NShiftEventModel)
}
