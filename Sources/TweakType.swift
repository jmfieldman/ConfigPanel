//
//  TweakType.swift
//  Copyright © 2025 Jason Fieldman.
//

public enum TweakType<Output: Codable> {
    case toggle(_ offValue: Output, _ onValue: Output)
    case freeform
    case selection([Output])
    case namedSelection([(String, Output)])
    case segment([(String, Output)])
}
