# MyNeuroUI — CLAUDE.md

Guidance for AI agents working in this repo. Read `SPEC.md`, `ARCHITECTURE.md` and `tasks.md` before changing code (see also `AGENTS.md`).

## Workflow
1. Pick ONE task from `tasks.md`. Create branch `feat/T-xxx-short-name`.
2. If the task changes structure or a contract, update `ARCHITECTURE.md` (and add an ADR) **before** the code.
3. Write tests with the code, never after.
4. Run the full check before declaring done: `swift build && swift test`, plus the linter once configured (F0-4) and iOS/tvOS builds once CI covers them (F0-5).
5. Have the change reviewed by a different agent than the one that wrote it (`.claude/agents/`, checklists in `docs/reviews/`). Fix findings, then update `tasks.md`.

## Hard rules
- Never read, print or commit credentials or keys.
- Components import only `NeumorphicCore`; `NeumorphicUI` and `MyNeuroButton` never import each other.
- Zero external dependencies. No `AnyView`. No inline shadows or scale: use `NeumorphicSurface` / `NeumorphicInset`.
- Don't expand scope: if you find unrelated problems, add a line to `tasks.md` instead of fixing them.
- Keep `MyNeuroButton` and its deprecated `iconFull` init until the next major version.

## Project Overview

Swift Package Manager library providing neumorphic-styled SwiftUI components with SF Symbol support, smooth press animations, and a shared design token system. Distributed as an open-source package on GitHub.

| Target | Type | Purpose |
|--------|------|---------|
| `Sources/NeumorphicCore/` | SwiftUI | Design tokens, Environment theme, `NeumorphicSurface` / `NeumorphicInset`, `NeuroPressable`, `Color` extensions |
| `Sources/NeumorphicUI/` | SwiftUI | Component library — new components go here |
| `Sources/MyNeuroButton/` | SwiftUI | Legacy backward-compat wrapper (keep until next major version) |
| `Tests/NeumorphicCoreTests/` | XCTest | Tests for tokens, modifiers, `NeuroPressable`, and Color extensions |
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
│   │   ├── NeumorphicTheme.swift                        ← Design tokens struct, `.default` and `.dark`
│   │   ├── NeumorphicEnvironment.swift                  ← `neumorphicTheme` Environment value + adaptive light/dark modifier
│   │   ├── NeumorphicSurface.swift                      ← Raised/pressed ViewModifier + View extension
│   │   ├── NeumorphicInset.swift                        ← Sunken (inner shadow) ViewModifier, generic over the shape
│   │   ├── NeuroPressable.swift                         ← Button + press tracking + theme resolution, base of pressable components
│   │   └── Color+Neumorphic.swift                       ← Color.neumorphicBackground/Foreground
│   ├── NeumorphicUI/
│   │   ├── NeumorphicTheme+Relief.swift                 ← internal `cappingShadow(at:)` for small elements
│   │   ├── NeuroToggle.swift                            ← Toggle
│   │   ├── NeuroCard.swift                              ← Raised container
│   │   ├── NeuroBadge.swift                             ← Small label with optional icon
│   │   ├── NeuroDivider.swift                           ← Horizontal / vertical groove
│   │   ├── NeuroProgress.swift                          ← Progress bar and ring
│   │   ├── NeuroSlider.swift                            ← Slider (drag, step, VoiceOver, tvOS remote)
│   │   ├── NeuroSegmentedControl.swift                  ← Segmented control + `NeuroSegment`
│   │   └── NeuroTextField.swift                         ← Text field with focus ring and error state
│   └── MyNeuroButton/
│       └── MyNeuroButton.swift                          ← Legacy button (backward compat)
└── Tests/
    ├── NeumorphicCoreTests/                             ← NeumorphicCoreTests, NeuroPressableTests
    ├── NeumorphicUITests/                               ← one `Neuro<Name>Tests.swift` per component
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

`NeumorphicUI` and `MyNeuroButton` never import each other. `NeuroPressable` lives in Core (not UI) because `MyNeuroButton` can only depend on Core.

---

## Public API

### `NeumorphicTheme` (design tokens)

```swift
public struct NeumorphicTheme: Sendable, Equatable {
    public var background: Color            // default: RGB(225, 225, 235)
    public var foreground: Color            // default: RGB(100, 100, 110)
    public var cornerRadius: CGFloat        // default: 10
    public var animationDuration: Double    // default: 0.1
    public var normalShadowRadius: CGFloat  // default: 10
    public var pressedShadowRadius: CGFloat // default: 5
    public var insetShadowRadius: CGFloat   // default: 5 (sunken surfaces)
    public var shadowColor: Color           // default: .black (opacity applied by the modifiers)
    public var highlightColor: Color        // default: .white (opacity applied by the modifiers)

    public init(...)                        // every parameter has the default above
    public static let `default` = NeumorphicTheme()
    public static let dark = NeumorphicTheme(...)   // dark grey surface, soft highlight
}
```

### Theme resolution (Environment, ADR-003 / ADR-005)

```swift
EnvironmentValues.neumorphicTheme            // default: .default
View.neumorphicTheme(_ theme: NeumorphicTheme)                          // inject for a subtree
View.neumorphicTheme(light: NeumorphicTheme = .default,
                     dark: NeumorphicTheme = .dark)                     // picks by colorScheme
```

Dark mode is explicit: apps opt in with `.neumorphicTheme()`. `Color.neumorphicBackground` is always the **light** default, so in dark mode use `@Environment(\.neumorphicTheme)` and read `theme.background`.

Every component takes `theme: NeumorphicTheme? = nil`. Resolution inside `body`: `explicitTheme ?? environmentTheme`. The public `theme` property is non-optional (`explicitTheme ?? .default`) and does **not** reflect the Environment (ADR-003 amendment, T-020).

### `NeumorphicSurface` (ViewModifier — raised / pressed)

Applies scale + shadow pair to any view. Dark shadow bottom-right, light shadow top-left at half-offset.

```swift
public struct NeumorphicSurface: ViewModifier {
    public init(theme: NeumorphicTheme = .default, isPressed: Bool)
}

// Convenience extension on View:
.neumorphicSurface(theme: .default, isPressed: Bool)
```

Shadow values derived from theme:
```
isPressed = false  →  scale 1.0,  shadowColor opacity 0.3, highlightColor opacity 0.8, radius = normalShadowRadius
isPressed = true   →  scale 0.95, shadowColor opacity 0.1, highlightColor opacity 0.4, radius = pressedShadowRadius
```
Light shadow offset = `-(radius / 2)` (top-left, half of dark offset).

### `NeumorphicInset` (ViewModifier — sunken, ADR-002)

Paints a sunken surface behind the content: `theme.background` fill plus two blurred inner shadows (dark from top-left, light from bottom-right), clipped to the shape. Offset is `insetShadowRadius / 2`.

```swift
public struct NeumorphicInset<S: Shape>: ViewModifier

// Convenience extensions on View:
.neumorphicInset(theme: .default)                    // RoundedRectangle(theme.cornerRadius)
.neumorphicInset(in: Capsule(), theme: .default)     // any Shape (a ring must wind its inner contour the opposite way)
```

Components never draw inner shadows themselves and never copy the theme to change `cornerRadius`: they pass another shape here.

### `NeuroPressable` (Core, ADR-006)

Plain `Button` that tracks finger-down and resolves the theme. Base of every pressable component.

```swift
@MainActor
public struct NeuroPressable<Content: View>: View {
    public init(
        theme: NeumorphicTheme? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: @escaping (_ isPressed: Bool, _ theme: NeumorphicTheme) -> Content
    )
}
```

On tvOS there is no press gesture: the control grows 10 % while focused (`FocusScale`, respects Reduce Motion) and the system focus platter is removed with a bare button style (T-035).

### Color extensions

```swift
Color.neumorphicBackground   // = NeumorphicTheme.default.background  (always the light default)
Color.neumorphicForeground   // = NeumorphicTheme.default.foreground
```

Single source of truth: values come from `NeumorphicTheme.default`, not hardcoded.

---

## Components

All components are `@MainActor public struct … : View` in `NeumorphicUI` (except `MyNeuroButton`), take `theme: NeumorphicTheme? = nil` and get their look only from `neumorphicSurface` / `neumorphicInset`.

| Component | Role | Primary init |
|-----------|------|--------------|
| `NeuroToggle` | Pressable on/off icon button | `init(icon:iconFilled:isOn:fillColor:width:height:theme:)` |
| `NeuroCard` | Raised container | `init(padding: CGFloat = 16, theme:, content:)` |
| `NeuroBadge` | Small label | `init(_ text: String, systemImage:tint:theme:)` |
| `NeuroDivider` | Groove line | `init(_ axis: Axis = .horizontal, theme:)` |
| `NeuroProgress` | Bar or ring | `init(value:total: = 1, style: = .bar, tint:thickness:theme:)`, `Style` is `.bar` / `.ring` |
| `NeuroSlider` | Drag slider | `init(value: Binding<Double>, in: = 0...1, step:tint:trackHeight:knobSize:accessibilityLabel:theme:)` |
| `NeuroSegmentedControl` | Sliding-pill selector | `init(selection:segments:tint:segmentHeight:theme:)` and `init(selection: Binding<Int>, titles:tint:segmentHeight:theme:)`; segments are `NeuroSegment(_ title:value:systemImage:showsTitle:)` |
| `NeuroTextField` | Sunken text field | `init(_ title: LocalizedStringKey, text:systemImage:isSecure:isError:errorMessage:focusColor:errorColor:fieldHeight:theme:)` |

Notes that are easy to get wrong:
- `NeuroToggle`: the surface stays depressed while `isOn == true`: `.neumorphicSurface(theme: theme, isPressed: isPressed || isOn)`.
- `NeuroProgress`: `value` is a plain `Double` (not a binding), clamped to `0...total`; a non-positive `total` counts as empty.
- `NeuroSlider`: on tvOS it is controlled with `onMoveCommand` (left/right) and shows focus by growing its knob (`focusedKnobScale`, honours Reduce Motion; T-026). Drag respects `layoutDirection`. Exposes VoiceOver `adjustable` actions.
- `NeuroSegmentedControl`: segments are identified by position, so duplicate values do not break it (only the first is highlighted). Respects Reduce Motion.
- `NeuroTextField`: `title` is a `LocalizedStringKey` (T-029 decision: new components localize by key). `errorMessage` is exposed to VoiceOver as a hint.
- Small elements (badge, slider knob, segmented pill) cap their shadow radius with the internal `cappingShadow(at:)` so the shadow does not swallow them.
- Shadows can be clipped by a `ScrollView` / `List` edge: leave padding around raised components.

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
        theme: NeumorphicTheme? = nil,
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

Pressable components (`NeuroToggle`, `MyNeuroButton`, each `NeuroSegmentedControl` segment) are built on `NeuroPressable`, which tracks `isPressed` with `onLongPressGesture(minimumDuration: 0)` — **not** a `ButtonStyle` — so state toggles precisely on finger-down / finger-up. On tvOS the focus engine gives the feedback instead. Shadow and scale live exclusively in `NeumorphicSurface` (raised) and `NeumorphicInset` (sunken); component bodies never define shadows directly.

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
3. Accept `theme: NeumorphicTheme? = nil`; keep `private let explicitTheme` + `public var theme: NeumorphicTheme { explicitTheme ?? .default }`, read `@Environment(\.neumorphicTheme)` and resolve `explicitTheme ?? environmentTheme` in `body` (ADR-003)
4. Pressable component: build it on `NeuroPressable` and use the `isPressed` / `theme` it hands to `label`. Static component: apply `.neumorphicSurface(theme:isPressed:)` (raised) or `.neumorphicInset(theme:)` / `.neumorphicInset(in:theme:)` (sunken) — never write shadow/scale inline
5. Add an accessibility label/value and respect `accessibilityReduceMotion` when animating
6. Create `Tests/NeumorphicUITests/<ComponentName>Tests.swift` with init, defaults, and binding/action tests

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
// Pressable component — NeuroPressable owns press tracking and theme resolution
NeuroPressable(theme: explicitTheme, action: action) { isPressed, theme in
    icon.neumorphicSurface(theme: theme, isPressed: isPressed)
}

// Static component — never inline shadows
content.neumorphicSurface(theme: theme, isPressed: false)   // raised
content.neumorphicInset(theme: theme)                        // sunken
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
