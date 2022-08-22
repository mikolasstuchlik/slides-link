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

//
//  FontPicker.swift
//
//  Created by : Tomoaki Yagishita on 2021/01/09
//  © 2021  SmallDeskSoftware
//
import SwiftUI

class FontPickerDelegate {
    var parent: FontPicker

    init(_ parent: FontPicker) {
        self.parent = parent
    }
    
    @objc
    func changeFont(_ id: Any) {
        parent.fontSelected()
    }

}

public struct FontPicker: View {
    let labelString: String
    
    @Binding var font: NSFont
    @State var fontPickerDelegate: FontPickerDelegate? = nil
    
    public init(_ label: String, selection: Binding<NSFont>) {
        self.labelString = label
        self._font = selection
    }
    
    public var body: some View {
        HStack {
            Text(labelString)
            
            Button {
                if NSFontPanel.shared.isVisible {
                    NSFontPanel.shared.orderOut(nil)
                    return
                }
                
                self.fontPickerDelegate = FontPickerDelegate(self)
                NSFontManager.shared.target = self.fontPickerDelegate
                NSFontPanel.shared.setPanelFont(self.font, isMultiple: false)
                NSFontPanel.shared.orderBack(nil)
            } label: {
                Image(systemName: "textformat")
                    .resizable()
                    .scaledToFit()
                    .padding(2)
            }
        }
    }
    
    func fontSelected() {
        self.font = NSFontPanel.shared.convert(self.font)
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker("font", selection: .constant(NSFont.systemFont(ofSize: 24)))
    }
}
