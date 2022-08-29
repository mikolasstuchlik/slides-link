import SwiftUI

// MARK: - Presentation support
protocol Background: View {
    static var offset: CGVector { get }
    static var relativeSize: CGSize { get }
    static var scale: CGFloat { get }
    
    init()
}

protocol Slide: View {
    static var offset: CGVector { get set }
    static var singleFocusScale: CGFloat { get }
    static var hint: String? { get set }
    static var name: String { get }
    
    init()
}

extension Slide {
    static var name: String { String(describing: Self.self) }
    static var singleFocusScale: CGFloat { 0.9999 } // When scale is 1.0, some shapes disappear :shurug:
    
    var name: String { Self.name }
}

struct Plane: View {
    @EnvironmentObject var presentation: PresentationProperties

    var body: some View {
        ZStack {
            ForEach(presentation.backgrounds.indices) { content(for: presentation.backgrounds[$0]) }
            ForEach(presentation.slides.indices) { content(for: presentation.slides[$0]) }
        }
        .frame(
            width: presentation.screenSize.width,
            height: presentation.screenSize.height
        )
    }

    private func content(for background: any Background.Type) -> some View {
        AnyView(
            background.init()
        )
        .frame(
            width: presentation.screenSize.width * background.relativeSize.width,
            height: presentation.screenSize.height * background.relativeSize.height
        )
        .scaleEffect(background.scale)
        .offset(
            x: presentation.screenSize.width * background.offset.dx,
            y: presentation.screenSize.height * background.offset.dy
        )
    }
    
    private func content(for slide: any Slide.Type) -> AnyView {
        AnyView(
            slide.init()
                .frame(
                    width: presentation.frameSize.width,
                    height: presentation.frameSize.height
                )
                .offset(
                    x: presentation.screenSize.width * slide.offset.dx,
                    y: presentation.screenSize.height * slide.offset.dy
                )
                .disabled(presentation.mode == .editor)
        )
    }
}


enum Focus: Hashable {
    struct Properties: Hashable {
        let uuid: UUID = UUID()
        var offset: CGVector
        var scale: CGFloat
        var hint: String?
    }
    
    case slides([any Slide.Type])
    case properties(Properties)
    
    static func == (lhs: Focus, rhs: Focus) -> Bool {
        switch (lhs, rhs) {
        case let (.slides(lCont), .slides(rCont)):
            return lCont.map { $0.name } == rCont.map { $0.name }
        case let (.properties(lCont), .properties(rCont)) where lCont == rCont:
            return true
        default:
            return false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .properties(properties):
            hasher.combine(0)
            hasher.combine(properties)
        case let .slides(slides):
            hasher.combine(slides.map { $0.name })
        }
    }
}

struct Camera: Equatable {
    var offset: CGVector
    var scale: CGFloat
}

private enum MouseMoveMachine<Context>: Equatable {
    case idle
    case callFlagDown
    case leftButtonDown(lastPosition: CGVector, context: Context)
    
    static func leftButtonDown(lastPosition: CGVector) -> Self where Context == Void {
        return Self.leftButtonDown(lastPosition: lastPosition, context: ())
    }
    
    static func == (lhs: MouseMoveMachine<Context>, rhs: MouseMoveMachine<Context>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.callFlagDown, .callFlagDown):
            return true
        case let (.leftButtonDown(llastPos, _), .leftButtonDown(rlastPos, _)) where llastPos == rlastPos:
            return true
        default:
            return false
        }
    }
}

struct Presentation: View {
    @EnvironmentObject var presentation: PresentationProperties
    
    @State private var mouseMoveMachine: MouseMoveMachine<Void> = .idle
    @State private var moveSlideMachine: MouseMoveMachine<any Slide.Type> = .idle
    
    var body: some View {
        GeometryReader { geometry in
            plane
                .onChange(of: geometry.size) { newSize in
                    if presentation.automaticFameSize {
                        presentation.frameSize = newSize
                    }
                    if presentation.automaticScreenSize {
                        presentation.screenSize = newSize
                    }
                }
                .preferredColorScheme(presentation.colorScheme)
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .leftMouseDragged, .leftMouseDown, .leftMouseUp, .flagsChanged], handler: handleMac(event:))
        }
    }
    
    private var plane: some View {
        Plane()
            .offset(
                x: -(presentation.screenSize.width * presentation.camera.offset.dx),
                y: -(presentation.screenSize.height * presentation.camera.offset.dy)
            )
            .scaleEffect(presentation.camera.scale)
            .clipped()
            .animation(
                presentation.mode == .presentation ? .easeInOut(duration: 1.0) : nil,
                value: presentation.camera
            )
    }
    
    private func handleMac(event: NSEvent) -> NSEvent? {
        guard !(presentation.mode == .editor && !presentation.allowHotkeys) else {
            return event
        }
        
        resolveMouseDrag(event: event)
        resolveSlideDrag(event: event)
        if resolveZoomHotkeys(event: event) {
            return nil
        }
        if resolveNavigation(event: event) {
            return nil
        }
        if resolveModeSwap(event: event) {
            return nil
        }
        
        return event
    }
    
    private func resolveMouseDrag(event: NSEvent) {
        switch event.type {
        case .flagsChanged:
            mouseMoveMachine = event.modifierFlags.contains(.command) ? .callFlagDown : .idle
        case .leftMouseDown where mouseMoveMachine == .callFlagDown:
            guard let windowSize = event.window?.frame.size else {
                break
            }
            mouseMoveMachine = .leftButtonDown(lastPosition: offset(for: event.locationInWindow, in: windowSize))
        case .leftMouseDragged where mouseMoveMachine != .idle:
            guard case let .leftButtonDown(lastPosition, _) = mouseMoveMachine, let windowSize = event.window?.frame.size else {
                break
            }
            let newPosition = offset(for: event.locationInWindow, in: windowSize)
            presentation.camera.offset = presentation.camera.offset - (newPosition - lastPosition)
            mouseMoveMachine = .leftButtonDown(lastPosition: newPosition)
        case .leftMouseUp where mouseMoveMachine != .idle:
            mouseMoveMachine = .callFlagDown
        default:
            break
        }
    }
    
    private func resolveSlideDrag(event: NSEvent) {
        guard presentation.mode == .editor else {
            return
        }
        
        switch event.type {
        case .flagsChanged:
            moveSlideMachine = event.modifierFlags.contains(.shift) ? .callFlagDown : .idle
        case .leftMouseDown where moveSlideMachine == .callFlagDown:
            guard let windowSize = event.window?.frame.size else {
                break
            }
            let offsetLocation = offset(for: event.locationInWindow, in: windowSize) + presentation.camera.offset
            let slide = presentation.slides.reversed().first { slide in
                getOffsetRect(of: slide).contains(CGPoint(x: offsetLocation.dx, y: offsetLocation.dy))
            }
            guard let slide else {
                moveSlideMachine = .callFlagDown
                break
            }
            moveSlideMachine = .leftButtonDown(lastPosition: offsetLocation, context: slide)
        case .leftMouseDragged where moveSlideMachine != .idle:
            guard case let .leftButtonDown(lastPosition, slide) = moveSlideMachine, let windowSize = event.window?.frame.size else {
                break
            }
            let newPosition = offset(for: event.locationInWindow, in: windowSize) + presentation.camera.offset

            slide.offset = slide.offset + (newPosition - lastPosition)
            // If some camera property isnt changed, the slide is not re-arranged on the plane
            presentation.camera.offset = presentation.camera.offset

            moveSlideMachine = .leftButtonDown(lastPosition: newPosition, context: slide)
        case .leftMouseUp where moveSlideMachine != .idle:
            moveSlideMachine = .callFlagDown
        default:
            break
        }
    }
    
    private func resolveZoomHotkeys(event: NSEvent) -> Bool {
        guard presentation.mode != .entry, event.type == .keyDown else {
            return false
        }
        switch event.keyCode {
        case 45 /* 'n' */:
            presentation.camera.scale = presentation.camera.scale - (presentation.camera.scale / 3)
        case 46 /* 'n' */:
            presentation.camera.scale = presentation.camera.scale + (presentation.camera.scale / 3)
        default:
            return false
        }

        return true
    }
    
    private func offset(for position: NSPoint, in window: CGSize) -> CGVector {
        CGVector(
            dx: (position.x - window.width / 2) / window.width / presentation.camera.scale,
            dy: (position.y - window.height / 2) / window.height / presentation.camera.scale
        ).invertedDY()
    }
    
    private func absoluteToOffset(size: CGSize) -> CGSize {
        CGSize(
            width: size.width / presentation.screenSize.width,
            height: size.height / presentation.screenSize.height
        )
    }

    private func getOffsetRect(of slide: any Slide.Type) -> CGRect {
        let offset = slide.offset
        let offsetSize = absoluteToOffset(size: presentation.frameSize)
        return CGRect(
            origin: CGPoint(
                x: offset.dx - offsetSize.width / 2,
                y: offset.dy - offsetSize.height / 2
            ),
            size: offsetSize
        )
    }
    
    private func resolveNavigation(event: NSEvent) -> Bool {
        guard
            presentation.mode == .presentation,
            event.type == .keyDown
        else {
            return false
        }
        
        switch event.keyCode {
        case 49 /* Space bar*/, 36 /* enter */:
            presentation.selectedFocus += 1
        case 51 /* Back space */:
            presentation.selectedFocus -= 1
        default:
            return false
        }
        
        return true
    }
    
    private func resolveModeSwap(event: NSEvent) -> Bool {
        guard
            event.type == .keyDown,
            event.keyCode == 53 /* escape */
        else {
            return false
        }
        
        switch presentation.mode {
        case .presentation:
            presentation.mode = .entry
        case .entry, .editor:
            presentation.mode = .presentation
        }
        
        return true
    }
}

final class PresentationProperties: ObservableObject {
    enum Mode: Int, Equatable {
        case entry, presentation, editor
        
        private static let navigationHotkeys = [
            "`spacebar`, `enter` - increment focus",
            "`backspace` - decrement focus",
        ]
        
        private static let globalHotkeys = [
            "`escape` - toggles between Inspection and Presentation mode",
            "`cmd` + *mouse drag* - move the camera",
        ]
        
        private static let editorHotkeys = [
            "`shift` + *mouse drag* - move slide on the plane",
        ]
        
        private static let scaleHotkeys = [
            "`n` - zoom out",
            "`m` - zoom in",
        ]
        
        var hotkeyHint: [String] {
            switch self {
            case .editor:
                return Mode.globalHotkeys + Mode.scaleHotkeys + Mode.editorHotkeys
            case .presentation:
                return Mode.globalHotkeys + Mode.scaleHotkeys + Mode.navigationHotkeys
            case .entry:
                return Mode.globalHotkeys
            }
        }
    }
    
    static func preview() -> PresentationProperties {
        PresentationProperties(rootPath: "", slidesPath: "", backgrounds: [], slides: [], focuses: [])
    }

    init(rootPath: String, slidesPath: String, backgrounds: [any Background.Type], slides: [any Slide.Type], focuses: [Focus]) {
        self.rootPath = rootPath
        self.slidesPath = slidesPath
        self.backgrounds = backgrounds
        self.slides = slides
        self.focuses = focuses
    }

    var selectedFocus: Int = 0 {
        didSet {
            guard let newConfiguration = getConfiguration(for: selectedFocus), !(mode == .editor && moveCamera == false) else {
                return
            }
            camera = .init(offset: newConfiguration.offset, scale: newConfiguration.scale)
        }
    }
    
    let rootPath: String
    let slidesPath: String
    var backgrounds: [any Background.Type]
    var slides: [any Slide.Type]
    @Published var focuses: [Focus]

    @Published var mode: Mode = .presentation
    @Published var colorScheme: ColorScheme = ColorScheme.dark

    @Published var automaticFameSize: Bool = true
    @Published var frameSize: CGSize = CGSize(width: 1024, height: 768)

    @Published var automaticScreenSize: Bool = true
    @Published var screenSize: CGSize = CGSize(width: 1024, height: 768)

    @Published var loadThumbnails: Bool = false
    
    @Published var camera: Camera = .init(offset: .zero, scale: 1.0)
    @Published var moveCamera: Bool = false
    @Published var allowHotkeys: Bool = true
    
    static let defaultTitle = NSFont.systemFont(ofSize: 80, weight: .bold)
    static let defaultSubTitle = NSFont.systemFont(ofSize: 70, weight: .regular)
    static let defaultHeadline = NSFont.systemFont(ofSize: 50, weight: .bold)
    static let defaultSubHeadline = NSFont.systemFont(ofSize: 40, weight: .regular)
    static let defaultBody = NSFont.systemFont(ofSize: 30)
    static let defaultNote = NSFont.systemFont(ofSize: 20, weight: .light)
    static let defaultEditorFont = NSFont.systemFont(ofSize: 25, weight: .regular)

    @Published var title: NSFont = PresentationProperties.defaultTitle {
        willSet {
            Font.presentationTitle = Font(newValue as CTFont)
        }
    }

    @Published var subTitle: NSFont = PresentationProperties.defaultSubTitle  {
        willSet {
            Font.presentationSubTitle = Font(newValue as CTFont)
        }
    }

    @Published var headline: NSFont = PresentationProperties.defaultHeadline {
        willSet {
            Font.presentationHeadline = Font(newValue as CTFont)
        }
    }

    @Published var subHeadline: NSFont = PresentationProperties.defaultSubHeadline  {
        willSet {
            Font.presentationSubHeadline = Font(newValue as CTFont)
        }
    }

    @Published var body: NSFont = PresentationProperties.defaultBody {
        willSet {
            Font.presentationBody = Font(newValue as CTFont)
        }
    }

    @Published var note: NSFont = PresentationProperties.defaultNote  {
        willSet {
            Font.presentationNote = Font(newValue as CTFont)
        }
    }

    @Published var codeEditorFontSize: CGFloat = 25 {
        willSet {
            Font.presentationEditorFont = Font.system(size: newValue)
            Font.presentationEditorFontSize = newValue
        }
    }

    private func getConfiguration(for newFocusIndex: Int) -> Focus.Properties? {
        guard
            newFocusIndex >= 0,
            newFocusIndex < focuses.count
        else {
            return nil
        }
        
        switch focuses[newFocusIndex] {
        case let .slides(slides) where slides.count == 1:
            return singleSlideFocus(for: slides.first!)
        case let .slides(slides):
            return computeFocus(for: slides)
        case let .properties(properties):
            return properties
        }
    }
    
    private func singleSlideFocus(for slide: any Slide.Type) -> Focus.Properties {
        .init(offset: slide.offset, scale: slide.singleFocusScale, hint: slide.hint)
    }
    
    private func computeFocus(for slides: [any Slide.Type]) -> Focus.Properties? {
        guard !slides.isEmpty else { return nil }

        var minXOffset = slides.first!.offset.dx
        var minYOffset = slides.first!.offset.dy
        var maxXOffset = slides.first!.offset.dx
        var maxYOffset = slides.first!.offset.dy
        
        for slide in slides {
            minXOffset = min(minXOffset, slide.offset.dx)
            minYOffset = min(minYOffset, slide.offset.dy)
            maxXOffset = max(maxXOffset, slide.offset.dx)
            maxYOffset = max(maxYOffset, slide.offset.dy)
        }

        let width = 1 / (minXOffset.distance(to: maxXOffset) + 1)
        let height = 1 / (minYOffset.distance(to: maxYOffset) + 1)
        
        let newScale = min(width, height)
        
        let newOffset = CGVector(
            dx: (minXOffset + minXOffset.distance(to: maxXOffset) / 2),
            dy: (minYOffset + minYOffset.distance(to: maxYOffset) / 2)
        )
        
        let newHint = slides
            .compactMap { slide in slide.hint.flatMap { "**\(slide.name):**\n" + $0 } }
            .joined(separator: "\n\n--\n\n")
        
        return .init(offset: newOffset, scale: newScale - 0.01, hint: newHint)
    }
    
}

extension Font {
    static fileprivate(set) var presentationTitle: Font = { Font(PresentationProperties.defaultTitle as CTFont) }()
    static fileprivate(set) var presentationSubTitle: Font = { Font(PresentationProperties.defaultSubTitle as CTFont) }()
    static fileprivate(set) var presentationHeadline: Font = { Font(PresentationProperties.defaultHeadline as CTFont) }()
    static fileprivate(set) var presentationSubHeadline: Font = { Font(PresentationProperties.defaultSubHeadline as CTFont) }()
    static fileprivate(set) var presentationBody: Font = { Font(PresentationProperties.defaultBody as CTFont) }()
    static fileprivate(set) var presentationNote: Font = { Font(PresentationProperties.defaultNote as CTFont) }()
    static fileprivate(set) var presentationEditorFont: Font = { Font(PresentationProperties.defaultEditorFont as CTFont) }()
    static fileprivate(set) var presentationEditorFontSize: CGFloat = { PresentationProperties.defaultEditorFont.pointSize }()
}
