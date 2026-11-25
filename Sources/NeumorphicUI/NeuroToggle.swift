import SwiftUI
import NeumorphicCore

/// Neumorphic-styled toggle button. Stays visually "depressed" while `isOn` is true.
@MainActor
public struct NeuroToggle: View {

    // MARK: - Private Properties

    @State private var isPressed = false
    @Environment(\.neumorphicTheme) private var environmentTheme
    private let explicitTheme: NeumorphicTheme?

    // MARK: - Public Properties

    /// SF Symbol name for the off state
    public let icon: String

    /// SF Symbol name for the on state
    public let iconFilled: String

    /// Background color while the toggle is on
    public let fillColor: Color

    /// Button width in points
    public let width: CGFloat

    /// Button height in points
    public let height: CGFloat

    /// Design tokens used when no environment theme applies. Explicit theme passed at init, else `.default`.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    /// Explicit theme if given, otherwise the one from the SwiftUI environment.
    var resolvedTheme: NeumorphicTheme { explicitTheme ?? environmentTheme }

    /// Binding that drives on/off state
    @Binding public var isOn: Bool

    // MARK: - Initialization

    public init(
        icon: String,
        iconFilled: String,
        isOn: Binding<Bool>,
        fillColor: Color = .blue,
        width: CGFloat = 100,
        height: CGFloat = 100,
        theme: NeumorphicTheme? = nil
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self._isOn = isOn
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.explicitTheme = theme
    }

    // MARK: - Body

    public var body: some View {
        Button {
            withAnimation(.easeInOut(duration: resolvedTheme.animationDuration)) {
                isOn.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: resolvedTheme.cornerRadius)
                    .fill(isOn ? fillColor : resolvedTheme.background)

                Image(systemName: isOn ? iconFilled : icon)
                    .foregroundStyle(isOn ? .white : resolvedTheme.foreground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            // Surface looks pressed while either the finger is down OR the toggle is on
            .neumorphicSurface(theme: resolvedTheme, isPressed: isPressed || isOn)
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
