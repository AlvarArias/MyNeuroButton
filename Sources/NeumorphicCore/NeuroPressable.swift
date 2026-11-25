import SwiftUI

/// Plain button that tracks the finger-down state and resolves the theme.
///
/// The `label` closure receives the live `isPressed` flag and the resolved theme, so each
/// component decides how every state looks. Press tracking uses
/// `onLongPressGesture(minimumDuration: 0)` instead of a `ButtonStyle` so the state flips
/// exactly on finger-down / finger-up.
@MainActor
public struct NeuroPressable<Content: View>: View {

    @State private var isPressed = false
    @Environment(\.neumorphicTheme) private var environmentTheme

    let explicitTheme: NeumorphicTheme?
    let action: @MainActor () -> Void
    private let label: (_ isPressed: Bool, _ theme: NeumorphicTheme) -> Content

    public init(
        theme: NeumorphicTheme? = nil,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: @escaping (_ isPressed: Bool, _ theme: NeumorphicTheme) -> Content
    ) {
        self.explicitTheme = theme
        self.action = action
        self.label = label
    }

    /// Explicit theme if given, otherwise the one from the environment.
    static func resolve(explicit: NeumorphicTheme?, environment: NeumorphicTheme) -> NeumorphicTheme {
        explicit ?? environment
    }

    public var body: some View {
        let theme = Self.resolve(explicit: explicitTheme, environment: environmentTheme)

        Button(action: action) {
            label(isPressed, theme)
        }
        .buttonStyle(.plain)
        #if !os(tvOS)
        // Touch-down feedback. tvOS has no press-and-hold gesture API; the focus
        // engine provides feedback there and `action` fires on select.
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: theme.animationDuration)) {
                isPressed = pressing
            }
        }, perform: {})
        #endif
    }
}
