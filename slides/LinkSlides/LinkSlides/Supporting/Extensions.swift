import AppKit
import SwiftUI
import CodeEditor

extension Substring {
    var range: Range<String.Index> {
        startIndex..<endIndex
    }
}

extension CGSize {
    static func /(_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

    static func *(_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}

extension CGVector {
    static func -(lhs: CGVector, rhs: CGVector) -> CGVector{
        CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
    }
    
    static func +(lhs: CGVector, rhs: CGVector) -> CGVector{
        CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
    }
    
    func invertedDY() -> CGVector {
        var copy = self
        copy.dy = -copy.dy
        return copy
    }
}

extension CGVector: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(dx)
        hasher.combine(dy)
    }
}

extension ClosedRange where Bound: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
    
    init<Other: BinaryInteger>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
}

extension View {
    func renderAsImage() -> NSImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        return view.bitmapImage()
    }
    
    func renderAsImage(delay: TimeInterval, result: @escaping (NSImage?) -> Void) {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(view.fittingSize)
        
        Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            result(view.bitmapImage())
        }
    }

}

class NoInsetHostingView<V>: NSHostingView<V> where V: View {
    
    override var safeAreaInsets: NSEdgeInsets {
        return .init()
    }
    
}

public extension NSView {
    
    func bitmapImage() -> NSImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        guard let cgImage = rep.cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
    
}

extension CodeEditor.Language {
    static let knownCases: [CodeEditor.Language] = [
        .accesslog,
        .actionscript,
        .ada,
        .apache,
        .applescript,
        .bash,
        .basic,
        .brainfuck,
        .c,
        .cpp,
        .cs,
        .css,
        .diff,
        .dockerfile,
        .go,
        .http,
        .java,
        .javascript,
        .json,
        .lua,
        .markdown,
        .makefile,
        .nginx,
        .objectivec,
        .pgsql,
        .php,
        .python,
        .ruby,
        .rust,
        .shell,
        .smalltalk,
        .sql,
        .swift,
        .tcl,
        .tex,
        .twig,
        .typescript,
        .vbnet,
        .vbscript,
        .xml,
        .yaml,
    ]
}
