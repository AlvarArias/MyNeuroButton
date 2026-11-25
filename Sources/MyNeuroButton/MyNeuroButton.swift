import SwiftUI
import NeumorphicCore

/// Neumorphic-styled SwiftUI button with SF Symbol support and press animation.
@MainActor
public struct MyNeuroButton: View {

    // MARK: - Private Properties

    @State private var isPressed = false
    @Environment(\.neumorphicTheme) private var environmentTheme
    private let explicitTheme: NeumorphicTheme?

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

    /// Design tokens used when no environment theme applies. Explicit theme passed at init, else `.default`.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    /// Explicit theme if given, otherwise the one from the SwiftUI environment.
    var resolvedTheme: NeumorphicTheme { explicitTheme ?? environmentTheme }

    /// Action executed on tap
    public let action: @MainActor () -> Void

    // MARK: - Initialization

    public init(
        icon: String,
        iconFilled: String,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        theme: NeumorphicTheme? = nil,
        action: @escaping @MainActor () -> Void
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.explicitTheme = theme
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
                RoundedRectangle(cornerRadius: resolvedTheme.cornerRadius)
                    .fill(isPressed ? fillColor : resolvedTheme.background)

                Image(systemName: isPressed ? iconFilled : icon)
                    .foregroundStyle(isPressed ? .white : resolvedTheme.foreground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            .neumorphicSurface(theme: resolvedTheme, isPressed: isPressed)
        }
        .buttonStyle(.plain)
        #if !os(tvOS)
        // Touch-down feedback. tvOS has no press-and-hold gesture API; the focus
        // engine provides feedback there and `action` fires on select.
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: resolvedTheme.animationDuration)) {
                isPressed = pressing
            }
        }, perform: {})
        #endif
    }
}
