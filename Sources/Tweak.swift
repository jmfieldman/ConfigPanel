//
//  Tweak.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public final class Tweak<Output: Codable> {
    let internalProperty: PersistentProperty<TweakState<Output>>
    let coordinate: TweakCoordinate
    let type: TweakType<Output>

    public init(
        coordinate: TweakCoordinate,
        type: TweakType<Output>
    ) {
        self.coordinate = coordinate
        self.type = type
        self.internalProperty = TweakRepository.shared.register(
            coordinate: coordinate,
            tweakType: type
        )
    }
}
