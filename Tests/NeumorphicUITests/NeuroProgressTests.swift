import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroProgressTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    // MARK: - Defaults

    func testDefaults() {
        let progress = NeuroProgress(value: 0.5)
        XCTAssertEqual(progress.total, 1)
        XCTAssertEqual(progress.style, .bar)
        XCTAssertEqual(progress.tint, .blue)
        XCTAssertEqual(progress.thickness, 16)
        XCTAssertNil(progress.theme)
    }

    func testStoresCustomValues() {
        let progress = NeuroProgress(
            value: 30, total: 60, style: .ring, tint: .green, thickness: 10,
            theme: NeumorphicTheme(cornerRadius: 3))
        XCTAssertEqual(progress.style, .ring)
        XCTAssertEqual(progress.tint, .green)
        XCTAssertEqual(progress.thickness, 10)
        XCTAssertEqual(progress.theme?.cornerRadius, 3)
    }

    // MARK: - Fraction

    func testFractionIsValueOverTotal() {
        XCTAssertEqual(NeuroProgress(value: 30, total: 60).fraction, 0.5, accuracy: 0.0001)
        XCTAssertEqual(NeuroProgress(value: 0.25).fraction, 0.25, accuracy: 0.0001)
    }

    func testFractionIsClamped() {
        XCTAssertEqual(NeuroProgress(value: -5).fraction, 0)
        XCTAssertEqual(NeuroProgress(value: 7, total: 2).fraction, 1)
    }

    func testFractionHandlesBadInput() {
        XCTAssertEqual(NeuroProgress(value: 1, total: 0).fraction, 0)
        XCTAssertEqual(NeuroProgress(value: 1, total: -3).fraction, 0)
        XCTAssertEqual(NeuroProgress(value: .nan).fraction, 0)
        XCTAssertEqual(NeuroProgress(value: .infinity).fraction, 0)
    }

    // MARK: - Rendering

    func testBarRenders() {
        let view = NeuroProgress(value: 0.5).frame(width: 200)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testRingRenders() {
        let view = NeuroProgress(value: 0.5, style: .ring).frame(width: 80, height: 80)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testValueChangesRenderedBar() throws {
        let low = try XCTUnwrap(pixels(NeuroProgress(value: 0.2).frame(width: 200)))
        let high = try XCTUnwrap(pixels(NeuroProgress(value: 0.8).frame(width: 200)))
        XCTAssertNotEqual(low, high)
    }

    func testValueChangesRenderedRing() throws {
        let low = try XCTUnwrap(pixels(NeuroProgress(value: 0.2, style: .ring).frame(width: 80, height: 80)))
        let high = try XCTUnwrap(pixels(NeuroProgress(value: 0.8, style: .ring).frame(width: 80, height: 80)))
        XCTAssertNotEqual(low, high)
    }

    func testBarAndRingLookDifferent() throws {
        let bar = try XCTUnwrap(pixels(NeuroProgress(value: 0.5).frame(width: 80, height: 80)))
        let ring = try XCTUnwrap(pixels(NeuroProgress(value: 0.5, style: .ring).frame(width: 80, height: 80)))
        XCTAssertNotEqual(bar, ring)
    }

    func testEnvironmentThemeReachesProgress() throws {
        let themed = NeumorphicTheme.dark
        let plain = try XCTUnwrap(pixels(NeuroProgress(value: 0.5).frame(width: 200)))
        let viaEnvironment = try XCTUnwrap(
            pixels(NeuroProgress(value: 0.5).frame(width: 200).neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(
            pixels(NeuroProgress(value: 0.5, theme: themed).frame(width: 200)))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }

    // MARK: - Edge cases from the independent review

    func testNegativeThicknessIsClampedToZero() {
        XCTAssertEqual(NeuroProgress(value: 0.5, thickness: -4).thickness, 0)
    }

    func testTinyThicknessBarRendersWithoutNegativeFrames() {
        for thickness in [CGFloat(1), 2, 3] {
            let view = NeuroProgress(value: 0.5, thickness: thickness).frame(width: 100)
            let image = ImageRenderer(content: view).cgImage
            XCTAssertNotNil(image, "thickness \(thickness)")
            XCTAssertEqual(image?.height, Int(thickness), "thickness \(thickness)")
        }
    }

    func testZeroThicknessRingRenders() {
        let view = NeuroProgress(value: 0.5, style: .ring, thickness: 0).frame(width: 60, height: 60)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testOversizedRingThicknessStaysInsideItsFrame() throws {
        let view = NeuroProgress(value: 0.5, style: .ring, thickness: 80).frame(width: 50, height: 50)
        let image = try XCTUnwrap(ImageRenderer(content: view).cgImage)
        XCTAssertEqual(image.width, 50)
        XCTAssertEqual(image.height, 50)
    }
}
