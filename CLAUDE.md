# MyNeuroButton — CLAUDE.md

## Project Overview

Swift Package Manager library that provides a neumorphic-styled SwiftUI button with SF Symbol support, smooth press animations, and customizable appearance. Distributed as an open-source package on GitHub.

| Component | Type | Purpose |
|-----------|------|---------|
| `Sources/MyNeuroButton/` | SwiftUI | Main library source — `MyNeuroButton` view + `Color` extensions |
| `Tests/MyNeuroButtonTests/` | XCTest | Unit tests for initialization, defaults, actions, and backward compatibility |

**Frameworks:** SwiftUI  
**Platforms:** iOS 26+, macOS 26+, tvOS 26+  
**Swift version:** 6.0 (strict concurrency: complete)  
**External dependencies:** none

---

## Package Structure

```
MyNeuroButton/
├── Package.swift                                    ← SPM manifest (swift-tools-version: 6.2)
├── Sources/
│   └── MyNeuroButton/
│       └── MyNeuroButton.swift                      ← MyNeuroButton struct + Color extensions
└── Tests/
    └── MyNeuroButtonTests/
        └── MyNeuroButtonTests.swift                 ← XCTestCase suite
```

---

## Public API

### `MyNeuroButton` (SwiftUI `View`)

```swift
@MainActor
public struct MyNeuroButton: View {
    public init(
        icon: String,           // SF Symbol name — normal state
        iconFilled: String,     // SF Symbol name — pressed state
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        action: @escaping @MainActor () -> Void
    )
}
```

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `icon` | `String` | required | SF Symbol for unpressed state |
| `iconFilled` | `String` | required | SF Symbol for pressed state |
| `fillColor` | `Color` | `.blue` | Background when pressed |
| `width` | `CGFloat` | `100` | Button width in points |
| `height` | `CGFloat` | `100` | Button height in points |
| `action` | `@MainActor () -> Void` | required | Called on tap |

### Deprecated initializer (backward compatibility)

```swift
// Old parameter name was `iconFull` — now `iconFilled`
@available(*, deprecated, message: "Use init(icon:iconFilled:fillColor:width:height:action:) instead")
public init(icon:iconFull:fillColor:height:width:action:)
```

Keep this initializer in place until a major version bump removes it.

### Color extensions

```swift
Color.neumorphicBackground   // RGB(225, 225, 235) — light grey-blue
Color.neumorphicForeground   // RGB(100, 100, 110) — medium grey
```

---

## Visual Behaviour

The button uses `onLongPressGesture` (minimumDuration: 0) to track the `pressing` state — **not** a `Button` with a custom style — so `isPressed` toggles precisely on finger-down / finger-up.

```
isPressed = false  →  neumorphicBackground fill, dark+white outer shadows (radius 10), scale 1.0
isPressed = true   →  fillColor fill,            dark+white inner shadows (radius 5),  scale 0.95
```

Animation: `.easeInOut(duration: 0.1)` on the press transition.

---

## Development Guidelines

### General Rules
- Keep the library zero-dependency — never add external packages
- All public API additions must include corresponding `XCTest` cases
- Do not use `AnyView` — keep the view body strongly typed
- Preserve the deprecated `iconFull` initializer until a semver-major release

### SwiftUI Patterns
```swift
// Press tracking — keep this pattern, do not replace with ButtonStyle
.onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
    withAnimation(.easeInOut(duration: 0.1)) { isPressed = pressing }
}, perform: {})

// Shadow pair (light source = top-left)
.shadow(color: Color.black.opacity(...), radius: ..., x: positive, y: positive)
.shadow(color: Color.white.opacity(...), radius: ..., x: negative, y: negative)
```

### Adding new parameters
1. Add the `public let` property
2. Update the primary `init` with a default value when sensible
3. Update the deprecated `init` to forward the new parameter
4. Add a test case in `MyNeuroButtonTests`

### Naming Conventions
- Types: `UpperCamelCase`
- Properties/functions: `lowerCamelCase`
- SF Symbol names come from the caller — validate nothing, trust `Image(systemName:)` to handle unknowns gracefully

---

## Running Tests

```bash
swift test
```

Tests run on macOS (the host). No simulator required.

---

## Known Issues / Tech Debt

| Area | Issue | Priority |
|------|-------|----------|
| Deprecated init | `iconFull` init kept for backward compat — remove on next major version | Low |
| Color extensions | `neumorphicBackground/Foreground` are `public` — could conflict if consumer also extends `Color` | Low |
| Platforms | visionOS not listed — add `.visionOS(.v3)` if the package is used on Apple Vision Pro | Low |
