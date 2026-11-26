# MyNeuroUI — CLAUDE.md

## Project Overview

Swift Package Manager library providing neumorphic-styled SwiftUI components with SF Symbol support, smooth press animations, and a shared design token system. Distributed as an open-source package on GitHub.

| Target | Type | Purpose |
|--------|------|---------|
| `Sources/NeumorphicCore/` | SwiftUI | Design tokens, shared `ViewModifier`, `Color` extensions |
| `Sources/NeumorphicUI/` | SwiftUI | Component library — new components go here |
| `Sources/MyNeuroButton/` | SwiftUI | Legacy backward-compat wrapper (keep until next major version) |
| `Tests/NeumorphicCoreTests/` | XCTest | Tests for tokens, modifier, and Color extensions |
| `Tests/NeumorphicUITests/` | XCTest | Tests for each component in `NeumorphicUI` |
| `Tests/MyNeuroButtonTests/` | XCTest | Tests for backward-compat `MyNeuroButton` |

**Frameworks:** SwiftUI  
**Platforms:** iOS 17+, macOS 14+, tvOS 17+  
**Swift version:** 6.2 (strict concurrency: complete)  
**External dependencies:** none

---

## Package Structure

```
MyNeuroUI/
├── Package.swift                                         ← SPM manifest (swift-tools-version: 6.2)
├── Sources/
│   ├── NeumorphicCore/
│   │   ├── NeumorphicTheme.swift                        ← Design tokens struct
│   │   ├── NeumorphicSurface.swift                      ← Shared ViewModifier + View extension
│   │   └── Color+Neumorphic.swift                       ← Color.neumorphicBackground/Foreground
│   ├── NeumorphicUI/
│   │   └── NeuroToggle.swift                            ← Toggle component
│   └── MyNeuroButton/
│       └── MyNeuroButton.swift                          ← Legacy button (backward compat)
└── Tests/
    ├── NeumorphicCoreTests/
    │   └── NeumorphicCoreTests.swift
    ├── NeumorphicUITests/
    │   └── NeuroToggleTests.swift
    └── MyNeuroButtonTests/
        └── MyNeuroButtonTests.swift
```

---

## Target Dependency Graph

```
NeumorphicCore   (no deps)
      ↑
      ├── NeumorphicUI      ← new components
      └── MyNeuroButton     ← legacy
```

---

## Public API

### `NeumorphicTheme` (design tokens)

```swift
public struct NeumorphicTheme: Sendable {
    public var background: Color            // default: RGB(225, 225, 235)
    public var foreground: Color            // default: RGB(100, 100, 110)
    public var cornerRadius: CGFloat        // default: 10
    public var animationDuration: Double    // default: 0.1
    public var normalShadowRadius: CGFloat  // default: 10
    public var pressedShadowRadius: CGFloat // default: 5

    public static let `default` = NeumorphicTheme()
}
```

### `NeumorphicSurface` (ViewModifier)

Applies scale + shadow pair to any view. Dark shadow bottom-right, white shadow top-left at half-offset.

```swift
public struct NeumorphicSurface: ViewModifier {
    public init(theme: NeumorphicTheme = .default, isPressed: Bool)
}

// Convenience extension on View:
.neumorphicSurface(theme: .default, isPressed: Bool)
```

Shadow values derived from theme:
```
isPressed = false  →  scale 1.0,  black opacity 0.3, white opacity 0.8, radius = normalShadowRadius
isPressed = true   →  scale 0.95, black opacity 0.1, white opacity 0.4, radius = pressedShadowRadius
```
White shadow offset = `-(radius / 2)` (top-left, half of dark offset).

### Color extensions

```swift
Color.neumorphicBackground   // = NeumorphicTheme.default.background
Color.neumorphicForeground   // = NeumorphicTheme.default.foreground
```

Single source of truth: values come from `NeumorphicTheme.default`, not hardcoded.

---

## Components

### `NeuroToggle` — `NeumorphicUI`

```swift
@MainActor
public struct NeuroToggle: View {
    public init(
        icon: String,               // SF Symbol — off state
        iconFilled: String,         // SF Symbol — on state
        isOn: Binding<Bool>,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        theme: NeumorphicTheme = .default
    )
}
```

Surface stays visually depressed while `isOn == true`: `.neumorphicSurface(theme: theme, isPressed: isPressed || isOn)`.

### `MyNeuroButton` — `MyNeuroButton` (legacy)

```swift
@MainActor
public struct MyNeuroButton: View {
    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        theme: NeumorphicTheme = .default,
        action: @escaping @MainActor () -> Void
    )
}
```

Deprecated initializer (backward compatibility — remove on next major version):
```swift
@available(*, deprecated, message: "Use init(icon:iconFilled:fillColor:width:height:theme:action:) instead")
public init(icon:iconFull:fillColor:height:width:action:)
```

---

## Visual Behaviour

All components use `onLongPressGesture(minimumDuration: 0)` to track `isPressed` — **not** a `ButtonStyle` — so state toggles precisely on finger-down / finger-up. Shadow and scale live exclusively in `NeumorphicSurface`; component bodies never define shadows directly.

---

## Development Guidelines

### General Rules
- Keep the library zero-dependency — never add external packages
- All public API additions must include corresponding `XCTest` cases
- Do not use `AnyView` — keep view bodies strongly typed
- New components go in `Sources/NeumorphicUI/`, not in `MyNeuroButton`
- Preserve the deprecated `iconFull` initializer in `MyNeuroButton` until a semver-major release

### Adding a new component
1. Create `Sources/NeumorphicUI/<ComponentName>.swift`
2. Mark the struct `@MainActor` and conform to `View`
3. Accept `theme: NeumorphicTheme = .default` as a parameter
4. Apply `.neumorphicSurface(theme: theme, isPressed: ...)` — never write shadow/scale inline
5. Create `Tests/NeumorphicUITests/<ComponentName>Tests.swift` with init, defaults, and binding/action tests

### Adding parameters to an existing component
1. Add the `public let` property
2. Add to primary `init` with a default value
3. If the component is in `MyNeuroButton`, also update the deprecated `init` to forward it
4. Add a test case

### Adding tokens to `NeumorphicTheme`
1. Add property with a default value
2. Update `NeumorphicSurface` if the new token affects shadow/scale behaviour
3. Add a test in `NeumorphicCoreTests`

### SwiftUI Patterns
```swift
// Press tracking — keep this pattern in every component
.onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
    withAnimation(.easeInOut(duration: theme.animationDuration)) { isPressed = pressing }
}, perform: {})

// Apply surface — never inline shadows
.neumorphicSurface(theme: theme, isPressed: isPressed)
```

### Naming Conventions
- Types: `UpperCamelCase`
- Properties/functions: `lowerCamelCase`
- New components: `Neuro<Name>` (e.g. `NeuroCard`, `NeuroSlider`)
- SF Symbol names come from the caller — validate nothing

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
| Deprecated init | `iconFull` init in `MyNeuroButton` — remove on next major version | Low |
| Color extensions | `neumorphicBackground/Foreground` are `public` — could conflict if consumer also extends `Color` | Low |
| Platforms | visionOS not listed — add `.visionOS(.v3)` if the package targets Apple Vision Pro | Low |
| MyNeuroButton target | Legacy target kept for backward compat — migrate consumers to `NeumorphicUI` and remove on next major | Medium |
