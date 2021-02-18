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

    // Groups a sequence, preserving the order of the elements
    func grouped<K>(by mapper: (Element) throws -> K) rethrows -> [(K, [Element])] where K: Hashable {
        try Dictionary(grouping: enumerated(), by: { try mapper($0.1) })
            .map { ($0.0, $0.1.sorted(by: ascendingComparator { $0.0 })) }
            .sorted(by: ascendingComparator { ($0.1)[0].0 })
            .map { ($0.0, $0.1.map(\.1)) }
    }
}

public extension Dictionary where Key: StringProtocol, Value: StringProtocol {
    var urlQueryEncoded: String {
        map { "\($0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($0))=\($1.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($1))" }
            .joined(separator: "&")
    }
}

public extension Collection {
    var nilIfEmpty: Self? {
        isEmpty ? nil : self
    }

    subscript(safely index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// Splits the collection into chunks
    func chunks(ofLength chunkLength: Int) -> [SubSequence] {
        guard chunkLength > 0 else { return [] }
        var chunks = [SubSequence]()
        var remaining = self[...]
        var index = startIndex
        while formIndex(&index, offsetBy: chunkLength, limitedBy: endIndex) {
            chunks.append(remaining.prefix(upTo: index))
            remaining = remaining.suffix(from: index)
        }
        if !remaining.isEmpty {
            chunks.append(remaining)
        }
        return chunks
    }
}

public extension Collection where Element: RandomAccessCollection {
    var transposed: [[Element.Element]] {
        first?.indices.map { i in map { $0[i] } } ?? []
    }
}

// TODO: Implement this as a generic extension over collections containing optionals
// once Swift supports this.
public func allNonNil<T>(_ array: [T?]) -> [T]? where T: Equatable {
    array.contains(nil) ? nil : array.map { $0! }
}

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

public extension Array {
    /// Picks a random index, then swaps the element to the end
    /// and pops it from the array. This should only be used
    /// if the order of the list does not matter.
    ///
    /// Runs in O(1).
    mutating func removeRandomElementBySwap() -> Element? {
        guard !isEmpty else { return nil }
        let index = Int.random(in: 0..<count)
        swapAt(index, count - 1)
        return popLast()
    }

    /// Randomly removes `count` elements by swapping them
    /// to the end. This should only be used if the order of
    /// the list does not matter.
    mutating func removeRandomlyChosenBySwap(count chosenCount: Int) -> [Element] {
        guard chosenCount <= count else { fatalError("Cannot choose \(chosenCount) elements from an array of size \(count)!") }
        var elements = [Element]()
        for _ in 0..<chosenCount {
            elements.append(removeRandomElementBySwap()!)
        }
        return elements
    }

    /// Randomly chooses `count` elements from the array.
    func randomlyChosen(count chosenCount: Int) -> [Element] {
        var copy = self
        return copy.removeRandomlyChosenBySwap(count: chosenCount)
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

public extension Array where Element: Equatable {
    @discardableResult
    mutating func removeFirst(value: Element) -> Element? {
        guard let index = firstIndex(of: value) else { return nil }
        return remove(at: index)
    }
}
