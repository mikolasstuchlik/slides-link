import Foundation
import RegexBuilder

@available(macOS 13.0, *)
final class OffsetCodeManipulator {
    enum Error: Swift.Error {
        case fileNotFound
    }
    
    static let xReference = Reference(Substring.self)
    static let yReference = Reference(Substring.self)
    static let nameReference = Reference(Substring.self)
    static let regex = {
        let real = Regex {
            Optionally { "-" }
            OneOrMore(.digit)
            Optionally {
                "."
                OneOrMore(.digit)
            }
        }

        return Regex {
            "// @offset("
            Capture(as: nameReference) {
                ZeroOrMore(.word)
            }
            ")"
            ZeroOrMore(.horizontalWhitespace)
            One(.verticalWhitespace)
            ZeroOrMore(.horizontalWhitespace)
            "static"
            ZeroOrMore(.horizontalWhitespace)
            "var"
            ZeroOrMore(.horizontalWhitespace)
            "offset"
            ZeroOrMore(.horizontalWhitespace)
            "="
            ZeroOrMore(.horizontalWhitespace)
            "CGVector("
            ZeroOrMore(.horizontalWhitespace)
            "dx:"
            ZeroOrMore(.horizontalWhitespace)
            Capture(as: xReference) {
                real
            }
            ZeroOrMore(.horizontalWhitespace)
            ","
            ZeroOrMore(.horizontalWhitespace)
            "dy:"
            ZeroOrMore(.horizontalWhitespace)
            Capture(as: yReference) {
                real
            }
            ZeroOrMore(.horizontalWhitespace)
            ")"
        }
    }()

    let slidesPath: String
    let knownSlides: [any Slide.Type]

    init(slidesPath: String, knowSlides: [any Slide.Type]) {
        self.slidesPath = slidesPath
        self.knownSlides = knowSlides
    }
    
    func saveUpdatesToSourceCode() -> [String: Result<Void, Swift.Error>] {
        let names = loadFilePathsForNames()
        
        var result = [String: Result<Void, Swift.Error>]()
        for slide in knownSlides {
            result[slide.name] = Result {
                guard let file = names[slide.name] else {
                    throw Error.fileNotFound
                }
                
                var content = try String(contentsOfFile: slidesPath + "/" + file, encoding: .utf8)
                if let regexResult = try OffsetCodeManipulator.regex.firstMatch(in: content) {
                    content.replaceSubrange(regexResult[OffsetCodeManipulator.yReference].range, with: "\(slide.offset.dy)")
                    content.replaceSubrange(regexResult[OffsetCodeManipulator.xReference].range, with: "\(slide.offset.dx)")
                }
                
                try content.write(toFile: slidesPath + "/" + file, atomically: true, encoding: .utf8)

                return ()
            }
        }
        return result
    }

    private func loadFilePathsForNames() -> [String: String] {
        let enumerator = FileManager.default.enumerator(atPath: slidesPath)
        
        var result = [String:String]()
        while let object = enumerator?.nextObject() as? String {
            guard object.hasSuffix(".swift"), let content = try? String(contentsOfFile: slidesPath + "/" + object, encoding: .utf8) else {
                continue
            }
            if let regexResult = try? OffsetCodeManipulator.regex.firstMatch(in: content) {
                let name = "\(regexResult[OffsetCodeManipulator.nameReference])"
                result[name] = object
            }
        }
        
        return result
    }

}

@available(macOS 13.0, *)
final class FocusCodeManipulator {
    enum Error: Swift.Error {
        case fileNotFound
    }
    
    static let indent = Reference(Substring.self)
    static let startName = Reference(Substring.self)
    static let endName = Reference(Substring.self)
    static let content = Reference(Substring.self)
    static let hintRegex = {
        return Regex {
            Capture(as: indent) {
                ZeroOrMore(.horizontalWhitespace)
            }
            "// @hint("
            Capture(as: startName) {
                ZeroOrMore(.word)
            }
            "){"
            One(.verticalWhitespace)
            Capture(as: content) {
                ZeroOrMore(.any)
            }
            One(.verticalWhitespace)
            ZeroOrMore(.horizontalWhitespace)
            "// }@hint("
            Capture(as: endName) {
                ZeroOrMore(.word)
            }
            ")"
        }
    }()
    
    static let focusRegex = {
        return Regex {
            Capture(as: indent) {
                ZeroOrMore(.horizontalWhitespace)
            }
            "// @focuses("
            Capture(as: startName) {
                ZeroOrMore(.word)
            }
            "){"
            One(.verticalWhitespace)
            Capture(as: content) {
                ZeroOrMore(.any)
            }
            One(.verticalWhitespace)
            ZeroOrMore(.horizontalWhitespace)
            "// }@focuses("
            Capture(as: endName) {
                ZeroOrMore(.word)
            }
            ")"
        }
    }()
    
    let rootPath: String
    let knownSlides: [any Slide.Type]
    let knownFocuses: [Focus]

    init(rootPath: String, knowSlides: [any Slide.Type], knownFocuses: [Focus]) {
        self.rootPath = rootPath
        self.knownSlides = knowSlides
        self.knownFocuses = knownFocuses
    }
    
    func saveUpdatesToSourceCode() -> [String: Result<Void, Swift.Error>] {
        let hints = loadFilePathsForHints()
        let focuses = loadFilePathsForFocuses()
        
        var result = [String: Result<Void, Swift.Error>]()
        for slide in knownSlides {
            result[slide.name] = Result {
                guard let file = hints[slide.name] else {
                    throw Error.fileNotFound
                }
                
                try store(slide: slide, at: file)
            }
        }
        
        result["%focuses%"] = Result {
            guard let file = focuses.values.first else {
                throw Error.fileNotFound
            }
            
            try storeFocuses(at: file)
        }
        
        return result
    }
    
    private func store(slide: any Slide.Type, at file: String) throws {
        var content = try String(contentsOfFile: rootPath + "/" + file, encoding: .utf8)
        let regexResult = try FocusCodeManipulator.hintRegex.firstMatch(in: content)!
        let indentation = "\(regexResult[FocusCodeManipulator.indent])"
        let hintContent = regexResult[FocusCodeManipulator.content].range
        
        let output =
#"""
\#(indentation)static var hint: String? =
"""

"""#
        +
        (slide.hint.flatMap {$0 + "\n" } ?? "")
        +
#"""
"""
"""#
        content.replaceSubrange(hintContent, with: output)
        
        try content.write(toFile: rootPath + "/" + file, atomically: true, encoding: .utf8)
    }

    private func storeFocuses(at file: String) throws {
        var content = try String(contentsOfFile: rootPath + "/" + file, encoding: .utf8)
        let regexResult = try FocusCodeManipulator.focusRegex.firstMatch(in: content)!
        let variableName = "\(regexResult[FocusCodeManipulator.startName])"
        let indentation = "\(regexResult[FocusCodeManipulator.indent])"
        let focusesContent = regexResult[FocusCodeManipulator.content].range
            
        func focusArrayContent() -> String {
            var acumulator: [String] = []
            var hintIndex = 0
            for focus in knownFocuses {
                switch focus {
                case let .properties(properties):
                    acumulator.append(
                        ".properties(.init(offset: CGVector(dx: \(properties.offset.dx), dy: \(properties.offset.dy)), scale: \(properties.scale), hint: generated_hint_\(hintIndex))),"
                    )
                    hintIndex += 1
                case let .slides(slides):
                    var line = ".slides(["
                    for slide in slides {
                        line += String(describing: slide.self) + ".self, "
                    }
                    line += "]),"
                    acumulator.append(line)
                }
            }
            
            return acumulator.map { indentation + "    " + $0 }.joined(separator: "\n")
        }
        
        func hintContent() -> String {
            var acumulator: [String] = []
            var hintIndex = 0
            for focus in knownFocuses {
                switch focus {
                case let .properties(properties):
                    let hintString =
#"""
\#(indentation)private let generated_hint_\#(hintIndex): String =
"""

"""#
        +
        (properties.hint.flatMap {$0 + "\n" } ?? "")
        +
#"""
"""
"""#
                    acumulator.append(hintString)
                    hintIndex += 1
                default:
                    break
                }
            }
            
            return acumulator.joined(separator: "\n\n")
        }
        
        let output =
#"""
\#(indentation)private var focuses: [Focus] = [
\#(focusArrayContent())
]

\#(hintContent())

"""#
        
        content.replaceSubrange(focusesContent, with: output)
        
        try content.write(toFile: rootPath + "/" + file, atomically: true, encoding: .utf8)
    }

    private func loadFilePathsForHints() -> [String: String] {
        let enumerator = FileManager.default.enumerator(atPath: rootPath)
        
        var result = [String:String]()
        while let object = enumerator?.nextObject() as? String {
            guard object.hasSuffix(".swift"), let content = try? String(contentsOfFile: rootPath + "/" + object, encoding: .utf8) else {
                continue
            }
            if let regexResult = try? FocusCodeManipulator.hintRegex.firstMatch(in: content) {
                let startName = "\(regexResult[FocusCodeManipulator.startName])"
                let endName = "\(regexResult[FocusCodeManipulator.endName])"
                if startName == endName {
                    result[startName] = object
                }
            }
        }
        
        return result
    }
    
    private func loadFilePathsForFocuses() -> [String: String] {
        let enumerator = FileManager.default.enumerator(atPath: rootPath)
        
        var result = [String:String]()
        while let object = enumerator?.nextObject() as? String {
            guard object.hasSuffix(".swift"), let content = try? String(contentsOfFile: rootPath + "/" + object, encoding: .utf8) else {
                continue
            }
            if let regexResult = try? FocusCodeManipulator.focusRegex.firstMatch(in: content) {
                let startName = "\(regexResult[FocusCodeManipulator.startName])"
                let endName = "\(regexResult[FocusCodeManipulator.endName])"
                if startName == endName {
                    result[startName] = object
                }
            }
        }
        
        return result
    }

}
