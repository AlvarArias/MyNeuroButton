import SwiftUI
import XCTest
@testable import NeumorphicCore

@MainActor
final class NeuroPressableTests: XCTestCase {

    func testResolvePrefersExplicitTheme() {
        let explicit = NeumorphicTheme(cornerRadius: 1)
        let environment = NeumorphicTheme(cornerRadius: 2)
        XCTAssertEqual(NeuroPressable<Text>.resolve(explicit: explicit, environment: environment), explicit)
    }

    func testResolveFallsBackToEnvironment() {
        let environment = NeumorphicTheme(cornerRadius: 2)
        XCTAssertEqual(NeuroPressable<Text>.resolve(explicit: nil, environment: environment), environment)
    }

    func testStoresExplicitTheme() {
        let theme = NeumorphicTheme(cornerRadius: 9)
        let pressable = NeuroPressable(theme: theme, action: {}) { _, _ in Text("x") }
        XCTAssertEqual(pressable.explicitTheme, theme)
    }

    func testNoThemeMeansNoExplicitTheme() {
        let pressable = NeuroPressable(action: {}) { _, _ in Text("x") }
        XCTAssertNil(pressable.explicitTheme)
    }

    func testActionIsInvoked() {
        var count = 0
        let pressable = NeuroPressable(action: { count += 1 }) { _, _ in Text("x") }
        pressable.action()
        pressable.action()
        XCTAssertEqual(count, 2)
    }

    func testRendersLabelWithResolvedTheme() {
        let view = NeuroPressable(theme: NeumorphicTheme(cornerRadius: 12), action: {}) { isPressed, theme in
            Text("\(isPressed) \(theme.cornerRadius)").frame(width: 60, height: 30)
        }
        XCTAssertNotNil(ImageRenderer(content: view).cgImage)
    }
}
