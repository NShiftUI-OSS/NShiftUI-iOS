enum NShiftRuntimePrecondition {
    nonisolated(unsafe) private static var handler: (String) -> Never = { message in
        Swift.preconditionFailure(message)
    }

    static func replace(with replacement: @escaping (String) -> Never) {
        handler = replacement
    }

    static func restore() {
        handler = { message in
            Swift.preconditionFailure(message)
        }
    }

    static func raise(_ message: String) -> Never {
        handler(message)
    }

    static func check(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String
    ) {
        if condition() == false {
            raise(message())
        }
    }
}
