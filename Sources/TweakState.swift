//
//  TweakState.swift
//  Copyright © 2025 Jason Fieldman.
//

struct TweakState<Output: Codable>: Codable {
    let value: Output
    let enabled: Bool
}
