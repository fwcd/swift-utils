import Foundation

// Unfortunately Swift (as of 5.10) does not support async property wrappers.
// For clarity, the API does not use autoclosure either.

/// A value that periodically expires and gets re-queried
/// through a supplied getter.
public struct AsyncLazyExpiring<T> {
    public let expiryInterval: TimeInterval
    public private(set) var nextExpiry: Date? = nil
    private var expired: Bool { nextExpiry.map { $0.timeIntervalSinceNow < 0 } ?? true }

    private let getter: () async throws -> T
    private var cachedValue: T?
    public var wrappedValue: T {
        mutating get async throws {
            if expired || cachedValue == nil {
                try await update()
            }
            return cachedValue!
        }
    }

    public init(in expiryInterval: TimeInterval = 1.0, wrappedValue getter: @escaping () async throws -> T) {
        self.getter = getter
        self.expiryInterval = expiryInterval
    }

    private mutating func update() async throws {
        cachedValue = try await getter()
        nextExpiry = Date(timeInterval: expiryInterval, since: Date())
    }
}
