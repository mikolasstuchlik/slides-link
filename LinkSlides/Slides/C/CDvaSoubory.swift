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

    @StateObject var execCode: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "ctwofiles") + "/source.c",
        format: .c,
        content: CDvaSoubory.defaultCode
    )

    @StateObject var exec2Code: TextEditorView.Model = .init(
        filePath: FileCoordinator.shared.pathToFolder(for: "ctwofiles") + "/mul.c",
        format: .c,
        content: CDvaSoubory.defaultSecond
    )

    @StateObject var terminal: TerminalView.Model = .init(
        workingPath: URL(fileURLWithPath: FileCoordinator.shared.pathToFolder(for: "ctwofiles")),
        stdIn: CDvaSoubory.defaultStdIn,
        state: .idle
    )

    @State var toggle: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            VStack(alignment: .leading) {
                Text("Jazyk C").font(.presentationHeadline)
                Text("Rychlokurz - Víc než jeden soubor, prosím").font(.presentationSubHeadline)
            }
            HStack {
                ToggleView(toggledOn: $toggle) {
                    VStack {
                        HStack {
                            TextEditorView(model: execCode)
                            TextEditorView(model: exec2Code)
                        }
                        TerminalView(model: terminal, aspectRatio: 0.5, axis: .horizontal).frame(height: 200)
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
