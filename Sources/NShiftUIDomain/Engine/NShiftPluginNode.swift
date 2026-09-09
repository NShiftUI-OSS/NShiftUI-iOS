import Combine

@MainActor
public final class NShiftPluginNode: ObservableObject, Identifiable {
    public nonisolated let renderId: NShiftRenderID
    @Published public var model: NShiftPluginModel
    @Published public var children: [NShiftPluginNode]
    @Published public var slotChildren: [NShiftSlotName: [NShiftPluginNode]]
    public weak var parent: NShiftPluginNode?

    public nonisolated var id: NShiftRenderID { renderId }

    public init(
        model: NShiftPluginModel,
        parent: NShiftPluginNode? = nil,
        renderId: NShiftRenderID = .root
    ) {
        self.renderId = renderId
        self.model = model
        self.parent = parent
        self.children = []
        self.slotChildren = [:]

        self.children = model.children.enumerated().map { index, childModel in
            NShiftPluginNode(
                model: childModel,
                parent: self,
                renderId: renderId.appendingChild(at: index)
            )
        }
        self.slotChildren = Dictionary(uniqueKeysWithValues: model.slots.map { name, models in
            (
                name,
                models.enumerated().map { index, childModel in
                    NShiftPluginNode(
                        model: childModel,
                        parent: self,
                        renderId: renderId.appendingSlot(name, at: index)
                    )
                }
            )
        })
    }

    public func replaceChildren(with models: [NShiftPluginModel]) {
        children = models.enumerated().map { index, childModel in
            NShiftPluginNode(
                model: childModel,
                parent: self,
                renderId: renderId.appendingChild(at: index)
            )
        }
    }

    public func replaceSlotChildren(
        _ name: NShiftSlotName,
        with models: [NShiftPluginModel]
    ) {
        var next = slotChildren
        next[name] = models.enumerated().map { index, childModel in
            NShiftPluginNode(
                model: childModel,
                parent: self,
                renderId: renderId.appendingSlot(name, at: index)
            )
        }
        slotChildren = next
    }

    public func replaceAllSlotChildren(
        with slots: [NShiftSlotName: [NShiftPluginModel]]
    ) {
        slotChildren = Dictionary(uniqueKeysWithValues: slots.map { name, models in
            (
                name,
                models.enumerated().map { index, childModel in
                    NShiftPluginNode(
                        model: childModel,
                        parent: self,
                        renderId: renderId.appendingSlot(name, at: index)
                    )
                }
            )
        })
    }
}
