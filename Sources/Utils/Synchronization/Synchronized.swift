import Dispatch

/**
 * A value with synchronized get/set.
 */
@propertyWrapper
public struct Synchronized<T>: Sendable {
    private let semaphore = DispatchSemaphore(value: 1)
    nonisolated(unsafe) private var storedValue: T
    public var wrappedValue: T {
        get {
            semaphore.wait()
            let tmp = storedValue
            semaphore.signal()
            return tmp
        }
        set {
            semaphore.wait()
            storedValue = newValue
            semaphore.signal()
        }
    }

    public init(wrappedValue: T) {
        storedValue = wrappedValue
    }
}
