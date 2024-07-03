import XCTest
@testable import Utils

final class CollectionUtilsTests: XCTestCase {
    func testChunks() {
        XCTAssertEqual("".chunks(ofLength: 0), [])
        XCTAssertEqual("".chunks(ofLength: 3), [])
        XCTAssertEqual("This is nice".chunks(ofLength: 3), ["Thi", "s i", "s n", "ice"])
        XCTAssertEqual("Test".chunks(ofLength: 1), ["T", "e", "s", "t"])
        XCTAssertEqual("Test".chunks(ofLength: 8), ["Test"])
        XCTAssertEqual("Test this".chunks(ofLength: 4), ["Test", " thi", "s"])
    }
}
