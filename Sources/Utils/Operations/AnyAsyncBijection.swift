public struct AnyAsyncBijection<V>: AsyncBijection {
    private let applyImpl: (V) async -> V
    private let inverseApplyImpl: (V) async -> V

    public init(apply applyImpl: @escaping (V) async -> V, inverseApply inverseApplyImpl: @escaping (V) async -> V) {
        self.applyImpl = applyImpl
        self.inverseApplyImpl = inverseApplyImpl
    }

    public init<B>(_ bijection: B) where B: AsyncBijection, B.Value == V {
        applyImpl = bijection.apply
        inverseApplyImpl = bijection.inverseApply
    }

    public init<B>(_ bijection: B) where B: Bijection, B.Value == V {
        applyImpl = bijection.apply
        inverseApplyImpl = bijection.inverseApply
    }

    public func apply(_ value: V) async -> V { return await applyImpl(value) }

    public func inverseApply(_ value: V) async -> V { return await inverseApplyImpl(value) }
}
