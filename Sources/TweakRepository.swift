//
//  TweakRepository.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import Foundation

/// Contains the main internal management of all registered tweaks
final class TweakRepository {
    static let shared = TweakRepository()

    private static let propertyEnvironment = FileBasedPersistentPropertyEnvironment(
        environmentId: "_tweaks_",
        rootDirectory: .documents
    )

    var nodes: [TweakCoordinate: any NodeProviding] = [:]
    let accessQueue = DispatchQueue(label: "TweakRepository.accessQueue")

    protocol NodeProviding<Output> {
        associatedtype Output: Codable
        var coordinate: TweakCoordinate { get }
        var tweakType: TweakType<Output> { get }
        var persistentProperty: PersistentProperty<TweakState<Output>> { get }
        var outputIdentifier: ObjectIdentifier { get }
    }

    final class Node<Output: Codable>: NodeProviding {
        let coordinate: TweakCoordinate
        let tweakType: TweakType<Output>
        let persistentProperty: PersistentProperty<TweakState<Output>>
        let outputIdentifier = ObjectIdentifier(Output.self)

        init(
            coordinate: TweakCoordinate,
            tweakType: TweakType<Output>
        ) {
            self.coordinate = coordinate
            self.tweakType = tweakType
            self.persistentProperty = PersistentProperty(
                environment: TweakRepository.propertyEnvironment,
                key: coordinate.propertyKey,
                defaultValue: TweakState(
                    value: tweakType.defaultValue(),
                    enabled: false
                )
            )
        }
    }

    func register<Output: Codable>(
        coordinate: TweakCoordinate,
        tweakType: TweakType<Output>
    ) -> PersistentProperty<TweakState<Output>> {
        accessQueue.sync(flags: .barrier) {
            let outputIdentifier = ObjectIdentifier(Output.self)
            if let testNode = self.nodes[coordinate] {
                guard testNode.outputIdentifier == outputIdentifier, let existingNode = testNode as? Node<Output> else {
                    fatalError("Attempting to re-register tweak with coordinate \(coordinate) of different type (was \(testNode.outputIdentifier), now \(outputIdentifier)")
                }
                return existingNode.persistentProperty
            }

            let newNode = Node<Output>(
                coordinate: coordinate,
                tweakType: tweakType
            )

            self.nodes[coordinate] = newNode
            return newNode.persistentProperty
        }
    }
}
