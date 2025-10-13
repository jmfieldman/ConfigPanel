//
//  ConfigItem.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import Foundation

public struct ConfigItemDynamicResolution<Output: TweakOutputType>: Equatable, Sendable {
    public enum `Type`: String, Equatable, Sendable {
        case `default`
        case tweak
        case config
    }

    public let type: `Type`
    public let value: Output

    public init(type: Type, value: Output) {
        self.type = type
        self.value = value
    }
}

public protocol ConfigProviding<Output>: PropertyProtocol {
    associatedtype Output
}

protocol ConfigInputIngesting<ConfigInput> {
    associatedtype ConfigInput
    func registerConfigItemProperty(
        itemName: String,
        parentPath: String,
        fullPath: String,
        configProperty: any PropertyProtocol<ConfigInput?>
    )
}

public final class ConfigItem<Output: TweakOutputType, ConfigInput>: ConfigProviding, ConfigInputIngesting {
    private var internalProperty: LazyContainer<Property<ConfigItemDynamicResolution<Output>>>?
    private var internalValueMap: LazyContainer<Property<Output>>?

    private let defaultValue: Output
    private let tweak: Tweak<Output>?
    private let config: ((ConfigInput) -> Output?)?
    private var configProperty: (any PropertyProtocol<ConfigInput?>)?

    public var itemName: String!
    public var parentPath: String!
    public var fullPath: String!

    public init(
        default: Output,
        tweak: Tweak<Output>? = nil,
        config: ((ConfigInput) -> Output)? = nil
    ) {
        self.defaultValue = `default`
        self.tweak = tweak
        self.config = config
        self.internalProperty = LazyContainer { [unowned self] in
            makeInternalProperty()
        }
        self.internalValueMap = LazyContainer { [unowned self] in
            internalProperty!.target.map(\.value)
        }
    }

    func registerConfigItemProperty(
        itemName: String,
        parentPath: String,
        fullPath: String,
        configProperty: any PropertyProtocol<ConfigInput?>
    ) {
        self.itemName = itemName
        self.parentPath = parentPath
        self.fullPath = fullPath
        self.configProperty = configProperty
    }

    /// Returns the immediate value -- returns nil if the value has not been exposed/read
    /// by the user yet.
    public var exposedResolution: ConfigItemDynamicResolution<Output>? {
        guard internalProperty!.resolved != nil else {
            return nil
        }

        return internalProperty!.target.value
    }

    fileprivate func makeInternalProperty() -> Property<ConfigItemDynamicResolution<Output>> {
        guard let configProperty else {
            fatalError("Cannot call makeInternalProperty before registering the config property")
        }

        return Property<ConfigItemDynamicResolution<Output>>.combineLatest(
            tweak?.internalProperty.map(\.self) ?? Property(value: TweakState(value: defaultValue, enabled: false)),
            configProperty
        ).map { [config, defaultValue] tweakState, configInput -> ConfigItemDynamicResolution<Output> in
            if tweakState.enabled {
                return ConfigItemDynamicResolution(type: .tweak, value: tweakState.value)
            }

            if let configInput, let resolution = config?(configInput) {
                return ConfigItemDynamicResolution(type: .config, value: resolution)
            }

            return ConfigItemDynamicResolution(type: .default, value: defaultValue)
        }.removeDuplicates()
    }
}

// MARK: PropertyProtocol

public extension ConfigItem {
    var value: Output {
        internalValueMap!.target.value
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        internalValueMap!.target.receive(subscriber: subscriber)
    }
}

// MARK: Lazy

private class LazyContainer<T> {
    let closure: () -> T
    let lockQueue = DispatchQueue(label: "LazyContainer")
    var resolved: T?

    init(_ closure: @escaping () -> T) {
        self.closure = closure
    }

    var target: T {
        lockQueue.sync {
            if let resolved {
                return resolved
            }

            resolved = closure()
            return resolved!
        }
    }
}
