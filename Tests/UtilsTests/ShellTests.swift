import XCTest
@testable import Utils

final class ShellTests: XCTestCase {
    static var allTests = [
        ("testShell", testShell),
    ]

    func testShell() {
        let output = try! Shell().utf8(for: "echo", args: ["hi"]).wait()
        XCTAssertEqual(output, "hi\n")
    }
}
