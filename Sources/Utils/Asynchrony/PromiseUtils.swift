import Dispatch

/// Returns a new promise that completes once all results from the
/// individual promises have returned. This means that they possibly
/// execute concurrently.
@discardableResult
public func all<T, E>(promises: [Promise<T, E>]) -> Promise<[T], E> where E: Error {
    Promise { then in
        let queue = DispatchQueue(label: "all(promises:)")

        // Safety: All accesses to the state are via the queue, thus synchronized
        nonisolated(unsafe) var values = [T]()
        nonisolated(unsafe) var remaining = promises.count
        nonisolated(unsafe) var failed = false

        for promise in promises {
            promise.listen { result in
                queue.sync {
                    switch result {
                        case let .success(value):
                            values.append(value)
                            remaining -= 1
                            if remaining == 0 && !failed {
                                then(.success(values))
                            }
                        case let .failure(error):
                            if !failed {
                                failed = true
                                then(.failure(error))
                            }
                    }
                }
            }
        }
    }
}

/// Sequentially executes the promises.
@discardableResult
public func sequence<T, C, E>(promises: C) -> Promise<[T], E>
where E: Error,
      C: Collection & Sendable,
      C.SubSequence: Sendable,
      C.Element == (() -> Promise<T, E>) {
    if let promise = promises.first {
        return promise().then { value in sequence(promises: promises.dropFirst()).map { [value] + $0 } }
    } else {
        return Promise(.success([]))
    }
}
