import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

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
    Focus(kind: .specific([Beginning.self]), hint: generated_hint_0),
    Focus(kind: .specific([UvodOTematu.self]), hint: generated_hint_1),
    Focus(kind: .specific([UvodProc.self]), hint: generated_hint_2),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 1.6922540350274722, dy: 5.434065934065933), scale: 0.10111111111111111)), hint: generated_hint_3),
    Focus(kind: .specific([KnihovnyHighLvl.self]), hint: generated_hint_4),
    Focus(kind: .specific([KnihovnyDylibVSA.self]), hint: generated_hint_5),
    Focus(kind: .specific([KnihovnyHandoff.self]), hint: generated_hint_6),
    Focus(kind: .specific([CZaklad.self]), hint: generated_hint_7),
    Focus(kind: .specific([CDvaSoubory.self]), hint: generated_hint_8),
    Focus(kind: .specific([CHeader.self]), hint: generated_hint_9),
    Focus(kind: .specific([CShrnuti.self]), hint: generated_hint_10),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 3.4140188066658204, dy: 3.4606751843397228), scale: 2.106785185185185)), hint: generated_hint_11),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 3.4926249937291525, dy: 4.155842471759384), scale: 1.8726979423868308)), hint: generated_hint_12),
    Focus(kind: .specific([OCoToJe.self]), hint: generated_hint_13),
    Focus(kind: .specific([OCteni.self]), hint: generated_hint_14),
    Focus(kind: .specific([CLibStaticka.self]), hint: generated_hint_15),
    Focus(kind: .specific([CLibDynamicka.self]), hint: generated_hint_16),
    Focus(kind: .specific([CShrnuti.self]), hint: generated_hint_17),
    Focus(kind: .specific([SwiftShrnuti.self]), hint: generated_hint_18),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 0.5041070690666503, dy: 10.129525911752044), scale: 3.1601777777777773)), hint: generated_hint_19),
    Focus(kind: .specific([SwiftShrnuti.self]), hint: generated_hint_20),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 0.4254430528548137, dy: 9.595775247528993), scale: 3.1601777777777773)), hint: generated_hint_21),
    Focus(kind: .specific([SwiftShrnuti.self]), hint: generated_hint_22),
    Focus(kind: .unbound(Camera(offset: CGVector(dx: 0.43980574469777456, dy: 9.790506373650125), scale: 3.1601777777777773)), hint: generated_hint_23),
    Focus(kind: .specific([SwiftShrnuti.self]), hint: generated_hint_24),
    Focus(kind: .specific([SwiftModule.self]), hint: generated_hint_25),
    Focus(kind: .specific([SwiftStatic.self]), hint: generated_hint_26),
    Focus(kind: .specific([End.self]), hint: generated_hint_27)
]

private let generated_hint_0: String =
"""

"""

private let generated_hint_1: String =
"""

"""

private let generated_hint_2: String =
"""

"""

private let generated_hint_3: String =
"""
Pokusil jsem se zkondenzovat prezentaci co nejvíc.

Abychom mohli pochopit co je knihovna, musíme se seznámit s tím, co je „objektový kód“ a k tomu je ideální C - i pokud neznáte C. 

Během prezentace můžete pokládat dotazy, ale připravil jsem i opory (link na slack), které obsahují základní věci.

Vyřadil jsem i spoustu témat, pokud by vás některé zajímalo, dejte vědět.
"""

private let generated_hint_4: String =
"""

"""

private let generated_hint_5: String =
"""

"""

private let generated_hint_6: String =
"""

"""

private let generated_hint_7: String =
"""

"""

private let generated_hint_8: String =
"""

"""

private let generated_hint_9: String =
"""

"""

private let generated_hint_10: String =
"""

"""

private let generated_hint_11: String =
"""

"""

private let generated_hint_12: String =
"""
Liker v toto případě je Linker Editor. (Program LD)
"""

private let generated_hint_13: String =
"""

"""

private let generated_hint_14: String =
"""

"""

private let generated_hint_15: String =
"""

"""

private let generated_hint_16: String =
"""

"""

private let generated_hint_17: String =
"""

"""

private let generated_hint_18: String =
"""

"""

private let generated_hint_19: String =
"""

"""

private let generated_hint_20: String =
"""

"""

private let generated_hint_21: String =
"""

"""

private let generated_hint_22: String =
"""

"""

private let generated_hint_23: String =
"""

"""

private let generated_hint_24: String =
"""

"""

private let generated_hint_25: String =
"""

"""

private let generated_hint_26: String =
"""

"""

private let generated_hint_27: String =
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
        WindowGroup("Toolbar") {
            SlideControlPanel().environmentObject(presentation)
        }

        Window("Slides", id: "slides") {
            Presentation(environment: presentation).environmentObject(presentation)
        }
    }
}
