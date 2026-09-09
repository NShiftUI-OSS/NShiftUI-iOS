public extension NShiftDependencyRegistering {
    func register<Service>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable () -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: []) { arguments in
            guard arguments.isEmpty else { return nil }
            return factory()
        }
    }

    func register<Service, A1>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self]) { arguments in
            guard arguments.count == 1, let a1 = arguments[0] as? A1 else { return nil }
            return factory(a1)
        }
    }

    func register<Service, A1, A2>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self]) { arguments in
            guard arguments.count == 2,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2 else { return nil }
            return factory(a1, a2)
        }
    }

    func register<Service, A1, A2, A3>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self]) { arguments in
            guard arguments.count == 3,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3 else { return nil }
            return factory(a1, a2, a3)
        }
    }

    func register<Service, A1, A2, A3, A4>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self]) { arguments in
            guard arguments.count == 4,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4 else { return nil }
            return factory(a1, a2, a3, a4)
        }
    }

    func register<Service, A1, A2, A3, A4, A5>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self]) { arguments in
            guard arguments.count == 5,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5 else { return nil }
            return factory(a1, a2, a3, a4, a5)
        }
    }

    func register<Service, A1, A2, A3, A4, A5, A6>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5, A6) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self]) { arguments in
            guard arguments.count == 6,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5,
                  let a6 = arguments[5] as? A6 else { return nil }
            return factory(a1, a2, a3, a4, a5, a6)
        }
    }

    func register<Service, A1, A2, A3, A4, A5, A6, A7>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5, A6, A7) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self]) { arguments in
            guard arguments.count == 7,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5,
                  let a6 = arguments[5] as? A6,
                  let a7 = arguments[6] as? A7 else { return nil }
            return factory(a1, a2, a3, a4, a5, a6, a7)
        }
    }

    func register<Service, A1, A2, A3, A4, A5, A6, A7, A8>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5, A6, A7, A8) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self]) { arguments in
            guard arguments.count == 8,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5,
                  let a6 = arguments[5] as? A6,
                  let a7 = arguments[6] as? A7,
                  let a8 = arguments[7] as? A8 else { return nil }
            return factory(a1, a2, a3, a4, a5, a6, a7, a8)
        }
    }

    func register<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5, A6, A7, A8, A9) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self]) { arguments in
            guard arguments.count == 9,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5,
                  let a6 = arguments[5] as? A6,
                  let a7 = arguments[6] as? A7,
                  let a8 = arguments[7] as? A8,
                  let a9 = arguments[8] as? A9 else { return nil }
            return factory(a1, a2, a3, a4, a5, a6, a7, a8, a9)
        }
    }

    func register<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        scope: NShiftDependencyScope = .transient,
        factory: @escaping @Sendable (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10) -> Service
    ) {
        register(serviceType, name: name, scope: scope, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self, A10.self]) { arguments in
            guard arguments.count == 10,
                  let a1 = arguments[0] as? A1,
                  let a2 = arguments[1] as? A2,
                  let a3 = arguments[2] as? A3,
                  let a4 = arguments[3] as? A4,
                  let a5 = arguments[4] as? A5,
                  let a6 = arguments[5] as? A6,
                  let a7 = arguments[6] as? A7,
                  let a8 = arguments[7] as? A8,
                  let a9 = arguments[8] as? A9,
                  let a10 = arguments[9] as? A10 else { return nil }
            return factory(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
        }
    }
}
