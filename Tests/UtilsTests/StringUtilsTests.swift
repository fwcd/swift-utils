import XCTest
@testable import Utils

final class StringUtilsTests: XCTestCase {
    func testSplitPreservingQuotes() {
        XCTAssertEqual("this is | a string | separated by pipes".splitPreservingQuotes(by: "|"), [
            "this is ",
            " a string ",
            " separated by pipes"
        ])
        XCTAssertEqual("this string has \"quoted | regions\" | that ' should | ` | not ` | be ' | split".splitPreservingQuotes(by: "|"), [
            "this string has \"quoted | regions\" ",
            " that ' should | ` | not ` | be ' ",
            " split"
        ])
    }

    func testCamelHumps() {
        XCTAssertEqual("".camelHumps, [])
        XCTAssertEqual("test".camelHumps, ["test"])
        XCTAssertEqual("Upper".camelHumps, ["Upper"])
        XCTAssertEqual("camelCase".camelHumps, ["camel", "Case"])
        XCTAssertEqual("UpperCamelCase".camelHumps, ["Upper", "Camel", "Case"])
    }

    func testLevenshteinDistance() {
        XCTAssertEqual("".levenshteinDistance(to: ""), 0)
        XCTAssertEqual("".levenshteinDistance(to: "abc"), 3)
        XCTAssertEqual("abc".levenshteinDistance(to: "abc"), 0)
        XCTAssertEqual("cba".levenshteinDistance(to: "abc"), 2)
        XCTAssertEqual("bc".levenshteinDistance(to: "abc"), 1)
        XCTAssertEqual("kitten".levenshteinDistance(to: "sitting"), 3)
    }

    func testLcsDistance() {
        XCTAssertEqual("".lcsDistance(to: ""), 0)
        XCTAssertEqual("".lcsDistance(to: "abc"), 3)
        XCTAssertEqual("abc".lcsDistance(to: "abc"), 0)
        XCTAssertEqual("cba".lcsDistance(to: "abc"), 4)
        XCTAssertEqual("bc".lcsDistance(to: "abc"), 1)
        XCTAssertEqual("kitten".lcsDistance(to: "sitting"), 5)
    }
}
