extension NShiftDependencyAssembly {
    @MainActor func assemble(in container: any NShiftDependencyContainer) {
        assemblePlugins(in: container)
        assembleEvents(in: container)
    }
}
