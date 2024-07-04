/// A positioned rectangular geographical region.
public struct GeoRegion: Hashable, Codable {
    /// The coordinates of the region's center.
    public let center: GeoCoordinates
    /// The size of the region.
    public let span: GeoSpan
}
