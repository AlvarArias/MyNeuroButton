import NeumorphicCore
import SwiftUI

/// Raised neumorphic container for grouping content.
///
/// The relief is drawn on a background shape, not on the content, so text and icons
/// inside the card never pick up a shadow halo.
@MainActor
public struct NeuroCard<Content: View>: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme

    // MARK: - Public Properties

    /// Padding between the card edge and its content, in points
    public let padding: CGFloat

    /// Explicit theme, or `nil` to use the one from the environment
    public let theme: NeumorphicTheme?

    private let content: Content

    // MARK: - Initialization

    public init(
        padding: CGFloat = 16,
        theme: NeumorphicTheme? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.theme = theme
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        let resolved = theme ?? environmentTheme

        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: resolved.cornerRadius)
                    .fill(resolved.background)
                    .neumorphicSurface(theme: resolved, isPressed: false)
            }
    }
}
