struct NShiftDependencyFactory: Sendable {
    let resolve: @Sendable ([Any]) -> Any?
}
