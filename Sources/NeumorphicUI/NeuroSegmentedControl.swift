import NeumorphicCore
import SwiftUI

/// One option of a `NeuroSegmentedControl`.
public struct NeuroSegment<Value: Hashable>: Identifiable {

    /// The value the control's selection takes when this segment is chosen
    public let value: Value

    /// Visible text, and the VoiceOver label
    public let title: String

    /// Optional SF Symbol shown before the title
    public let systemImage: String?

    /// Whether the title is drawn. When `false` only the symbol shows; VoiceOver still reads the title.
    public let showsTitle: Bool

    public var id: Value { value }

    /// - Parameters:
    ///   - title: Visible text and VoiceOver label.
    ///   - value: Selection value this segment stands for. Keep values unique inside one control;
    ///     if two segments share a value, only the first one is highlighted.
    ///   - systemImage: Optional SF Symbol shown before the title.
    ///   - showsTitle: Pass `false` for an icon-only segment (needs `systemImage`).
    public init(_ title: String, value: Value, systemImage: String? = nil, showsTitle: Bool = true) {
        self.title = title
        self.value = value
        self.systemImage = systemImage
        self.showsTitle = showsTitle
    }
}

/// Sunken track with one raised pill that slides to the selected segment.
///
/// Tapping anywhere on a segment selects it. If `selection` matches no segment, nothing is
/// highlighted; if it matches several, only the first is. The pill's shadow extends a few points
/// past the track, so leave some room around the control inside clipped containers. The slide is
/// skipped when the system's Reduce Motion setting is on.
@MainActor
public struct NeuroSegmentedControl<Value: Hashable>: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var pillNamespace
    private let explicitTheme: NeumorphicTheme?

    // MARK: - Public Properties

    /// The selected value
    @Binding public var selection: Value

    /// The options, in display order. Values should be unique.
    public let segments: [NeuroSegment<Value>]

    /// Color of the selected segment's content
    public let tint: Color

    /// Minimum height of each segment, in points
    public let segmentHeight: CGFloat

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    // MARK: - Initialization

    /// - Parameters:
    ///   - selection: Binding to the selected value.
    ///   - segments: The options, in display order.
    ///   - tint: Color of the selected segment's content.
    ///   - segmentHeight: Minimum height of each segment, in points.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(
        selection: Binding<Value>,
        segments: [NeuroSegment<Value>],
        tint: Color = .blue,
        segmentHeight: CGFloat = 36,
        theme: NeumorphicTheme? = nil
    ) {
        self._selection = selection
        self.segments = segments
        self.tint = tint
        self.segmentHeight = max(segmentHeight, 0)
        self.explicitTheme = theme
    }

    // MARK: - Logic

    /// Index of the highlighted segment: the first one whose value equals `selection`, or `nil`.
    var selectedIndex: Int? {
        segments.firstIndex { $0.value == selection }
    }

    /// Makes `segment` the selection.
    func select(_ segment: NeuroSegment<Value>) {
        if selection != segment.value { selection = segment.value }
    }

    /// The pill sits `trackPadding` inside the track, so its corners are that much tighter.
    static func pillCornerRadius(for theme: NeumorphicTheme, trackPadding: CGFloat) -> CGFloat {
        max(theme.cornerRadius - trackPadding, 0)
    }

    private static var trackPadding: CGFloat { 4 }

    // MARK: - Body

    public var body: some View {
        let resolved = explicitTheme ?? environmentTheme

        HStack(spacing: Self.trackPadding) {
            // Identified by position, not by value, so duplicate values cannot break the layout.
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                segmentView(segment, isSelected: index == selectedIndex)
            }
        }
        .padding(Self.trackPadding)
        .neumorphicInset(theme: resolved)
        .animation(reduceMotion ? nil : .easeInOut(duration: resolved.animationDuration), value: selection)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Private Views

    private func segmentView(_ segment: NeuroSegment<Value>, isSelected selected: Bool) -> some View {
        NeuroPressable(theme: explicitTheme, action: { select(segment) }) { isPressed, theme in
            HStack(spacing: 6) {
                if let systemImage = segment.systemImage {
                    Image(systemName: systemImage)
                }
                if segment.showsTitle {
                    Text(segment.title)
                }
            }
            .font(.subheadline.weight(selected ? .semibold : .regular))
            .foregroundStyle(selected ? tint : theme.foreground)
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: segmentHeight)
            .opacity(isPressed && !selected ? 0.6 : 1)
            // Make the whole segment tappable, not just the text, even when it has no pill behind it.
            .contentShape(Rectangle())
            .background {
                if selected {
                    RoundedRectangle(
                        cornerRadius: Self.pillCornerRadius(for: theme, trackPadding: Self.trackPadding)
                    )
                    .fill(theme.background)
                    .neumorphicSurface(theme: theme.cappingShadow(at: 5), isPressed: isPressed)
                    .matchedGeometryEffect(id: "pill", in: pillNamespace)
                }
            }
        }
        .accessibilityLabel(segment.title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

extension NeuroSegmentedControl where Value == Int {
    /// Control whose selection is the index of the chosen title.
    /// - Parameters:
    ///   - selection: Binding to the selected index.
    ///   - titles: One title per segment, in display order.
    ///   - tint: Color of the selected segment's content.
    ///   - segmentHeight: Minimum height of each segment, in points.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(
        selection: Binding<Int>,
        titles: [String],
        tint: Color = .blue,
        segmentHeight: CGFloat = 36,
        theme: NeumorphicTheme? = nil
    ) {
        self.init(
            selection: selection,
            segments: titles.enumerated().map { NeuroSegment($0.element, value: $0.offset) },
            tint: tint,
            segmentHeight: segmentHeight,
            theme: theme)
    }
}
