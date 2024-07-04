/// An unpositioned rectangular geographical size.
public struct GeoSpan: Hashable, Codable, AdditiveArithmetic {
    public static let zero = Self(latitudeDelta: 0, longitudeDelta: 0)

    /// The height of the region in degrees.
    public let latitudeDelta: Double
    /// The width of the region in degrees.
    public var longitudeDelta: Double

    public init(latitudeDelta: Double, longitudeDelta: Double) {
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }

    public func transposed() -> Self {
        Self(
            latitudeDelta: longitudeDelta,
            longitudeDelta: latitudeDelta
        )
    }

    public static func +(lhs: Self, rhs: Self) -> Self {
        Self(
            latitudeDelta: lhs.latitudeDelta + rhs.latitudeDelta,
            longitudeDelta: lhs.longitudeDelta + rhs.longitudeDelta
        )
    }

    public static func -(lhs: Self, rhs: Self) -> Self {
        Self(
            latitudeDelta: lhs.latitudeDelta - rhs.latitudeDelta,
            longitudeDelta: lhs.longitudeDelta - rhs.longitudeDelta
        )
    }

    public static func *(lhs: Self, rhs: Double) -> Self {
        Self(
            latitudeDelta: lhs.latitudeDelta * rhs,
            longitudeDelta: lhs.longitudeDelta * rhs
        )
    }

    public static func *(lhs: Double, rhs: Self) -> Self {
        Self(
            latitudeDelta: lhs * rhs.latitudeDelta,
            longitudeDelta: lhs * rhs.longitudeDelta
        )
    }

    public static func /(lhs: Self, rhs: Double) -> Self {
        Self(
            latitudeDelta: lhs.latitudeDelta / rhs,
            longitudeDelta: lhs.longitudeDelta / rhs
        )
    }
}
