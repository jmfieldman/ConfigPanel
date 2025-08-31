//
//  ConfigProvider.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public final class ConfigProvider<Output: Codable>: PropertyProtocol {
    private let internalProperty: Property<Output>

    public init(
        default: Output
    ) {
        self.internalProperty = Property(value: `default`)
    }
}

// MARK: PropertyProtocol

public extension ConfigProvider {
    var value: Output {
        internalProperty.value
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {}
}
