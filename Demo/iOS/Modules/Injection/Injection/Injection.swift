//
//  Injection.swift
//  Copyright © 2025 Jason Fieldman.
//

import ConfigRefreshManager
import ConfigRefreshManagerImpl
import FeatureOneConfigManager
import FeatureOneConfigManagerImpl
import FeatureTwoConfigManager
import FeatureTwoConfigManagerImpl
@_exported import Inject

public extension InjectionManager {
    static func registerInjections() {
        InjectionManager.register(ConfigRefreshManager.self) { ConfigRefreshManagerImpl() }
        InjectionManager.register(FeatureOneConfigManager.self) { FeatureOneConfigManagerImpl() }
        InjectionManager.register(FeatureTwoConfigManager.self) { FeatureTwoConfigManagerImpl() }
    }
}
