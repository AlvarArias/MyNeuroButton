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

    // MARK: - Environment

    func testEnvironmentThemeDefaultsToDefaultTheme() {
        XCTAssertEqual(EnvironmentValues().neumorphicTheme, NeumorphicTheme.default)
    }

    func testEnvironmentThemeCanBeSet() {
        var values = EnvironmentValues()
        values.neumorphicTheme = NeumorphicTheme(cornerRadius: 30)
        XCTAssertEqual(values.neumorphicTheme.cornerRadius, 30)
    }

    func testThemeEquatable() {
        XCTAssertEqual(NeumorphicTheme(cornerRadius: 4), NeumorphicTheme(cornerRadius: 4))
        XCTAssertNotEqual(NeumorphicTheme(cornerRadius: 4), NeumorphicTheme(cornerRadius: 5))
    }

    func testNeumorphicThemeViewModifierRenders() {
        let view = Text("Hi").neumorphicTheme(NeumorphicTheme(cornerRadius: 3)).frame(width: 40, height: 20)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    // MARK: - Dark mode

    func testShadowColorTokensDefaultToBlackAndWhite() {
        XCTAssertEqual(NeumorphicTheme.default.shadowColor, .black)
        XCTAssertEqual(NeumorphicTheme.default.highlightColor, .white)
    }

    func testDarkPresetDiffersFromDefault() {
        XCTAssertNotEqual(NeumorphicTheme.dark, NeumorphicTheme.default)
        XCTAssertNotEqual(NeumorphicTheme.dark.background, NeumorphicTheme.default.background)
    }

    func testDarkPresetKeepsGeometryTokens() {
        XCTAssertEqual(NeumorphicTheme.dark.cornerRadius, NeumorphicTheme.default.cornerRadius)
        XCTAssertEqual(NeumorphicTheme.dark.normalShadowRadius, NeumorphicTheme.default.normalShadowRadius)
    }

    func testAdaptiveThemePicksByColorScheme() {
        let modifier = AdaptiveNeumorphicTheme()
        XCTAssertEqual(modifier.theme(for: .light), .default)
        XCTAssertEqual(modifier.theme(for: .dark), .dark)
    }

    func testAdaptiveThemeCustomPair() {
        let light = NeumorphicTheme(cornerRadius: 1)
        let dark = NeumorphicTheme(cornerRadius: 2)
        let modifier = AdaptiveNeumorphicTheme(light: light, dark: dark)
        XCTAssertEqual(modifier.theme(for: .light), light)
        XCTAssertEqual(modifier.theme(for: .dark), dark)
    }

    func testAdaptiveViewModifierRenders() {
        let view = Text("Hi").neumorphicTheme().frame(width: 40, height: 20)
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    // MARK: - Inset with custom shape

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(20))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    func testInsetInRoundedRectangleMatchesDefaultInset() throws {
        let theme = NeumorphicTheme.default
        let byDefault = try XCTUnwrap(pixels(Color.clear.frame(width: 100, height: 60).neumorphicInset()))
        let explicit = try XCTUnwrap(pixels(
            Color.clear.frame(width: 100, height: 60)
                .neumorphicInset(in: RoundedRectangle(cornerRadius: theme.cornerRadius))))
        XCTAssertEqual(byDefault, explicit)
    }

    func testInsetShapeChangesRenderedOutput() throws {
        let rounded = try XCTUnwrap(pixels(Color.clear.frame(width: 100, height: 40).neumorphicInset()))
        let capsule = try XCTUnwrap(pixels(Color.clear.frame(width: 100, height: 40).neumorphicInset(in: Capsule())))
        XCTAssertNotEqual(rounded, capsule)
    }

    func testInsetStoresShape() {
        let inset = NeumorphicInset(theme: .default, shape: Capsule())
        XCTAssertEqual(inset.shadowOffset, NeumorphicTheme.default.insetShadowRadius / 2)
    }
}
