import SwiftUI

/*
 Known issues: entering editor mode when focus is out of bounds will crash
 */

private let backgrounds: [any Background] = [
    XcodeBackground(),
]

private let slides: [any Slide.Type] = [
    Beginning.self,
    End.self,
]

// @focuses(focuses){
private var focuses: [Focus] = [
    .slides([Beginning.self, ]),
    .slides([End.self, ]),
]
// }@focuses(focuses)

private let presentation = PresentationProperties(
    rootPath: Array(String(#file).components(separatedBy: "/").dropLast()).joined(separator: "/"),
    slidesPath: Array(String(#file).components(separatedBy: "/").dropLast()).joined(separator: "/") + "/Slides",
    backgrounds: backgrounds,
    slides: slides,
    focuses: focuses
)

@main
struct LinkSlidesApp: App {

    var body: some Scene {
        get {
            if #available(macOS 13.0, *) {
                return new
            } else {
                return old
            }
        }
    }
    
    var old: some Scene {
        WindowGroup {
            Presentation().environmentObject(presentation)
        }
    }
    
    @available(macOS 13.0, *)
    @SceneBuilder var new: some Scene {
        WindowGroup("Toolbar") {
            SlideControlPanel(environment: presentation).environmentObject(presentation)
        }

        Window("Slides", id: "slides") {
            Presentation().environmentObject(presentation)
        }
    }
}
