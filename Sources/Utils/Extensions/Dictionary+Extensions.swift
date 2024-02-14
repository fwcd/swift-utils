public extension Dictionary where Key: StringProtocol, Value: StringProtocol {
    var urlQueryEncoded: String {
        map { "\($0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($0))=\($1.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? String($1))" }
            .joined(separator: "&")
    }
}
