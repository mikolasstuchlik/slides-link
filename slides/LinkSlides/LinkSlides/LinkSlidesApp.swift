import SwiftUI

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
            LinkSlides().environmentObject(PresentationProperties.shared)
        }
    }
    
    @available(macOS 13.0, *)
    @SceneBuilder var new: some Scene {
        WindowGroup("Toolbar") {
            SlideControlPanel().environmentObject(PresentationProperties.shared)
        }

        Window("Slides", id: "slides") {
            LinkSlides().environmentObject(PresentationProperties.shared)
        }
    }
}
