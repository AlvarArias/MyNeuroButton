# MyNeuroButton

![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat&logo=swift)
![SPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen?style=flat)
![iOS](https://img.shields.io/badge/iOS-26+-blue?style=flat&logo=apple)
![macOS](https://img.shields.io/badge/macOS-26+-blue?style=flat&logo=apple)
![tvOS](https://img.shields.io/badge/tvOS-26+-blue?style=flat&logo=apple)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat)

A customizable SwiftUI button component with neumorphic design and smooth animations. Supports SF Symbols, adjustable size and color, and runs on iOS, macOS, and tvOS.

---

## Features

- Neumorphic design with realistic light and shadow
- SF Symbol support — normal and pressed states
- Customizable color, width, and height
- Fluid press animation with visual feedback
- Cross-platform: iOS, macOS, tvOS
- Unit test coverage included

---

## Requirements

| Requirement | Minimum version |
|-------------|----------------|
| Swift       | 6.0            |
| iOS         | 26+            |
| macOS       | 26+            |
| tvOS        | 26+            |
| Xcode       | 16+            |

---

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies**, then enter the repository URL:

```
https://github.com/AlvarArias/MyNeuroButton
```

Or add it manually to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AlvarArias/MyNeuroButton.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["MyNeuroButton"]
    )
]
```

---

## Usage

### Basic example

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

### Custom size and color

```swift
MyNeuroButton(
    icon: "heart",
    iconFilled: "heart.fill",
    fillColor: .red,
    width: 120,
    height: 80
) {
    performFavoriteAction()
}
```

---

## API Reference

### `MyNeuroButton`

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

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `String` | Required | SF Symbol name for normal state |
| `iconFilled` | `String` | Required | SF Symbol name for pressed state |
| `fillColor` | `Color` | `.blue` | Accent color when pressed |
| `width` | `CGFloat` | `100` | Button width in points |
| `height` | `CGFloat` | `100` | Button height in points |
| `action` | `() -> Void` | Required | Closure executed on tap |

### Color extensions

```swift
Color.neumorphicBackground  // Default background color
Color.neumorphicForeground  // Default foreground color
```

---

## Screenshots

| Normal State | Pressed State |
|---|---|
| ![Normal](https://github.com/AlvarArias/MyNeuroButton/assets/7523384/9f7db769-72f3-4d57-abad-5999664b3874) | ![Pressed](https://github.com/AlvarArias/MyNeuroButton/assets/7523384/7210c273-0b29-43df-9ae5-f1a936b20c00) |

---

## License

Available under the [MIT](LICENSE) license.

---

Developed by [Alvar Arias](https://github.com/AlvarArias) · [LinkedIn](https://www.linkedin.com/in/alvararias/) · [Portfolio](https://alvararias.github.io/)
