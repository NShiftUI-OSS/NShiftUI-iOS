struct NShiftDependencyKey: Hashable, Sendable {
    let serviceIdentifier: ObjectIdentifier
    let name: String?
    let argumentTypeIdentifiers: [ObjectIdentifier]

    init(
        serviceType: Any.Type,
        name: String?,
        argumentTypes: [Any.Type]
    ) {
        self.serviceIdentifier = ObjectIdentifier(serviceType)
        self.name = name
        self.argumentTypeIdentifiers = argumentTypes.map(ObjectIdentifier.init)
    }
}
