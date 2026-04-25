import SwiftUI
import XCTest
import NeumorphicCore
@testable import MyNeuroButton

@MainActor
final class MyNeuroButtonTests: XCTestCase {

    func testButtonInitialization() {
        let button = MyNeuroButton(
            icon: "star",
            iconFilled: "star.fill",
            fillColor: .blue,
            width: 120,
            height: 80
        ) {}

        XCTAssertEqual(button.icon, "star")
        XCTAssertEqual(button.iconFilled, "star.fill")
        XCTAssertEqual(button.fillColor, .blue)
        XCTAssertEqual(button.width, 120)
        XCTAssertEqual(button.height, 80)
    }

    func testButtonActionExecution() {
        var actionWasCalled = false
        let button = MyNeuroButton(
            icon: "star",
            iconFilled: "star.fill"
        ) {
            actionWasCalled = true
        }

        button.action()

        XCTAssertTrue(actionWasCalled)
    }

    func testButtonDefaultValues() {
        let button = MyNeuroButton(icon: "heart", iconFilled: "heart.fill") {}

        XCTAssertEqual(button.fillColor, .blue)
        XCTAssertEqual(button.width, 100)
        XCTAssertEqual(button.height, 100)
    }

    func testButtonUsesDefaultTheme() {
        let button = MyNeuroButton(icon: "star", iconFilled: "star.fill") {}
        XCTAssertEqual(button.theme.cornerRadius, NeumorphicTheme.default.cornerRadius)
        XCTAssertEqual(button.theme.animationDuration, NeumorphicTheme.default.animationDuration)
    }

    func testButtonCustomTheme() {
        let custom = NeumorphicTheme(cornerRadius: 20, normalShadowRadius: 15)
        let button = MyNeuroButton(icon: "star", iconFilled: "star.fill", theme: custom) {}
        XCTAssertEqual(button.theme.cornerRadius, 20)
        XCTAssertEqual(button.theme.normalShadowRadius, 15)
    }

    func testBackwardCompatibilityInitializer() {
        var actionCalled = false
        let button = MyNeuroButton(
            icon: "star",
            iconFull: "star.fill",
            fillColor: .red,
            height: 80,
            width: 120
        ) {
            actionCalled = true
        }

        button.action()

        XCTAssertTrue(actionCalled)
        XCTAssertEqual(button.icon, "star")
        XCTAssertEqual(button.iconFilled, "star.fill")
        XCTAssertEqual(button.fillColor, .red)
        XCTAssertEqual(button.width, 120)
        XCTAssertEqual(button.height, 80)
    }
}
