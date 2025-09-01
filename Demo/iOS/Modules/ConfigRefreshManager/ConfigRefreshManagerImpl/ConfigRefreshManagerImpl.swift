//
//  ConfigRefreshManagerImpl.swift
//  Copyright © 2025 Jason Fieldman.
//

import CombineEx
import ConfigPanel
import ConfigRefreshManager

public final class ConfigRefreshManagerImpl: ConfigRefreshManager {
    var currentIncrement: Int = 1

    let mutableConfigStruct = MutableProperty<ConfigStruct?>(ConfigStruct(1))
    public private(set) lazy var configProperty = Property(mutableConfigStruct)

    public init() {}

    public func incrementConfigStruct() {
        currentIncrement += 1
        mutableConfigStruct.value = ConfigStruct(currentIncrement)
    }
}
