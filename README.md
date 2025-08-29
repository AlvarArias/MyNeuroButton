# MyNeuroButton

A customizable SwiftUI button component with beautiful neumorphic design and smooth animations.

## Features

- 🎨 **Neumorphic Design**: Modern, soft UI aesthetics with realistic shadows
- 🖼️ **SF Symbol Support**: Built-in support for Apple's SF Symbols
- 🌈 **Customizable**: Adjustable colors, sizes, and icons
- ✨ **Smooth Animations**: Fluid press animations with visual feedback
- 📱 **Cross-Platform**: Works on iOS, macOS, and tvOS
- 🧪 **Tested**: Comprehensive unit test coverage

## Requirements

- iOS 13.0+ / macOS 11.0+ / tvOS 13.0+
- Xcode 12.0+
- Swift 5.8+

## Installation

### Swift Package Manager

Add MyNeuroButton to your project using Swift Package Manager:

1. In Xcode, select **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/AlvarArias/MyNeuroButton.git`
3. Select the version you want to use
4. Click **Add Package**

Alternatively, you can add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/AlvarArias/MyNeuroButton.git", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import SwiftUI
import MyNeuroButton

struct ContentView: View {
    var body: some View {
        MyNeuroButton(
            icon: "star",
            iconFilled: "star.fill",
            fillColor: .blue
        ) {
            print("Button tapped!")
        }
    }
}
```

### Advanced Usage

```swift
MyNeuroButton(
    icon: "heart",
    iconFilled: "heart.fill",
    fillColor: .red,
    width: 120,
    height: 80
) {
    // Handle button tap
    performFavoriteAction()
}
```

### Available Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `String` | Required | SF Symbol name for normal state |
| `iconFilled` | `String` | Required | SF Symbol name for pressed state |
| `fillColor` | `Color` | `.blue` | Background color when pressed |
| `width` | `CGFloat` | `100` | Button width in points |
| `height` | `CGFloat` | `100` | Button height in points |
| `action` | `() -> Void` | Required | Action to perform on tap |

## Examples

![Normal State](https://github.com/AlvarArias/MyNeuroButton/assets/7523384/9f7db769-72f3-4d57-abad-5999664b3874)

![Pressed State](https://github.com/AlvarArias/MyNeuroButton/assets/7523384/7210c273-0b29-43df-9ae5-f1a936b20c00)

## API Reference

### MyNeuroButton

The main button component with neumorphic styling.

```swift
public struct MyNeuroButton: View {
    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        action: @escaping () -> Void
    )
}
```

### Color Extensions

The package includes predefined colors for neumorphic design:

```swift
Color.neumorphicBackground  // Default background color
Color.neumorphicForeground  // Default foreground color
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MyNeuroButton is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

Created by [Álvar Arias](https://github.com/AlvarArias)

---

*Made with ❤️ for the Swift community*