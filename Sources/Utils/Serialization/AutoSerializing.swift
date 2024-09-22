@preconcurrency import Logging

fileprivate let log = Logger(label: "Utils.AutoSerializing")

/** Wraps a value that is automatically read from/written to a file. */
@propertyWrapper
public class AutoSerializing<T: Codable> {
    private let serializer = DiskJsonSerializer()
    private let filePath: String
    public private(set) var storedValue: T
    public var wrappedValue: T {
        get { storedValue }
        set {
            storedValue = newValue
            writeToDisk()
        }
    }

    /// A strong reference to the value.
    public var projectedValue: Binding<T> {
        Binding { [self] in
            wrappedValue
        } set: { [self] in
            wrappedValue = $0
        }
    }

    public init(wrappedValue: T, filePath: String) {
        self.filePath = filePath
        if let onDiskValue = try? serializer.readJson(as: T.self, fromFile: filePath) {
            storedValue = onDiskValue
        } else {
            storedValue = wrappedValue
            writeToDisk()
        }
    }

    private func writeToDisk() {
        do {
            log.info("Auto-serializing to \(filePath)")
            try serializer.write(storedValue, asJsonToFile: filePath)
        } catch {
            log.error("Error during auto-serialization: \(error)")
        }
    }
}
