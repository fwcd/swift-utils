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

public extension Array where Element: Equatable {
    @discardableResult
    mutating func removeFirst(value: Element) -> Element? {
        guard let index = firstIndex(of: value) else { return nil }
        return remove(at: index)
    }
}
