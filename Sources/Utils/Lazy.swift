@propertyWrapper
public class Lazy<K, V> {
    private var state: State
    public var wrappedValue: V {
        switch state {
            case let .computed(v):
                return v
            case let .lazy(f):
                let v = f()
                state = .computed(v)
                return v
        }
    }

    public enum State {
        case lazy(() -> V)
        case computed(V)
    }

    public convenience init(wrappedValue: @autoclosure @escaping () -> V) {
        self.init(state: .lazy(wrappedValue))
    }

    public init(state: State) {
        self.state = state
    }

    public static func lazy(_ f: @escaping () -> V) -> Lazy { .init(state: .lazy(f)) }

    public static func computed(_ v: V) -> Lazy { .init(state: .computed(v)) }
}
