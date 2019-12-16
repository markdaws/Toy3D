import XCTest
@testable import Toy3D

final class Toy3DTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Toy3D().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
