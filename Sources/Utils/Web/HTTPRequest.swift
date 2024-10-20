import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif
@preconcurrency import SwiftSoup
import XMLCoder

public struct HTTPRequest {
    private var request: URLRequest
    private let session: URLSession?

    public init(request: URLRequest, session: URLSession? = nil) {
        self.request = request
        self.session = session
    }

    public init(url: URL, session: URLSession? = nil) {
        self.init(request: URLRequest(url: url), session: session)
    }

    public init(
        scheme: String = "https",
        host: String,
        port: Int? = nil,
        path: String,
        method: String = "GET",
        query: [String: String] = [:],
        headers: [String: String] = [:],
        body customBody: String? = nil,
        session: URLSession = URLSession.shared
    ) throws {
        let isPost = method == "POST"

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = query.isEmpty ? nil : query.map { URLQueryItem(name: $0.key, value: $0.value) }

        if let p = port {
            components.port = p
        }

        let body: Data

        if isPost && !query.isEmpty {
            body = components.percentEncodedQuery?.data(using: .utf8) ?? .init()
            components.queryItems = []
        } else {
            body = customBody?.data(using: .utf8) ?? .init()
        }

        guard let url = components.url else { throw NetworkError.couldNotCreateURL(components) }

        var request = URLRequest(url: url)
        request.httpMethod = method

        if isPost {
            if !query.isEmpty {
                request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            }
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = body
        }

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        self.init(request: request, session: session)
    }

    /// Runs the request and asynchronously returns the response.
    @discardableResult
    public func run() async throws -> Data {
        try await runAsync().get()
    }

    /// Runs the request and returns a `Promise` with the response.
    public func runAsync() -> Promise<Data, Error> {
        Promise { then in
            let session = session ?? URLSession.shared
            session.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    then(.failure(NetworkError.ioError(error!)))
                    return
                }
                guard let data = data else {
                    then(.failure(NetworkError.missingData))
                    return
                }

                then(.success(data))
            }.resume()
        }
    }

    /// Runs the request and asynchronously returns the UTF-8-decoded response.
    public func fetchUTF8() async throws -> String {
        try await fetchUTF8Async().get()
    }

    /// Runs the request and returns a `Promise` with the UTF-8-decoded response.
    public func fetchUTF8Async() -> Promise<String, Error> {
        runAsync().mapCatching {
            if let utf8 = String(data: $0, encoding: .utf8) {
                return utf8
            } else {
                throw NetworkError.notUTF8($0)
            }
        }
    }

    /// Runs the request and asynchronously decodes the response as JSON.
    public func fetchJSON<T>(as type: T.Type) async throws -> T where T: Decodable & Sendable {
        try await fetchJSONAsync(as: type).get()
    }

    /// Runs the request and returns a `Promise` with the value decoded from the
    /// response interpreted as JSON.
    public func fetchJSONAsync<T>(as type: T.Type) -> Promise<T, Error> where T: Decodable & Sendable {
        runAsync().mapCatching {
            do {
                return try JSONDecoder().decode(type, from: $0)
            } catch {
                throw NetworkError.jsonDecodingError("\(error): \(String(data: $0, encoding: .utf8) ?? "<non-UTF-8-encoded data: \($0)>")")
            }
        }
    }

    /// Runs the request and asynchronously decodes the response as XML.
    public func fetchXML<T>(as type: T.Type) async throws -> T where T: Decodable & Sendable {
        try await fetchXMLAsync(as: type).get()
    }

    /// Runs the request and returns a `Promise` with the value decoded from the
    /// response interpreted as XML.
    public func fetchXMLAsync<T>(as type: T.Type) -> Promise<T, Error> where T: Decodable & Sendable {
        runAsync().mapCatching { try XMLDecoder().decode(type, from: $0) }
    }

    /// Runs the request and interprets the response as XML via the given delegate.
    public func fetchXMLAsync(using delegate: any XMLParserDelegate & Sendable) {
        fetchXMLAsync { delegate }
    }

    /// Runs the request and interprets the response as XML via the given delegate.
    public func fetchXMLAsync(using delegateFactory: @Sendable @escaping () -> any XMLParserDelegate) {
        runAsync().listen {
            let delegate = delegateFactory()
            switch $0 {
                case .success(let data):
                    let parser = XMLParser(data: data)
                    parser.delegate = delegate
                    _ = parser.parse()
                case .failure(let error):
                    // Work around the issue that the method is marked optional on macOS but not on Linux
                    #if os(macOS)
                    delegate.parser?(XMLParser(data: Data()), parseErrorOccurred: error)
                    #else
                    delegate.parser(XMLParser(data: Data()), parseErrorOccurred: error)
                    #endif
            }
        }
    }

    /// Runs the request and asynchronously parses the response as HTML.
    public func fetchHTML() async throws -> Document {
        try await fetchHTMLAsync().get()
    }

    /// Runs the request and returns a `Promise` with the parsed HTML document.
    public func fetchHTMLAsync() -> Promise<Document, Error> {
        fetchUTF8Async().mapCatching { try SwiftSoup.parse($0) }
    }
}
