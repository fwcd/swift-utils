public struct AnyAsyncBijection<V>: AsyncBijection where V: Sendable {
    private let applyImpl: @Sendable (V) async -> V
    private let inverseApplyImpl: @Sendable (V) async -> V

    public init(apply applyImpl: @Sendable @escaping (V) async -> V, inverseApply inverseApplyImpl: @Sendable @escaping (V) async -> V) {
        self.applyImpl = applyImpl
        self.inverseApplyImpl = inverseApplyImpl
    }

    public init<B>(_ bijection: B) where B: AsyncBijection, B.Value == V {
        applyImpl = { await bijection.apply($0) }
        inverseApplyImpl = { await bijection.inverseApply($0) }
    }

    public init<B>(_ bijection: B) where B: Bijection, B.Value == V {
        applyImpl = { bijection.apply($0) }
        inverseApplyImpl = { bijection.inverseApply($0) }
    }

    public func apply(_ value: V) async -> V { return await applyImpl(value) }

    public func inverseApply(_ value: V) async -> V { return await inverseApplyImpl(value) }
}
