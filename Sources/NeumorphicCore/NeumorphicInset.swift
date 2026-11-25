import SwiftUI

/// Draws a sunken (inset) neumorphic surface behind any view, in the given shape.
/// Dark inner shadow comes from the top-left, light inner shadow from the bottom-right.
/// Counterpart of `NeumorphicSurface`, which raises a view.
///
/// Shapes with holes (such as a ring) must wind their inner contour in the opposite
/// direction so the hole stays empty under the default fill rule.
public struct NeumorphicInset<S: Shape>: ViewModifier {

    public let theme: NeumorphicTheme
    public let shape: S

    public init(theme: NeumorphicTheme = .default, shape: S) {
        self.theme = theme
        self.shape = shape
    }

    /// How far each inner shadow is shifted, in points.
    public var shadowOffset: CGFloat {
        theme.insetShadowRadius / 2
    }

    public func body(content: Content) -> some View {
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

extension NeumorphicInset where S == RoundedRectangle {
    /// Inset in a rounded rectangle whose corner radius comes from the theme.
    public init(theme: NeumorphicTheme = .default) {
        self.init(theme: theme, shape: RoundedRectangle(cornerRadius: theme.cornerRadius))
    }
}

public extension View {
    /// Sunken surface in a rounded rectangle using the theme's corner radius.
    func neumorphicInset(theme: NeumorphicTheme = .default) -> some View {
        modifier(NeumorphicInset(theme: theme))
    }

    /// Sunken surface in any shape, e.g. `Capsule()` or a ring.
    func neumorphicInset<S: Shape>(in shape: S, theme: NeumorphicTheme = .default) -> some View {
        modifier(NeumorphicInset(theme: theme, shape: shape))
    }
}
