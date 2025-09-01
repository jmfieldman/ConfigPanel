//
//  FeatureTwoConfigManagerImpl.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import ConfigPanel
import ConfigRefreshManager
import FeatureTwoConfigManager
import Inject

extension TweakCoordinate.Table {
    static var featureTwo: TweakCoordinate.Table {
        .init("FeatureTwo")
    }
}

extension TweakCoordinate.Section {
    static var variables: TweakCoordinate.Section {
        .init("variables")
    }
}

public final class FeatureTwoConfigManagerImpl: FeatureTwoConfigManager, ConfigContainer {
    public typealias ConfigInput = ConfigStruct

    let configRefreshManager = Inject(ConfigRefreshManager.self)

    public let configInteger: any PropertyProtocol<Int> = ConfigItem<Int, ConfigInput>(
        default: 0,
        tweak: Tweak(coordinate: .init(.featureTwo, .variables, "integer"), type: .freeformInt()),
        config: { $0.integer }
    )

    public let configString: any PropertyProtocol<String> = ConfigItem<String, ConfigInput>(
        default: "",
        tweak: Tweak(coordinate: .init(.featureTwo, .variables, "string"), type: .freeformString()),
        config: { $0.string }
    )

    public init() {
        registerConfigProperty(configRefreshManager.configProperty)
    }
}
