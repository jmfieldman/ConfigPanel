//
//  ConfigContainer.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import Foundation

public protocol ConfigContainer<ConfigInput> {
    associatedtype ConfigInput
}

public extension ConfigContainer {
    func registerConfigProperty(_ configProperty: any PropertyProtocol<ConfigInput?>) {
        for (_, child) in Mirror(reflecting: self).children {
            if let child = child as? (any ConfigInputIngesting<ConfigInput>) {
                child.registerConfigItemProperty(configProperty)
            } else if let child = child as? (any ConfigContainer<ConfigInput>) {
                child.registerConfigProperty(configProperty)
            }
        }
    }
}
