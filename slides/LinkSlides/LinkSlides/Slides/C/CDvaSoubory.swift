import SwiftUI
import SlideUIViews
import SlideUI
import SlideUICommons

struct CDvaSoubory: View, Slide {
    // @offset(CDvaSoubory)
    static var offset = CGVector(dx: 1.5, dy: 3.75)
    
    // @hint(CDvaSoubory){
    static var hint: String? =
"""

"""
    // }@hint(CDvaSoubory)
    
    init() {}

    private static let defaultCode =
"""
#include <stdio.h>

int mul2(int input);

int main(void) {
  printf("Mám %d slidů!!!\\n", 20);
  return 0;
}

"""
    
    private static let defaultSecond =
"""

int mul2(int input) {
  return input * 2;
}

"""
    
    private static let defaultStdIn = "clang -c mul.c && clang mul.o source.c -o source && ./source"
    
    @State var content: String = CDvaSoubory.defaultCode
    @State var otherCont: String = CDvaSoubory.defaultSecond
    @State var state: TerminalView.State = .idle
    @State var stdin: String = CDvaSoubory.defaultStdIn

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - Víc než jeden soubor, prosím").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView {
                    VStack {
                        HStack {
                            TextEditorView(
                                filePath: FileCoordinator.shared.pathToFolder(for: "ctwofiles") + "/source.c",
                                format: .constant(.c),
                                content: $content
                            )
                            TextEditorView(
                                filePath: FileCoordinator.shared.pathToFolder(for: "ctwofiles") + "/mul.c",
                                format: .constant(.c),
                                content: $otherCont
                            )
                        }
                        TerminalView(
                            workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "ctwofiles")),
                            stdIn: $stdin,
                            state: $state,
                            aspectRatio: 0.5,
                            axis: .horizontal
                        ).frame(height: 200)
                    }
                }
            }
            .font(.presentationNote)
        }.padding()
    }
}

struct CDvaSoubory_Previews: PreviewProvider {
    static var previews: some View {
        CDvaSoubory().frame(width: 1024, height: 768).environmentObject(PresentationProperties.preview())
    }
}
