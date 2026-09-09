public extension NShiftDependencyResolver {
    func resolve<Service>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [], arguments: [])
    }

    func resolve<Service, A1>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self], arguments: [a1])
    }

    func resolve<Service, A1, A2>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self], arguments: [a1, a2])
    }

    func resolve<Service, A1, A2, A3>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self], arguments: [a1, a2, a3])
    }

    func resolve<Service, A1, A2, A3, A4>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self], arguments: [a1, a2, a3, a4])
    }

    func resolve<Service, A1, A2, A3, A4, A5>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self], arguments: [a1, a2, a3, a4, a5])
    }

    func resolve<Service, A1, A2, A3, A4, A5, A6>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self], arguments: [a1, a2, a3, a4, a5, a6])
    }

    func resolve<Service, A1, A2, A3, A4, A5, A6, A7>(
        _ serviceType: Service.Type = Service.self,
        name: String? = nil,
        _ a1: A1,
        _ a2: A2,
        _ a3: A3,
        _ a4: A4,
        _ a5: A5,
        _ a6: A6,
        _ a7: A7
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self], arguments: [a1, a2, a3, a4, a5, a6, a7])
    }

    func resolve<Service, A1, A2, A3, A4, A5, A6, A7, A8>(
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
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self], arguments: [a1, a2, a3, a4, a5, a6, a7, a8])
    }

    func resolve<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9>(
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
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self], arguments: [a1, a2, a3, a4, a5, a6, a7, a8, a9])
    }

    func resolve<Service, A1, A2, A3, A4, A5, A6, A7, A8, A9, A10>(
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
    ) -> Service? {
        resolve(serviceType, name: name, argumentTypes: [A1.self, A2.self, A3.self, A4.self, A5.self, A6.self, A7.self, A8.self, A9.self, A10.self], arguments: [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10])
    }
}
