import NShiftUIDomain

@MainActor
public extension NShiftDependencyRegistering {
    func registerEngine(
        factory: @escaping @MainActor (_ rootModel: NShiftPluginModel) -> any NShiftEngine
    ) {
        register(
            (any NShiftEngine).self,
            name: nil,
            argumentTypes: [NShiftPluginModel.self]
        ) { arguments in
            guard let rootModel = arguments.first as? NShiftPluginModel else { return nil }
            return MainActor.assumeIsolated {
                factory(rootModel)
            }
        }
    }
}
