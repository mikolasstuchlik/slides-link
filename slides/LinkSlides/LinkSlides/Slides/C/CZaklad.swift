import SwiftUI

struct CZaklad: View, Slide {
    // @offset(CZaklad)
    static var offset = CGVector(dx: 0.5, dy: 3.75)
    
    // @hint(CZaklad){
    static var hint: String? =
"""

"""
    // }@hint(CZaklad)
    
    init() {}
    
    private static let defaultCode =
"""
#include <stdio.h>

int main(void) {
  printf("Mám %d slidů!!!\\n", 20);
  return 0;
}

"""
    
    private static let defaultStdIn = "clang source.c -o source && ./source"
    
    @State var content: String = CZaklad.defaultCode
    @State var state: TerminalView.State = .idle
    @State var stdin: String = CZaklad.defaultStdIn

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - funkce a volání").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView {
                    VStack {
                        TextEditorView(
                            axis: .vertical,
                            filePath: FileCoordinator.shared.pathToFolder(for: "cbasic") + "/source.c",
                            format: .constant(.c),
                            content: $content
                        )
                        TerminalView(
                            axis: .horizontal,
                            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cbasic")),
                            aspectRatio: 0.5,
                            stdIn: $stdin,
                            state: $state
                        ).frame(height: 200)
                    }
                }
            }
            
            Text(
"""
Předpis funkce:

`"návratový typ" "název funkce"( "argumenty" ) {`
`  "tělo funkce"`
`}`
"""
            )
            .font(.presentationNote)
        }.padding()
    }
}

struct CZaklad_Previews: PreviewProvider {
    static var previews: some View {
        CZaklad().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
