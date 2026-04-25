import SwiftUI

/// Design tokens that control the visual appearance of all neumorphic components.
public struct NeumorphicTheme: Sendable {

    public var background: Color
    public var foreground: Color
    public var cornerRadius: CGFloat
    public var animationDuration: Double
    public var normalShadowRadius: CGFloat
    public var pressedShadowRadius: CGFloat

    public init(
        background: Color = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255),
        foreground: Color = Color(red: 100 / 255, green: 100 / 255, blue: 110 / 255),
        cornerRadius: CGFloat = 10,
        animationDuration: Double = 0.1,
        normalShadowRadius: CGFloat = 10,
        pressedShadowRadius: CGFloat = 5
    ) {
        self.background = background
        self.foreground = foreground
        self.cornerRadius = cornerRadius
        self.animationDuration = animationDuration
        self.normalShadowRadius = normalShadowRadius
        self.pressedShadowRadius = pressedShadowRadius
    }

    public static let `default` = NeumorphicTheme()
}
