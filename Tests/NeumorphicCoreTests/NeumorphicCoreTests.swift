import SwiftUI
import XCTest
@testable import NeumorphicCore

@MainActor
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

    func testNeumorphicSurfaceStoresProperties() {
        let surface = NeumorphicSurface(theme: .default, isPressed: false)
        XCTAssertFalse(surface.isPressed)
        XCTAssertEqual(surface.theme.normalShadowRadius, NeumorphicTheme.default.normalShadowRadius)
    }

    func testNeumorphicSurfacePressedState() {
        let surface = NeumorphicSurface(isPressed: true)
        XCTAssertTrue(surface.isPressed)
    }

    func testNeumorphicSurfaceCustomTheme() {
        let custom = NeumorphicTheme(pressedShadowRadius: 3)
        let surface = NeumorphicSurface(theme: custom, isPressed: true)
        XCTAssertEqual(surface.theme.pressedShadowRadius, 3)
    }
}
