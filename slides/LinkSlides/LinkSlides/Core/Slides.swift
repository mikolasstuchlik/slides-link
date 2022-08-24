import SwiftUI

// MARK: - Presentation support
protocol Background: View {
    static var offset: CGVector { get }
    static var relativeSize: CGSize { get }
    static var name: String { get }
}

extension Background {
    static var name: String { String(describing: Self.self) }

    var name: String { Self.name }
}

protocol Slide: View {
    static var offset: CGVector { get }
    static var singleFocusScale: CGFloat { get }
    static var hint: String? { get }
    static var name: String { get }
    
    init()
}

extension Slide {
    static var hint: String? { nil }
    static var name: String { String(describing: Self.self) }
    static var singleFocusScale: CGFloat { 0.9999 } // When scale is 1.0, some shapes disappear :shurug:
    
    var name: String { Self.name }
}

struct Plane: View {
    @EnvironmentObject var presentation: PresentationProperties

    var body: some View {
        ZStack {
            ForEach(presentation.backgrounds, id: \.name, content: content(for:))
            ForEach(presentation.slides.indices) { content(for: presentation.slides[$0]) }
        }
        .frame(
            width: presentation.screenSize.width,
            height: presentation.screenSize.height
        )
    }

    private func content(for background: any Background) -> AnyView {
        AnyView(
            background.body
                .frame(
                    width: presentation.screenSize.width * type(of: background).relativeSize.width,
                    height: presentation.screenSize.height * type(of: background).relativeSize.height
                )
                .offset(
                    x: presentation.screenSize.width * type(of: background).offset.dx,
                    y: presentation.screenSize.height * type(of: background).offset.dy
                )
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
        )
    }
}

enum Focus {
    struct Properties {
        let offset: CGVector
        let scale: CGFloat
        let hint: String?
    }
    
    case slides([any Slide.Type])
    case properties(Properties)
}

struct Camera: Equatable {
    var offset: CGVector
    var scale: CGFloat
}

struct Presentation: View {
    @EnvironmentObject var presentation: PresentationProperties

    private enum MouseMoveMachine: Equatable {
        case idle
        case cmdDown
        case leftButtonDown(lastPosition: NSPoint)
    }
    
    @State private var mouseMoveMachine: MouseMoveMachine = .idle

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
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .leftMouseDragged, .leftMouseDown, .flagsChanged], handler: handleMac(event:))
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
            .animation(.easeInOut(duration: 1.0), value: presentation.camera)
    }

    private func handleMac(event: NSEvent) -> NSEvent? {
        resolveMouseDrag(event: event)
        if resolveNavigation(event: event) {
            return nil
        }
        
        return event
    }
    
    private func resolveMouseDrag(event: NSEvent) {
        switch event.type {
        case .flagsChanged:
            mouseMoveMachine = event.modifierFlags.contains(.command) ? .cmdDown : .idle
        case .leftMouseDown where mouseMoveMachine == .cmdDown:
            mouseMoveMachine = .leftButtonDown(lastPosition: event.locationInWindow)
        case .leftMouseDragged where mouseMoveMachine != .idle:
            guard case let .leftButtonDown(lastPosition) = mouseMoveMachine, let windowSize = event.window?.frame.size else {
                break
            }
            let newPosition = event.locationInWindow
            let movement = CGVector(
                dx: (newPosition.x - lastPosition.x) / windowSize.width / presentation.camera.scale,
                dy: (newPosition.y - lastPosition.y) / windowSize.height / presentation.camera.scale
            )
            
            presentation.camera.offset = CGVector(
                dx: presentation.camera.offset.dx - movement.dx, // X axis is inverted due to different cooridinate usage
                dy: presentation.camera.offset.dy + movement.dy
            )
            
            mouseMoveMachine = .leftButtonDown(lastPosition: newPosition)
        default:
            break
        }
    }
    
    private func resolveNavigation(event: NSEvent) -> Bool {
        guard
            presentation.mode == .navigation,
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
}

final class PresentationProperties: ObservableObject {
    enum Mode: Int, Equatable {
        case entry, navigation
    }

    init(backgrounds: [any Background], slides: [any Slide.Type], focuses: [Focus]) {
        self.backgrounds = backgrounds
        self.slides = slides
        self.focuses = focuses
    }

    var selectedFocus: Int = 0 {
        didSet {
            guard let newConfiguration = getConfiguration(for: selectedFocus) else {
                return
            }
            camera = .init(offset: newConfiguration.offset, scale: newConfiguration.scale)
            hint = newConfiguration.hint
        }
    }

    var backgrounds: [any Background]
    var slides: [any Slide.Type]
    @Published var focuses: [Focus]

    @Published var mode: Mode = .navigation
    @Published var colorScheme: ColorScheme = ColorScheme.dark

    @Published var automaticFameSize: Bool = true
    @Published var frameSize: CGSize = CGSize(width: 480, height: 360)

    @Published var automaticScreenSize: Bool = true
    @Published var screenSize: CGSize = CGSize(width: 480, height: 360)

    @Published var camera: Camera = .init(offset: .zero, scale: 1.0)
    
    @Published var hint: String? = nil
    
    static let defaultTitle = NSFont.systemFont(ofSize: 80, weight: .bold)
    static let defaultSubTitle = NSFont.systemFont(ofSize: 70, weight: .regular)
    static let defaultHeadline = NSFont.systemFont(ofSize: 50, weight: .bold)
    static let defaultSubHeadline = NSFont.systemFont(ofSize: 40, weight: .regular)
    static let defaultBody = NSFont.systemFont(ofSize: 30)
    static let defaultNote = NSFont.systemFont(ofSize: 20, weight: .light)

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
    
}
