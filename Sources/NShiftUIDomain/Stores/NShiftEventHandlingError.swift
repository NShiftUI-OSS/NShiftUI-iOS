public struct NShiftEventHandlingError: Error, Equatable, Sendable, CustomStringConvertible {
    public let eventID: String
    public let eventName: String
    public let trigger: String
    public let reason: NShiftEventHandlingFailureReason

    public var description: String {
        "Failed to handle event '\(eventName)' (id: \(eventID), trigger: \(trigger)): \(reason.description)"
    }

    public init(
        eventID: String,
        eventName: String,
        trigger: String,
        reason: NShiftEventHandlingFailureReason
    ) {
        self.eventID = eventID
        self.eventName = eventName
        self.trigger = trigger
        self.reason = reason
    }

    public init(
        event: NShiftEventModel,
        reason: NShiftEventHandlingFailureReason
    ) {
        self.init(
            eventID: event.id,
            eventName: event.name.rawValue,
            trigger: event.trigger.rawValue,
            reason: reason
        )
    }
}

public enum NShiftEventHandlingFailureReason: Equatable, Sendable, CustomStringConvertible {
    case actionNotFound
    case actionFailed(String)
    case initializationFailed

    public var description: String {
        switch self {
        case .actionNotFound:
            "event action was not registered"
        case .actionFailed(let message):
            "event action failed with error: \(message)"
        case .initializationFailed:
            "event init? returned nil"
        }
    }
}

package struct NShiftEventInitializationError: Error, Sendable {
    package init() {}
}
