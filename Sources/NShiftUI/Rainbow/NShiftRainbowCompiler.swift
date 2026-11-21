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

        let children = try node.children.map { child in
            try compilePlugin(node: child, pins: pins)
        }
        let slots = try compileSlots(node.slots, pins: pins)
        let events = try compileModifierEvents(node.events, pins: pins)
        let metadata = try decodeMetadata(
            pluginName: node.name,
            parameters: node.parameters
        )
        let style = try decodeStyle(from: node.style)

        return NShiftPluginModel(
            id: node.id,
            name: pluginName,
            version: version,
            metadata: metadata,
            style: style,
            children: children,
            slots: slots,
            events: events
        )
    }

    private func compileSlots(
        _ slots: [RainbowSlot],
        pins: NShiftDSLVersionPins
    ) throws -> [NShiftSlotName: [NShiftPluginModel]] {
        var compiled: [NShiftSlotName: [NShiftPluginModel]] = [:]
        for slot in slots {
            let slotName: NShiftSlotName
            do {
                slotName = try NShiftSlotName(validating: slot.name)
            } catch {
                throw NShiftRainbowCompileError.invalidSlotName(slot.name)
            }
            let plugins = try slot.plugins.map { plugin in
                try compilePlugin(node: plugin, pins: pins)
            }
            compiled[slotName, default: []].append(contentsOf: plugins)
        }
        return compiled
    }

    private func compileModifierEvents(
        _ triggers: [RainbowTrigger],
        pins: NShiftDSLVersionPins
    ) throws -> [NShiftEventModel] {
        var events: [NShiftEventModel] = []
        for triggerNode in triggers {
            guard let trigger = trigger(from: triggerNode.name) else {
                throw NShiftRainbowCompileError.invalidTriggerName(triggerNode.name)
            }
            for eventNode in triggerNode.events {
                events.append(
                    try compileEvent(
                        node: eventNode,
                        trigger: trigger,
                        pins: pins
                    )
                )
            }
        }
        return events
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

        let metadata = try decodeMetadata(
            pluginName: node.name,
            parameters: node.parameters
        )
        let slots = try compileSlots(node.slots, pins: pins)
        let nested = try compileModifierEvents(node.events, pins: pins)

        return NShiftEventModel(
            id: node.id ?? "",
            name: eventName,
            version: version,
            metadata: metadata,
            trigger: trigger,
            slots: slots,
            events: nested
        )
    }

    private func decodeMetadata(
        pluginName: String,
        parameters: [RainbowParameter]
    ) throws -> AnyNShiftMetadata? {
        let decoder = configuration.metadataDecoders[pluginName]
            ?? NShiftRainbowCatalog.shared.decoder(named: pluginName)
        guard let decoder else {
            return nil
        }
        return try decoder.decode(parameters: parameters)
    }

    private func decodeStyle(
        from parameters: [RainbowParameter]
    ) throws -> NShiftPluginStyle {
        var spacing: CGFloat = 0
        var alignment = NShiftPluginAlignment.center
        for parameter in parameters {
            switch parameter.name {
            case "spacing":
                switch parameter.value {
                case .int(let value):
                    spacing = CGFloat(value)
                case .double(let value):
                    spacing = CGFloat(value)
                default:
                    break
                }
            case "alignment":
                if case .identifier(let name) = parameter.value {
                    let token = name.hasPrefix(".") ? String(name.dropFirst()) : name
                    if let parsed = NShiftPluginAlignment(rawValue: token) {
                        alignment = parsed
                    }
                }
            default:
                break
            }
        }
        return NShiftPluginStyle(alignment: alignment, spacing: spacing)
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
