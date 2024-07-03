public struct ComposedAsyncBijection<B, C>: AsyncBijection where B: AsyncBijection, C: AsyncBijection, B.Value == C.Value {
    public typealias Value = B.Value

    private let outer: B
    private let inner: C

    public init(outer: B, inner: C) {
        self.outer = outer
        self.inner = inner
    }

    public func apply(_ value: Value) async -> Value {
        await outer.apply(inner.apply(value))
    }

    public func inverseApply(_ value: Value) async -> Value {
        await inner.inverseApply(outer.inverseApply(value))
    }
}

extension AsyncBijection {
    public func then<B: AsyncBijection>(_ outer: B) -> ComposedAsyncBijection<B, Self> where B.Value == Value {
        ComposedAsyncBijection(outer: outer, inner: self)
    }

    public func compose<B: AsyncBijection>(_ inner: B) -> ComposedAsyncBijection<Self, B> where B.Value == Value {
        ComposedAsyncBijection(outer: self, inner: inner)
    }
}
