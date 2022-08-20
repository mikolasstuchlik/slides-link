import SwiftUI

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
    @Published var exception: String?
}
