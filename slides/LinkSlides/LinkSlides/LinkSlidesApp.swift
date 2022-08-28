import SwiftUI

/*
 Known issues: entering editor mode when focus is out of bounds will crash
 */

private let backgrounds: [any Background] = [
    XcodeBackground(),
]

private let slides: [any Slide.Type] = [
    Beginning.self,
    UvodOTematu.self, UvodProc.self,
    KnihovnyDylibVSA.self,
    End.self,
]

// @focuses(focuses){
let hint_manual1 =
"""
 - Nejprve se podíváme na to, co to vůbec je knihovna
 - Ukážeme si jak se pracuje s knihovnami v C a na tomto základě si vysvětlíme jak funguje proces kompilace
 - Co jsme viděli u C si zopakujeme v C++ ale zaměříme se na rozdíly
 - Ukážeme si jak do toho všeho zapadá Swift

 - Zásadní pojmy si nejdřív definujeme "z výšky" resp. tak, jak je můžeme znát z praxe
"""

private var focuses: [Focus] = [
    .slides([Beginning.self, ]),
    .slides([UvodOTematu.self]),
    .slides([UvodProc.self]),
    .properties(.init(offset: .zero, scale: 0.5, hint: hint_manual1)),
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
