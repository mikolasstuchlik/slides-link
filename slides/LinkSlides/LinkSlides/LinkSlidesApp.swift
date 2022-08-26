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
private var focuses: [Focus] = [
    .slides([Beginning.self, ]),
    .slides([FTDExample.self, ]),
    .slides([WhatIsFTD.self, ]),
    .properties(.init(offset: CGVector(dx: 0.0, dy: -4.0), scale: 0.2, hint: generated_hint_0)),
    .properties(.init(offset: CGVector(dx: 0.0, dy: -3.5), scale: 0.9, hint: generated_hint_1)),
    .slides([Beginning.self, WhatIsFTD.self, ]),
    .slides([End.self, ]),
    .slides([Beginning.self, WhatIsFTD.self, FTDExample.self, End.self, ]),
    .properties(.init(offset: CGVector(dx: 1.0, dy: 1.0), scale: 0.07, hint: generated_hint_2)),
]

private let generated_hint_0: String =
"""

"""

private let generated_hint_1: String =
"""

"""

private let generated_hint_2: String =
"""
Poslední hint
:)
:)
:)
"""

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
