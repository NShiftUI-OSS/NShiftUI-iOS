import Dispatch
import Foundation
@testable import NShiftUI

final class NShiftRuntimePreconditionCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: String?

    var message: String? {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }

    func store(_ message: String) {
        lock.lock()
        defer { lock.unlock() }
        stored = message
    }
}

func captureRuntimePrecondition(_ body: @escaping @Sendable () -> Void) -> String? {
    let capture = NShiftRuntimePreconditionCapture()
    let semaphore = DispatchSemaphore(value: 0)

    NShiftRuntimePrecondition.replace { message in
        capture.store(message)
        semaphore.signal()
        Thread.exit()

        while true {
            Thread.sleep(forTimeInterval: 1)
        }
    }

    Thread(block: body).start()

    let result = semaphore.wait(timeout: .now() + 2)
    NShiftRuntimePrecondition.restore()

    guard result == .success else {
        return nil
    }
    return capture.message
}
