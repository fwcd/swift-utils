@propertyWrapper
public struct UncheckedSendable<Value>: @unchecked Sendable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}
