import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroBadgeTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    func testDefaults() {
        let badge = NeuroBadge("New")
        XCTAssertEqual(badge.text, "New")
        XCTAssertNil(badge.systemImage)
        XCTAssertNil(badge.tint)
        XCTAssertEqual(badge.theme, .default)
    }

    func testStoresCustomValues() {
        let badge = NeuroBadge("Hot", systemImage: "flame", tint: .red, theme: NeumorphicTheme(cornerRadius: 3))
        XCTAssertEqual(badge.systemImage, "flame")
        XCTAssertEqual(badge.tint, .red)
        XCTAssertEqual(badge.theme.cornerRadius, 3)
    }

    func testRenders() {
        XCTAssertNotNil(ImageRenderer(content: NeuroBadge("New")).cgImage)
    }

    func testIconMakesBadgeWider() throws {
        let plain = try XCTUnwrap(ImageRenderer(content: NeuroBadge("New")).cgImage)
        let withIcon = try XCTUnwrap(ImageRenderer(content: NeuroBadge("New", systemImage: "star.fill")).cgImage)
        XCTAssertGreaterThan(withIcon.width, plain.width)
    }

    func testEnvironmentThemeReachesBadge() throws {
        let themed = NeumorphicTheme.dark
        let plain = try XCTUnwrap(pixels(NeuroBadge("New")))
        let viaEnvironment = try XCTUnwrap(pixels(NeuroBadge("New").neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(pixels(NeuroBadge("New", theme: themed)))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }

    func testCappingShadowLimitsBothRadii() {
        let big = NeumorphicTheme(normalShadowRadius: 20, pressedShadowRadius: 9)
        let capped = big.cappingShadow(at: 4)
        XCTAssertEqual(capped.normalShadowRadius, 4)
        XCTAssertEqual(capped.pressedShadowRadius, 4)
        XCTAssertEqual(capped.cornerRadius, big.cornerRadius)
    }

    func testCappingShadowLeavesSmallerRadiiAlone() {
        let small = NeumorphicTheme(normalShadowRadius: 2, pressedShadowRadius: 1)
        let capped = small.cappingShadow(at: 4)
        XCTAssertEqual(capped.normalShadowRadius, 2)
        XCTAssertEqual(capped.pressedShadowRadius, 1)
    }
}
