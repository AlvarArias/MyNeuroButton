import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroDividerTests: XCTestCase {

    func testDefaultsToHorizontal() {
        let divider = NeuroDivider()
        XCTAssertEqual(divider.axis, .horizontal)
        XCTAssertNil(divider.theme)
    }

    func testStoresAxisAndTheme() {
        let theme = NeumorphicTheme(cornerRadius: 1)
        let divider = NeuroDivider(.vertical, theme: theme)
        XCTAssertEqual(divider.axis, .vertical)
        XCTAssertEqual(divider.theme, theme)
    }

    func testHorizontalIsTwoPointsTall() throws {
        let image = try XCTUnwrap(ImageRenderer(content: NeuroDivider().frame(width: 50)).cgImage)
        XCTAssertEqual(image.height, 2)
        XCTAssertEqual(image.width, 50)
    }

    func testVerticalIsTwoPointsWide() throws {
        let image = try XCTUnwrap(ImageRenderer(content: NeuroDivider(.vertical).frame(height: 50)).cgImage)
        XCTAssertEqual(image.width, 2)
        XCTAssertEqual(image.height, 50)
    }
}
