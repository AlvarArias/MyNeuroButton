import SwiftUI
import XCTest
@testable import MyNeuroButton

final class MyNeuroButtonTests: XCTestCase {
    
    func testButtonInitialization() {
        // Given
        let icon = "star"
        let iconFilled = "star.fill"
        let fillColor = Color.blue
        let width: CGFloat = 120
        let height: CGFloat = 80
        var actionCalled = false
        
        // When
        let button = MyNeuroButton(
            icon: icon,
            iconFilled: iconFilled,
            fillColor: fillColor,
            width: width,
            height: height
        ) {
            actionCalled = true
        }
        
        // Then
        XCTAssertEqual(button.icon, icon)
        XCTAssertEqual(button.iconFilled, iconFilled)
        XCTAssertEqual(button.fillColor, fillColor)
        XCTAssertEqual(button.width, width)
        XCTAssertEqual(button.height, height)
    }
    
    func testButtonActionExecution() {
        // Given
        var actionWasCalled = false
        let button = MyNeuroButton(
            icon: "star",
            iconFilled: "star.fill",
            fillColor: .blue,
            width: 100,
            height: 100
        ) {
            actionWasCalled = true
        }

        // When
        button.action()

        // Then
        XCTAssertTrue(actionWasCalled, "The button's action should be called when executed.")
    }
    
    func testButtonDefaultValues() {
        // Given
        let button = MyNeuroButton(
            icon: "heart",
            iconFilled: "heart.fill"
        ) {
            // Empty action
        }
        
        // Then
        XCTAssertEqual(button.fillColor, .blue)
        XCTAssertEqual(button.width, 100)
        XCTAssertEqual(button.height, 100)
    }
    
    func testBackwardCompatibilityInitializer() {
        // Given
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
        
        // When
        button.action()
        
        // Then
        XCTAssertTrue(actionCalled, "Legacy initializer should work correctly")
        XCTAssertEqual(button.icon, "star")
        XCTAssertEqual(button.iconFilled, "star.fill")
        XCTAssertEqual(button.fillColor, .red)
        XCTAssertEqual(button.width, 120)
        XCTAssertEqual(button.height, 80)
    }
}


