import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

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

    @StateObject var execCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "cbasic") + "/source.c",
        format: .c,
        content: CZaklad.defaultCode
    )

    @StateObject var terminal: TerminalView.Model = .init(
        workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cbasic")),
        stdIn: CZaklad.defaultStdIn,
        state: .idle
    )

    @State var toggle: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - funkce a volání").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView(toggledOn: $toggle) {
                    VStack {
                        TextEditorView(model: execCode)
                        TerminalView(model: terminal, aspectRatio: 0.5, axis: .horizontal).frame(height: 200)
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
