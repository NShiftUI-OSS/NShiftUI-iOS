import Foundation

public protocol NShiftCatalogHook: AnyObject {
    func typeRegistered(_ type: Any.Type)
}

public final class NShiftCatalogHooks: @unchecked Sendable {
    public static let shared = NShiftCatalogHooks()

    private let lock = NSLock()
    private var stored: (any NShiftCatalogHook)?

    public var hook: (any NShiftCatalogHook)? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return stored
        }
        set {
            lock.lock()
            stored = newValue
            lock.unlock()
        }
    }

    private init() {}
}
