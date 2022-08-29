import SwiftUI

struct CHeader: View, Slide {
    // @offset(CHeader)
    static var offset = CGVector(dx: 0, dy: -4)
    
    // @hint(CHeader){
    static var hint: String? =
"""

"""
    // }@hint(CHeader)
    
    init() {}

    private static let defaultCode =
"""
#include "source.h"

int main(void) {
  printf("Mám %d slidů!!!\\n", 20);
  return 0;
}

int mul2(int input) {
  return input * 2;
}

"""
    
    private static let defaultHeader =
"""
#include <stdio.h>

int mul2(int input);

"""
    
    private static let defaultStdIn = "clang source.c -o source && ./source"
    
    @State var content: String = CHeader.defaultCode
    @State var header: String = CHeader.defaultHeader
    @State var state: TerminalView.State = .idle
    @State var stdin: String = CHeader.defaultStdIn

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - Hlavičkové soubory").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView {
                    VStack {
                        HStack {
                            TextEditorView(
                                axis: .vertical,
                                filePath: FileCoordinator.shared.pathToFolder(for: "cheader") + "/source.c",
                                format: .constant(.c),
                                content: $content
                            )
                            TextEditorView(
                                axis: .vertical,
                                filePath: FileCoordinator.shared.pathToFolder(for: "cheader") + "/source.h",
                                format: .constant(.c),
                                content: $header
                            )
                        }
                        TerminalView(
                            axis: .horizontal,
                            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cheader")),
                            aspectRatio: 0.5,
                            stdIn: $stdin,
                            state: $state
                        ).frame(height: 200)
                    }
                }
            }
            
            Text(
"""
Kompilátor C jako 1. krok spustí *preprocesor*. V tomto kroku se zpracovávají všechny ... "pokyny" se znakem `#`.
Například "pokyn" `#include` se pokusí copy-pastnout na svoje místo odkazovaný soubor.
Pokud se to nepovede, skončí kompilátor s chybou.
"""
            )
            .font(.presentationNote)
        }.padding()
    }
}

struct CHeader_Previews: PreviewProvider {
    static var previews: some View {
        CHeader().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
