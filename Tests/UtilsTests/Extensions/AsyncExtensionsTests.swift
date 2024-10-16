import XCTest
@testable import Utils

@globalActor
private actor GlobalTestActor: GlobalActor {
    static let shared = GlobalTestActor()
}

actor OtherActor {
    var y: Int = 12
}

final class AsyncExtensionsTests: XCTestCase {
    func testOptionalAsyncMap() async {
        let mapped = await Optional.some(42).asyncMap { $0 * 2 }
        XCTAssertEqual(mapped, 84)

        await Task { @GlobalTestActor in
            let x: Int = 42
            let other = OtherActor()
            let mapped = await Optional.some(x).asyncMap { _ in await other.y }
            XCTAssertEqual(mapped, 12)
        }.value
    }
}
