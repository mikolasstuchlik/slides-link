import SwiftUI

/*
 Known issues: entering editor mode when focus is out of bounds will crash
 */

private let backgrounds: [any Background.Type] = [
    SwiftBackground.self, CBackground.self, CBackground2.self, LibBackground.self, OBackground.self,
]

private let slides: [any Slide.Type] = [
    Beginning.self,
    UvodOTematu.self, UvodProc.self,
    KnihovnyDylibVSA.self, KnihovnyHighLvl.self, KnihovnyHandoff.self,
    CZaklad.self, CHeader.self, CDvaSoubory.self, CShrnuti.self,
    OCoToJe.self, OCteni.self,
    CLibStaticka.self, CLibDynamicka.self,
    SwiftShrnuti.self, SwiftModule.self, SwiftStatic.self,
    End.self,
]

// @focuses(focuses){
private var focuses: [Focus] = [
    .slides([Beginning.self, ]),
    .slides([UvodOTematu.self, ]),
    .slides([UvodProc.self, ]),
    .properties(.init(offset: CGVector(dx: 1.6922540350274722, dy: 5.434065934065933), scale: 0.10111111111111111, hint: generated_hint_0)),
    .slides([KnihovnyHighLvl.self, ]),
    .slides([KnihovnyDylibVSA.self, ]),
    .slides([KnihovnyHandoff.self, ]),
    .slides([CZaklad.self, ]),
    .slides([CDvaSoubory.self, ]),
    .slides([CHeader.self, ]),
    .slides([CShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 3.4140188066658204, dy: 3.4606751843397228), scale: 2.106785185185185, hint: generated_hint_1)),
    .properties(.init(offset: CGVector(dx: 3.4926249937291525, dy: 4.155842471759384), scale: 1.8726979423868308, hint: generated_hint_2)),
    .slides([OCoToJe.self, ]),
    .slides([OCteni.self, ]),
    .slides([CLibStaticka.self, ]),
    .slides([CLibDynamicka.self, ]),
    .slides([CShrnuti.self, ]),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.5041070690666503, dy: 10.129525911752044), scale: 3.1601777777777773, hint: generated_hint_3)),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.4254430528548137, dy: 9.595775247528993), scale: 3.1601777777777773, hint: generated_hint_4)),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.43980574469777456, dy: 9.790506373650125), scale: 3.1601777777777773, hint: generated_hint_5)),
    .slides([SwiftShrnuti.self, ]),
    .slides([SwiftModule.self, ]),
    .slides([SwiftStatic.self, ]),
    .slides([End.self, ]),
]

private let generated_hint_0: String =
"""
Pokusil jsem se zkondenzovat prezentaci co nejvíc.

Abychom mohli pochopit co je knihovna, musíme se seznámit s tím, co je „objektový kód“ a k tomu je ideální C - i pokud neznáte C. 

Během prezentace můžete pokládat dotazy, ale připravil jsem i opory (link na slack), které obsahují základní věci.

Vyřadil jsem i spoustu témat, pokud by vás některé zajímalo, dejte vědět.
"""

private let generated_hint_1: String =
"""
"""

private let generated_hint_2: String =
"""
Liker v toto případě je Linker Editor. (Program LD)
"""

private let generated_hint_3: String =
"""

"""

private let generated_hint_4: String =
"""

"""

private let generated_hint_5: String =
"""

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
