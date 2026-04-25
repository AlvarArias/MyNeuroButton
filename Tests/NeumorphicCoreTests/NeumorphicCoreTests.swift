import SwiftUI
import XCTest
@testable import NeumorphicCore

final class NeumorphicCoreTests: XCTestCase {

    func testDefaultThemeValues() {
        let theme = NeumorphicTheme.default
        XCTAssertEqual(theme.cornerRadius, 10)
        XCTAssertEqual(theme.animationDuration, 0.1)
        XCTAssertEqual(theme.normalShadowRadius, 10)
        XCTAssertEqual(theme.pressedShadowRadius, 5)
    }

    func testCustomThemeOverridesDefaults() {
        let theme = NeumorphicTheme(
            cornerRadius: 20,
            animationDuration: 0.2,
            normalShadowRadius: 15,
            pressedShadowRadius: 8
        )
        XCTAssertEqual(theme.cornerRadius, 20)
        XCTAssertEqual(theme.animationDuration, 0.2)
        XCTAssertEqual(theme.normalShadowRadius, 15)
        XCTAssertEqual(theme.pressedShadowRadius, 8)
    }

    func testColorExtensionsMatchThemeDefaults() {
        XCTAssertEqual(Color.neumorphicBackground, NeumorphicTheme.default.background)
        XCTAssertEqual(Color.neumorphicForeground, NeumorphicTheme.default.foreground)
    }
}
