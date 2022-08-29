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
    .slides([KnihovnyHighLvl.self, SwiftStatic.self, ]),
    .slides([KnihovnyHighLvl.self, ]),
    .slides([KnihovnyDylibVSA.self, ]),
    .slides([KnihovnyHandoff.self, ]),
    .slides([CZaklad.self, ]),
    .slides([CDvaSoubory.self, ]),
    .slides([CHeader.self, ]),
    .slides([CShrnuti.self, ]),
    .slides([OCoToJe.self, ]),
    .slides([OCteni.self, ]),
    .slides([CLibStaticka.self, ]),
    .slides([CLibDynamicka.self, ]),
    .slides([CShrnuti.self, ]),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.5041070690666503, dy: 10.129525911752044), scale: 3.1601777777777773, hint: generated_hint_0)),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.4254430528548137, dy: 9.595775247528993), scale: 3.1601777777777773, hint: generated_hint_1)),
    .slides([SwiftShrnuti.self, ]),
    .properties(.init(offset: CGVector(dx: 0.43980574469777456, dy: 9.790506373650125), scale: 3.1601777777777773, hint: generated_hint_2)),
    .slides([SwiftShrnuti.self, ]),
    .slides([SwiftModule.self, ]),
    .slides([SwiftStatic.self, ]),
    .slides([End.self, ]),
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
