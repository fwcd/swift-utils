public struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }
}
