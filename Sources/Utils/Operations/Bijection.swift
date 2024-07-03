public protocol Bijection: AsyncBijection {
    associatedtype Value

    func apply(_ value: Value) -> Value

    func inverseApply(_ value: Value) -> Value
}
