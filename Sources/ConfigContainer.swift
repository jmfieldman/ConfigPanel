//
//  ConfigContainer.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import Foundation

public protocol ConfigContainer<ConfigInput>: AnyObject, Sendable {
    associatedtype ConfigInput
}

public extension ConfigContainer {
    func registerContainer(
        pathComponent: String,
        configProperty: any PropertyProtocol<ConfigInput?>
    ) {
        associatedConfigPath = pathComponent

        for (label, child) in Mirror(reflecting: self).children {
            let resolvedLabel = label ?? "unknown"

            if let child = child as? (any ConfigInputIngesting<ConfigInput>) {
                child.registerConfigItemProperty(
                    itemName: resolvedLabel,
                    parentPath: associatedConfigPath,
                    fullPath: "\(associatedConfigPath).\(resolvedLabel)",
                    configProperty: configProperty
                )
            } else if let child = child as? (any ConfigContainer<ConfigInput>) {
                child.registerContainer(
                    pathComponent: "\(associatedConfigPath).\(resolvedLabel)",
                    configProperty: configProperty
                )
            }
        }
    }

    var associatedConfigPath: String {
        get {
            objc_getAssociatedObject(self, &kAssociatedPath) as! String
        }
        set {
            objc_setAssociatedObject(self, &kAssociatedPath, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var kAssociatedPath: Int = 0
