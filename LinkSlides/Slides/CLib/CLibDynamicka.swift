import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct CLibDynamicka: View, Slide {
    // @offset(CLibDynamicka)
    static var offset = CGVector(dx: 1.5, dy: 7.75)
    
    // @hint(CLibDynamicka){
    static var hint: String? =
"""

"""
    // }@hint(CLibDynamicka)
    
    init() {}

    private static let defaultCode =
"""
#include <stdio.h>

#include "mylib.h" // #include <mylib.h>

int main(void) {
  printf("Pi: %f", getPi());
  return 0;
}

"""

    private static let defaultHeader =
"""

float getPi();

"""
    
    private static let defaultLib =
"""
#include "mylib.h"

float getPi() {
    return 3.14;
}

"""
    
    private static let defaultStdIn =  [
        "clang -c -fPIC mylib.c && ls",
        "clang -shared -o libmylib.dylib mylib.c && ls",
        "nm libmylib.dylib",
        "clang -o exec libmylib.dylib exec.c && ./exec",
        #"clang -I"$(pwd)" -L"$(pwd)" -o exec -lmylib exec.c && ./exec"#,
        "otool -L exec",
        "rm libmylib.dylib && ./exec"
    ]


    @StateObject var libCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/mylib.c",
        format: .c,
        content: CLibDynamicka.defaultLib
    )

    @StateObject var headerCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/mylib.h",
        format: .c,
        content: CLibDynamicka.defaultHeader
    )

    @StateObject var execCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/exec.c",
        format: .c,
        content: CLibDynamicka.defaultCode
    )

    @StateObject var terminal: TerminalView.Model = .init(
        workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib")),
        stdIn: CLibDynamicka.defaultStdIn[0],
        state: .idle
    )

    @State var line = 0
    @State var toggle: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("C knihovna").font(.presentationHeadline)
                Text("Vytvoření statické knihovny").font(.presentationSubHeadline)
            }
            ToggleView(toggledOn: $toggle) {
                HStack(spacing: 8) {
                    VStack(spacing: 8) {
                        TextEditorView(model: headerCode)
                        TextEditorView(model: libCode)
                    }
                    VStack(spacing: 8) {
                        TextEditorView(model: execCode)
                        TerminalView(model: terminal, aspectRatio: 0.5, axis: .horizontal)
                        Button("Další řádek") {
                            line += 1

                            if line >= Self.defaultStdIn.count {
                                line = 0
                            }
                            terminal.stdIn = Self.defaultStdIn[line]
                        }
                    }
                }
            }
            Text(
"""
`dl` - Linker editor (součást toolchain)
`dyld` - Dynamický linker (součást OS)
"""
            )
            .font(.presentationNote)
        }.padding()
    }
}

struct CLibDynamicka_Previews: PreviewProvider {
    static var previews: some View {
        CLibDynamicka().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
