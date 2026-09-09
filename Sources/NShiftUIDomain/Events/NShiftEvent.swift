public protocol NShiftEvent {
    static var name: NShiftEventName { get }
    static var version: NShiftVersion { get }

    init?(
        model: NShiftEventModel,
        resolver: any NShiftDependencyResolver
    )

    func execute() async throws
}

public protocol NShiftEventWithMetadata: NShiftEvent {
    static var metadataType: any NShiftMetadata.Type { get }
}
