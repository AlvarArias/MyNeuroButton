import NeumorphicCore
import SwiftUI

/// Small raised capsule with a label and an optional SF Symbol.
///
/// The shadow extends a few points past the badge; leave room around it inside clipped containers.
@MainActor
public struct NeuroBadge: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme

    // MARK: - Public Properties

    /// Badge text
    public let text: String

    /// Optional SF Symbol shown before the text
    public let systemImage: String?

    /// Text and icon color. `nil` uses the theme foreground.
    public let tint: Color?

    /// Explicit theme, or `nil` to use the one from the environment
    public let theme: NeumorphicTheme?

    // MARK: - Initialization

    /// - Parameters:
    ///   - text: Badge label.
    ///   - systemImage: Optional SF Symbol shown before the text. Hidden from VoiceOver.
    ///   - tint: Text and icon color; `nil` uses the theme foreground.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(
        _ text: String,
        systemImage: String? = nil,
        tint: Color? = nil,
        theme: NeumorphicTheme? = nil
    ) {
        self.text = text
        self.systemImage = systemImage
        self.tint = tint
        self.theme = theme
    }

    /// Badges are small: cap the shadow so it does not swallow the label.
    static func smallRelief(of theme: NeumorphicTheme) -> NeumorphicTheme {
        var relief = theme
        relief.normalShadowRadius = min(theme.normalShadowRadius, 4)
        return relief
    }

    // MARK: - Body

    public var body: some View {
        let resolved = theme ?? environmentTheme
        let relief = Self.smallRelief(of: resolved)

        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint ?? resolved.foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule()
                .fill(resolved.background)
                .neumorphicSurface(theme: relief, isPressed: false)
        }
    }
}
