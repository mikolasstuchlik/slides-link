import SwiftUI
import Foundation
import Darwin

// MARK: - Presentation support

protocol Slide {
    static var offset: CGVector { get }
    static var identifier: String { get }

    var slideView: AnyView { get }
}

extension Slide where Self: View {
    static var identifier: String { String(describing: Self.self) }
    var slideView: AnyView { AnyView(body) }
}

struct Plane: View {
    @EnvironmentObject var presentation: PresentationProperties
    
    let slides: [Slide]

    var body: some View {
        ZStack {
            ForEach(Array(zip(slides.indices, slides)), id: \.0) { _, slide in
                slide.slideView
                    .frame(
                        width: presentation.frameSize.width,
                        height: presentation.frameSize.height
                    )
                    .offset(
                        x: presentation.screenSize.width * type(of: slide).offset.dx,
                        y: presentation.screenSize.height * type(of: slide).offset.dy
                    )
            }
        }
        .frame(
            width: presentation.screenSize.width,
            height: presentation.screenSize.height
        )
    }
}

struct Presentation: View {
    @EnvironmentObject var presentation: PresentationProperties

    let slides: [Slide]
    let focuses: [[Slide.Type]]

    @Binding var selectedFocus: Int

    var body: some View {
        Plane(slides: slides)
            .scaleEffect(presentation.scale)
            .offset(
                x: -(presentation.screenSize.width * presentation.offset.dx),
                y: -(presentation.screenSize.height * presentation.offset.dy)
            )
            .border(.blue)
            .clipped()
            .onChange(
                of: selectedFocus,
                perform: { newFocus in
                    if let newConfiguration = getConfiguration(for: newFocus) {
                        withAnimation(.easeInOut(duration: 1.0)) {
                            presentation.offset = newConfiguration.offset
                        }
                        if abs(presentation.scale - newConfiguration.scale) < 0.1 {
                            withAnimation(.easeIn(duration: 0.5)) {
                                presentation.scale = newConfiguration.scale * 3 / 4
                            }
                            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                                presentation.scale = newConfiguration.scale
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                presentation.scale = newConfiguration.scale
                            }
                        }
                    }
                }
            )
    }
    
    private func getConfiguration(for newFocusIndex: Int) -> (scale: CGFloat, offset: CGVector)? {
        guard
            newFocusIndex >= 0,
            newFocusIndex < focuses.count,
            !focuses[newFocusIndex].isEmpty
        else {
            return nil
        }
        let focus = focuses[newFocusIndex]
        
        var minXOffset = focus.first!.offset.dx
        var minYOffset = focus.first!.offset.dy
        var maxXOffset = focus.first!.offset.dx
        var maxYOffset = focus.first!.offset.dy
        
        for frame in focus {
            minXOffset = min(minXOffset, frame.offset.dx)
            minYOffset = min(minYOffset, frame.offset.dy)
            maxXOffset = max(maxXOffset, frame.offset.dx)
            maxYOffset = max(maxYOffset, frame.offset.dy)
        }

        let width = 1 / (minXOffset.distance(to: maxXOffset) + 1)
        let height = 1 / (minYOffset.distance(to: maxYOffset) + 1)
        
        let newScale = min(width, height)
        
        let newOffset = CGVector(
            dx: (minXOffset + minXOffset.distance(to: maxXOffset) / 2) * newScale,
            dy: (minYOffset + minYOffset.distance(to: maxYOffset) / 2) * newScale
        )
        
        return (scale: newScale, offset: newOffset)
    }
}

final class PresentationProperties: ObservableObject {
    static let shared = PresentationProperties()
    
    @Published var frameSize: CGSize = CGSize(width: 480, height: 360)
    @Published var screenSize: CGSize = CGSize(width: 480, height: 360)
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGVector = .zero
}

// MARK: - View builder support
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
        try dispose()
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

    private func dispose() throws {
        existingHandle.flatMap(dlclose(_:))
        existingHandle = nil
        try FileManager.default.removeItem(atPath: libraryPath)
    }

    deinit { try! dispose() }
}


// MARK: - Presentation

struct Beginning: View, Slide {
    static let offset = CGVector(dx: 0, dy: 0)

    var body: some View {
        ZStack {
            Color.white
            Text("**Moje prezentace**")
                .foregroundColor(.black)
                .font(.system(size: 80))
        }
    }
}

struct Naming: View, Slide {
    static let offset = CGVector(dx: 0, dy: 2)

    var body: some View {
        ZStack {
            Color.white
            VStack(alignment: .leading, spacing: 16) {
                Text("Moje prezentace")
                    .foregroundColor(.black)
                    .font(.headline)
                
                Text(
"""
**Ahoj**
 - Miki
 - Jak
 - Se
 - Vede
"""
                )
                .foregroundColor(.black)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .padding()
        }
    }
}

struct End: View, Slide {
    static let offset = CGVector(dx: -1, dy: -2)

    var body: some View {
        ZStack {
            Color.gray
            Text("Děkuji za pozornost")
                .foregroundColor(.black)
                .font(.title)
        }
    }
}

struct Demo: View {
    @EnvironmentObject var presentation: PresentationProperties
    @State var selectedFocus: Int = 0

    var body: some View {
        VStack {
            Presentation(
                slides: [
                    Beginning(),
                    Naming(),
                    End()
                ],
                focuses: [
                    [Beginning.self],
                    [Naming.self],
                    [Beginning.self, Naming.self, End.self],
                    [End.self],
                    [Beginning.self],
                ],
                selectedFocus: $selectedFocus
            )

            Stepper(
                "Configuration \(selectedFocus)",
                onIncrement: { selectedFocus += 1 },
                onDecrement: { selectedFocus -= 1 }
            )
            HStack {
                Text("Scale")
                Slider(value: $presentation.scale, in: 0.0...2.0)
            }
            HStack {
                Text("X \(presentation.offset.dx)")
                Slider(value: $presentation.offset.dx, in: -2...2)
            }
            HStack {
                Text("Y \(presentation.offset.dy)")
                Slider(value: $presentation.offset.dy, in: -2...2)
            }
        }
    }
}

let pluginView =
"""
public struct MyView: View {
    @State var isPushed: Bool = false

    public var body: some View {
        VStack(spacing: 8) {
            Text("Ahoj")
            Button("Zmáčkni mě", action: { isPushed.toggle() })
        }.background(
            isPushed ? .green : .red
        )
    }
}
"""

let runtimeProvider = RuntimeViewProvider(rootViewName: "MyView")
let view = try! runtimeProvider.compileAndLoad(code: pluginView)

