# ConfigPanel

ConfigPanel is a Swift framework for managing runtime configuration and feature toggles in iOS applications. It provides an elegant way to expose application settings through a configurable UI, allowing developers and QA teams to modify app behavior without recompiling.

## Features

- **Runtime Configuration**: Modify application settings at runtime
- **Feature Toggles**: Enable/disable features dynamically 
- **Multiple Input Types**: Support for toggles, freeform text inputs, and selection controls
- **Persistent Storage**: Configuration values persist between app launches
- **UI Integration**: Built-in UIKit view controllers for displaying tweak interfaces
- **Combine Support**: Leverages Combine framework for reactive programming patterns

## Core Components

### Tweak
The `Tweak` class represents a single configuration option. Each tweak is identified by a coordinate (table, section, row) and has a specific type.

### TweakType
Defines the different types of configuration options:
- `toggle`: Boolean on/off switches
- `freeform`: Text inputs for custom values  
- `selection`: Dropdown selections from predefined options
- `namedSelection`: Named dropdown selections

### TweakRepository
Manages all registered tweaks and provides persistent storage using `PersistentProperty`.

### ConfigItem
A wrapper that combines both tweak configuration and external config inputs (like server-side configurations) into a single reactive property.

### TweakViewController
A UIKit view controller that displays all tweaks organized by table and section, with built-in reset functionality.

## Usage Example

```swift
// Define a tweak coordinate
let myFeatureTweak = TweakCoordinate(
    .init("MyApp"), 
    .init("Features"), 
    "Enable New Feature"
)

// Create a boolean toggle tweak
let myFeatureToggle = Tweak(
    coordinate: myFeatureTweak,
    type: .boolToggle(defaultOn: false)
)

// Create a string tweak
let myStringTweak = Tweak(
    coordinate: .init(.init("MyApp"), .init("Settings"), "API Endpoint"),
    type: .freeformString(default: "https://api.example.com")
)

// Create a selection tweak
let mySelectionTweak = Tweak(
    coordinate: .init(.init("MyApp"), .init("Settings"), "Theme"),
    type: .selection(
        options: ["Light", "Dark", "Auto"],
        defaultIndex: 0
    )
)
```

## Integration with Config Items

`ConfigItem` combines both tweak configuration and external config inputs.

`ConfigItem` resolution order:
1. Use Tweak value, if it is enabled
2. Otherwise, use external config value, if non-nil
3. Otherwise, use default value

```swift
// Create a config item that uses both tweaks and server configs
let myConfigItem = ConfigItem<String, ServerConfigType>(
    default: "default_value",
    tweak: myStringTweak,
    config: { serverConfig in
        // Resolve from server configuration if available
        return serverConfig?.apiEndpoint
    }
)
```

Your config API modules should expose these as CombineEx.PropertyProtocol, which masks the external config implementation.

```swift
import CombineEx

protocol Configs {
    var myConfigItem: PropertyProtocol<String> { get }
}
```

In your implementation modules, you should have a `ConfigContainer` that holds some number of `ConfigItem`, and may also contain nested containers. 

You then use the method `registerConfigProperty` on the container to inject the argument (a `PropertyProtocol<ConfigItem>`) into all child/sub-child `ConfigItem` instances.

Note that ConfigItem will subscribe to the external config lazily -- i.e. it will not execute its external config resolution block until it is subscribed to. This ensures that any exposure mechanisms in your resolution block do not fire until the config is actually used.

```swift
class MyContainer: ConfigContainer {
    init() {
        registerConfigProperty(someExternalConfigProperty)
    }

    let config1 = ConfigItem(...)
    let config2 = ConfigItem(...)
    let configSubcontainer = MySubContainer()
}
```

## UI Integration

To display the tweak interface:

```swift
present(TweakViewController(), animated: true)
```

## Installation

ConfigPanel can be integrated into your iOS project using Swift Package Manager or as a dependency in your project's package manifest.

## Dependencies

ConfigPanel is built using [CombineEx](https://github.com/jmfieldman/CombineEx), and uses CombineEx.Property and CombineEx.PersistentProperty to expose and store config items.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
