@propertyWrapper
public struct UncheckedSendable<Value>: @unchecked Sendable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(_ wrappedValue: Value) {
        self.init(wrappedValue: wrappedValue)
    }
}
