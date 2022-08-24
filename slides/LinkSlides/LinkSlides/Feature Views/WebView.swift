import WebKit
import SwiftUI

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
