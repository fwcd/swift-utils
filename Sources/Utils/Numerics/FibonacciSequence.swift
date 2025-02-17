public struct FibonacciSequence<Value>: Sequence where Value: ExpressibleByIntegerLiteral & Addable & Equatable {
    public init() {}

    public func makeIterator() -> Iterator {
        Iterator()
    }

    public struct Iterator: IteratorProtocol {
        private var nMinus2: Value = 0
        private var nMinus1: Value = 0

        public mutating func next() -> Value? {
            guard nMinus1 != 0 else {
                nMinus1 = 1
                return 1
            }
            let n = nMinus1 + nMinus2
            nMinus2 = nMinus1
            nMinus1 = n
            return n
        }
    }
}
