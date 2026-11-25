import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroCardTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    func testDefaults() {
        let card = NeuroCard { Text("Hi") }
        XCTAssertEqual(card.padding, 16)
        XCTAssertNil(card.theme)
    }

    func testStoresCustomValues() {
        let theme = NeumorphicTheme(cornerRadius: 22)
        let card = NeuroCard(padding: 8, theme: theme) { Text("Hi") }
        XCTAssertEqual(card.padding, 8)
        XCTAssertEqual(card.theme, theme)
    }

    func testRenders() {
        let view = NeuroCard { Text("Hello") }
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }

    func testPaddingChangesSize() throws {
        let small = ImageRenderer(content: NeuroCard(padding: 4) { Text("Hello") })
        let large = ImageRenderer(content: NeuroCard(padding: 40) { Text("Hello") })
        let smallImage = try XCTUnwrap(small.cgImage)
        let largeImage = try XCTUnwrap(large.cgImage)
        XCTAssertGreaterThan(largeImage.width, smallImage.width)
    }

    func testEnvironmentThemeReachesCard() throws {
        let themed = NeumorphicTheme(cornerRadius: 45)
        let plain = try XCTUnwrap(pixels(NeuroCard(padding: 40) { Color.clear.frame(width: 60, height: 60) }))
        let viaEnvironment = try XCTUnwrap(
            pixels(NeuroCard(padding: 40) { Color.clear.frame(width: 60, height: 60) }.neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(
            pixels(NeuroCard(padding: 40, theme: themed) { Color.clear.frame(width: 60, height: 60) }))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }

    func testExplicitThemeBeatsEnvironment() throws {
        let explicit = NeumorphicTheme(cornerRadius: 45)
        let body = { Color.clear.frame(width: 60, height: 60) }
        let withEnvironment = try XCTUnwrap(
            pixels(NeuroCard(padding: 40, theme: explicit, content: body).neumorphicTheme(NeumorphicTheme(cornerRadius: 0))))
        let without = try XCTUnwrap(pixels(NeuroCard(padding: 40, theme: explicit, content: body)))
        XCTAssertEqual(withEnvironment, without)
    }
}
