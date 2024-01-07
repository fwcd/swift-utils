/// A mutable, reference-like property wrapper that can read and write a value.
@propertyWrapper
public struct Binding<Value> {
    private let _get: () -> Value
    private let _set: (Value) -> Void

    public var wrappedValue: Value {
        get { _get() }
        nonmutating set { _set(newValue) }
    }

    public var projectedValue: Binding<Value> {
        self
    }

    /// Creates a binding from another.
    public init(projectedValue: Binding<Value>) {
        _get = projectedValue._get
        _set = projectedValue._set
    }

    /// Creates a binding with the given getter and setter.
    public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
        _get = get
        _set = set
    }

    /// Creates an immutable binding.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding {
            value
        } set: { _ in }
    }

    /// A binding to the value keyed under the given path.
    public subscript<U>(dynamicMember keyPath: WritableKeyPath<Value, U>) -> Binding<U> {
        Binding<U> {
            wrappedValue[keyPath: keyPath]
        } set: {
            wrappedValue[keyPath: keyPath] = $0
        }
    }
}
