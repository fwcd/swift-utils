/// Geographical coordinates in degrees.
public struct GeoCoordinates: Hashable, Codable {
    /// The latitude in degrees.
    public var latitude: Double
    /// The longitude in degrees.
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public static func +(lhs: Self, rhs: GeoSpan) -> Self {
        Self(
            latitude: lhs.latitude + rhs.latitudeDelta,
            longitude: lhs.longitude + rhs.longitudeDelta
        )
    }

    public static func -(lhs: Self, rhs: GeoSpan) -> Self {
        Self(
            latitude: lhs.latitude - rhs.latitudeDelta,
            longitude: lhs.longitude - rhs.longitudeDelta
        )
    }

    public static func +=(lhs: inout Self, rhs: GeoSpan) {
        lhs.latitude += rhs.latitudeDelta
        lhs.longitude += rhs.longitudeDelta
    }

    public static func -=(lhs: inout Self, rhs: GeoSpan) {
        lhs.latitude -= rhs.latitudeDelta
        lhs.longitude -= rhs.longitudeDelta
    }
}
