import SwiftUI
import CodeEditor

struct CodeView: View {
    private final class Providers {
        private static var providers: [String: RuntimeViewProvider] = [:]
        
        static func provider(for name: String) -> RuntimeViewProvider {
            if let provider = providers[name] {
                return provider
            }
            
            let provider = RuntimeViewProvider(rootViewName: name)
            providers[name] = provider
            return provider
        }
        
        static subscript(_ name: String) -> RuntimeViewProvider {
            return provider(for: name)
        }
        
        private init () {}
    }
    
    enum Axis {
        case horizontal, vertical
    }
    
    enum State {
        case idle, loading, exception(Error), view(AnyView)
    }
    
    let axis: Axis
    let uniqueName: String
    @Binding var code: String
    @Binding var state: State
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if axis == .horizontal {
                    HStack { elements }
                } else {
                    VStack { elements }
                }
            }
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [3]))
            )
            .padding(6)
            Text("SwiftUI View: \(uniqueName)")
                .background(.background)
                .padding(.leading, 16)
                .foregroundColor(.gray)
                .font(.system(.footnote))
        }
    }
    
    @ViewBuilder private var elements: some View {
        CodeEditor(
            source: $code,
            language: .swift,
            theme: CodeEditor.ThemeName(rawValue: "xcode"),
            indentStyle: .softTab(width: 2)
        ).preferredColorScheme(.light)
        if case .loading = state {
            ProgressView()
                .frame(width: 50, height: 50)
        } else {
            Button {
                state = .loading
                Task {
                    do {
                        state = .view(try Providers[uniqueName].compileAndLoad(code: code))
                    } catch {
                        state = .exception(error)
                    }
                }
            } label: {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .foregroundStyle(.primary, .secondary, .green)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
        }
    }
}

struct CodeView_Previews: PreviewProvider {
    static var previews: some View {
        CodeView(axis: .horizontal, uniqueName: "preview", code: .constant(""), state: .constant(.idle))
    }
}
