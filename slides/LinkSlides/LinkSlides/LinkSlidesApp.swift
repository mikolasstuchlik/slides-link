import SwiftUI

/*
 TODO:
  - Clean code (separate features)
  - Fix WebView so it stops rendering when off-view
  - Add Feature View:
     - Placeholder View
     - Text editor view
     - Modify command option for CodeView
  - Add Editor mode:
    - The ability to arrange Slides and Backgrounds runtime
    - The ability to define Focuses runtime
    - Source code propagation using simple file processing
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

private let focuses: [Focus] = [
    .slides([Beginning.self]),
    .slides([WhatIsFTD.self]),
    .properties(.init(offset: CGVector(dx: 0, dy: -4), scale: 0.2, hint: nil)),
    .properties(.init(offset: CGVector(dx: 0, dy: -3.5), scale: 0.9, hint: nil)),
    .slides([Beginning.self, WhatIsFTD.self]),
    .slides([FTDExample.self]),
    .slides([End.self]),
    .slides([Beginning.self, WhatIsFTD.self, FTDExample.self, End.self]),
]

private let presentation = PresentationProperties(
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
            SlideControlPanel().environmentObject(presentation)
        }

        Window("Slides", id: "slides") {
            Presentation().environmentObject(presentation)
        }
    }
}
