import Foundation

/// A value that periodically expires and gets re-queried
/// through a supplied getter.
@propertyWrapper
public struct Expiring<T> {
    public let expiryInterval: TimeInterval
    public private(set) var nextExpiry: Date!
    private var expired: Bool { nextExpiry.timeIntervalSinceNow < 0 }

    private let getter: () -> T
    private var cachedValue: T!
    public var wrappedValue: T {
        mutating get {
            if expired {
                update()
            }
            return cachedValue
        }
    }

    public init(wrappedValue getter: @autoclosure @escaping () -> T, in expiryInterval: TimeInterval = 1.0) {
        self.getter = getter
        self.expiryInterval = expiryInterval
        update()
    }

    private mutating func update() {
        cachedValue = getter()
        nextExpiry = Date(timeInterval: expiryInterval, since: Date())
    }
}
