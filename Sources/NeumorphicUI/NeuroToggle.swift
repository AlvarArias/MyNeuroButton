import SwiftUI
import NeumorphicCore

/// Neumorphic-styled toggle button. Stays visually "depressed" while `isOn` is true.
@MainActor
public struct NeuroToggle: View {

    // MARK: - Private Properties

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

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

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
        NeuroPressable(theme: explicitTheme) {
            isOn.toggle()
        } label: { isPressed, theme in
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
            .animation(.easeInOut(duration: theme.animationDuration), value: isOn)
        }
    }
}
