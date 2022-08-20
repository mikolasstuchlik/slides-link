import SwiftUI
import AppKit
import WebKit
import Foundation
 
struct WebView: NSViewRepresentable {
    var url: URL
 
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct Beginning: View, Slide {
    static let offset = CGVector(dx: 0, dy: 0)

    let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    var body: some View {
        ZStack {
            Color.white
            VStack {
                Text("**Dynamická SwiftUI Prezentace**")
                    .foregroundColor(.black)
                    .font(.system(size: 80))
                
                if !isPreview {
                    WebView(url: URL(string: "https://www.youtube.com/watch?v=78706bv98S8")!)
                }
            }
            .padding()
        }
    }
}

struct Beginning_Previews: PreviewProvider {
    static var previews: some View {
        Beginning()
    }
}
