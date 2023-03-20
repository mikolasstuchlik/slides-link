import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct CLibStaticka: View, Slide {
    // @offset(CLibStaticka)
    static var offset = CGVector(dx: 0.5, dy: 7.75)
    
    // @hint(CLibStaticka){
    static var hint: String? =
"""

"""
    // }@hint(CLibStaticka)
    
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
        "clang -c mylib.c && ls",
        "ar -q libmylib.a mylib.o && ls",
        "nm libmylib.a",
        "clang -o exec libmylib.a exec.c && ./exec",
        #"clang -I"$(pwd)" -o exec libmylib.a exec.c && ./exec"#,
        #"clang -I"$(pwd)" -L"$(pwd)" -o exec -lmylib exec.c && ./exec"#,
    ]
    
    @State var code: String = CLibStaticka.defaultCode
    @State var lib: String = CLibStaticka.defaultLib
    @State var header: String = CLibStaticka.defaultHeader

    @State var state: TerminalView.State = .idle
    @State var stdin: String = CLibStaticka.defaultStdIn[0]
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
                            filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/mylib.h",
                            format: .constant(.c),
                            content: $header
                        )
                        TextEditorView(
                            filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/mylib.c",
                            format: .constant(.c),
                            content: $lib
                        )
                    }
                    VStack(spacing: 8) {
                        TextEditorView(
                            filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/exec.c",
                            format: .constant(.c),
                            content: $code
                        )
                        TerminalView(
                            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cstaticlib")),
                            stdIn: $stdin,
                            state: $state,
                            aspectRatio: 0.5,
                            axis: .horizontal
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
Argumenty  `-I` ,  `-L`  a  `-l`  neukazuji jen tak pro radost - ke stejnému účelu se používají se i ve Swiftu!
Ekvivalent `-I`/`-L` pro `.framework` je `-F` a ekvivalent `-l<jméno frameworku>` je `-framework <jméno frameworku>`
"""
            )
            .font(.presentationNote)
        }.padding()
    }
}

struct CLibStaticka_Previews: PreviewProvider {
    static var previews: some View {
        CLibStaticka().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
