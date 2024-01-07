import XCTest
@testable import Utils

final class MathUtilsTests: XCTestCase {
    func testLog2Floor() throws {
        XCTAssertEqual(UInt(1).log2Floor(), 0)
        XCTAssertEqual(UInt(2).log2Floor(), 1)
        XCTAssertEqual(UInt(3).log2Floor(), 1)
        XCTAssertEqual(UInt(4).log2Floor(), 2)
        XCTAssertEqual(UInt(5).log2Floor(), 2)
        XCTAssertEqual(UInt(6).log2Floor(), 2)
        XCTAssertEqual(UInt(7).log2Floor(), 2)
        XCTAssertEqual(UInt(8).log2Floor(), 3)
    }
}
