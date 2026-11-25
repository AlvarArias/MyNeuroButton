import NeumorphicCore
import SwiftUI

/// Raised neumorphic container for grouping content.
///
/// The relief is drawn on a background shape, not on the content, so text and icons
/// inside the card never pick up a shadow halo.
///
/// The shadow extends past the card bounds (about `normalShadowRadius` points). Leave that much
/// space around the card, or `ScrollView`, `List` and `.clipped()` will cut it.
@MainActor
public struct NeuroCard<Content: View>: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme

    // MARK: - Public Properties

    /// Padding between the card edge and its content, in points
    public let padding: CGFloat

    private let explicitTheme: NeumorphicTheme?

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    private let content: Content

    // MARK: - Initialization

    /// - Parameters:
    ///   - padding: Space between the card edge and its content, in points.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    ///   - content: The content shown inside the card.
    public init(
        padding: CGFloat = 16,
        theme: NeumorphicTheme? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.explicitTheme = theme
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        let resolved = explicitTheme ?? environmentTheme

        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: resolved.cornerRadius)
                    .fill(resolved.background)
                    .neumorphicSurface(theme: resolved, isPressed: false)
            }
    }
}
