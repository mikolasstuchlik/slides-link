import SwiftUI
import CodeEditor

struct TextEditorView: View {
    enum Axis {
        case horizontal, vertical
    }

    let axis: Axis
    let filePath: String
    @Binding var format: CodeEditor.Language
    @Binding var content: String
    @State var saveError: Bool = false
    @State var loadError: Bool = false
    
    @ViewBuilder var body: some View {
        OutlineView(title: filePath) {
            if axis == .vertical {
                VStack {
                    viewContent
                    HStack(spacing: 32) { controls }
                }
            } else {
                HStack {
                    viewContent
                    VStack(spacing: 32) { controls }
                }
            }
        }
    }
    
    @ViewBuilder private var viewContent: some View {
        editor
    }
    
    @ViewBuilder private var editor: some View {
        if format == .swift {
            CodeEditor(
                source: $content,
                language: format,
                theme: format == .swift
                    ? CodeEditor.ThemeName(rawValue: "xcode")
                    : .default,
                indentStyle: .softTab(width: 2)
            ).colorScheme(.light)
        } else {
            CodeEditor(
                source: $content,
                language: format,
                theme: format == .swift
                    ? CodeEditor.ThemeName(rawValue: "xcode")
                    : .default,
                indentStyle: .softTab(width: 2)
            )
        }
    }
    
    @ViewBuilder private var controls: some View {
        Button {
            do  {
                content = try String(contentsOfFile: filePath)
                loadError = false
            } catch {
                loadError = true
            }
        } label: {
            if loadError {
                Text("Načti").foregroundColor(.red)
            } else {
                Text("Načti")
            }
        }
        Button {
            do {
                try content.write(toFile: filePath, atomically: true, encoding: .utf8)
                saveError = false
            } catch {
                saveError = true
            }
        } label: {
            if saveError {
                Text("Ulož").foregroundColor(.red)
            } else {
                Text("Ulož")
            }
        }
        Menu(format.rawValue) {
            ForEach(CodeEditor.Language.knownCases.indices) { index in
                Button(CodeEditor.Language.knownCases[index].rawValue) {
                    format = CodeEditor.Language.knownCases[index]
                }
            }
        }.frame(width: 100)
    }
    
}

struct TextEditorView_Previews: PreviewProvider {
    static var previews: some View {
        TextEditorView(axis: .horizontal, filePath: "~/nothing.txt", format: .constant(.c), content: .constant("import Nothing\n"))
    }
}
