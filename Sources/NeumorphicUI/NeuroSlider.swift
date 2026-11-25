import NeumorphicCore
import SwiftUI

/// Neumorphic slider: a sunken track, a tinted fill and a raised knob you drag.
///
/// Dragging anywhere on the track moves the knob. With `step` set, values snap to
/// `range.lowerBound + n * step`. VoiceOver can adjust it with swipe up and down, and on tvOS the
/// remote's left and right directions move it.
///
/// The drag takes the touch immediately, so a vertical swipe that starts on the slider will not
/// scroll a surrounding `ScrollView` or `List`. The knob's shadow extends a few points past the
/// slider's frame; leave some room around it inside clipped containers.
@MainActor
public struct NeuroSlider: View {

    // MARK: - Private Properties

    @Environment(\.neumorphicTheme) private var environmentTheme
    @Environment(\.layoutDirection) private var layoutDirection
    /// Resets by itself if SwiftUI cancels the gesture, so the knob can never stay stuck in its pressed look.
    @GestureState private var isDragging = false
    private let explicitTheme: NeumorphicTheme?

    // MARK: - Public Properties

    /// The value being edited
    @Binding public var value: Double

    /// Allowed values. A reversed or empty range behaves like a single value.
    public let range: ClosedRange<Double>

    /// Distance between selectable values, or `nil` for a continuous slider
    public let step: Double?

    /// Color of the filled part of the track
    public let tint: Color

    /// Height of the sunken track, in points
    public let trackHeight: CGFloat

    /// Diameter of the knob, in points
    public let knobSize: CGFloat

    /// Optional VoiceOver label
    public let accessibilityLabel: LocalizedStringKey?

    /// Theme given at init, or `.default` when none was given. When none was given the
    /// environment theme is applied at render time (ADR-003), which this property cannot see.
    public var theme: NeumorphicTheme { explicitTheme ?? .default }

    // MARK: - Initialization

    /// - Parameters:
    ///   - value: Binding to the edited value.
    ///   - range: Allowed values. Defaults to 0...1.
    ///   - step: Spacing between selectable values; `nil` or a non-positive number means continuous.
    ///   - tint: Color of the filled part of the track.
    ///   - trackHeight: Height of the sunken track, in points.
    ///   - knobSize: Diameter of the knob, in points.
    ///   - accessibilityLabel: Optional VoiceOver label.
    ///   - theme: Explicit theme; `nil` uses the environment theme.
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        tint: Color = .blue,
        trackHeight: CGFloat = 16,
        knobSize: CGFloat = 32,
        accessibilityLabel: LocalizedStringKey? = nil,
        theme: NeumorphicTheme? = nil
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.tint = tint
        self.trackHeight = max(trackHeight, 0)
        self.knobSize = max(knobSize, 0)
        self.accessibilityLabel = accessibilityLabel
        self.explicitTheme = theme
    }

    // MARK: - Slider math

    /// Position of `value` inside `range`, from 0 to 1.
    static func fraction(of value: Double, in range: ClosedRange<Double>) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0, span.isFinite, value.isFinite else { return 0 }
        return min(max((value - range.lowerBound) / span, 0), 1)
    }

    /// Rounds `value` to the nearest step and keeps it inside `range`.
    static func snapped(_ value: Double, in range: ClosedRange<Double>, step: Double?) -> Double {
        guard value.isFinite else { return range.lowerBound }
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        guard let step, step > 0, step.isFinite else { return clamped }
        let steps = ((clamped - range.lowerBound) / step).rounded()
        let snapped = range.lowerBound + steps * step
        // Remove floating point noise such as 0.30000000000000004 from step = 0.1.
        let clean = (snapped * 1e9).rounded() / 1e9
        return min(clean, range.upperBound)
    }

    /// Value that corresponds to a touch at horizontal position `x`. The knob centre travels
    /// between `knobSize / 2` and `width - knobSize / 2`. In a right-to-left layout the lower
    /// bound sits on the right edge, so the position is mirrored.
    static func value(
        atPosition x: CGFloat, width: CGFloat, knobSize: CGFloat,
        in range: ClosedRange<Double>, step: Double?, isRightToLeft: Bool = false
    ) -> Double {
        let usable = Double(width - knobSize)
        guard usable > 0 else { return range.lowerBound }
        let position = isRightToLeft ? Double(width - x) : Double(x)
        let fraction = min(max((position - Double(knobSize) / 2) / usable, 0), 1)
        let raw = range.lowerBound + fraction * (range.upperBound - range.lowerBound)
        return snapped(raw, in: range, step: step)
    }

    /// One accessibility or remote-control step up (`+1`) or down (`-1`).
    /// Without `step`, a step is a tenth of the range.
    static func adjusted(
        _ value: Double, direction: Int, in range: ClosedRange<Double>, step: Double?
    ) -> Double {
        let span = range.upperBound - range.lowerBound
        let size: Double
        if let step, step > 0, step.isFinite {
            size = step
        } else {
            size = span / 10
        }
        let moved = snapped(value, in: range, step: step) + Double(direction) * size
        return snapped(moved, in: range, step: step)
    }

    // MARK: - Body

    public var body: some View {
        let resolved = explicitTheme ?? environmentTheme
        let fraction = Self.fraction(of: value, in: range)
        let knobRelief = resolved.cappingShadow(at: 5)
        let height = max(knobSize, trackHeight)

        GeometryReader { proxy in
            let travel = max(proxy.size.width - knobSize, 0)
            let knobX = travel * fraction
            let fillInset: CGFloat = 2
            let fillWidth = max(knobX + knobSize / 2 - fillInset, 0)

            ZStack(alignment: .leading) {
                Color.clear
                    .frame(height: trackHeight)
                    .neumorphicInset(in: Capsule(), theme: resolved)

                Capsule()
                    .fill(tint)
                    .frame(width: fillWidth, height: max(trackHeight - fillInset * 2, 0))
                    .padding(.leading, fillInset)

                Circle()
                    .fill(resolved.background)
                    .frame(width: knobSize, height: knobSize)
                    .neumorphicSurface(theme: knobRelief, isPressed: isDragging)
                    .offset(x: knobX)
                    .animation(.easeInOut(duration: resolved.animationDuration), value: isDragging)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
            .contentShape(Rectangle())
            #if !os(tvOS)
            // tvOS has no DragGesture; the remote's left/right directions drive the slider there.
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in state = true }
                    .onChanged { drag in
                        let new = Self.value(
                            atPosition: drag.location.x, width: proxy.size.width,
                            knobSize: knobSize, in: range, step: step,
                            isRightToLeft: layoutDirection == .rightToLeft)
                        if new != value { value = new }
                    }
            )
            #endif
        }
        .frame(height: height)
        .modifier(SliderAccessibility(
            label: accessibilityLabel,
            fraction: fraction,
            adjust: { direction in
                value = Self.adjusted(value, direction: direction, in: range, step: step)
            }))
    }
}

/// VoiceOver adjustment, percentage value and (on tvOS) remote-control support.
private struct SliderAccessibility: ViewModifier {
    let label: LocalizedStringKey?
    let fraction: Double
    let adjust: (Int) -> Void

    func body(content: Content) -> some View {
        remote(
            labeled(
                content
                    .accessibilityElement(children: .ignore)
                    .accessibilityValue(Text(fraction.formatted(.percent.precision(.fractionLength(0)))))
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: adjust(1)
                        case .decrement: adjust(-1)
                        @unknown default: break
                        }
                    }))
    }

    @ViewBuilder
    private func labeled<V: View>(_ view: V) -> some View {
        if let label {
            view.accessibilityLabel(label)
        } else {
            view
        }
    }

    @ViewBuilder
    private func remote<V: View>(_ view: V) -> some View {
        #if os(tvOS)
        view
            .focusable()
            .onMoveCommand { direction in
                switch direction {
                case .right: adjust(1)
                case .left: adjust(-1)
                default: break
                }
            }
        #else
        view
        #endif
    }
}
