public protocol NShiftDependencyRegistering: Sendable {
    func register<Service>(
        _ serviceType: Service.Type,
        name: String?,
        scope: NShiftDependencyScope,
        argumentTypes: [Any.Type],
        factory: @escaping @Sendable ([Any]) -> Service?
    )
}

public extension NShiftDependencyRegistering {
    func register<Service>(
        _ serviceType: Service.Type,
        name: String?,
        argumentTypes: [Any.Type],
        factory: @escaping @Sendable ([Any]) -> Service?
    ) {
        register(
            serviceType,
            name: name,
            scope: .transient,
            argumentTypes: argumentTypes,
            factory: factory
        )
    }
}
