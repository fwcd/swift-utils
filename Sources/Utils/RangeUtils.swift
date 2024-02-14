fileprivate let intRangePattern = #/(\d+)\.\.<(\d+)/#
fileprivate let closedIntRangePattern = #/(\d+)\.\.\.(\d+)/#

public func parseIntRange(from str: String) -> Range<Int>? {
    if let rawBounds = try? intRangePattern.firstMatch(in: str) {
        return Int(rawBounds.1)!..<Int(rawBounds.2)!
    } else {
        return nil
    }
}

public func parseClosedIntRange(from str: String) -> ClosedRange<Int>? {
    if let rawBounds = try? closedIntRangePattern.firstMatch(in: str) {
        return Int(rawBounds.1)!...Int(rawBounds.2)!
    } else {
        return nil
    }
}
