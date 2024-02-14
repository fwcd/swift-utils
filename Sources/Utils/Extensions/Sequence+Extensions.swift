public extension Sequence {
    func count(forWhich predicate: (Element) throws -> Bool) rethrows -> Int {
        // TODO: Implemented in https://github.com/apple/swift-evolution/blob/master/proposals/0220-count-where.md
        try reduce(0) { try predicate($1) ? $0 + 1 : $0 }
    }

    /// Similar to reduce, but returns a list of successive reduced values from the left
    func scan<T>(_ initial: T, _ accumulator: (T, Element) throws -> T) rethrows -> [T] {
        var scanned = [initial]
        for value in self {
            scanned.append(try accumulator(scanned.last!, value))
        }
        return scanned
    }

    /// Similar to scan, but without an initial element
    func scan1(_ accumulator: (Element, Element) throws -> Element) rethrows -> [Element] {
        var scanned = [Element]()
        for value in self {
            scanned.append(try scanned.last.map { try accumulator($0, value) } ?? value)
        }
        return scanned
    }

    /// Reduce, but without an initial element
    func reduce1(_ accumulator: (Element, Element) throws -> Element) rethrows -> Element? {
        var result: Element? = nil
        for value in self {
            result = try result.map { try accumulator($0, value) } ?? value
        }
        return result
    }

    /// Turns a list of optionals into an optional list, like Haskell's 'sequence'.
    func sequenceMap<T>(_ transform: (Element) throws -> T? ) rethrows -> [T]? {
        var result = [T]()

        for element in self {
            guard let transformed = try transform(element) else { return nil }
            result.append(transformed)
        }

        return result
    }

    func withoutDuplicates<T>(by mapper: (Element) throws -> T) rethrows -> [Element] where T: Hashable {
        var result = [Element]()
        var keys = Set<T>()

        for element in self {
            let key = try mapper(element)
            if !keys.contains(key) {
                keys.insert(key)
                result.append(element)
            }
        }

        return result
    }

    @available(*, deprecated, message: "Use groupingPreservingOrder(by:) instead")
    func grouped<K>(by mapper: (Element) throws -> K) rethrows -> [(K, [Element])] where K: Hashable {
        try Dictionary(grouping: enumerated(), by: { try mapper($0.1) })
            .map { ($0.0, $0.1.sorted(by: ascendingComparator { $0.0 })) }
            .sorted(by: ascendingComparator { ($0.1)[0].0 })
            .map { ($0.0, $0.1.map(\.1)) }
    }

    // Groups a sequence, preserving the order of the elements
    func groupingPreservingOrder<K>(by mapper: (Element) throws -> K) rethrows -> [(K, [Element])] where K: Hashable {
        try Dictionary(grouping: enumerated(), by: { try mapper($0.1) })
            .map { ($0.0, $0.1.sorted(by: ascendingComparator { $0.0 })) }
            .sorted(by: ascendingComparator { ($0.1)[0].0 })
            .map { ($0.0, $0.1.map(\.1)) }
    }
}
