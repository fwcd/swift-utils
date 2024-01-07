/// A simple property wrapper that stores a value on the heap.
///
/// Useful for turning a value type into a reference type without manually
/// writing a class.
@propertyWrapper
public class Box<T> {
    public var wrappedValue: T

    /// A strong reference to the value.
    public var projectedValue: Binding<T> {
        Binding { [self] in
            wrappedValue
        } set: { [self] in
            wrappedValue = $0
        }
    }

    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}
