import SwiftUI

/// Applies neumorphic shadows and press-scale to any view.
/// Dark shadow: bottom-right. White shadow: top-left (half-offset).
public struct NeumorphicSurface: ViewModifier {

    public let theme: NeumorphicTheme
    public let isPressed: Bool

    public init(theme: NeumorphicTheme = .default, isPressed: Bool) {
        self.theme = theme
        self.isPressed = isPressed
    }

    public func body(content: Content) -> some View {
        let radius = isPressed ? theme.pressedShadowRadius : theme.normalShadowRadius
        return content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.black.opacity(isPressed ? 0.1 : 0.3),
                radius: radius,
                x: radius,
                y: radius
            )
            .shadow(
                color: Color.white.opacity(isPressed ? 0.4 : 0.8),
                radius: radius,
                x: -(radius / 2),
                y: -(radius / 2)
            )
    }
}

public extension View {
    func neumorphicSurface(theme: NeumorphicTheme = .default, isPressed: Bool) -> some View {
        modifier(NeumorphicSurface(theme: theme, isPressed: isPressed))
    }
}
