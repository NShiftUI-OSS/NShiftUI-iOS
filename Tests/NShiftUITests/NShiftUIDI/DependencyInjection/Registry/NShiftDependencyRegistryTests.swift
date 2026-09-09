@testable import NShiftUIDI
import Dispatch
import Foundation
import Testing

private struct TestClient: Equatable, Sendable {
    let value: String
}

private final class FatalErrorCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var storedMessage: String?

    var message: String? {
        lock.withLock {
            storedMessage
        }
    }

    func store(_ message: String) {
        lock.withLock {
            storedMessage = message
        }
    }
}

@Test func registryResolvesRegisteredDependencyByType() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self) {
        TestClient(value: "default")
    }

    let client = registry.resolve(TestClient.self)

    #expect(client == TestClient(value: "default"))
}

@Test func registryResolvesRegisteredDependencyByName() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self, name: "primary") {
        TestClient(value: "primary")
    }
    registry.register(TestClient.self, name: "secondary") {
        TestClient(value: "secondary")
    }

    #expect(registry.resolve(TestClient.self, name: "primary") == TestClient(value: "primary"))
    #expect(registry.resolve(TestClient.self, name: "secondary") == TestClient(value: "secondary"))
}

@Test func registryReturnsNilForMissingDependency() {
    let registry = NShiftDependencyRegistry()

    let client = registry.resolve(TestClient.self, name: "missing")

    #expect(client == nil)
}

@Test func registryResolvesDependencyWithArguments() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self, name: "request") { (method: String, url: String) in
        TestClient(value: "\(method) \(url)")
    }

    let client = registry.resolve(TestClient.self, name: "request", "POST", "/login")

    #expect(client == TestClient(value: "POST /login"))
}

@Test func registryResolvesSameDependencyNameWithDifferentArgumentSignatures() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self, name: "client") { (baseURL: String) in
        TestClient(value: baseURL)
    }
    registry.register(TestClient.self, name: "client") { (baseURL: String, token: String) in
        TestClient(value: "\(baseURL):\(token)")
    }

    #expect(registry.resolve(TestClient.self, name: "client", "https://api") == TestClient(value: "https://api"))
    #expect(registry.resolve(TestClient.self, name: "client", "https://api", "token") == TestClient(value: "https://api:token"))
}

@Test func registryResolvesDependencyWithTenArguments() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self, name: "sum") {
        (
            a1: Int,
            a2: Int,
            a3: Int,
            a4: Int,
            a5: Int,
            a6: Int,
            a7: Int,
            a8: Int,
            a9: Int,
            a10: Int
        ) in
        TestClient(value: String(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10))
    }

    let client = registry.resolve(TestClient.self, name: "sum", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    #expect(client == TestClient(value: "55"))
}

@Test func registryResolveUnwrappingReturnsDependencyWhenRegistered() {
    let registry = NShiftDependencyRegistry()
    registry.register(TestClient.self, name: "required") {
        TestClient(value: "resolved")
    }

    let client = registry.resolveUnwrapping(TestClient.self, name: "required")

    #expect(client == TestClient(value: "resolved"))
}

@Test func registryResolveUnwrappingRaisesFatalErrorWhenDependencyIsMissing() {
    let capture = FatalErrorCapture()
    let semaphore = DispatchSemaphore(value: 0)

    NShiftFatalError.replace { message, _, _ in
        capture.store(message())
        semaphore.signal()
        Thread.exit()

        while true {
            Thread.sleep(forTimeInterval: 1)
        }
    }
    defer {
        NShiftFatalError.restore()
    }

    Thread {
        let registry = NShiftDependencyRegistry()
        let _: TestClient = registry.resolveUnwrapping(TestClient.self, name: "missing")
    }.start()

    let result = semaphore.wait(timeout: .now() + 2)

    #expect(result == .success)
    #expect(capture.message?.contains("TestClient") == true)
    #expect(capture.message?.contains("'missing'") == true)
    #expect(capture.message?.contains("arguments []") == true)
}

@Test func registryResolveUnwrappingSupportsArgumentCountsUpToTen() {
    let registry = NShiftDependencyRegistry()

    registry.register(TestClient.self, name: "arity-0") { TestClient(value: "0") }
    registry.register(TestClient.self, name: "arity-1") { (a1: Int) in TestClient(value: "\(a1)") }
    registry.register(TestClient.self, name: "arity-2") { (a1: Int, a2: Int) in TestClient(value: "\(a1 + a2)") }
    registry.register(TestClient.self, name: "arity-3") { (a1: Int, a2: Int, a3: Int) in TestClient(value: "\(a1 + a2 + a3)") }
    registry.register(TestClient.self, name: "arity-4") { (a1: Int, a2: Int, a3: Int, a4: Int) in TestClient(value: "\(a1 + a2 + a3 + a4)") }
    registry.register(TestClient.self, name: "arity-5") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5)") }
    registry.register(TestClient.self, name: "arity-6") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5 + a6)") }
    registry.register(TestClient.self, name: "arity-7") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, a7: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5 + a6 + a7)") }
    registry.register(TestClient.self, name: "arity-8") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, a7: Int, a8: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8)") }
    registry.register(TestClient.self, name: "arity-9") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, a7: Int, a8: Int, a9: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9)") }
    registry.register(TestClient.self, name: "arity-10") { (a1: Int, a2: Int, a3: Int, a4: Int, a5: Int, a6: Int, a7: Int, a8: Int, a9: Int, a10: Int) in TestClient(value: "\(a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10)") }

    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-0") == TestClient(value: "0"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-1", 1) == TestClient(value: "1"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-2", 1, 2) == TestClient(value: "3"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-3", 1, 2, 3) == TestClient(value: "6"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-4", 1, 2, 3, 4) == TestClient(value: "10"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-5", 1, 2, 3, 4, 5) == TestClient(value: "15"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-6", 1, 2, 3, 4, 5, 6) == TestClient(value: "21"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-7", 1, 2, 3, 4, 5, 6, 7) == TestClient(value: "28"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-8", 1, 2, 3, 4, 5, 6, 7, 8) == TestClient(value: "36"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-9", 1, 2, 3, 4, 5, 6, 7, 8, 9) == TestClient(value: "45"))
    #expect(registry.resolveUnwrapping(TestClient.self, name: "arity-10", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) == TestClient(value: "55"))
}

@Test func registryReturnsNilWhenResolvedArgumentsDoNotMatchRegisteredSignature() {
    let registry = NShiftDependencyRegistry()

    registry.register(TestClient.self, name: "mismatch-0") { TestClient(value: "0") }
    registry.register(TestClient.self, name: "mismatch-1") { (_: Int) in TestClient(value: "1") }
    registry.register(TestClient.self, name: "mismatch-2") { (_: Int, _: Int) in TestClient(value: "2") }
    registry.register(TestClient.self, name: "mismatch-3") { (_: Int, _: Int, _: Int) in TestClient(value: "3") }
    registry.register(TestClient.self, name: "mismatch-4") { (_: Int, _: Int, _: Int, _: Int) in TestClient(value: "4") }
    registry.register(TestClient.self, name: "mismatch-5") { (_: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "5") }
    registry.register(TestClient.self, name: "mismatch-6") { (_: Int, _: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "6") }
    registry.register(TestClient.self, name: "mismatch-7") { (_: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "7") }
    registry.register(TestClient.self, name: "mismatch-8") { (_: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "8") }
    registry.register(TestClient.self, name: "mismatch-9") { (_: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "9") }
    registry.register(TestClient.self, name: "mismatch-10") { (_: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int, _: Int) in TestClient(value: "10") }

    let resolved0: TestClient? = registry.resolve(TestClient.self, name: "mismatch-0", argumentTypes: [], arguments: [1])
    let resolved1: TestClient? = registry.resolve(TestClient.self, name: "mismatch-1", argumentTypes: [Int.self], arguments: ["bad"])
    let resolved2: TestClient? = registry.resolve(TestClient.self, name: "mismatch-2", argumentTypes: [Int.self, Int.self], arguments: [1, "bad"])
    let resolved3: TestClient? = registry.resolve(TestClient.self, name: "mismatch-3", argumentTypes: [Int.self, Int.self, Int.self], arguments: [1, 2, "bad"])
    let resolved4: TestClient? = registry.resolve(TestClient.self, name: "mismatch-4", argumentTypes: [Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, "bad"])
    let resolved5: TestClient? = registry.resolve(TestClient.self, name: "mismatch-5", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, "bad"])
    let resolved6: TestClient? = registry.resolve(TestClient.self, name: "mismatch-6", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, 5, "bad"])
    let resolved7: TestClient? = registry.resolve(TestClient.self, name: "mismatch-7", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, 5, 6, "bad"])
    let resolved8: TestClient? = registry.resolve(TestClient.self, name: "mismatch-8", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, 5, 6, 7, "bad"])
    let resolved9: TestClient? = registry.resolve(TestClient.self, name: "mismatch-9", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, 5, 6, 7, 8, "bad"])
    let resolved10: TestClient? = registry.resolve(TestClient.self, name: "mismatch-10", argumentTypes: [Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self, Int.self], arguments: [1, 2, 3, 4, 5, 6, 7, 8, 9, "bad"])

    #expect(resolved0 == nil)
    #expect(resolved1 == nil)
    #expect(resolved2 == nil)
    #expect(resolved3 == nil)
    #expect(resolved4 == nil)
    #expect(resolved5 == nil)
    #expect(resolved6 == nil)
    #expect(resolved7 == nil)
    #expect(resolved8 == nil)
    #expect(resolved9 == nil)
    #expect(resolved10 == nil)
}

@Test func unresolvedDependencyMessageIdentifiesMissingDependency() {
    let namedMessage = unresolvedDependencyMessage(
        serviceType: TestClient.self,
        name: "primary",
        argumentTypes: [String.self, Int.self]
    )
    let defaultMessage = unresolvedDependencyMessage(
        serviceType: TestClient.self,
        name: nil,
        argumentTypes: []
    )

    #expect(namedMessage.contains("TestClient"))
    #expect(namedMessage.contains("'primary'"))
    #expect(namedMessage.contains("Swift.String"))
    #expect(namedMessage.contains("Swift.Int"))
    #expect(defaultMessage.contains("<default>"))
}

@Test func registrySupportsConcurrentRegisterAndResolve() async {
    let registry = NShiftDependencyRegistry()

    await withTaskGroup(of: Void.self) { group in
        for index in 0..<100 {
            group.addTask {
                registry.register(TestClient.self, name: "client-\(index)") {
                    TestClient(value: "\(index)")
                }
            }
        }
    }

    await withTaskGroup(of: Bool.self) { group in
        for index in 0..<100 {
            group.addTask {
                let client = registry.resolve(TestClient.self, name: "client-\(index)")
                return client == TestClient(value: "\(index)")
            }
        }

        for await resolved in group {
            #expect(resolved)
        }
    }
}

private final class ReferenceClient: @unchecked Sendable {}

@Test func registryTransientScopeProducesANewInstanceEachResolution() {
    let registry = NShiftDependencyRegistry()
    registry.register(ReferenceClient.self, scope: .transient) {
        ReferenceClient()
    }

    let first = registry.resolve(ReferenceClient.self)
    let second = registry.resolve(ReferenceClient.self)

    #expect(first != nil)
    #expect(second != nil)
    #expect(first !== second)
}

@Test func registryDefaultScopeIsTransient() {
    let registry = NShiftDependencyRegistry()
    registry.register(ReferenceClient.self) {
        ReferenceClient()
    }

    let first = registry.resolve(ReferenceClient.self)
    let second = registry.resolve(ReferenceClient.self)

    #expect(first !== second)
}

@Test func registrySingletonScopeReusesTheSameInstance() {
    let registry = NShiftDependencyRegistry()
    registry.register(ReferenceClient.self, scope: .singleton) {
        ReferenceClient()
    }

    let first = registry.resolve(ReferenceClient.self)
    let second = registry.resolve(ReferenceClient.self)

    #expect(first != nil)
    #expect(first === second)
}

@Test func registryReregisteringSingletonResetsTheCachedInstance() {
    let registry = NShiftDependencyRegistry()
    registry.register(ReferenceClient.self, scope: .singleton) {
        ReferenceClient()
    }
    let first = registry.resolve(ReferenceClient.self)

    registry.register(ReferenceClient.self, scope: .singleton) {
        ReferenceClient()
    }
    let second = registry.resolve(ReferenceClient.self)

    #expect(first !== second)
}
