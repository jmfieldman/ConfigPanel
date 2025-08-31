//
//  TweakType.swift
//  Copyright © 2025 Jason Fieldman.
//

public enum TweakType<Output: Codable> {
    case toggle(off: Output, on: Output, toggleDefault: Bool)
    case freeform(fromString: (String) -> Output, toString: (Output) -> String?, default: Output)
    case selection(options: [Output], nameTransform: (Output) -> String, defaultIndex: Int)
    case namedSelection(options: [(String, Output)], defaultIndex: Int)
    case segment(options: [(String, Output)], defaultIndex: Int)

    func defaultValue() -> Output {
        switch self {
        case let .toggle(off, on, toggleDefault):
            toggleDefault ? on : off
        case let .freeform(_, _, defaultValue):
            defaultValue
        case let .selection(options, _, defaultIndex):
            options[defaultIndex]
        case let .namedSelection(options, defaultIndex):
            options[defaultIndex].1
        case let .segment(options, defaultIndex):
            options[defaultIndex].1
        }
    }
}

public extension TweakType {
    static func boolToggle(default: Bool) -> TweakType<Bool> {
        .toggle(off: false, on: true, toggleDefault: `default`)
    }

    static func freeformString(default: String = "") -> TweakType<String> {
        .freeform(fromString: { $0 }, toString: { $0 }, default: `default`)
    }

    static func freeformOptionalString(default: String? = nil) -> TweakType<String?> {
        .freeform(fromString: { $0 }, toString: { $0 }, default: `default`)
    }

    static func freeformInt(default: Int = 0) -> TweakType<Int> {
        .freeform(fromString: { Int($0) ?? `default` }, toString: { "\($0)" }, default: `default`)
    }

    static func freeformOptionalInt(default: Int? = nil) -> TweakType<Int?> {
        .freeform(fromString: { Int($0) ?? `default` }, toString: { ($0 ?? `default`).flatMap(\.description) }, default: `default`)
    }
}
