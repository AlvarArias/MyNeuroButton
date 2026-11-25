import SwiftUI

/// Design tokens that control the visual appearance of all neumorphic components.
public struct NeumorphicTheme: Sendable, Equatable {

    public var background: Color
    public var foreground: Color
    public var cornerRadius: CGFloat
    public var animationDuration: Double
    public var normalShadowRadius: CGFloat
    public var pressedShadowRadius: CGFloat
    public var insetShadowRadius: CGFloat
    /// Color of the dark shadow (opacity is applied by the surface modifiers).
    public var shadowColor: Color
    /// Color of the light shadow (opacity is applied by the surface modifiers).
    public var highlightColor: Color

    public init(
        background: Color = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255),
        foreground: Color = Color(red: 100 / 255, green: 100 / 255, blue: 110 / 255),
        cornerRadius: CGFloat = 10,
        animationDuration: Double = 0.1,
        normalShadowRadius: CGFloat = 10,
        pressedShadowRadius: CGFloat = 5,
        insetShadowRadius: CGFloat = 5,
        shadowColor: Color = .black,
        highlightColor: Color = .white
    ) {
        self.background = background
        self.foreground = foreground
        self.cornerRadius = cornerRadius
        self.animationDuration = animationDuration
        self.normalShadowRadius = normalShadowRadius
        self.pressedShadowRadius = pressedShadowRadius
        self.insetShadowRadius = insetShadowRadius
        self.shadowColor = shadowColor
        self.highlightColor = highlightColor
    }

    public static let `default` = NeumorphicTheme()

    /// Dark counterpart of `.default`: dark grey surface, soft highlight.
    public static let dark = NeumorphicTheme(
        background: Color(red: 38 / 255, green: 40 / 255, blue: 46 / 255),
        foreground: Color(red: 190 / 255, green: 190 / 255, blue: 200 / 255),
        highlightColor: Color.white.opacity(0.2)
    )
}
