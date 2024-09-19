import Foundation

/// A wrapper around an executable node package that is located in `Node` under
/// the current working directory.
@available(*, deprecated, message: "This is too project-specific and will be removed from this library.")
public struct NodePackage {
    private let directoryURL: URL

    public init(name: String) {
        directoryURL = URL(fileURLWithPath: "Node/\(name)")
    }

    /// Invokes `npm start` with the given arguments.
    public func start(withArgs args: [String]) -> Promise<Data, Error> {
        Shell().output(for: "npm", in: directoryURL, args: ["run", "--silent", "start", "--"] + args)
    }
}
