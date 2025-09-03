//
//  TweakState.swift
//  Copyright © 2025 Jason Fieldman.
//

struct TweakState<Output: TweakOutputType>: Codable, Equatable {
    let value: Output
    let enabled: Bool
}
