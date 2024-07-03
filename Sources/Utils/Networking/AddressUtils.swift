fileprivate let hostPortPattern = #/([^:]+)(?::(\d+))?/#

public func parseHostPort(from raw: String) -> (String, Int32?)? {
    (try? hostPortPattern.firstMatch(in: raw)).map {
        (String($0.1), $0.2.flatMap { Int32($0) })
    }
}
