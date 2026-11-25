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

    // MARK: - Inset

    func testThemeInsetShadowRadiusDefault() {
        XCTAssertEqual(NeumorphicTheme.default.insetShadowRadius, 5)
    }

    func testThemeInsetShadowRadiusOverride() {
        XCTAssertEqual(NeumorphicTheme(insetShadowRadius: 8).insetShadowRadius, 8)
    }

    func testExistingThemeInitCallsStillWork() {
        let theme = NeumorphicTheme(pressedShadowRadius: 3)
        XCTAssertEqual(theme.pressedShadowRadius, 3)
        XCTAssertEqual(theme.insetShadowRadius, 5)
    }

    func testNeumorphicInsetStoresTheme() {
        let inset = NeumorphicInset(theme: NeumorphicTheme(cornerRadius: 20))
        XCTAssertEqual(inset.theme.cornerRadius, 20)
    }

    func testNeumorphicInsetUsesDefaultTheme() {
        XCTAssertEqual(NeumorphicInset().theme.insetShadowRadius, NeumorphicTheme.default.insetShadowRadius)
    }

    func testNeumorphicInsetShadowOffsetIsHalfTheRadius() {
        let inset = NeumorphicInset(theme: NeumorphicTheme(insetShadowRadius: 12))
        XCTAssertEqual(inset.shadowOffset, 6)
    }

    func testNeumorphicInsetRendersAnImage() {
        let view = Text("Hi").frame(width: 80, height: 40).neumorphicInset()
        let renderer = ImageRenderer(content: view)
        XCTAssertNotNil(renderer.cgImage)
    }
}
