import SwiftUI
import NeumorphicCore

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

    /// Design tokens controlling shadows, corner radius, and animation
    public let theme: NeumorphicTheme

    /// Action executed on tap
    public let action: @MainActor () -> Void

    // MARK: - Initialization

    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        theme: NeumorphicTheme = .default,
        action: @escaping @MainActor () -> Void
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.theme = theme
        self.action = action
    }

    @available(*, deprecated, message: "Use init(icon:iconFilled:fillColor:width:height:theme:action:) instead")
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
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isPressed ? fillColor : theme.background)

                Image(systemName: isPressed ? iconFilled : icon)
                    .foregroundStyle(isPressed ? .white : theme.foreground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            .neumorphicSurface(theme: theme, isPressed: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: theme.animationDuration)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
