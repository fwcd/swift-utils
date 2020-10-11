public struct LazyDictionary<K, V>: ExpressibleByDictionaryLiteral, Sequence where K: Hashable {
    private var inner: [K: Lazy<V?>] = [:]

    public var count: Int { inner.count }
    public var isEmpty: Bool { inner.isEmpty }
    public var keys: Dictionary<K, Lazy<V?>>.Keys { inner.keys }

    public init(dictionaryLiteral elements: (K, V)...) {
        for (key, value) in elements {
            inner[key] = .computed(value)
        }
    }

    public subscript(_ key: K) -> V? {
        get { inner[key]?.wrappedValue }
        set { inner[key] = newValue.map { .computed($0) } }
    }

    public subscript(lazy key: K) -> Lazy<V?>? {
        get { inner[key] }
        set { inner[key] = newValue }
    }

    public func makeIterator() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<[K: Lazy<V?>], (K, V)?>>, (K, V)>.Iterator {
        return inner.lazy.compactMap { (k, v) in v.wrappedValue.map { (k, $0) } }.makeIterator()
    }
}
