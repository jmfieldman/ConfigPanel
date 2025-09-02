//
//  FeatureOneConfigManagerImpl.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import ConfigPanel
import ConfigRefreshManager
import FeatureOneConfigManager
import Inject

extension TweakCoordinate.Table {
    static var featureOne: TweakCoordinate.Table {
        .init("FeatureOne")
    }
}

extension TweakCoordinate.Section {
    static var sectionOne: TweakCoordinate.Section {
        .init("SectionOne")
    }

    static var sectionTwo: TweakCoordinate.Section {
        .init("SectionTwo")
    }
}

public final class FeatureOneConfigSubContainerImpl: FeatureOneConfigSubContainer, ConfigContainer {
    public typealias ConfigInput = ConfigStruct

    public let configStringThreed: any PropertyProtocol<String> = ConfigItem<String, ConfigInput>(
        default: "000",
        tweak: Tweak(coordinate: .init(.featureOne, .sectionTwo, "Threes"), type: .freeformString()),
        config: { "\($0.string)\($0.string)\($0.string)" }
    )

    public let configToggle: any PropertyProtocol<Bool> = ConfigItem<Bool, ConfigInput>(
        default: false,
        tweak: Tweak(coordinate: .init(.featureOne, .sectionTwo, "Toggle"), type: .boolToggle(default: false))
    )
}

public final class FeatureOneConfigManagerImpl: FeatureOneConfigManager, ConfigContainer {
    public typealias ConfigInput = ConfigStruct

    let configRefreshManager = Inject(ConfigRefreshManager.self)

    public let subContainer: FeatureOneConfigSubContainer = FeatureOneConfigSubContainerImpl()

    public let configIsOdd: any PropertyProtocol<Bool> = ConfigItem<Bool, ConfigInput>(
        default: true,
        tweak: Tweak(coordinate: .init(.featureOne, .sectionOne, "is odd"), type: .boolToggle(default: false)),
        config: { $0.integer % 2 != 0 }
    )

    public let configIsEven: any PropertyProtocol<Bool> = ConfigItem<Bool, ConfigInput>(
        default: true,
        tweak: Tweak(coordinate: .init(.featureOne, .sectionOne, "is even"), type: .boolToggle(default: false)),
        config: { $0.integer % 2 == 0 }
    )

    public init() {
        registerConfigProperty(configRefreshManager.configProperty)
    }
}
