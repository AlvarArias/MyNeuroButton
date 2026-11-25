import SwiftUI

/// Draws a sunken (inset) neumorphic surface behind any view.
/// Dark inner shadow comes from the top-left, light inner shadow from the bottom-right.
/// Counterpart of `NeumorphicSurface`, which raises a view.
public struct NeumorphicInset: ViewModifier {

    public let theme: NeumorphicTheme

    public init(theme: NeumorphicTheme = .default) {
        self.theme = theme
    }

    /// How far each inner shadow is shifted, in points.
    public var shadowOffset: CGFloat {
        theme.insetShadowRadius / 2
    }

    public func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.cornerRadius)
        let radius = theme.insetShadowRadius
        let offset = shadowOffset

        return content.background {
            shape
                .fill(theme.background)
                .overlay {
                    shape
                        .stroke(theme.shadowColor.opacity(0.3), lineWidth: radius)
                        .blur(radius: radius / 2)
                        .offset(x: offset, y: offset)
                        .mask(shape)
                }
                .overlay {
                    shape
                        .stroke(theme.highlightColor.opacity(0.8), lineWidth: radius)
                        .blur(radius: radius / 2)
                        .offset(x: -offset, y: -offset)
                        .mask(shape)
                }
        }
    }
}

public extension View {
    func neumorphicInset(theme: NeumorphicTheme = .default) -> some View {
        modifier(NeumorphicInset(theme: theme))
    }
}
