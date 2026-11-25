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
        XCTAssertNil(badge.theme)
    }

    func testStoresCustomValues() {
        let badge = NeuroBadge("Hot", systemImage: "flame", tint: .red, theme: NeumorphicTheme(cornerRadius: 3))
        XCTAssertEqual(badge.systemImage, "flame")
        XCTAssertEqual(badge.tint, .red)
        XCTAssertEqual(badge.theme?.cornerRadius, 3)
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

    func testSmallReliefCapsShadowRadius() {
        let big = NeumorphicTheme(normalShadowRadius: 20)
        XCTAssertEqual(NeuroBadge.smallRelief(of: big).normalShadowRadius, 4)
        XCTAssertEqual(NeuroBadge.smallRelief(of: NeumorphicTheme(normalShadowRadius: 2)).normalShadowRadius, 2)
        XCTAssertEqual(NeuroBadge.smallRelief(of: big).cornerRadius, big.cornerRadius)
    }
}
