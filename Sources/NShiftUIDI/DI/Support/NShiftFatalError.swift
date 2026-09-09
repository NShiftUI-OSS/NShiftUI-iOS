enum NShiftFatalError {
    nonisolated(unsafe) private static var handler: (@autoclosure () -> String, StaticString, UInt) -> Never = Swift.fatalError

    static func replace(
        with replacement: @escaping (@autoclosure () -> String, StaticString, UInt) -> Never
    ) {
        handler = replacement
    }

    static func restore() {
        handler = Swift.fatalError
    }

    static func raise(
        _ message: @autoclosure () -> String,
        file: StaticString,
        line: UInt
    ) -> Never {
        handler(message(), file, line)
    }
}

func fatalError(
    _ message: @autoclosure () -> String,
    file: StaticString = #fileID,
    line: UInt = #line
) -> Never {
    NShiftFatalError.raise(message(), file: file, line: line)
}
