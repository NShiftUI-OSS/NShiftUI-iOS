
public struct NShiftSlotMap<Key: NShiftSlotKey>: Equatable, Sendable {
    private let storage: [NShiftSlotName: [NShiftPluginModel]]

    public init(storage: [NShiftSlotName: [NShiftPluginModel]] = [:]) {
        self.storage = storage
    }

    public subscript(_ key: Key) -> [NShiftPluginModel] {
        storage[key.slotName] ?? []
    }

    public var untyped: [NShiftSlotName: [NShiftPluginModel]] {
        storage
    }
}
