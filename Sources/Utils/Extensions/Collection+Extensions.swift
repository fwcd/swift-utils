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
