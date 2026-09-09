import CoreGraphics
import Foundation
import RainbowParser

public struct NShiftRainbowCompiler: Sendable {
    private let configuration: NShiftRainbowCompileConfiguration

    public init(
        configuration: NShiftRainbowCompileConfiguration = .default
    ) {
        self.configuration = configuration
    }

    public func compile(
        source: String
    ) throws -> NShiftPluginModel {
        let document = try RainbowParser().decode(source)
        return try compile(document: document)
    }

    public func compile(
        document: RainbowDocument
    ) throws -> NShiftPluginModel {
        guard let root = document.nodes.first else {
            throw NShiftRainbowCompileError.emptyDocument
        }

        let pins = try makePins(from: document.uses)
        return try compilePlugin(
            node: root,
            pins: pins
        )
    }

    public func compileAll(
        source: String
    ) throws -> [NShiftPluginModel] {
        let document = try RainbowParser().decode(source)
        return try compileAll(document: document)
    }

    public func compileAll(
        document: RainbowDocument
    ) throws -> [NShiftPluginModel] {
        let pins = try makePins(from: document.uses)
        return try document.nodes.map { node in
            try compilePlugin(
                node: node,
                pins: pins
            )
        }
    }

    private func makePins(
        from uses: [RainbowUseDeclaration]
    ) throws -> NShiftDSLVersionPins {
        do {
            return try NShiftDSLVersionPins(
                uses: uses.map { ($0.name, $0.version) }
            )
        } catch {
            throw NShiftRainbowCompileError.invalidVersion(String(describing: error))
        }
    }

    private func compilePlugin(
        node: RainbowNode,
        pins: NShiftDSLVersionPins
    ) throws -> NShiftPluginModel {
        let pluginName: NShiftPluginName
        do {
            pluginName = try NShiftPluginName(validating: node.name)
        } catch {
            throw NShiftRainbowCompileError.invalidPluginName(node.name)
        }

        let version = try resolveVersion(
            name: node.name,
            pins: pins,
            isEvent: false
        )

        let partitioned = try partitionChildren(
            node.children,
            pins: pins
        )

        let metadata = try decodeMetadata(
            pluginName: node.name,
            parameters: node.parameters
        )

        let id = stringParameter(
            named: "id",
            in: node.parameters
        )

        let style = try decodeStyle(
            from: node.parameters
        )

        return NShiftPluginModel(
            id: id,
            name: pluginName,
            version: version,
            metadata: metadata,
            style: style,
            children: partitioned.children,
            slots: partitioned.slots,
            events: partitioned.events
        )
    }

    private func partitionChildren(
        _ nodes: [RainbowNode],
        pins: NShiftDSLVersionPins
    ) throws -> (
        children: [NShiftPluginModel],
        slots: [NShiftSlotName: [NShiftPluginModel]],
        events: [NShiftEventModel]
    ) {
        var children: [NShiftPluginModel] = []
        var slots: [NShiftSlotName: [NShiftPluginModel]] = [:]
        var events: [NShiftEventModel] = []

        for node in nodes {
            if configuration.slotMarkers.contains(node.name) {
                let slotName: NShiftSlotName
                do {
                    slotName = try NShiftSlotName(validating: node.name)
                } catch {
                    throw NShiftRainbowCompileError.invalidSlotName(node.name)
                }

                let compiled = try node.children.map { child in
                    try compilePlugin(
                        node: child,
                        pins: pins
                    )
                }
                slots[slotName, default: []].append(contentsOf: compiled)
                continue
            }

            if let trigger = trigger(from: node.name) {
                let compiledEvents = try compileEvents(
                    under: node,
                    trigger: trigger,
                    pins: pins
                )
                events.append(contentsOf: compiledEvents)
                continue
            }

            children.append(
                try compilePlugin(
                    node: node,
                    pins: pins
                )
            )
        }

        return (
            children: children,
            slots: slots,
            events: events
        )
    }

    private func compileEvents(
        under triggerNode: RainbowNode,
        trigger: NShiftTrigger,
        pins: NShiftDSLVersionPins
    ) throws -> [NShiftEventModel] {
        try triggerNode.children.map { eventNode in
            try compileEvent(
                node: eventNode,
                trigger: trigger,
                pins: pins
            )
        }
    }

    private func compileEvent(
        node: RainbowNode,
        trigger: NShiftTrigger,
        pins: NShiftDSLVersionPins
    ) throws -> NShiftEventModel {
        let eventName: NShiftEventName
        do {
            eventName = try NShiftEventName(validating: node.name)
        } catch {
            throw NShiftRainbowCompileError.invalidEventName(node.name)
        }

        let version = try resolveVersion(
            name: node.name,
            pins: pins,
            isEvent: true
        )

        var nestedEvents: [NShiftEventModel] = []
        var slots: [NShiftSlotName: [NShiftPluginModel]] = [:]

        for child in node.children {
            if let nestedTrigger = self.trigger(from: child.name) {
                nestedEvents.append(
                    contentsOf: try compileEvents(
                        under: child,
                        trigger: nestedTrigger,
                        pins: pins
                    )
                )
                continue
            }

            if configuration.slotMarkers.contains(child.name) {
                let slotName: NShiftSlotName
                do {
                    slotName = try NShiftSlotName(validating: child.name)
                } catch {
                    throw NShiftRainbowCompileError.invalidSlotName(child.name)
                }

                let compiled = try child.children.map { nested in
                    try compilePlugin(
                        node: nested,
                        pins: pins
                    )
                }
                slots[slotName, default: []].append(contentsOf: compiled)
                continue
            }

            nestedEvents.append(
                try compileEvent(
                    node: child,
                    trigger: trigger,
                    pins: pins
                )
            )
        }

        let metadata = try decodeMetadata(
            pluginName: node.name,
            parameters: node.parameters
        )

        let id = stringParameter(
            named: "id",
            in: node.parameters
        )

        return NShiftEventModel(
            id: id ?? UUID().uuidString,
            name: eventName,
            version: version,
            metadata: metadata,
            trigger: trigger,
            slots: slots,
            events: nestedEvents
        )
    }

    private func decodeMetadata(
        pluginName: String,
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata? {
        guard let decoder = configuration.metadataDecoders[pluginName] else {
            return nil
        }
        return try decoder.decode(parameters: parameters)
    }

    private func decodeStyle(
        from parameters: [RainbowParameter]
    ) throws -> NShiftPluginStyle {
        guard let styleParameter = parameters.first(where: { $0.name == "style" }) else {
            return NShiftPluginStyle()
        }

        guard case .object(let entries) = styleParameter.value else {
            return NShiftPluginStyle()
        }

        var spacing: CGFloat = 0
        for entry in entries {
            if entry.key == "spacing" {
                switch entry.value {
                case .int(let value):
                    spacing = CGFloat(value)
                case .double(let value):
                    spacing = CGFloat(value)
                default:
                    break
                }
            }
        }

        return NShiftPluginStyle(spacing: spacing)
    }

    private func resolveVersion(
        name: String,
        pins: NShiftDSLVersionPins,
        isEvent: Bool
    ) throws -> NShiftVersion {
        if isEvent {
            let eventName: NShiftEventName
            do {
                eventName = try NShiftEventName(validating: name)
            } catch {
                throw NShiftRainbowCompileError.invalidEventName(name)
            }

            if let pinned = pins.pinnedVersion(forEvent: eventName) {
                return pinned
            }

            if let latest = configuration.catalog.latestEvent(named: eventName) {
                return latest
            }

            if let fallback = configuration.defaultVersion {
                return fallback
            }

            throw NShiftRainbowCompileError.missingVersion(name)
        }

        let pluginName: NShiftPluginName
        do {
            pluginName = try NShiftPluginName(validating: name)
        } catch {
            throw NShiftRainbowCompileError.invalidPluginName(name)
        }

        if let pinned = pins.pinnedVersion(forPlugin: pluginName) {
            return pinned
        }

        if let latest = configuration.catalog.latestPlugin(named: pluginName) {
            return latest
        }

        if let fallback = configuration.defaultVersion {
            return fallback
        }

        throw NShiftRainbowCompileError.missingVersion(name)
    }

    private func trigger(
        from nodeName: String
    ) -> NShiftTrigger? {
        guard nodeName.hasPrefix("On"),
              nodeName.count > 2 else {
            return nil
        }

        let suffix = nodeName.dropFirst(2)
        let rawValue = "on" + suffix
        do {
            return try NShiftTrigger(validating: String(rawValue))
        } catch {
            return nil
        }
    }

    private func stringParameter(
        named name: String,
        in parameters: [RainbowParameter]
    ) -> String? {
        guard let parameter = parameters.first(where: { $0.name == name }) else {
            return nil
        }

        if case .string(let value) = parameter.value {
            return value
        }

        return nil
    }
}
