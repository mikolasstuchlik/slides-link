import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct SwiftStatic: View, Slide {
    // @offset(SwiftStatic)
    static var offset = CGVector(dx: 2.5, dy: 9.75)
    
    // @hint(SwiftStatic){
    static var hint: String? =
"""
Po kompilaci nezapomenout ukázat opet rozdíl mezi ld a dyld. DŮLEŽITÉ.
"""
    // }@hint(SwiftStatic)
    
    init() {}

    private static let defaultCode =
#"""
import MyLib

print("Pi: \(getPi())")

"""#

    private static let defaultLib =
"""

private let piValue: Double = 3.14

public func getPi() -> Double {
  return piValue
}

"""
    
    private static let defaultStdIn =  [
        "swiftc -parse-as-library -emit-library -static -emit-module MyLib.swift && ls",
        "nm libMyLib.a",
        "swift demangle s5MyLib5getPiSdyF",
        #"swiftc -I"$(pwd)" -L"$(pwd)" -lMyLib Exec.swift && ./Exec"#,
    ]

    @StateObject var libCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "swiftslib") + "/MyLib.swift",
        format: .swift,
        content: SwiftStatic.defaultLib
    )

    @StateObject var execCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "swiftslib") + "/Exec.swift",
        format: .swift,
        content: SwiftStatic.defaultCode
    )

    @StateObject var terminal: TerminalView.Model = .init(
        workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "swiftslib")),
        stdIn: SwiftStatic.defaultStdIn[0],
        state: .idle
    )

    @State var line = 0
    @State var toggle: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("C knihovna").font(.presentationHeadline)
                Text("Vytvoření statické nebo dynamické knihovny").font(.presentationSubHeadline)
            }
            ToggleView(toggledOn: $toggle) {
                HStack(spacing: 8) {
                    VStack(spacing: 8) {
                        TextEditorView(model: libCode)
                        TextEditorView(model: execCode)
                    }
                    
                    TerminalView(model: terminal, aspectRatio: 0.25, axis: .horizontal)
                    Button("Další řádek") {
                        line += 1
                        
                        if line >= Self.defaultStdIn.count {
                            line = 0
                        }
                        terminal.stdIn = Self.defaultStdIn[line]
                    }
                }
            }
            
            Text(
"""
Argumenty:
 1. `swiftc` kompilátor swift
 2. `-parse-as-library` chovej se k modulu jako ke knihovně, tj. **neumožni** spustitelný kód mimo scope funkce a **nevytvářej** funkci `main`
 3. `-emit-library` vystup kompilace nechť je knihovna (výchozí nastavení je dynamická)
 4. `-static` pokud je výstupem knihovna, nechť je statická
 5. `-emit-module` vygeneruj soubory `.swiftmodule` a `.swiftdoc` nutné pro to, aby byl modul "importovatelný"
"""
            )
            .font(.presentationBody)
        }.padding()
    }
}

struct SwiftStatic_Previews: PreviewProvider {
    static var previews: some View {
        SwiftStatic().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
