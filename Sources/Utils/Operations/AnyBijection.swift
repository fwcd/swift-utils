public struct AnyBijection<V>: Bijection {
    private let applyImpl: @Sendable (V) -> V
    private let inverseApplyImpl: @Sendable (V) -> V

    public init(apply applyImpl: @Sendable @escaping (V) -> V, inverseApply inverseApplyImpl: @Sendable @escaping (V) -> V) {
        self.applyImpl = applyImpl
        self.inverseApplyImpl = inverseApplyImpl
    }

    public init<B>(_ bijection: B) where B: Bijection, B.Value == V {
        applyImpl = { bijection.apply($0) }
        inverseApplyImpl = { bijection.inverseApply($0) }
    }

    public func apply(_ value: V) -> V { return applyImpl(value) }

    public func inverseApply(_ value: V) -> V { return inverseApplyImpl(value) }
}
