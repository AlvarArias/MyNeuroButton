import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroSliderTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    // MARK: - Init

    func testDefaults() {
        let slider = NeuroSlider(value: .constant(0.5))
        XCTAssertEqual(slider.range, 0...1)
        XCTAssertNil(slider.step)
        XCTAssertEqual(slider.tint, .blue)
        XCTAssertEqual(slider.trackHeight, 16)
        XCTAssertEqual(slider.knobSize, 32)
        XCTAssertNil(slider.accessibilityLabel)
        XCTAssertEqual(slider.theme, .default)
        XCTAssertEqual(slider.value, 0.5)
    }

    func testStoresCustomValues() {
        let theme = NeumorphicTheme(cornerRadius: 3)
        let slider = NeuroSlider(
            value: .constant(5), in: 0...10, step: 2, tint: .green, trackHeight: 10, knobSize: 24, theme: theme)
        XCTAssertEqual(slider.range, 0...10)
        XCTAssertEqual(slider.step, 2)
        XCTAssertEqual(slider.tint, .green)
        XCTAssertEqual(slider.trackHeight, 10)
        XCTAssertEqual(slider.knobSize, 24)
        XCTAssertEqual(slider.theme, theme)
    }

    func testNegativeSizesAreClampedToZero() {
        let slider = NeuroSlider(value: .constant(0), trackHeight: -3, knobSize: -9)
        XCTAssertEqual(slider.trackHeight, 0)
        XCTAssertEqual(slider.knobSize, 0)
    }

    // MARK: - fraction

    func testFraction() {
        XCTAssertEqual(NeuroSlider.fraction(of: 5, in: 0...10), 0.5, accuracy: 1e-9)
        XCTAssertEqual(NeuroSlider.fraction(of: 15, in: 10...20), 0.5, accuracy: 1e-9)
    }

    func testFractionIsClampedAndSafe() {
        XCTAssertEqual(NeuroSlider.fraction(of: -3, in: 0...10), 0)
        XCTAssertEqual(NeuroSlider.fraction(of: 99, in: 0...10), 1)
        XCTAssertEqual(NeuroSlider.fraction(of: 5, in: 3...3), 0, "empty range")
        XCTAssertEqual(NeuroSlider.fraction(of: .nan, in: 0...1), 0)
        XCTAssertEqual(NeuroSlider.fraction(of: .infinity, in: 0...1), 0)
    }

    // MARK: - snapping

    func testSnappedWithoutStepOnlyClamps() {
        XCTAssertEqual(NeuroSlider.snapped(0.37, in: 0...1, step: nil), 0.37, accuracy: 1e-9)
        XCTAssertEqual(NeuroSlider.snapped(5, in: 0...1, step: nil), 1)
        XCTAssertEqual(NeuroSlider.snapped(-5, in: 0...1, step: nil), 0)
    }

    func testSnappedRoundsToNearestStep() {
        XCTAssertEqual(NeuroSlider.snapped(4.4, in: 0...10, step: 2), 4)
        XCTAssertEqual(NeuroSlider.snapped(5.1, in: 0...10, step: 2), 6)
    }

    func testSnappedStepsStartAtLowerBound() {
        XCTAssertEqual(NeuroSlider.snapped(13.9, in: 10...20, step: 5), 15)
    }

    func testSnappedNeverExceedsUpperBoundWhenStepDoesNotDivideRange() {
        XCTAssertEqual(NeuroSlider.snapped(10, in: 0...10, step: 3), 9)
        XCTAssertLessThanOrEqual(NeuroSlider.snapped(9.9, in: 0...10, step: 4), 10)
    }

    func testSnappedIgnoresInvalidStep() {
        XCTAssertEqual(NeuroSlider.snapped(0.37, in: 0...1, step: 0), 0.37, accuracy: 1e-9)
        XCTAssertEqual(NeuroSlider.snapped(0.37, in: 0...1, step: -1), 0.37, accuracy: 1e-9)
        XCTAssertEqual(NeuroSlider.snapped(.nan, in: 2...4, step: 1), 2)
    }

    // MARK: - touch position

    func testPositionMapsKnobCentreAcrossTheTravel() {
        // width 200, knob 40: the knob centre travels from x = 20 to x = 180.
        func value(_ x: CGFloat) -> Double {
            NeuroSlider.value(atPosition: x, width: 200, knobSize: 40, in: 0...100, step: nil)
        }
        XCTAssertEqual(value(20), 0, accuracy: 1e-9)
        XCTAssertEqual(value(100), 50, accuracy: 1e-9)
        XCTAssertEqual(value(180), 100, accuracy: 1e-9)
    }

    func testPositionOutsideTheTrackIsClamped() {
        XCTAssertEqual(NeuroSlider.value(atPosition: -50, width: 200, knobSize: 40, in: 0...1, step: nil), 0)
        XCTAssertEqual(NeuroSlider.value(atPosition: 999, width: 200, knobSize: 40, in: 0...1, step: nil), 1)
    }

    func testPositionSnapsToStep() {
        let value = NeuroSlider.value(atPosition: 100, width: 200, knobSize: 40, in: 0...100, step: 25)
        XCTAssertEqual(value, 50)
        let nearly = NeuroSlider.value(atPosition: 108, width: 200, knobSize: 40, in: 0...100, step: 25)
        XCTAssertEqual(nearly, 50)
    }

    func testPositionWithNoRoomToTravelReturnsLowerBound() {
        XCTAssertEqual(NeuroSlider.value(atPosition: 10, width: 30, knobSize: 40, in: 5...9, step: nil), 5)
        XCTAssertEqual(NeuroSlider.value(atPosition: 10, width: 40, knobSize: 40, in: 5...9, step: nil), 5)
    }

    // MARK: - accessibility / remote steps

    func testAdjustedUsesStepWhenGiven() {
        XCTAssertEqual(NeuroSlider.adjusted(4, direction: 1, in: 0...10, step: 2), 6)
        XCTAssertEqual(NeuroSlider.adjusted(4, direction: -1, in: 0...10, step: 2), 2)
    }

    func testAdjustedUsesATenthOfTheRangeWithoutStep() {
        XCTAssertEqual(NeuroSlider.adjusted(50, direction: 1, in: 0...100, step: nil), 60, accuracy: 1e-9)
        XCTAssertEqual(NeuroSlider.adjusted(0.5, direction: -1, in: 0...1, step: nil), 0.4, accuracy: 1e-9)
    }

    func testAdjustedStopsAtTheEnds() {
        XCTAssertEqual(NeuroSlider.adjusted(10, direction: 1, in: 0...10, step: 2), 10)
        XCTAssertEqual(NeuroSlider.adjusted(0, direction: -1, in: 0...10, step: 2), 0)
    }

    func testAdjustedWithInvalidStepFallsBackToATenth() {
        XCTAssertEqual(NeuroSlider.adjusted(50, direction: 1, in: 0...100, step: 0), 60, accuracy: 1e-9)
    }

    // MARK: - rendering

    func testRenders() {
        let view = NeuroSlider(value: .constant(0.5)).frame(width: 240)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testRenderedHeightIsTheTallerOfKnobAndTrack() throws {
        let tallKnob = try XCTUnwrap(
            ImageRenderer(content: NeuroSlider(value: .constant(0.5), trackHeight: 10, knobSize: 44).frame(width: 240)).cgImage)
        let tallTrack = try XCTUnwrap(
            ImageRenderer(content: NeuroSlider(value: .constant(0.5), trackHeight: 60, knobSize: 20).frame(width: 240)).cgImage)
        XCTAssertEqual(tallKnob.height, 44)
        XCTAssertEqual(tallTrack.height, 60)
    }

    func testValueChangesRenderedOutput() throws {
        let low = try XCTUnwrap(pixels(NeuroSlider(value: .constant(0.1)).frame(width: 240)))
        let high = try XCTUnwrap(pixels(NeuroSlider(value: .constant(0.9)).frame(width: 240)))
        XCTAssertNotEqual(low, high)
    }

    func testOutOfRangeValueRendersLikeTheNearestEnd() throws {
        let over = try XCTUnwrap(pixels(NeuroSlider(value: .constant(7)).frame(width: 240)))
        let full = try XCTUnwrap(pixels(NeuroSlider(value: .constant(1)).frame(width: 240)))
        XCTAssertEqual(over, full)
    }

    func testEnvironmentThemeReachesSlider() throws {
        let themed = NeumorphicTheme.dark
        let plain = try XCTUnwrap(pixels(NeuroSlider(value: .constant(0.5)).frame(width: 240)))
        let viaEnvironment = try XCTUnwrap(
            pixels(NeuroSlider(value: .constant(0.5)).frame(width: 240).neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(
            pixels(NeuroSlider(value: .constant(0.5), theme: themed).frame(width: 240)))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }

    // MARK: - Cases from the independent review

    func testSnappedRemovesFloatingPointNoise() {
        XCTAssertEqual(NeuroSlider.snapped(0.3, in: 0...1, step: 0.1), 0.3)
        XCTAssertEqual(NeuroSlider.snapped(0.7, in: 0...1, step: 0.1), 0.7)
        XCTAssertEqual(NeuroSlider.snapped(0.69, in: 0...1, step: 0.1), 0.7)
    }

    func testSnappedKeepsExactBoundsWithDecimalStep() {
        XCTAssertEqual(NeuroSlider.snapped(1, in: 0...1, step: 0.1), 1)
        XCTAssertEqual(NeuroSlider.snapped(0, in: 0...1, step: 0.1), 0)
        XCTAssertEqual(NeuroSlider.snapped(2.5, in: 2...3, step: 0.25), 2.5)
    }

    func testAdjustedWithDecimalStepStaysClean() {
        var value = 0.0
        for _ in 0..<3 { value = NeuroSlider.adjusted(value, direction: 1, in: 0...1, step: 0.1) }
        XCTAssertEqual(value, 0.3)
    }

    func testRightToLeftMirrorsTheTouchPosition() {
        func value(_ x: CGFloat, rtl: Bool) -> Double {
            NeuroSlider.value(
                atPosition: x, width: 200, knobSize: 40, in: 0...100, step: nil, isRightToLeft: rtl)
        }
        XCTAssertEqual(value(20, rtl: false), 0, accuracy: 1e-9)
        XCTAssertEqual(value(20, rtl: true), 100, accuracy: 1e-9)
        XCTAssertEqual(value(180, rtl: true), 0, accuracy: 1e-9)
        XCTAssertEqual(value(100, rtl: true), 50, accuracy: 1e-9)
    }

    func testRightToLeftRendersMirroredToLeftToRight() throws {
        let ltr = try XCTUnwrap(pixels(NeuroSlider(value: .constant(0.2)).frame(width: 240)))
        let rtl = try XCTUnwrap(
            pixels(NeuroSlider(value: .constant(0.2)).frame(width: 240).environment(\.layoutDirection, .rightToLeft)))
        XCTAssertNotEqual(ltr, rtl)
    }
}
