import SwiftUI

/// Neumorphic-styled SwiftUI button with SF Symbol support and press animation.
@MainActor
public struct MyNeuroButton: View {

    // MARK: - Private Properties

    @State private var isPressed = false

    // MARK: - Public Properties

    /// SF Symbol name for the normal (unpressed) state
    public let icon: String

    /// SF Symbol name for the pressed state
    public let iconFilled: String

    /// Background color when the button is pressed
    public let fillColor: Color

    /// Button width in points
    public let width: CGFloat

    /// Button height in points
    public let height: CGFloat

    /// Action executed on tap
    public let action: @MainActor () -> Void

    // MARK: - Initialization

    /// - Parameters:
    ///   - icon: SF Symbol name for the normal state
    ///   - iconFilled: SF Symbol name for the pressed state
    ///   - fillColor: Background color when pressed (default: `.blue`)
    ///   - width: Button width in points (default: `100`)
    ///   - height: Button height in points (default: `100`)
    ///   - action: Closure executed when tapped
    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        action: @escaping @MainActor () -> Void
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.action = action
    }

    @available(*, deprecated, message: "Use init(icon:iconFilled:fillColor:width:height:action:) instead")
    public init(
        icon: String,
        iconFull: String,
        fillColor: Color = .blue,
        height: CGFloat = 100,
        width: CGFloat = 100,
        action: @escaping @MainActor () -> Void
    ) {
        self.init(
            icon: icon,
            iconFilled: iconFull,
            fillColor: fillColor,
            width: width,
            height: height,
            action: action
        )
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isPressed ? fillColor : Color.neumorphicBackground)

                Image(systemName: isPressed ? iconFilled : icon)
                    .foregroundStyle(isPressed ? .white : Color.neumorphicForeground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: Color.black.opacity(isPressed ? 0.1 : 0.3),
                radius: isPressed ? 5 : 10,
                x: isPressed ? 5 : 10,
                y: isPressed ? 5 : 10
            )
            .shadow(
                color: Color.white.opacity(isPressed ? 0.4 : 0.8),
                radius: isPressed ? 5 : 10,
                x: isPressed ? -2 : -5,
                y: isPressed ? -2 : -5
            )
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Color Extensions

public extension Color {
    /// Light grey-blue background for neumorphic design
    static let neumorphicBackground = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)

    /// Medium grey foreground for neumorphic design
    static let neumorphicForeground = Color(red: 100 / 255, green: 100 / 255, blue: 110 / 255)
}
