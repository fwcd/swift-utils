import XCTest
@testable import Utils

final class FibonacciSequenceTests: XCTestCase {
    func testFibonacciSequence() {
        XCTAssertEqual(Array(FibonacciSequence<Int>().prefix(10)), [1, 1, 2, 3, 5, 8, 13, 21, 34, 55])
    }
}
