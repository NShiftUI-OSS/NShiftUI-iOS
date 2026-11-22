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
            pins: pins,
            uses: document.uses
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
                pins: pins,
                uses: document.uses
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
        pins: NShiftDSLVersionPins,
        uses: [RainbowUseDeclaration] = []
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

        let decodedMetadata = try decodeMetadata(
            pluginName: node.name,
            parameters: node.parameters,
            pins: pins,
            uses: uses,
            children: node.children
        )
        let children = decodedMetadata.consumesChildren ? [] : try node.children.map { child in
            try compilePlugin(node: child, pins: pins, uses: uses)
        }
        var slots = try compileSlots(node.slots, pins: pins, uses: uses)
        let events = try compileModifierEvents(node.events, pins: pins, uses: uses)
        let style = try decodeStyle(from: node.style)
        for (slot, models) in decodedMetadata.slots {
            slots[slot, default: []].append(contentsOf: models)
        }

        return NShiftPluginModel(
            id: node.id,
            name: pluginName,
            version: version,
            metadata: decodedMetadata.metadata,
            style: style,
            children: children,
            slots: slots,
            events: events
        )
    }

    private func compileSlots(
        _ slots: [RainbowSlot],
        pins: NShiftDSLVersionPins,
        uses: [RainbowUseDeclaration] = []
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
                try compilePlugin(node: plugin, pins: pins, uses: uses)
            }
            compiled[slotName, default: []].append(contentsOf: plugins)
        }
        return compiled
    }

    private func compileModifierEvents(
        _ triggers: [RainbowTrigger],
        pins: NShiftDSLVersionPins,
        uses: [RainbowUseDeclaration] = []
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
                        pins: pins,
                        uses: uses
                    )
                )
            }
        }
        return events
    }

    private func compileEvent(
        node: RainbowNode,
        trigger: NShiftTrigger,
        pins: NShiftDSLVersionPins,
        uses: [RainbowUseDeclaration] = []
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
            parameters: node.parameters,
            pins: pins,
            uses: uses
        )
        let slots = try compileSlots(node.slots, pins: pins, uses: uses)
        let nested = try compileModifierEvents(node.events, pins: pins, uses: uses)

        return NShiftEventModel(
            id: node.id ?? "",
            name: eventName,
            version: version,
            metadata: metadata.metadata,
            trigger: trigger,
            slots: slots,
            events: nested
        )
    }

    private func decodeMetadata(
        pluginName: String,
        parameters: [RainbowParameter],
        pins: NShiftDSLVersionPins,
        uses: [RainbowUseDeclaration] = [],
        children: [RainbowNode] = []
    ) throws -> NShiftRainbowMetadataDecodeResult {
        let decoder = configuration.metadataDecoders[pluginName]
            ?? NShiftRainbowCatalog.shared.decoder(named: pluginName)
        guard let decoder else {
            return NShiftRainbowMetadataDecodeResult(metadata: nil)
        }
        return try decoder.decode(
            parameters: parameters,
            context: NShiftRainbowMetadataDecodingContext(
                compilePlugins: { parameterName in
                    let pluginNodes = Self.pluginNodes(
                        named: parameterName,
                        in: parameters
                    )
                    return try pluginNodes.map { plugin in
                        try self.compilePlugin(node: plugin, pins: pins, uses: uses)
                    }
                },
                childrenSource: {
                    RainbowParser().encode(RainbowDocument(uses: uses, nodes: children))
                }
            )
        )
    }

    private func decodeStyle(
        from parameters: [RainbowParameter]
    ) throws -> NShiftPluginStyle {
        var width: Double?
        var height: Double?
        var minWidth: Double?
        var maxWidth: Double?
        var minHeight: Double?
        var maxHeight: Double?
        var background: NShiftPluginBackground?
        var padding = NShiftPluginPadding.zero
        var ignoreSafeArea = NShiftSafeAreaEdges()
        var offset = NShiftPluginOffset.zero
        var animation: NShiftPluginAnimation?

        for parameter in parameters {
            switch parameter.name {
            case "width":
                width = Self.number(parameter.value)
            case "height":
                height = Self.number(parameter.value)
            case "minWidth":
                minWidth = Self.number(parameter.value)
            case "maxWidth":
                maxWidth = Self.number(parameter.value)
            case "minHeight":
                minHeight = Self.number(parameter.value)
            case "maxHeight":
                maxHeight = Self.number(parameter.value)
            case "background":
                background = Self.background(parameter.value)
            case "padding":
                padding = Self.padding(parameter.value)
            case "ignoreSafeArea":
                ignoreSafeArea = Self.edges(parameter.value)
            case "offset":
                offset = Self.offset(parameter.value)
            case "animation":
                animation = Self.animation(parameter.value)
            default:
                break
            }
        }

        let frame = try NShiftPluginFrame(
            width: width,
            height: height,
            minWidth: minWidth.map(NShiftPluginDimension.value),
            maxWidth: maxWidth.map(NShiftPluginDimension.value),
            minHeight: minHeight.map(NShiftPluginDimension.value),
            maxHeight: maxHeight.map(NShiftPluginDimension.value)
        )
        return NShiftPluginStyle(
            frame: frame,
            background: background,
            padding: padding,
            ignoreSafeArea: ignoreSafeArea,
            offset: offset,
            animation: animation
        )
    }

    private static func number(_ value: RainbowValue) -> Double? {
        switch value {
        case .int(let int):
            return Double(int)
        case .double(let double):
            return double
        default:
            return nil
        }
    }

    private static func token(_ value: RainbowValue) -> String? {
        switch value {
        case .identifier(let name), .string(let name):
            return name.hasPrefix(".") ? String(name.dropFirst()) : name
        default:
            return nil
        }
    }

    private static func edges(_ value: RainbowValue) -> NShiftSafeAreaEdges {
        switch value {
        case .array(let values):
            return NShiftSafeAreaEdges.parse(values.compactMap(token))
        default:
            return NShiftSafeAreaEdges.parse([token(value)].compactMap { $0 })
        }
    }

    private static func background(_ value: RainbowValue) -> NShiftPluginBackground? {
        guard case .object(let entries) = value else { return nil }
        var color: String?
        var ignoreSafeArea = NShiftSafeAreaEdges()
        for entry in entries {
            switch entry.key {
            case "color":
                color = token(entry.value)
            case "ignoreSafeArea":
                ignoreSafeArea = edges(entry.value)
            default:
                break
            }
        }
        guard color != nil || !ignoreSafeArea.isEmpty else { return nil }
        return NShiftPluginBackground(color: color, ignoreSafeArea: ignoreSafeArea)
    }

    private static func padding(_ value: RainbowValue) -> NShiftPluginPadding {
        guard case .object(let entries) = value else { return .zero }
        var top: Int?
        var leading: Int?
        var trailing: Int?
        var horizontal: Int?
        var vertical: Int?
        var bottom: Int?
        for entry in entries {
            let amount = integer(entry.value)
            switch entry.key {
            case "top":
                top = amount
            case "leading":
                leading = amount
            case "trailing":
                trailing = amount
            case "horizontal":
                horizontal = amount
            case "vertical":
                vertical = amount
            case "bottom":
                bottom = amount
            default:
                break
            }
        }
        return NShiftPluginPadding(
            top: top,
            leading: leading,
            trailing: trailing,
            horizontal: horizontal,
            vertical: vertical,
            bottom: bottom
        )
    }

    private static func integer(_ value: RainbowValue) -> Int? {
        switch value {
        case .int(let int):
            return int
        case .double(let double):
            return Int(double)
        default:
            return nil
        }
    }

    private static func pluginNodes(
        named path: String,
        in parameters: [RainbowParameter]
    ) -> [RainbowNode] {
        let components = path.split(separator: ".").map(String.init)
        guard let first = components.first,
              let parameter = parameters.first(where: { $0.name == first }) else {
            return []
        }
        var value = parameter.value
        for component in components.dropFirst() {
            guard case .object(let entries) = value,
                  let entry = entries.first(where: { $0.key == component }) else {
                return []
            }
            value = entry.value
        }
        guard case .plugins(let plugins) = value else {
            return []
        }
        return plugins
    }

    private static func offset(_ value: RainbowValue) -> NShiftPluginOffset {
        guard case .object(let entries) = value else { return .zero }
        var x = 0.0
        var y = 0.0
        for entry in entries {
            switch entry.key {
            case "x":
                x = number(entry.value) ?? x
            case "y":
                y = number(entry.value) ?? y
            default:
                break
            }
        }
        return NShiftPluginOffset(x: x, y: y)
    }

    private static func animation(_ value: RainbowValue) -> NShiftPluginAnimation? {
        guard case .object(let entries) = value else { return nil }
        var isEnabled = false
        var durationMillis = 300
        var delayMillis = 0
        var curve = NShiftAnimationCurve.easeInOut
        for entry in entries {
            switch entry.key {
            case "isEnabled":
                if case .bool(let enabled) = entry.value {
                    isEnabled = enabled
                }
            case "duration":
                if let number = number(entry.value) {
                    durationMillis = Int(number)
                }
            case "delay":
                if let number = number(entry.value) {
                    delayMillis = Int(number)
                }
            case "curve":
                if let name = token(entry.value), let parsed = NShiftAnimationCurve(rawValue: name) {
                    curve = parsed
                }
            default:
                break
            }
        }
        return NShiftPluginAnimation(
            isEnabled: isEnabled,
            durationMillis: durationMillis,
            delayMillis: delayMillis,
            curve: curve
        )
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
