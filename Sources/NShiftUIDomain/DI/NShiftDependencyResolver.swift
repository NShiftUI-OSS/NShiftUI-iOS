public protocol NShiftDependencyResolver: Sendable {
    func resolve<Service>(
        _ serviceType: Service.Type,
        name: String?,
        argumentTypes: [Any.Type],
        arguments: [Any]
    ) -> Service?
}
