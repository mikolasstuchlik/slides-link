import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct CHeader: View, Slide {
    // @offset(CHeader)
    static var offset = CGVector(dx: 2.5, dy: 3.75)
    
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

    public final class ExposedState: ForwardEventCapturingState {
        public static var stateSingleton: CHeader.ExposedState = .init()

        @Published var headerCode: TextEditorView.Model = .init(
            filePath: FileCoordinator.shared.pathToFolder(for: "cheader") + "/source.h",
            format: .c,
            content: CHeader.defaultHeader
        )

        @Published var execCode: TextEditorView.Model = .init(
            filePath: FileCoordinator.shared.pathToFolder(for: "cheader") + "/source.c",
            format: .c,
            content: CHeader.defaultCode
        )

        @Published var terminal: TerminalView.Model = .init(
            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "cheader")),
            stdIn: CHeader.defaultStdIn,
            state: .idle
        )

        @Published var toggle: Bool = false

        public func captured(forwardEvent number: UInt) -> Bool {
            switch number {
            case 0:
                toggle.toggle()
            case 1:
                headerCode.save()
                execCode.save()
            case 2:
                terminal.execute()
            case 3:
                toggle.toggle()
            default:
                return false
            }
            return true
        }
    }
    @ObservedObject private var state: ExposedState = ExposedState.stateSingleton

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - Hlavičkové soubory").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView(toggledOn: $state.toggle) {
                    VStack {
                        HStack {
                            TextEditorView(model: state.execCode)
                            TextEditorView(model: state.headerCode)
                        }
                        TerminalView(model: state.terminal, aspectRatio: 0.5, axis: .horizontal).frame(height: 200)
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
