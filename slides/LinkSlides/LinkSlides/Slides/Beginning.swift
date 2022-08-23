import SwiftUI
 
struct Beginning: View, Slide {
    static let offset = CGVector(dx: 0, dy: 0)
    static let hint: String? = "Čau lidi!"

    let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    var body: some View {
        VStack {
            Text("**Dynamická SwiftUI Prezentace**")
                .font(.presentationTitle)
            if !isPreview {
                WebView(url: URL(string: "https://www.youtube.com/watch?v=AJgiKKLEhZw")!)
                //WebView(url: URL(string: "https://www.youtube.com/watch?v=78706bv98S8")!)
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
