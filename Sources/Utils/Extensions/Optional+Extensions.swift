public extension Optional {
    func filter(_ predicate: (Wrapped) throws -> Bool) rethrows -> Wrapped? {
        try flatMap { try predicate($0) ? $0 : nil }
    }

    // MARK: Async combinators

    func filter(_ predicate: (Wrapped) async throws -> Bool) async rethrows -> Wrapped? {
        try await flatMap { try await predicate($0) ? $0 : nil }
    }

    func map<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
        try await flatMap(transform)
    }

    func flatMap<T>(_ transform: (Wrapped) async throws -> T?) async rethrows -> T? {
        if let self {
            try await transform(self)
        } else {
            nil
        }
    }
}
