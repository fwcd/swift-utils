public extension Result {
    static func from(_ value: Success?, errorIfNil: Failure) -> Self {
        value.map { Result.success($0) } ?? Result.failure(errorIfNil)
    }
}
