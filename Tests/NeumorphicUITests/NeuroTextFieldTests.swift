import NeumorphicCore
import SwiftUI
import XCTest

@testable import NeumorphicUI

@MainActor
final class NeuroTextFieldTests: XCTestCase {

    private func pixels<V: View>(_ view: V) -> Data? {
        let renderer = ImageRenderer(content: view.padding(30).frame(width: 260))
        renderer.scale = 1
        return renderer.cgImage?.dataProvider?.data as Data?
    }

    func testDefaults() {
        let field = NeuroTextField("Email", text: .constant(""))
        XCTAssertNil(field.systemImage)
        XCTAssertFalse(field.isSecure)
        XCTAssertFalse(field.isError)
        XCTAssertNil(field.errorMessage)
        XCTAssertEqual(field.focusColor, .blue)
        XCTAssertEqual(field.errorColor, .red)
        XCTAssertEqual(field.fieldHeight, 44)
        XCTAssertEqual(field.theme, .default)
    }

    func testStoresCustomValues() {
        let field = NeuroTextField(
            "Password",
            text: .constant(""),
            systemImage: "lock",
            isSecure: true,
            isError: true,
            errorMessage: "Too short",
            focusColor: .green,
            errorColor: .orange,
            fieldHeight: 60,
            theme: NeumorphicTheme(cornerRadius: 3)
        )
        XCTAssertEqual(field.systemImage, "lock")
        XCTAssertTrue(field.isSecure)
        XCTAssertTrue(field.isError)
        XCTAssertNotNil(field.errorMessage)
        XCTAssertEqual(field.focusColor, .green)
        XCTAssertEqual(field.errorColor, .orange)
        XCTAssertEqual(field.fieldHeight, 60)
        XCTAssertEqual(field.theme.cornerRadius, 3)
    }

    func testBindingReadsAndWritesThroughTheField() {
        var stored = "hello"
        let binding = Binding(get: { stored }, set: { stored = $0 })
        let field = NeuroTextField("Name", text: binding)
        XCTAssertEqual(field.text.wrappedValue, "hello")
        field.text.wrappedValue = "world"
        XCTAssertEqual(stored, "world")
    }

    func testRenders() {
        XCTAssertNotNil(ImageRenderer(content: NeuroTextField("Name", text: .constant(""))).cgImage)
        XCTAssertNotNil(
            ImageRenderer(content: NeuroTextField("Name", text: .constant(""), isSecure: true)).cgImage)
    }

    func testErrorStateChangesTheRender() throws {
        let valid = try XCTUnwrap(pixels(NeuroTextField("Name", text: .constant("x"))))
        let invalid = try XCTUnwrap(
            pixels(NeuroTextField("Name", text: .constant("x"), isError: true)))
        XCTAssertNotEqual(valid, invalid)
    }

    func testErrorMessageMakesTheFieldTaller() throws {
        let without = try XCTUnwrap(
            ImageRenderer(content: NeuroTextField("Name", text: .constant("x"), isError: true)).cgImage)
        let with = try XCTUnwrap(
            ImageRenderer(
                content: NeuroTextField(
                    "Name", text: .constant("x"), isError: true, errorMessage: "Required")
            ).cgImage)
        XCTAssertGreaterThan(with.height, without.height)
    }

    func testErrorMessageIsHiddenWhileValid() throws {
        let plain = try XCTUnwrap(
            ImageRenderer(content: NeuroTextField("Name", text: .constant("x"))).cgImage)
        let withMessage = try XCTUnwrap(
            ImageRenderer(
                content: NeuroTextField("Name", text: .constant("x"), errorMessage: "Required")
            ).cgImage)
        XCTAssertEqual(plain.height, withMessage.height)
    }

    func testIconMakesTheContentShift() throws {
        let plain = try XCTUnwrap(pixels(NeuroTextField("Name", text: .constant("x"))))
        let withIcon = try XCTUnwrap(
            pixels(NeuroTextField("Name", text: .constant("x"), systemImage: "person")))
        XCTAssertNotEqual(plain, withIcon)
    }

    func testFieldHeightSetsMinimumHeight() throws {
        let short = try XCTUnwrap(
            ImageRenderer(content: NeuroTextField("Name", text: .constant(""), fieldHeight: 44)).cgImage)
        let tall = try XCTUnwrap(
            ImageRenderer(content: NeuroTextField("Name", text: .constant(""), fieldHeight: 80)).cgImage)
        XCTAssertGreaterThan(tall.height, short.height)
    }

    func testEnvironmentThemeReachesField() throws {
        let themed = NeumorphicTheme.dark
        let plain = try XCTUnwrap(pixels(NeuroTextField("Name", text: .constant(""))))
        let viaEnvironment = try XCTUnwrap(
            pixels(NeuroTextField("Name", text: .constant("")).neumorphicTheme(themed)))
        let explicit = try XCTUnwrap(
            pixels(NeuroTextField("Name", text: .constant(""), theme: themed)))
        XCTAssertNotEqual(plain, viaEnvironment)
        XCTAssertEqual(viaEnvironment, explicit)
    }
}
