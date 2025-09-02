//
//  FeatureOneConfigManager.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx

public protocol FeatureOneConfigSubContainer {
    var configStringThreed: any PropertyProtocol<String> { get }
    var configToggle: any PropertyProtocol<Bool> { get }
}

public protocol FeatureOneConfigManager {
    var subContainer: FeatureOneConfigSubContainer { get }

    var configIsEven: any PropertyProtocol<Bool> { get }
    var configIsOdd: any PropertyProtocol<Bool> { get }
}
