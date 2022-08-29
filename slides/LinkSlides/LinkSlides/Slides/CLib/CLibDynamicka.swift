import SwiftUI

struct CLibDynamicka: View, Slide {
    // @offset(CLibDynamicka)
    static var offset = CGVector(dx: -2, dy: 0)
    
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
    
    @State var code: String = CLibDynamicka.defaultCode
    @State var lib: String = CLibDynamicka.defaultLib
    @State var header: String = CLibDynamicka.defaultHeader

    @State var state: TerminalView.State = .idle
    @State var stdin: String = CLibDynamicka.defaultStdIn[0]
    @State var line = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("C knihovna").font(.presentationHeadline)
                Text("Vytvoření statické knihovny").font(.presentationSubHeadline)
            }
            ToggleView {
                HStack(spacing: 8) {
                    VStack(spacing: 8) {
                        TextEditorView(
                            axis: .vertical,
                            filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/mylib.h",
                            format: .constant(.c),
                            content: $header
                        )
                        TextEditorView(
                            axis: .vertical,
                            filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/mylib.c",
                            format: .constant(.c),
                            content: $lib
                        )
                    }
                    VStack(spacing: 8) {
                        TextEditorView(
                            axis: .vertical,
                            filePath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib") + "/exec.c",
                            format: .constant(.c),
                            content: $code
                        )
                        TerminalView(
                            axis: .horizontal,
                            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cdynamiclib")),
                            aspectRatio: 0.5,
                            stdIn: $stdin,
                            state: $state
                        )
                        Button("Další řádek") {
                            line += 1

                            if line >= Self.defaultStdIn.count {
                                line = 0
                            }
                            stdin = Self.defaultStdIn[line]
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
