import SwiftUI
import NeumorphicCore

/// Neumorphic-styled toggle button. Stays visually "depressed" while `isOn` is true.
@MainActor
public struct NeuroToggle: View {

    // MARK: - Private Properties

    @State private var isPressed = false

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

    /// Design tokens controlling shadows, corner radius, and animation
    public let theme: NeumorphicTheme

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
        theme: NeumorphicTheme = .default
    ) {
        self.icon = icon
        self.iconFilled = iconFilled
        self._isOn = isOn
        self.fillColor = fillColor
        self.width = width
        self.height = height
        self.theme = theme
    }

    // MARK: - Body

    public var body: some View {
        Button {
            withAnimation(.easeInOut(duration: theme.animationDuration)) {
                isOn.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isOn ? fillColor : theme.background)

                Image(systemName: isOn ? iconFilled : icon)
                    .foregroundStyle(isOn ? .white : theme.foreground)
                    .font(.title2)
            }
            .frame(width: width, height: height)
            // Surface looks pressed while either the finger is down OR the toggle is on
            .neumorphicSurface(theme: theme, isPressed: isPressed || isOn)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: theme.animationDuration)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
