public struct AnyCodingKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(intValue: value)
    }
}
