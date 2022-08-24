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
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
