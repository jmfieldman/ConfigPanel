//
//  ConfigRefreshManager.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public struct ConfigStruct {
    public let integer: Int
    public let string: String

    public init(_ i: Int) {
        self.integer = i
        self.string = "\(i)"
    }
}

public protocol ConfigRefreshManager {
    var configProperty: Property<ConfigStruct?> { get }
    func incrementConfigStruct()
}
