import SwiftUI

/*
 Known issues: entering editor mode when focus is out of bounds will crash
 */

private let backgrounds: [any Background] = [
    SwiftBackground(), CBackground(), CBackground2(), LibBackground(), OBackground(),
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
    .slides([SwiftStatic.self, ]),
    .slides([UvodOTematu.self, ]),
    .slides([UvodProc.self, ]),
    .properties(.init(offset: CGVector(dx: 0.0, dy: 0.0), scale: 0.5, hint: generated_hint_0)),
    .slides([End.self, ]),
]

private let generated_hint_0: String =
"""
 - Nejprve se podíváme na to, co to vůbec je knihovna
 - Ukážeme si jak se pracuje s knihovnami v C a na tomto základě si vysvětlíme jak funguje proces kompilace
 - Ukážeme si jak do toho všeho zapadá Swift

 - Zásadní pojmy si nejdřív definujeme "z výšky" resp. tak, jak je můžeme znát z praxe
"""

// }@focuses(focuses)

private let presentation = PresentationProperties(
    rootPath: Array(String(#file).components(separatedBy: "/").dropLast()).joined(separator: "/"),
    slidesPath: Array(String(#file).components(separatedBy: "/").dropLast()).joined(separator: "/") + "/Slides",
    backgrounds: backgrounds,
    slides: slides,
    focuses: focuses
)

final class FileCoordinator {
    static let shared = FileCoordinator()
    
    private static let workFolder = "/slides"
    
    let appSupportURL: URL
    var workFolder: String { appSupportURL.path + FileCoordinator.workFolder }
    private var preparedFolders: Set<String> = []
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.appSupportURL = appSupport
        var isDir = ObjCBool(true)
        if FileManager.default.fileExists(atPath: appSupport.path + FileCoordinator.workFolder, isDirectory: &isDir) {
            guard isDir.boolValue else {
                fatalError()
            }

            try! FileManager.default.removeItem(atPath: appSupport.path + FileCoordinator.workFolder)
        }
        
        try! FileManager.default.createDirectory(atPath: appSupport.path + FileCoordinator.workFolder, withIntermediateDirectories: true)
    }
    
    func pathToFolder(for name: String) -> String {
        if preparedFolders.contains(name) {
            return workFolder + "/" + name
        }
        
        var isDir = ObjCBool(true)
        if FileManager.default.fileExists(atPath: workFolder + "/" + name, isDirectory: &isDir) {
            guard isDir.boolValue else {
                fatalError()
            }

            try! FileManager.default.removeItem(atPath: workFolder + "/" + name)
        }
        
        try! FileManager.default.createDirectory(atPath: workFolder + "/" + name, withIntermediateDirectories: true)
        
        preparedFolders.insert(name)
        return workFolder + "/" + name
    }
}

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
