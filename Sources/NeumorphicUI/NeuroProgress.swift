import NeumorphicCore
import SwiftUI

/// Sunken progress indicator, as a horizontal bar or a ring.
@MainActor
public struct NeuroProgress: View {

    /// Visual form of the indicator
    public enum Style: Sendable, Equatable {
        /// Horizontal sunken track that fills from the leading edge.
        case bar
        /// Circular groove that fills clockwise from the top.
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

    /// Thickness of the bar, or of the ring line, in points. Negative values count as 0; a ring never exceeds half its frame.
    public let thickness: CGFloat

    /// Explicit theme, or `nil` to use the one from the environment
    public let theme: NeumorphicTheme?

    // MARK: - Initialization

    /// - Parameters:
    ///   - value: Current value, from 0 to `total`. Out-of-range values are clamped.
    ///   - total: Value at which the indicator is full. Defaults to 1.
    ///   - style: `.bar` or `.ring`.
    ///   - tint: Color of the filled part.
    ///   - thickness: Bar height or ring line width, in points.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
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
        self.thickness = max(thickness, 0)
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
        let inset: CGFloat = 2
        let fillHeight = max(thickness - inset * 2, 0)

        return GeometryReader { proxy in
            let innerWidth = max(proxy.size.width - inset * 2, 0)
            let fillWidth = fraction > 0 ? max(innerWidth * fraction, fillHeight) : 0

            ZStack(alignment: .leading) {
                Color.clear.neumorphicInset(in: Capsule(), theme: resolved)

                Capsule()
                    .fill(tint)
                    .frame(width: fillWidth, height: fillHeight)
                    .padding(inset)
            }
        }
        .frame(height: thickness)
    }

    private func ring(_ resolved: NeumorphicTheme) -> some View {
        GeometryReader { proxy in
            // The line can never be thicker than the radius, or the ring would collapse.
            let line = min(thickness, min(proxy.size.width, proxy.size.height) / 2)

            ZStack {
                Color.clear.neumorphicInset(in: RingShape(thickness: line), theme: resolved)

                Circle()
                    .inset(by: line / 2)
                    .trim(from: 0, to: fraction)
                    .stroke(tint, style: StrokeStyle(lineWidth: line, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .opacity(fraction > 0 ? 1 : 0)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// Annulus that fills its rect: outer circle touches the edges, inner circle is `thickness` smaller.
/// The inner contour runs counter-clockwise so the hole stays empty under the default fill rule.
struct RingShape: Shape {
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = max(outer - thickness, 0)

        var path = Path()
        path.addArc(center: center, radius: outer, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        if inner > 0 {
            path.addArc(center: center, radius: inner, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        }
        return path
    }
}
