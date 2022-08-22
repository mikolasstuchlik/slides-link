import SwiftUI

// MARK: - Presentation support
protocol Slide: View {
    static var offset: CGVector { get }
    static var hint: String? { get }
    static var name: String { get }
}

extension Slide {
    static var hint: String? { nil }
    static var name: String { String(describing: Self.self) }
    
    var name: String { Self.name }
}

struct Plane: View {
    @EnvironmentObject var presentation: PresentationProperties
    
    let slides: [any Slide]

    var body: some View {
        ZStack {
            ForEach(slides, id: \.name, content: content(for:))
        }
        .frame(
            width: presentation.screenSize.width,
            height: presentation.screenSize.height
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

    let slides: [any Slide]
    let focuses: [Focus]

    var body: some View {
        GeometryReader { geometry in
            plane.onChange(of: geometry.size) { newSize in
                if presentation.automaticFameSize {
                    presentation.frameSize = newSize
                }
                if presentation.automaticScreenSize {
                    presentation.screenSize = newSize
                }
            }
        }
    }
    
    private var plane: some View {
        Plane(slides: slides)
            .scaleEffect(presentation.scale)
            .offset(
                x: -(presentation.screenSize.width * presentation.offset.dx),
                y: -(presentation.screenSize.height * presentation.offset.dy)
            )
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
    }
    
    private func getConfiguration(for newFocusIndex: Int) -> Focus.Properties? {
        guard
            newFocusIndex >= 0,
            newFocusIndex < focuses.count
        else {
            return nil
        }
        
        switch focuses[newFocusIndex] {
        case let .slides(slides):
            return computeFocus(for: slides)
        case let .properties(properties):
            return properties
        }
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
            dx: (minXOffset + minXOffset.distance(to: maxXOffset) / 2) * newScale,
            dy: (minYOffset + minYOffset.distance(to: maxYOffset) / 2) * newScale
        )
        
        let newHint = slides
            .compactMap { slide in slide.hint.flatMap { "**\(slide.name):**\n" + $0 } }
            .joined(separator: "\n")
        
        return .init(offset: newOffset, scale: newScale, hint: newHint)
    }
}

final class PresentationProperties: ObservableObject {
    static let shared = PresentationProperties()
    
    @Published var automaticFameSize: Bool = true
    @Published var frameSize: CGSize = CGSize(width: 480, height: 360)
    
    @Published var selectedFocus: Int = 0
    
    @Published var automaticScreenSize: Bool = true
    @Published var screenSize: CGSize = CGSize(width: 480, height: 360)
    @Published var scale: CGFloat = 1.0
    @Published var offset: CGVector = .zero
}
