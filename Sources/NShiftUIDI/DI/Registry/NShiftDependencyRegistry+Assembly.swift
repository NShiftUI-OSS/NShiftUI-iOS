public extension NShiftDependencyRegistry {
    @MainActor func apply(_ assembly: any NShiftDependencyAssembly) {
        assembly.assemble(in: self)
    }

    @MainActor func apply(_ assemblies: [any NShiftDependencyAssembly]) {
        assemblies.forEach { $0.assemble(in: self) }
    }
}
