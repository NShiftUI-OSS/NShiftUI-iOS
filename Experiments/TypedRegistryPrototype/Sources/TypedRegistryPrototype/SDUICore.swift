import SwiftUI

public struct SDUINode: Identifiable, Equatable, Sendable {
    public let id: String
    public let type: String
    public let properties: [String: String]
    public let children: [SDUINode]

    public init(
        id: String,
        type: String,
        properties: [String: String] = [:],
        children: [SDUINode] = []
    ) {
        self.id = id
        self.type = type
        self.properties = properties
        self.children = children
    }
}

public enum SDUIFallback: Sendable {
    case empty
    case unsupportedLabel

    @MainActor
    @ViewBuilder
    public func view(for node: SDUINode) -> some View {
        switch self {
        case .empty:
            EmptyView()
        case .unsupportedLabel:
            Text("Unsupported component: \(node.type)")
        }
    }
}

public struct SDUIContext: Sendable {
    public let fallback: SDUIFallback

    public init(fallback: SDUIFallback = .empty) {
        self.fallback = fallback
    }
}
