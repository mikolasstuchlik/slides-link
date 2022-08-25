import SwiftUI
 
struct Beginning: View, Slide {
    // @offset(Beginning)
    static var offset = CGVector(dx: 0.0, dy: 0.0)
    static var hint: String? = "Čau lidi!"

    init() {}
    
    let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    var body: some View {
        VStack {
            Text("**Dynamická SwiftUI Prezentace**")
                .font(.presentationTitle)
            if !isPreview {
                ToggleView {
                    WebView(url: URL(string: "https://www.youtube.com/watch?v=AJgiKKLEhZw")!)
                }
            }
        }
        .padding()
    }
}

struct Beginning_Previews: PreviewProvider {
    static var previews: some View {
        Beginning()
    }
}
