import Dispatch
import Logging

fileprivate let log = Logger(label: "Utils.Promise")

/// Represents an asynchronously computed value.
///
/// Promises are executed immediately, i.e. is body
/// runs synchronously with the constructor, similar
/// to e.g. JavaScript's promises, but different from
/// Python/Rust.
public class Promise<T, E> where E: Error {
    private let mutex = MutexLock()
    private var state: State
    private var listeners: [(Result<T, E>) -> Void] = []
    private var wasListenedTo: Bool = false

    /// Creates a finished, succeeded promise.
    public convenience init(_ value: T) {
        self.init(.success(value))
    }

    /// Creates a finished promise.
    public required init(_ value: Result<T, E>) {
        state = .finished(value)
    }

    /// Creates a promise from the given thenable and
    /// synchronously begins running it.
    public required init(_ thenable: (@escaping (Result<T, E>) -> Void) -> Void) {
        state = .pending
        thenable { result in
            self.mutex.lock {
                self.state = .finished(result)
                for listener in self.listeners {
                    listener(result)
                }
                self.listeners = []
            }
        }
    }

    deinit {
        switch state {
        case .pending:
            log.warning("Deinitializing a pending promise, this is probably an error.")
        case .finished(.failure(let error)):
            if !wasListenedTo {
                log.error("Unhandled promise error: \(error)")
            }
        default:
            break
        }
    }

    private enum State {
        case pending
        case finished(Result<T, E>)
    }

    /// Listens for the result. Only fires once.
    public func listen(_ listener: @escaping (Result<T, E>) -> Void) {
        mutex.lock {
            wasListenedTo = true
            if case let .finished(result) = state {
                listener(result)
            } else {
                listeners.append(listener)
            }
        }
    }

    /// Listens for a successful result or logs an error otherwise. Only fires once.
    public func listenOrLogError(file: String = #file, line: Int = #line, _ listener: @escaping (T) -> Void) {
        listen {
            switch $0 {
                case .success(let value):
                    listener(value)
                case .failure(let error):
                    log.error("Asynchronous error (listened for at \(file):\(line)): \(error)")
            }
        }
    }

    /// Listens for the result. Only fires once. Returns the promise.
    public func peekListen(_ listener: @escaping (Result<T, E>) -> Void) -> Self {
        listen(listener)
        return self
    }

    /// Chains another asynchronous computation after this one.
    public func then<U>(_ next: @escaping (T) -> Promise<U, E>) -> Promise<U, E> {
        Promise<U, E> { then in
            listen {
                switch $0 {
                    case .success(let value):
                        next(value).listen(then)
                    case .failure(let error):
                        then(.failure(error))
                }
            }
        }
    }

    /// Chains another synchronous computation after this one.
    public func map<U>(_ transform: @escaping (T) -> U) -> Promise<U, E> {
        Promise<U, E> { then in
            listen {
                then($0.map(transform))
            }
        }
    }

    /// Chains another synchronous computation after this one.
    public func mapResult<U>(_ transform: @escaping (Result<T, E>) -> Result<U, E>) -> Promise<U, E> {
        Promise<U, E> { then in
            listen {
                then(transform($0))
            }
        }
    }

    /// Ignores the return value of the promise.
    public func void() -> Promise<Void, E> {
        map { _ in }
    }

    /// Voids the result and swallows the error.
    public func swallow() -> Promise<Void, E> {
        Promise<Void, E> { then in
            listen { _ in
                then(.success(()))
            }
        }
    }

    /// Convenience method for discarding the promise in a method chain.
    /// Making this explicit helps preventing accidental race conditions.
    public func forget() {}

    /// Awaits the promise result synchronously by blocking the
    /// current thread. You should make sure to not run this method
    /// from the same thread that also fulfills your promise since that
    /// might result in a deadlock.
    public func wait() throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, E>!

        listen {
            result = $0
            semaphore.signal()
        }

        semaphore.wait()
        return try result.get()
    }

    /// Fetches the result asynchronously.
    public func get() async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            listen(continuation.resume(with:))
        }
    }

    /// Fetches the result asynchronously and logs an error if absent.
    public func getOrLogError(file: String = #file, line: Int = #line) async -> T? {
        await withCheckedContinuation { continuation in
            listen {
                switch $0 {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        log.error("Asynchronous error (fetched at \(file):\(line)): \(error)")
                        continuation.resume(returning: nil)
                }
            }
        }
    }
}

extension Promise where E == Error {
    /// Creates a (finished) promise catching the given block.
    public static func catching(_ block: () throws -> T) -> Self {
        Self(Result(catching: block))
    }

    /// Creates a promise catching the given block returning another promise.
    public static func catchingThen(_ block: () throws -> Promise<T, Error>) -> Promise<T, Error> {
        Promise<Promise<T, Error>, Error>.catching(block).then { $0 }
    }

    /// Creates another promise from mapping the current one with a callback that may synchronously throw.
    public func mapCatching<U>(_ transform: @escaping (T) throws -> U) -> Promise<U, E> {
        then { x in
            .catching {
                try transform(x)
            }
        }
    }

    /// Chains another promise with a callback that may synchronously throw.
    public func thenCatching<U>(_ next: @escaping (T) throws -> Promise<U, Error>) -> Promise<U, Error> {
        then { x in
            .catchingThen {
                try next(x)
            }
        }
    }
}
