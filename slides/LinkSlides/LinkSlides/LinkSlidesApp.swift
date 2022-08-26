import SwiftUI

/*
 Known issues: entering editor mode when focus is out of bounds will crash
 */

private let backgrounds: [any Background] = [
    XcodeBackground(),
    SwiftBackground()
]

private let slides: [any Slide.Type] = [
    Beginning.self,
    WhatIsFTD.self,
    FTDExample.self,
    End.self,
]

// @focuses(focuses){
private let focuses: [Focus] = [
    .slides([Beginning.self]),
    .slides([FTDExample.self]),
    .slides([WhatIsFTD.self]),
    .properties(.init(offset: CGVector(dx: 0, dy: -4), scale: 0.2, hint: nil)),
    .properties(.init(offset: CGVector(dx: 0, dy: -3.5), scale: 0.9, hint: nil)),
    .slides([Beginning.self, WhatIsFTD.self]),
    .slides([End.self]),
    .slides([Beginning.self, WhatIsFTD.self, FTDExample.self, End.self]),
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
