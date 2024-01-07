/// A mutable, reference-like property wrapper that can read and write a value.
@propertyWrapper
public struct Binding<Value> {
    private let _get: () -> Value
    private let _set: (Value) -> Void

    public var wrappedValue: Value {
        get { _get() }
        set { _set(newValue) }
    }

    public var projectedValue: Binding<Value> {
        self
    }

    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        _get = get
        _set = set
    }
}
