public struct Vec2<T>: CustomStringConvertible {
    public var x: T
    public var y: T

    public var asTuple: (x: T, y: T) { (x: x, y: y) }
    public var description: String { "(\(x), \(y))" }

    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }

    public init(both value: T) {
        x = value
        y = value
    }

    public func map<U>(_ f: (T) throws -> U) rethrows -> Vec2<U> {
        try Vec2<U>(x: f(x), y: f(y))
    }

    public func mapBoth<U>(_ fx: (T) throws -> U, _ fy: (T) throws -> U) rethrows -> Vec2<U> {
        try Vec2<U>(x: fx(x), y: fy(y))
    }

    public func with(x newX: T) -> Vec2<T> {
        Vec2(x: newX, y: y)
    }

    public func with(y newY: T) -> Vec2<T> {
        Vec2(x: x, y: newY)
    }
}

extension Vec2: Equatable where T: Equatable {}
extension Vec2: Hashable where T: Hashable {}

extension Vec2 where T: ExpressibleByIntegerLiteral {
    public static func zero() -> Vec2<T> { Vec2() }

    public init() {
        self.init(x: 0, y: 0)
    }

    public init(x: T) {
        self.init(x: x, y: 0)
    }

    public init(y: T) {
        self.init(x: 0, y: y)
    }
}

extension Vec2 where T: IntExpressibleAlgebraicField {
    public var asNDArray: NDArray<T> { NDArray([x, y]) }
}

extension Vec2: Addable where T: Addable {
    public static func +(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> { Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }

    public static func +=(lhs: inout Vec2<T>, rhs: Vec2<T>) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}

extension Vec2: Subtractable where T: Subtractable {
    public static func -(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> { Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }

    public static func -=(lhs: inout Vec2<T>, rhs: Vec2<T>) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
}

extension Vec2: Multipliable where T: Multipliable {
    public static func *(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> { Vec2(x: lhs.x * rhs.x, y: lhs.y * rhs.y) }

    public static func *(lhs: T, rhs: Vec2<T>) -> Vec2<T> { Vec2(x: lhs * rhs.x, y: lhs * rhs.y) }

    public static func *(lhs: Vec2<T>, rhs: T) -> Vec2<T> { Vec2(x: lhs.x * rhs, y: lhs.y * rhs) }

    public static func *=(lhs: inout Vec2<T>, rhs: Vec2<T>) {
        lhs.x *= rhs.x
        lhs.y *= rhs.y
    }
}

extension Vec2: Divisible where T: Divisible {
    public static func /(lhs: Vec2<T>, rhs: Vec2<T>) -> Vec2<T> { Vec2(x: lhs.x / rhs.x, y: lhs.y / rhs.y) }

    public static func /(lhs: Vec2<T>, rhs: T) -> Vec2<T> { Vec2(x: lhs.x / rhs, y: lhs.y / rhs) }

    public static func /=(lhs: inout Vec2<T>, rhs: Vec2<T>) {
        lhs.x /= rhs.x
        lhs.y /= rhs.y
    }
}

extension Vec2: Negatable where T: Negatable {
    public mutating func negate() {
        x.negate()
        y.negate()
    }

    public prefix static func -(operand: Vec2<T>) -> Vec2<T> { Vec2(x: -operand.x, y: -operand.y) }
}

extension Vec2 where T: Multipliable & Addable {
    public func dot(_ other: Vec2<T>) -> T {
        (x * other.x) + (y * other.y)
    }
}

extension Vec2 where T: Multipliable & Subtractable {
    public func cross(_ other: Vec2<T>) -> T {
        (x * other.y) - (y * other.x)
    }
}

extension Vec2 where T: Negatable {
    public var xInverted: Vec2<T> { Vec2(x: -x, y: y) }
    public var yInverted: Vec2<T> { Vec2(x: x, y: -y) }
}

extension Vec2 where T: BinaryFloatingPoint {
    public var squaredMagnitude: T { ((x * x) + (y * y)) }
    public var magnitude: T { squaredMagnitude.squareRoot() }
    public var floored: Vec2<Int> { Vec2<Int>(x: Int(x.rounded(.down)), y: Int(y.rounded(.down))) }
}

extension Vec2 where T: BinaryFloatingPoint & Divisible {
    public var normalized: Vec2<T> { self / magnitude }
}

extension Vec2 where T: BinaryInteger {
    public var squaredMagnitude: Double { Double((x * x) + (y * y)) }
    public var magnitude: Double { squaredMagnitude.squareRoot() }
    public var asDouble: Vec2<Double> { map { Double($0) } }
}

extension NDArray {
    public var asVec2: Vec2<T>? {
        shape == [2] ? Vec2(x: values[0], y: values[1]) : nil
    }
}
