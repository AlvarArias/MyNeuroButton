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
}
