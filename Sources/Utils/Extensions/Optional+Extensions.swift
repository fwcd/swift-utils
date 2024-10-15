public extension Optional {
    func filter(_ predicate: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        try flatMap { try predicate($0) ? $0 : nil }
    }

    // MARK: Async combinators

    func asyncFilter(_ predicate: (Wrapped) async throws -> Bool) async rethrows -> Wrapped? {
        try await asyncFlatMap { try await predicate($0) ? $0 : nil }
    }

    func asyncMap<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
        try await asyncFlatMap(transform)
    }

    func asyncFlatMap<T>(_ transform: (Wrapped) async throws -> T?) async rethrows -> T? {
        if let self {
            try await transform(self)
        } else {
            nil
        }
    }
}
