import Darwin
import Foundation
import SwiftUI

enum ProcessError: Error {
    case endedWith(code: Int, error: String?)
    case couldNotBeSpawned
    case programNotFound
}

private extension ProcessInfo {
    var environmentPaths: [String]? {
        environment["PATH"].flatMap { $0.split(separator: ":", omittingEmptySubsequences: true) }?.map(String.init)
    }
}

private extension Pipe {
    var stringContents: String? {
        String(
            data: self.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        )?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func urlForExecutable(named executable: String, in path: [String]) -> URL? {
    path.map {
        URL(fileURLWithPath: $0).appendingPathComponent(executable, isDirectory: false)
    }.first { file in
        var directory = ObjCBool(false)
        return  FileManager.default.fileExists(atPath: file.path, isDirectory: &directory)
                && !directory.boolValue
            && FileManager.default.isExecutableFile(atPath: file.path)
    }
}

private func createProcess(
    command: String,
    in path: [String] = ProcessInfo.processInfo.environmentPaths ?? [],
    arguments: [String] = [],
    workingDir: URL? = nil,
    standardInput: Any,
    standardOutput: Any,
    standardError: Any,
    fallbackToEnv: Bool
) throws -> Process {
    let process = Process()
    var arguments = arguments

    guard
        let url = urlForExecutable(named: command, in: path) ?? {
           arguments.insert(command, at: 0)
               return fallbackToEnv
               ? urlForExecutable(named: "env", in: path)
                         : nil
          }()
    else { throw ProcessError.programNotFound }

    if !arguments.isEmpty {
        process.arguments = arguments
    }

    workingDir.flatMap { process.currentDirectoryURL = $0 }
    process.standardInput = standardInput
    process.standardOutput = standardOutput
    process.standardError = standardError
    process.executableURL = url

    return process
}

extension Process {
    /// Executes desired program and
    /// - Parameters:
    ///   - program: The name of the program
    ///   - arguments: List of arguments
    /// - Throws: Throws in case, that the process could not be executed or returned non-zero code.
    /// - Returns: The contents of std-out
    static func executeAndWait(_ program: String, arguments: [String], fallbackToEnv: Bool = false, workingDir: URL? = nil) throws -> String? {
        let outPipe = Pipe()
        let inPipe = Pipe()
        let errorPipe = Pipe()
        let process = try createProcess(
            command: program,
            arguments: arguments,
            workingDir: workingDir,
            standardInput: inPipe,
            standardOutput: outPipe,
            standardError: errorPipe,
            fallbackToEnv: fallbackToEnv
        )

        if #available(macOS 10.13, *) {
            try process.run()
        } else {
            process.launch()
        }
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ProcessError.endedWith(code: Int(process.terminationStatus), error: errorPipe.stringContents)
        }

        return outPipe.stringContents
    }
}

final class RuntimeViewProvider {
    enum Error: Swift.Error {
        case failedToOpenSymbol
    }

    private typealias FunctionPrototype = @convention(c) () -> Any

    let rootViewName: String
    let workingURL = FileManager.default.temporaryDirectory
    let workingPath = FileManager.default.temporaryDirectory.path

    private let symbolName = "loadViewFunc"
    private lazy var fileTemplate: String =
"""
import SwiftUI

@_cdecl("\(symbolName)")
public func \(symbolName)() -> Any {
    return AnyView(\(rootViewName).init())
}


"""

    private var sourceFileName: String { rootViewName + ".swift" }
    private var sourceFilePath: String { workingPath + "/" + sourceFileName}
    private var libraryPath: String { workingPath + "/" + "lib" + rootViewName + ".dylib"}

    private var existingHandle: UnsafeMutableRawPointer?

    init(rootViewName: String) {
        self.rootViewName = rootViewName
    }

    func compileAndLoad(code: String) throws -> AnyView {
        dispose()
        try writeFile(code: code)

        _ = try Process.executeAndWait(
            "swiftc",
            arguments: ["-parse-as-library", "-emit-library", sourceFileName],
            workingDir: workingURL
        )

        try deleteSourceFile()

        let handle = dlopen(libraryPath, RTLD_NOW)!
        existingHandle = handle

        guard let symbol = dlsym(handle, symbolName) else {
            throw Error.failedToOpenSymbol
        }

        let callable = unsafeBitCast(symbol, to: FunctionPrototype.self)

        return callable() as! AnyView
    }

    private func writeFile(code: String) throws {
        let file = fileTemplate + code
        try file.write(toFile: sourceFilePath, atomically: true, encoding: .utf8)
    }

    private func deleteSourceFile() throws {
        try FileManager.default.removeItem(atPath: sourceFilePath)
    }

    private func dispose() {
        _ = existingHandle.flatMap(dlclose(_:))
        existingHandle = nil
        try? FileManager.default.removeItem(atPath: libraryPath)
    }

    deinit { dispose() }
}

