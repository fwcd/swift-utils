public protocol AsyncBijection: Sendable {
    associatedtype Value: Sendable

    func apply(_ value: Value) async -> Value

    func inverseApply(_ value: Value) async -> Value
}
