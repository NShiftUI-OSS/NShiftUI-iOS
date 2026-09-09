func unresolvedDependencyMessage(
    serviceType: Any.Type,
    name: String?,
    argumentTypes: [Any.Type]
) -> String {
    let serviceName = String(reflecting: serviceType)
    let dependencyName = name.map { "'\($0)'" } ?? "<default>"
    let arguments = argumentTypes
        .map { String(reflecting: $0) }
        .joined(separator: ", ")

    return "NShiftUI failed to resolve dependency \(serviceName) named \(dependencyName) with arguments [\(arguments)]. Register the dependency or verify the app DI adapter maps it."
}
