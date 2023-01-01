import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct OCteni: View, Slide {
    // @offset(OCteni)
    static var offset = CGVector(dx: 1.5, dy: 5.75)
    
    // @hint(OCteni){
    static var hint: String? =
"""

"""
    // }@hint(OCteni)
    
    init() {}

    private static var defaultStdIn = "nm mul.o"
    
    @State var state: TerminalView.State = .idle
    @State var stdin: String = OCteni.defaultStdIn

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Objektový soubor").font(.presentationHeadline)
                Text("Čtení tabulky symbolů").font(.presentationSubHeadline)
            }
            ToggleView {
                TerminalView(
                    axis: .horizontal,
                    workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "ctwofiles")),
                    aspectRatio: 0.20,
                    stdIn: $stdin,
                    state: $state
                )
            }
            Text(
"""
`man nm:`
`Each symbol name is preceded by its value (blanks if undefined). Unless the -m option is specified, this value is followed by one of the following characters, representing the symbol type: U (undefined), A (absolute), T (text section symbol), D (data section symbol), B (bss section symbol), C (common symbol), - (for debugger symbol table entries; see -a below), S (symbol in a section other than those above), or I (indirect symbol).  If the symbol is local (non-external), the symbol's type is instead represented by the corresponding lowercase letter.  A lower case u in a dynamic shared library indicates a undefined reference to a private external in another module in the same library.`
"""
            )
            .font(.presentationNote)
        }.padding()
    }
}

struct OCteni_Previews: PreviewProvider {
    static var previews: some View {
        OCteni().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
