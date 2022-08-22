import Foundation
import WebKit
import AppKit
import SwiftUI

extension ClosedRange where Bound: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
    
    init<Other: BinaryInteger>(_ other: ClosedRange<Other>) {
        self = Bound(other.lowerBound)...Bound(other.upperBound)
    }
}

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

struct EffectView: NSViewRepresentable {
    @State var material: NSVisualEffectView.Material = .headerView
    @State var blendingMode: NSVisualEffectView.BlendingMode = .withinWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
