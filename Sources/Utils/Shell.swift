import Foundation
import Logging

fileprivate let log = Logger(label: "Utils.Shell")

/** A wrapper that simplifies the creation of subprocesses. */
public struct Shell {
    public init() {}

    /** Creates a new subprocess without launching it. */
    public func newProcess(
        _ executable: String,
        in directory: URL? = nil,
        args: [String]? = nil,
        useBash: Bool = false,
        withPipedOutput: Bool = false,
        then terminationHandler: ((Process, Pipe?) -> Void)? = nil
    ) -> (Pipe?, Process) {
        var pipe: Pipe? = nil
        let process = Process()
        let path = useBash ? "/bin/bash" : findPath(of: executable)

        setExecutable(for: process, toPath: path)

        if let dirURL = directory {
            setCurrentDirectory(for: process, toURL: dirURL)
        }

        process.arguments = (useBash ? ["-c", executable] : []) + (args ?? [])

        if let handler = terminationHandler {
            process.terminationHandler = { handler($0, pipe) }
        }

        if withPipedOutput {
            pipe = Pipe()
            process.standardOutput = pipe
        }

        return (pipe, process)
    }

    /** Runs the executable and returns the standard output synchronously after the process exits. */
    @discardableResult
    public func outputSync(for executable: String, in directory: URL? = nil, args: [String]? = nil, useBash: Bool = false) throws -> Data {
        let (pipe, process) = newProcess(executable, in: directory, args: args, useBash: useBash, withPipedOutput: true)

        try execute(process: process)
        process.waitUntilExit()

        return pipe!.fileHandleForReading.availableData
    }

    /** Runs the executable and returns the standard output synchronously after the process exits. */
    @discardableResult
    public func utf8Sync(for executable: String, in directory: URL? = nil, args: [String]? = nil, useBash: Bool = false) throws -> String? {
        return String(data: try outputSync(for: executable, in: directory, args: args, useBash: useBash), encoding: .utf8)
    }

    /** Runs the executable and asynchronously returns the standard output. */
    @discardableResult
    public func output(for executable: String, in directory: URL? = nil, args: [String]? = nil, useBash: Bool = false) -> Promise<Data, Error> {
        Promise { then in
            let (_, process) = newProcess(executable, in: directory, args: args, useBash: useBash, withPipedOutput: true) {
                then(.success(($0, $1)))
            }

            do {
                try execute(process: process)
            } catch {
                then(.failure(error))
            }
        }
        .map { (_: Process, pipe: Pipe?) in
            pipe!.fileHandleForReading.availableData
        }
    }

    /** Runs the executable and asynchronously returns the standard output. */
    @discardableResult
    public func utf8(for executable: String, in directory: URL? = nil, args: [String]? = nil, useBash: Bool = false) -> Promise<String?, Error> {
        output(for: executable, in: directory, args: args, useBash: useBash)
            .map { String(data: $0, encoding: .utf8) }
    }

    /** Creates a new subprocess and launches it. */
    public func run(
        _ executable: String,
        in directory: URL? = nil,
        args: [String]? = nil,
        useBash: Bool = false,
        withPipedOutput: Bool = false,
        then terminationHandler: ((Process, Pipe?) -> Void)? = nil
    ) throws {
        try execute(process: newProcess(executable, in: directory, args: args, useBash: useBash, withPipedOutput: withPipedOutput, then: terminationHandler).1)
    }

    public func findPath(of executable: String) -> String {
        if executable.contains("/") {
            return executable
        } else {
            // Find executable using 'which'. This code fragment explicitly
            // does not invoke 'outputSync' to avoid infinite recursion.

            let pipe = Pipe()
            let process = Process()

            setExecutable(for: process, toPath: "/usr/bin/which")
            process.arguments = [executable]
            process.standardOutput = pipe

            do {
                try execute(process: process)
                process.waitUntilExit()
            } catch {
                log.warning("Shell.findPath could launch 'which' to find \(executable)")
                return executable
            }

            if let output = String(data: pipe.fileHandleForReading.availableData, encoding: .utf8) {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                log.warning("Shell.findPath could not read 'which' output to find \(executable)")
                return executable
            }
        }
    }

    private func setExecutable(for process: Process, toPath filePath: String) {
        if #available(macOS 10.13, *) {
            process.executableURL = URL(fileURLWithPath: filePath)
        } else {
            process.launchPath = filePath
        }
    }

    private func setCurrentDirectory(for process: Process, toURL url: URL) {
        if #available(macOS 10.13, *) {
            process.currentDirectoryURL = url
        } else {
            process.currentDirectoryPath = url.path
        }
    }

    public func execute(process: Process) throws {
        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
    }
}
