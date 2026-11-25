import NeumorphicCore
import SwiftUI

/// Thin engraved line: a dark and a light hairline side by side.
@MainActor
public struct NeuroDivider: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme

    // MARK: - Public Properties

    /// Direction of the line
    public let axis: Axis

    private let explicitTheme: NeumorphicTheme?

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    // MARK: - Initialization

    /// - Parameters:
    ///   - axis: `.horizontal` (default) or `.vertical`.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(_ axis: Axis = .horizontal, theme: NeumorphicTheme? = nil) {
        self.axis = axis
        self.explicitTheme = theme
    }

    // MARK: - Body

    public var body: some View {
        let resolved = explicitTheme ?? environmentTheme
        let dark = resolved.shadowColor.opacity(0.25)
        let light = resolved.highlightColor.opacity(0.8)

        switch axis {
        case .horizontal:
            VStack(spacing: 0) {
                dark.frame(height: 1)
                light.frame(height: 1)
            }
            .frame(height: 2)
            .accessibilityHidden(true)
        case .vertical:
            HStack(spacing: 0) {
                dark.frame(width: 1)
                light.frame(width: 1)
            }
            .frame(width: 2)
            .accessibilityHidden(true)
        }
    }
}
