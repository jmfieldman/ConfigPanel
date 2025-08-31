//
//  TweakRepository.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

/// Contains the main internal management of all registered tweaks
final class TweakRepository {
    static let shared = TweakRepository()

    protocol NodeProviding<Output> {
        associatedtype Output: Codable
        var coordinate: TweakCoordinate { get }
        var tweakType: TweakType<Output> { get }
        var persistentProperty: PersistentProperty<Output> { get }
        var outputIdentifier: ObjectIdentifier { get }
    }

    final class Node<Output: Codable>: NodeProviding {
        let coordinate: TweakCoordinate
        let tweakType: TweakType<Output>
        let persistentProperty: PersistentProperty<Output>
        let outputIdentifier = ObjectIdentifier(Output.self)

        init(
            coordinate: TweakCoordinate,
            tweakType: TweakType<Output>,
            persistentProperty: PersistentProperty<Output>
        ) {
            self.coordinate = coordinate
            self.tweakType = tweakType
            self.persistentProperty = persistentProperty
        }
    }

    let z: [TweakCoordinate: any NodeProviding] = [:]

    init() {}
}
