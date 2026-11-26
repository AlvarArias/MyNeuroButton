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

    /// Scale of the control while it holds focus. tvOS has no press gesture and the neumorphic
    /// label draws nothing the focus engine can show, so focus is made visible by growing it.
    static var focusedScale: CGFloat { 1.1 }

    /// Explicit theme if given, otherwise the one from the environment.
    static func resolve(explicit: NeumorphicTheme?, environment: NeumorphicTheme) -> NeumorphicTheme {
        explicit ?? environment
    }

    public var body: some View {
        let theme = Self.resolve(explicit: explicitTheme, environment: environmentTheme)

        Button(action: action) {
            label(isPressed, theme)
                #if os(tvOS)
                .modifier(FocusScale(scale: Self.focusedScale, duration: theme.animationDuration))
                #endif
        }
        .buttonStyle(.plain)
        #if os(tvOS)
        // The system focus platter is a large white rounded rectangle that ignores the
        // neumorphic shape; `FocusScale` above shows focus instead.
        .focusEffectDisabled()
        #else
        // Touch-down feedback. tvOS has no press-and-hold gesture API (see above): there
        // focus is the feedback and `action` fires on select.
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: theme.animationDuration)) {
                isPressed = pressing
            }
        }, perform: {})
        #endif
    }
}

/// Grows its content while the enclosing focusable control holds focus.
/// Must be applied inside the control's label so `isFocused` reflects that control.
struct FocusScale: ViewModifier {
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let scale: CGFloat
    let duration: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isFocused ? scale : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: duration), value: isFocused)
    }
}
