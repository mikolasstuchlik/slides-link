import WebKit
import SwiftUI

struct WebView: NSViewRepresentable {
    var url: URL

    static func dismantleNSView(_ nsView: WKWebView, coordinator: Self.Coordinator) {
        nsView.load(URLRequest(url: URL(string:"about:blank")!))
    }
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
