public protocol AsyncBijection {
    associatedtype Value

    func apply(_ value: Value) async -> Value

    func inverseApply(_ value: Value) async -> Value
}
