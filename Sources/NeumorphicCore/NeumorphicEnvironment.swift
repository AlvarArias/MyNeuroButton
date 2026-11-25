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
