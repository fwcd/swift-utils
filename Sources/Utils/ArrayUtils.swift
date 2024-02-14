// TODO: Implement this as a generic extension over collections containing optionals
// once Swift supports this.
public func allNonNil<T>(_ array: [T?]) -> [T]? where T: Equatable {
    array.contains(nil) ? nil : array.map { $0! }
}
