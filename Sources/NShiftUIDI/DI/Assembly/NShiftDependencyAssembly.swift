public protocol NShiftDependencyAssembly: Sendable {
    @MainActor func assemblePlugins(in container: any NShiftDependencyContainer)
    func assembleEvents(in container: any NShiftDependencyContainer)
}

public extension NShiftDependencyAssembly {
    @MainActor func assemblePlugins(in container: any NShiftDependencyContainer) {}

    func assembleEvents(in container: any NShiftDependencyContainer) {}
}
