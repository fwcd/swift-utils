public struct InverseAsyncBijection<B>: AsyncBijection where B: AsyncBijection {
    public typealias Value = B.Value

    private let inverse: B

    public init(inverting inverse: B) {
        self.inverse = inverse
    }

    public func apply(_ value: Value) async -> Value {
        await inverse.inverseApply(value)
    }

    public func inverseApply(_ value: Value) async -> Value {
        await inverse.apply(value)
    }
}

extension AsyncBijection {
    public var inverse: InverseAsyncBijection<Self> { InverseAsyncBijection(inverting: self) }
}
