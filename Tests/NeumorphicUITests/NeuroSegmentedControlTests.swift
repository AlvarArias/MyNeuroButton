import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroSegmentedControlTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    private let titles = ["Day", "Week", "Month"]

    // MARK: - NeuroSegment

    func testSegmentDefaults() {
        let segment = NeuroSegment("Day", value: 3)
        XCTAssertEqual(segment.title, "Day")
        XCTAssertEqual(segment.value, 3)
        XCTAssertNil(segment.systemImage)
        XCTAssertTrue(segment.showsTitle)
    }

    func testSegmentIdIsItsValue() {
        XCTAssertEqual(NeuroSegment("A", value: "x").id, "x")
    }

    func testSegmentStoresIconOptions() {
        let segment = NeuroSegment("Map", value: 1, systemImage: "map", showsTitle: false)
        XCTAssertEqual(segment.systemImage, "map")
        XCTAssertFalse(segment.showsTitle)
    }

    // MARK: - Control init

    func testDefaults() {
        let control = NeuroSegmentedControl(selection: .constant(0), titles: titles)
        XCTAssertEqual(control.segments.count, 3)
        XCTAssertEqual(control.tint, .blue)
        XCTAssertEqual(control.segmentHeight, 36)
        XCTAssertEqual(control.theme, .default)
    }

    func testTitlesInitUsesIndicesAsValues() {
        let control = NeuroSegmentedControl(selection: .constant(0), titles: titles)
        XCTAssertEqual(control.segments.map(\.value), [0, 1, 2])
        XCTAssertEqual(control.segments.map(\.title), titles)
    }

    func testStoresCustomValues() {
        let theme = NeumorphicTheme(cornerRadius: 4)
        let control = NeuroSegmentedControl(
            selection: .constant("a"),
            segments: [NeuroSegment("A", value: "a")],
            tint: .green, segmentHeight: 50, theme: theme)
        XCTAssertEqual(control.tint, .green)
        XCTAssertEqual(control.segmentHeight, 50)
        XCTAssertEqual(control.theme, theme)
    }

    func testNegativeSegmentHeightIsClamped() {
        let control = NeuroSegmentedControl(
            selection: .constant(0), segments: [NeuroSegment("A", value: 0)], segmentHeight: -5)
        XCTAssertEqual(control.segmentHeight, 0)
    }

    // MARK: - Selection logic

    func testIsSelectedFollowsTheBinding() {
        let control = NeuroSegmentedControl(selection: .constant(1), titles: titles)
        XCTAssertFalse(control.isSelected(control.segments[0]))
        XCTAssertTrue(control.isSelected(control.segments[1]))
        XCTAssertFalse(control.isSelected(control.segments[2]))
    }

    func testSelectWritesTheSegmentValueToTheBinding() {
        var stored = 0
        let control = NeuroSegmentedControl(
            selection: Binding(get: { stored }, set: { stored = $0 }), titles: titles)
        control.select(control.segments[2])
        XCTAssertEqual(stored, 2)
    }

    func testSelectingTheCurrentSegmentDoesNotWrite() {
        var writes = 0
        let control = NeuroSegmentedControl(
            selection: Binding(get: { 1 }, set: { _ in writes += 1 }), titles: titles)
        control.select(control.segments[1])
        XCTAssertEqual(writes, 0)
    }

    func testSelectionNotInSegmentsSelectsNothing() {
        let control = NeuroSegmentedControl(selection: .constant(99), titles: titles)
        XCTAssertFalse(control.segments.contains { control.isSelected($0) })
    }

    func testWorksWithNonIntegerSelection() {
        enum Mode: Hashable { case light, dark }
        var mode = Mode.light
        let control = NeuroSegmentedControl(
            selection: Binding(get: { mode }, set: { mode = $0 }),
            segments: [NeuroSegment("Light", value: Mode.light), NeuroSegment("Dark", value: Mode.dark)])
        control.select(control.segments[1])
        XCTAssertEqual(mode, .dark)
    }

    // MARK: - Geometry

    func testPillCornerRadiusIsTighterThanTheTrack() {
        let theme = NeumorphicTheme(cornerRadius: 12)
        XCTAssertEqual(NeuroSegmentedControl<Int>.pillCornerRadius(for: theme, trackPadding: 4), 8)
    }

    func testPillCornerRadiusNeverGoesNegative() {
        let theme = NeumorphicTheme(cornerRadius: 2)
        XCTAssertEqual(NeuroSegmentedControl<Int>.pillCornerRadius(for: theme, trackPadding: 4), 0)
    }

    // MARK: - Rendering

    func testRenders() {
        let view = NeuroSegmentedControl(selection: .constant(0), titles: titles).frame(width: 300)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testEmptySegmentListRenders() {
        let view = NeuroSegmentedControl<Int>(selection: .constant(0), segments: []).frame(width: 200)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testSelectionChangesRenderedOutput() throws {
        let first = try XCTUnwrap(
            pixels(NeuroSegmentedControl(selection: .constant(0), titles: titles).frame(width: 300)))
        let last = try XCTUnwrap(
            pixels(NeuroSegmentedControl(selection: .constant(2), titles: titles).frame(width: 300)))
        XCTAssertNotEqual(first, last)
    }

    func testNoSelectionLooksDifferentFromASelection() throws {
        let none = try XCTUnwrap(
            pixels(NeuroSegmentedControl(selection: .constant(99), titles: titles).frame(width: 300)))
        let some = try XCTUnwrap(
            pixels(NeuroSegmentedControl(selection: .constant(0), titles: titles).frame(width: 300)))
        XCTAssertNotEqual(none, some)
    }

    func testSegmentHeightChangesRenderedHeight() throws {
        let short = try XCTUnwrap(
            ImageRenderer(content: NeuroSegmentedControl(selection: .constant(0), titles: titles, tint: .blue)
                .frame(width: 300)).cgImage)
        let tall = try XCTUnwrap(
            ImageRenderer(content: NeuroSegmentedControl(
                selection: .constant(0), segments: titles.enumerated().map { NeuroSegment($0.element, value: $0.offset) },
                segmentHeight: 60).frame(width: 300)).cgImage)
        XCTAssertGreaterThan(tall.height, short.height)
    }

    func testEnvironmentThemeReachesControl() throws {
        let themed = NeumorphicTheme.dark
        func control(_ theme: NeumorphicTheme? = nil) -> NeuroSegmentedControl<Int> {
            NeuroSegmentedControl(selection: .constant(1), titles: titles, theme: theme)
        }
        let plain = try XCTUnwrap(pixels(control().frame(width: 300)))
        let viaEnvironment = try XCTUnwrap(pixels(control().frame(width: 300).neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(pixels(control(themed).frame(width: 300)))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }

    func testExplicitThemeBeatsEnvironmentTheme() throws {
        let explicit = NeumorphicTheme.dark
        let withEnvironment = try XCTUnwrap(
            pixels(
                NeuroSegmentedControl(selection: .constant(1), titles: titles, theme: explicit)
                    .frame(width: 300).neumorphicTheme(NeumorphicTheme(cornerRadius: 0))))
        let without = try XCTUnwrap(
            pixels(NeuroSegmentedControl(selection: .constant(1), titles: titles, theme: explicit).frame(width: 300)))
        XCTAssertEqual(withEnvironment, without)
    }
}
