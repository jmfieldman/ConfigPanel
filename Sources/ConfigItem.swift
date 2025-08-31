//
//  ConfigItem.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import Foundation

public final class ConfigItem<Output: Codable & Equatable, ConfigInput>: PropertyProtocol {
    private var internalProperty: LazyContainer<Property<Output>>?
    private let defaultValue: Output
    private let tweak: Tweak<Output>?
    private let config: ((ConfigInput) -> Output?)?
    private var configProperty: (any PropertyProtocol<ConfigInput?>)?

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
    }

    func registerConfigProperty(_ configProperty: any PropertyProtocol<ConfigInput?>) {
        self.configProperty = configProperty
    }

    fileprivate static func evaluate(
        defaultValue: Output,
        tweakState: TweakState<Output>?,
        config: ((ConfigInput) -> Output?)?,
        configInput: ConfigInput?
    ) -> Output {
        if let tweakState, tweakState.enabled {
            return tweakState.value
        }

        if let configInput, let resolution = config?(configInput) {
            return resolution
        }

        return defaultValue
    }

    fileprivate func makeInternalProperty() -> Property<Output> {
        guard let configProperty else {
            fatalError("Cannot call makeInternalProperty before registering the config property")
        }

        return Property<Output>.combineLatest(
            tweak?.internalProperty.map(\.self) ?? Property(value: TweakState(value: defaultValue, enabled: false)),
            configProperty
        ).map { [config, defaultValue] tweakState, configInput -> Output in
            if tweakState.enabled {
                return tweakState.value
            }

            if let configInput, let resolution = config?(configInput) {
                return resolution
            }

            return defaultValue
        }.removeDuplicates()
    }
}

// MARK: PropertyProtocol

public extension ConfigItem {
    var value: Output {
        internalProperty!.target.value
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        internalProperty!.target.receive(subscriber: subscriber)
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
