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

    @StateObject var libCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/mylib.c",
        format: .c,
        content: CLibStaticka.defaultLib
    )

    @StateObject var headerCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/mylib.h",
        format: .c,
        content: CLibStaticka.defaultHeader
    )

    @StateObject var execCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cstaticlib") + "/exec.c",
        format: .c,
        content: CLibStaticka.defaultCode
    )

    @StateObject var terminal: TerminalView.Model = .init(
        workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cstaticlib")),
        stdIn: CLibStaticka.defaultStdIn[0],
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
