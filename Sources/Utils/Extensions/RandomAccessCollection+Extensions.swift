public extension RandomAccessCollection {
    func truncated(to length: Int, appending appended: Element? = nil) -> [Element] {
        if count > length {
            return appended.map { prefix(length - 1) + [$0] } ?? Array(prefix(length))
        } else {
            return Array(self)
        }
    }

    func truncated(to length: Int, _ appender: ([Element]) -> Element) -> [Element] {
        if count > length {
            return prefix(length - 1) + [appender(Array(dropFirst(length - 1)))]
        } else {
            return Array(self)
        }
    }

    func repeated(count: Int) -> [Element] {
        assert(count >= 0)
        var result = [Element]()
        for _ in 0..<count {
            result += self
        }
        return result
    }

    /// The longest prefix satisfying the predicate and the rest of the list
    func span(_ inPrefix: (Element) throws -> Bool) rethrows -> (SubSequence, SubSequence) {
        let pre = try prefix(while: inPrefix)
        let rest = self[pre.endIndex...]
        return (pre, rest)
    }
}

public extension RandomAccessCollection where Element: StringProtocol {
    /// Creates a natural language 'enumeration' of the items, e.g.
    ///
    /// ["apples", "bananas", "pears"] -> "apples, bananas and pears"
    func englishEnumerated() -> String {
        switch count {
            case 0: return ""
            case 1: return String(first!)
            default: return "\(prefix(count - 1).joined(separator: ", ")) and \(last!)"
        }
    }
}

public extension RandomAccessCollection where Element: Equatable {
    func allIndices(of element: Element) -> [Index] {
        return zip(indices, self).filter { $0.1 == element }.map { $0.0 }
    }
}
