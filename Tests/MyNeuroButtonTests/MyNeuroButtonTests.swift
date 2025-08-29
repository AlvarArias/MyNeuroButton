/*
import XCTest
@testable import MyNeuroButton

final class MyNeuroButtonTests: XCTestCase {
   /* func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MyNeuroButton)., )
    }*/
  
}
*/
import SwiftUI
import XCTest
@testable import MyNeuroButton

final class MyNeuroBUttons: XCTestCase {
    func testButtonAction() {
        var actionWasCalled = false

        let button = MyNeuroButton(icon: "star", iconFull: "star.full", fillColor: Color.blue, height: 100, width: 100, action: {
            actionWasCalled = true
        })

        button.action()

        XCTAssertTrue(actionWasCalled, "The button's action should be called.")
    }
}


