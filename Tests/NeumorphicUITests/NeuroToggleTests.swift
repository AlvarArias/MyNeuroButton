import SwiftUI
import XCTest
import NeumorphicCore
@testable import NeumorphicUI

@MainActor
final class NeuroToggleTests: XCTestCase {

    func testToggleInitialization() {
        let toggle = NeuroToggle(
            icon: "star",
            iconFilled: "star.fill",
            isOn: .constant(false),
            fillColor: .green,
            width: 120,
            height: 80
        )

        XCTAssertEqual(toggle.icon, "star")
        XCTAssertEqual(toggle.iconFilled, "star.fill")
        XCTAssertEqual(toggle.fillColor, .green)
        XCTAssertEqual(toggle.width, 120)
        XCTAssertEqual(toggle.height, 80)
        XCTAssertFalse(toggle.isOn)
    }

    func testToggleDefaultValues() {
        let toggle = NeuroToggle(icon: "heart", iconFilled: "heart.fill", isOn: .constant(false))

        XCTAssertEqual(toggle.fillColor, .blue)
        XCTAssertEqual(toggle.width, 100)
        XCTAssertEqual(toggle.height, 100)
        XCTAssertEqual(toggle.theme.cornerRadius, NeumorphicTheme.default.cornerRadius)
    }

    func testToggleReadsOnState() {
        let toggle = NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(true))
        XCTAssertTrue(toggle.isOn)
    }

    func testToggleCustomTheme() {
        let custom = NeumorphicTheme(cornerRadius: 20, normalShadowRadius: 15)
        let toggle = NeuroToggle(
            icon: "star",
            iconFilled: "star.fill",
            isOn: .constant(false),
            theme: custom
        )
        XCTAssertEqual(toggle.theme.cornerRadius, 20)
        XCTAssertEqual(toggle.theme.normalShadowRadius, 15)
    }

    func testToggleMutatesBinding() {
        var state = false
        let binding = Binding(get: { state }, set: { state = $0 })
        let toggle = NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: binding)

        toggle.isOn = true

        XCTAssertTrue(state)
    }

    func testExplicitThemeWinsOverDefault() {
        let custom = NeumorphicTheme(cornerRadius: 22)
        let toggle = NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false), theme: custom)
        XCTAssertEqual(toggle.theme, custom)
        XCTAssertEqual(toggle.resolvedTheme, custom)
    }

    func testToggleWithoutThemeReportsDefault() {
        let toggle = NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false))
        XCTAssertEqual(toggle.theme, .default)
    }

    func testToggleRendersWithEnvironmentTheme() {
        let view = NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(true))
            .neumorphicTheme(NeumorphicTheme(cornerRadius: 40))
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    /// Raw pixel bytes of a rendered view, used to prove that a theme really changes the output.
    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    func testEnvironmentThemeChangesRenderedToggle() throws {
        let themed = NeumorphicTheme(cornerRadius: 45)
        func toggle() -> NeuroToggle { NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false)) }

        let plain = try XCTUnwrap(pixels(toggle()))
        let viaEnvironment = try XCTUnwrap(pixels(toggle().neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(pixels(
            NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false), theme: themed)))

        XCTAssertNotEqual(plain, viaEnvironment, "environment theme must reach the toggle")
        XCTAssertEqual(viaEnvironment, explicit)
    }

    func testExplicitThemeBeatsEnvironmentTheme() throws {
        let explicit = NeumorphicTheme(cornerRadius: 45)
        let withEnvironment = try XCTUnwrap(pixels(
            NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false), theme: explicit)
                .neumorphicTheme(NeumorphicTheme(cornerRadius: 0))))
        let withoutEnvironment = try XCTUnwrap(pixels(
            NeuroToggle(icon: "star", iconFilled: "star.fill", isOn: .constant(false), theme: explicit)))
        XCTAssertEqual(withEnvironment, withoutEnvironment)
    }
}
