import SwiftUI

public extension EnvironmentValues {
    /// Theme used by neumorphic components that were not given an explicit `theme`.
    @Entry var neumorphicTheme: NeumorphicTheme = .default
}

public extension View {
    /// Sets the neumorphic theme for this view and its subviews.
    func neumorphicTheme(_ theme: NeumorphicTheme) -> some View {
        environment(\.neumorphicTheme, theme)
    }
}

/// Picks a theme from the current color scheme and injects it into the environment.
public struct AdaptiveNeumorphicTheme: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    public let light: NeumorphicTheme
    public let dark: NeumorphicTheme

    public init(light: NeumorphicTheme = .default, dark: NeumorphicTheme = .dark) {
        self.light = light
        self.dark = dark
    }

    /// Theme that applies for the given color scheme.
    public func theme(for scheme: ColorScheme) -> NeumorphicTheme {
        scheme == .dark ? dark : light
    }

    public func body(content: Content) -> some View {
        content.environment(\.neumorphicTheme, theme(for: colorScheme))
    }
}

public extension View {
    /// Uses `light` or `dark` depending on the current color scheme. Defaults to `.default` and `.dark`.
    func neumorphicTheme(light: NeumorphicTheme = .default, dark: NeumorphicTheme = .dark) -> some View {
        modifier(AdaptiveNeumorphicTheme(light: light, dark: dark))
    }
}
