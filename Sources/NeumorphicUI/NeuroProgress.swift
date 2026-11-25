import NeumorphicCore
import SwiftUI

/// Sunken progress indicator, as a horizontal bar or a ring.
@MainActor
public struct NeuroProgress: View {

    /// Visual form of the indicator
    public enum Style: Sendable, Equatable {
        case bar
        case ring
    }

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme

    // MARK: - Public Properties

    /// Current value, between 0 and `total`
    public let value: Double

    /// Value at which the indicator is full
    public let total: Double

    /// Bar or ring
    public let style: Style

    /// Color of the filled part
    public let tint: Color

    /// Thickness of the bar, or of the ring line, in points
    public let thickness: CGFloat

    /// Explicit theme, or `nil` to use the one from the environment
    public let theme: NeumorphicTheme?

    // MARK: - Initialization

    public init(
        value: Double,
        total: Double = 1,
        style: Style = .bar,
        tint: Color = .blue,
        thickness: CGFloat = 16,
        theme: NeumorphicTheme? = nil
    ) {
        self.value = value
        self.total = total
        self.style = style
        self.tint = tint
        self.thickness = thickness
        self.theme = theme
    }

    /// Completed share, clamped to 0...1. A non-positive `total` counts as empty.
    public var fraction: Double {
        guard total > 0, value.isFinite else { return 0 }
        return min(max(value / total, 0), 1)
    }

    // MARK: - Body

    public var body: some View {
        let resolved = theme ?? environmentTheme

        Group {
            switch style {
            case .bar:
                bar(resolved)
            case .ring:
                ring(resolved)
            }
        }
        .animation(.easeInOut(duration: resolved.animationDuration), value: fraction)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int((fraction * 100).rounded())) percent")
    }

    // MARK: - Private Views

    private func bar(_ resolved: NeumorphicTheme) -> some View {
        var capsule = resolved
        capsule.cornerRadius = thickness / 2

        let inset: CGFloat = 2

        return GeometryReader { proxy in
            let innerWidth = max(proxy.size.width - inset * 2, 0)
            let fillWidth = fraction > 0 ? max(innerWidth * fraction, thickness - inset * 2) : 0

            ZStack(alignment: .leading) {
                Color.clear.neumorphicInset(theme: capsule)

                Capsule()
                    .fill(tint)
                    .frame(width: fillWidth, height: thickness - inset * 2)
                    .padding(inset)
            }
        }
        .frame(height: thickness)
    }

    private func ring(_ resolved: NeumorphicTheme) -> some View {
        let line = StrokeStyle(lineWidth: thickness, lineCap: .round)

        return ZStack {
            Circle()
                .stroke(resolved.background, lineWidth: thickness)
                .overlay { grooveShadows(resolved) }

            Circle()
                .trim(from: 0, to: fraction)
                .stroke(tint, style: line)
                .rotationEffect(.degrees(-90))
                .opacity(fraction > 0 ? 1 : 0)
        }
        .padding(thickness / 2)
        .aspectRatio(1, contentMode: .fit)
    }

    /// Inner shadows of the ring track. They hug both walls of the groove (outer and inner edge)
    /// and are masked to the track so nothing spills outside it.
    private func grooveShadows(_ resolved: NeumorphicTheme) -> some View {
        let radius = resolved.insetShadowRadius
        let offset = radius / 2
        let walls = [-thickness / 2, thickness / 2]

        return ZStack {
            ForEach(walls, id: \.self) { wall in
                Circle()
                    .inset(by: wall)
                    .stroke(resolved.shadowColor.opacity(0.3), lineWidth: radius)
                    .blur(radius: radius / 2)
                    .offset(x: offset, y: offset)
                Circle()
                    .inset(by: wall)
                    .stroke(resolved.highlightColor.opacity(0.8), lineWidth: radius)
                    .blur(radius: radius / 2)
                    .offset(x: -offset, y: -offset)
            }
        }
        .mask(Circle().stroke(lineWidth: thickness))
    }
}
