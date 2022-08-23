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
}

extension Slide {
    static var hint: String? { nil }
    static var name: String { String(describing: Self.self) }
    static var singleFocusScale: CGFloat { 0.9999 } // When scale is 1.0, some shapes disappear :shurug:
    
    var name: String { Self.name }
}

struct Plane: View {
    @EnvironmentObject var presentation: PresentationProperties
    
    let backgrounds: [any Background]
    let slides: [any Slide]

    var body: some View {
        ZStack {
            ForEach(backgrounds, id: \.name, content: content(for:))
            ForEach(slides, id: \.name, content: content(for:))
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
    
    private func content(for slide: any Slide) -> AnyView {
        AnyView(
            slide.body
                .frame(
                    width: presentation.frameSize.width,
                    height: presentation.frameSize.height
                )
                .offset(
                    x: presentation.screenSize.width * type(of: slide).offset.dx,
                    y: presentation.screenSize.height * type(of: slide).offset.dy
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

struct Presentation: View {
    @EnvironmentObject var presentation: PresentationProperties

    let backgrounds: [any Background]
    let slides: [any Slide]
    let focuses: [Focus]

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
        }
    }
    
    private var plane: some View {
        Plane(backgrounds: backgrounds, slides: slides)
            .offset(
                x: -(presentation.screenSize.width * presentation.offset.dx),
                y: -(presentation.screenSize.height * presentation.offset.dy)
            )
            .scaleEffect(presentation.scale)
            .clipped()
            .onChange(of: presentation.selectedFocus, perform: applyNew(focus:))
    }
    
    private func applyNew(focus focusIndex: Int) {
        guard let newConfiguration = getConfiguration(for: focusIndex) else {
            return
        }
        
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
        
        presentation.hint = newConfiguration.hint
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

final class PresentationProperties: ObservableObject {
    static let shared = PresentationProperties()
    
    @Published var colorScheme: ColorScheme = ColorScheme.dark

    @Published var automaticFameSize: Bool = true
    @Published var frameSize: CGSize = CGSize(width: 480, height: 360)

    @Published var automaticScreenSize: Bool = true
    @Published var screenSize: CGSize = CGSize(width: 480, height: 360)

    @Published var selectedFocus: Int = 0

    @Published var scale: CGFloat = 1.0
    @Published var offset: CGVector = .zero
    
    @Published var hint: String? = nil
    
    @Published var title: NSFont = NSFont.systemFont(ofSize: 80, weight: .bold) {
        willSet {
            Font.presentationTitle = Font(newValue as CTFont)
        }
    }

    @Published var subTitle: NSFont = NSFont.systemFont(ofSize: 70, weight: .regular) {
        willSet {
            Font.presentationSubTitle = Font(newValue as CTFont)
        }
    }

    @Published var headline: NSFont = NSFont.systemFont(ofSize: 50, weight: .bold) {
        willSet {
            Font.presentationHeadline = Font(newValue as CTFont)
        }
    }

    @Published var subHeadline: NSFont = NSFont.systemFont(ofSize: 40, weight: .regular) {
        willSet {
            Font.presentationSubHeadline = Font(newValue as CTFont)
        }
    }

    @Published var body: NSFont = NSFont.systemFont(ofSize: 30) {
        willSet {
            Font.presentationBody = Font(newValue as CTFont)
        }
    }

    @Published var note: NSFont = NSFont.systemFont(ofSize: 20, weight: .light) {
        willSet {
            Font.presentationNote = Font(newValue as CTFont)
        }
    }

}

extension Font {
    static fileprivate(set) var presentationTitle: Font = { Font(PresentationProperties.shared.title as CTFont) }()
    static fileprivate(set) var presentationSubTitle: Font = { Font(PresentationProperties.shared.subTitle as CTFont) }()
    static fileprivate(set) var presentationHeadline: Font = { Font(PresentationProperties.shared.headline as CTFont) }()
    static fileprivate(set) var presentationSubHeadline: Font = { Font(PresentationProperties.shared.subHeadline as CTFont) }()
    static fileprivate(set) var presentationBody: Font = { Font(PresentationProperties.shared.body as CTFont) }()
    static fileprivate(set) var presentationNote: Font = { Font(PresentationProperties.shared.note as CTFont) }()
    
}
