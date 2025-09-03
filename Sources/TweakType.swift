//
//  TweakType.swift
//  Copyright © 2025 Jason Fieldman.
//

public enum TweakType<Output: Codable> {
    case toggle(
        off: Output,
        on: Output,
        toggleDefaultOn: Bool = false
    )

    case freeform(
        fromString: (String) -> Output,
        toString: (Output) -> String?,
        default: Output
    )

    case selection(
        options: [Output],
        required: Bool = false,
        defaultIndex: Int? = nil
    )

    case namedSelection(
        options: [(String, Output)],
        required: Bool = false,
        defaultIndex: Int? = nil
    )

    func defaultValue() -> Output {
        switch self {
        case let .toggle(off, on, toggleDefault):
            toggleDefault ? on : off
        case let .freeform(_, _, defaultValue):
            defaultValue
        case let .selection(options, _, defaultIndex):
            options[defaultIndex ?? 0]
        case let .namedSelection(options, _, defaultIndex):
            options[defaultIndex ?? 0].1
        }
    }

    func hasDisableState() -> Bool {
        switch self {
        case .toggle:
            false
        case .freeform:
            true
        case let .selection(_, required, _):
            !required
        case let .namedSelection(_, required, _):
            !required
        }
    }
}

public extension TweakType {
    static func boolToggle(defaultOn: Bool = false) -> TweakType<Bool> {
        .toggle(off: false, on: true, toggleDefaultOn: defaultOn)
    }

    static func tristateBool() -> TweakType<Bool> {
        .namedSelection(
            options: [
                ("True", true),
                ("False", false),
            ],
            required: false,
            defaultIndex: nil
        )
    }

    static func freeformString(default: String = "") -> TweakType<String> {
        .freeform(fromString: { $0 }, toString: { $0 }, default: `default`)
    }

    static func freeformString(default: String? = nil) -> TweakType<String?> {
        .freeform(fromString: { $0 }, toString: { $0 }, default: `default`)
    }

    static func freeformInt(default: Int = 0) -> TweakType<Int> {
        .freeform(fromString: { Int($0) ?? `default` }, toString: { "\($0)" }, default: `default`)
    }

    static func freeformInt(default: Int? = nil) -> TweakType<Int?> {
        .freeform(fromString: { Int($0) ?? `default` }, toString: { ($0 ?? `default`).flatMap(\.description) }, default: `default`)
    }
}
