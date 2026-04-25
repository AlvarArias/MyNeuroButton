import SwiftUI
import XCTest
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
