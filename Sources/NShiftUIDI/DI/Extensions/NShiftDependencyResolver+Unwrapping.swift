public extension NShiftDependencyResolver {
    func resolveUnwrapping<Service>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil
    ) -> Service {
        unwrap(resolve(serviceType, name: name), serviceType: serviceType, name: name, argumentTypes: [])
    }

    func resolveUnwrapping<Service, A1>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1), serviceType: serviceType, name: name, argumentTypes: [A1.self])
    }

    func resolveUnwrapping<Service, A1, A2>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5, A6>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5, a6), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5, A6, A7>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6,
        _ a7: A7
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5, a6, a7), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5, A6, A7, A8>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6,
        _ a7: A7,
        _ a8: A8
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5, a6, a7, a8), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6,
        _ a7: A7,
        _ a8: A8,
        _ a9: A9
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5, a6, a7, a8, a9), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self])
    }

    func resolveUnwrapping<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6,
        _ a7: A7,
        _ a8: A8,
        _ a9: A9,
        _ a10: A10
    ) -> Service {
        unwrap(resolve(serviceType, name: name, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10), serviceType: serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self, A10.self])
    }

    private func unwrap<Service>(
        _ service: Service?,
        serviceType: Service.Type,
        name: String?,
        argumentTypes: [Any.Type]
    ) -> Service {
        guard let service else {
            fatalError(unresolvedDependencyMessage(serviceType: serviceType, name: name, argumentTypes: argumentTypes))
        }

        return service
    }
}
