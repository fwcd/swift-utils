import Dispatch
import Foundation
import Logging

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

/**
 * A handler that logs to the console and stores
 * the last n lines in a global cyclic queue.
 */
public struct StoringLogHandler: LogHandler {
    private static let lastOutputsQueue = DispatchQueue(label: "StoringLogHandler.lastOutputs")
    public private(set) static var lastOutputs = CircularArray<String>(capacity: 100)
    public static let timestampFormatKey = "timestamp"

    public var logLevel: Logger.Level
    public var metadata: Logger.Metadata = [
        timestampFormatKey: .string("dd.MM.yyyy HH:mm:ss")
    ]

    private let label: String
    private let printToStdout: Bool
    private let autoFlushStdout: Bool

    public init(
        label: String,
        printToStdout: Bool = true,
        autoFlushStdout: Bool = false,
        logLevel: Logger.Level = .info
    ) {
        self.label = label
        self.printToStdout = printToStdout
        self.autoFlushStdout = autoFlushStdout
        self.logLevel = logLevel
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String, function: String, line: UInt) {
        let mergedMetadata = self.metadata.merging(metadata ?? [:], uniquingKeysWith: { _, newKey in newKey })
        let output = "\(timestamp(using: mergedMetadata)) [\(level)] \(label): \(message)"

        if printToStdout {
            print(output)
            if autoFlushStdout {
                fflush(stdout)
            }
        }

        Self.lastOutputsQueue.async {
            Self.lastOutputs.push(output)
        }
    }

    private func timestamp(using metadata: Logger.Metadata?) -> String {
        guard case let .string(timestampFormat)? = metadata?[Self.timestampFormatKey] else { return "<invalid timestamp format>" }
        let formatter = DateFormatter()
        formatter.dateFormat = timestampFormat
        return formatter.string(from: Date())
    }

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get { return metadata[metadataKey] }
        set { metadata[metadataKey] = newValue }
    }
}
