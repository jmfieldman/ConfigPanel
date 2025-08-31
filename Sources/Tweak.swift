//
//  Tweak.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public final class Tweak<Output: Codable>: PropertyProtocol {
    let internalProperty: Property<Output>
    let coordinate: TweakCoordinate

    public init(
        coordinate: TweakCoordinate,
        default: Output
    ) {
        self.coordinate = coordinate
        self.internalProperty = .init(value: `default`)
    }
}

public extension Tweak {
    var value: Output {
        internalProperty.value
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {}
}
