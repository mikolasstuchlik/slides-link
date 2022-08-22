import SwiftUI

@main
struct LinkSlidesApp: App {
    var body: some Scene {
        WindowGroup("Toolbar") {
            SlideControlPanel().environmentObject(PresentationProperties.shared)
        }
        
        Window("Slides", id: "slides") {
            LinkSlides().environmentObject(PresentationProperties.shared)
        }
    }
}
