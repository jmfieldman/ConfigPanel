//
//  FeatureTwoConfigManager.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public protocol FeatureTwoConfigManager {
    var configInteger: any PropertyProtocol<Int> { get }
    var configString: any PropertyProtocol<String> { get }
}
