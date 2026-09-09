import Foundation

public final class NShiftDependencyRegistry: @unchecked Sendable, NShiftDependencyContainer {
    private struct Registration {
        let factory: NShiftDependencyFactory
        let scope: NShiftDependencyScope
    }

    private let lock = NSLock()
    private var registrations: [NShiftDependencyKey: Registration]
    private var singletons: [NShiftDependencyKey: Any]

    public init() {
        self.registrations = [:]
        self.singletons = [:]
    }

    public func register<Service>(
        _ serviceType: Service.Type,
        name: String?,
        scope: NShiftDependencyScope,
        argumentTypes: [Any.Type],
        factory: @escaping @Sendable ([Any]) -> Service?
    ) {
        let key = NShiftDependencyKey(
            serviceType: serviceType,
            name: name,
            argumentTypes: argumentTypes
        )
        let erasedFactory = NShiftDependencyFactory { arguments in
            factory(arguments)
        }

        lock.withLock {
            registrations[key] = Registration(factory: erasedFactory, scope: scope)
            singletons[key] = nil
        }
    }

    public func resolve<Service>(
        _ serviceType: Service.Type,
        name: String?,
        argumentTypes: [Any.Type],
        arguments: [Any]
    ) -> Service? {
        let key = NShiftDependencyKey(
            serviceType: serviceType,
            name: name,
            argumentTypes: argumentTypes
        )
        let registration = lock.withLock {
            registrations[key]
        }

        guard let registration else { return nil }

        switch registration.scope {
        case .transient:
            return registration.factory.resolve(arguments) as? Service
        case .singleton:
            if let cached = lock.withLock({ singletons[key] }) {
                return cached as? Service
            }

            guard let made = registration.factory.resolve(arguments) else { return nil }

            let stored = lock.withLock { () -> Any in
                if let existing = singletons[key] {
                    return existing
                }
                singletons[key] = made
                return made
            }

            return stored as? Service
        }
    }
}

private extension NSLock {
    func withLock<Value>(_ body: () -> Value) -> Value {
        lock()
        defer { unlock() }
        return body()
    }
}
