import SwiftUI
import CodeEditor

struct TerminalView: View {
    enum Axis {
        case horizontal, vertical
    }
    
    enum State {
        case idle, loading, result(Result<String?, Error>)
    }
    
    let axis: Axis
    let workingPath: URL
    @Binding var stdIn: String
    @Binding var state: State
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            elements
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, style: StrokeStyle(lineWidth: 1, dash: [3]))
                )
                .padding(6)
            Text("\(workingPath.path)%")
                .background( EffectView(material: .windowBackground))
                .padding(.leading, 16)
                .foregroundColor(.gray)
                .font(.system(.footnote))
        }
    }
    
    @ViewBuilder private var elements: some View {
        HStack {
            VStack(spacing: 4.0) {
                inputView
                if axis == .vertical {
                    buttonView
                }
                resultView
            }
            if axis == .horizontal {
                buttonView
            }
        }
    }
    
    @ViewBuilder private var inputView: some View {
        VStack(spacing: 0) {
            Text("stdin:")
                .foregroundColor(.gray)
                .font(.system(.footnote))
                .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
            CodeEditor(
                source: $stdIn,
                language: .bash,
                indentStyle: .softTab(width: 2)
            )
        }
    }
    
    @ViewBuilder private var resultView: some View {
        ScrollView {
            switch state {
            case .idle, .loading:
                Text("stdout:")
                    .foregroundColor(.gray)
                    .font(.system(.footnote))
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                Text("")
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            case let .result(.success(stdout)):
                Text("stdout:")
                    .foregroundColor(.gray)
                    .font(.system(.footnote))
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                Text(stdout ?? "(Empty)")
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
                
            case let .result(.failure(ProcessError.endedWith(code: code, error: stderr))):
                Text("Status: \(code)  stderr:")
                    .foregroundColor(.gray)
                    .font(.system(.footnote))
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                Text(stderr ?? "(Empty)")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            case let .result(.failure(unknownError)):
                Text("Chyba:")
                    .foregroundColor(.gray)
                    .font(.system(.footnote))
                    .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                Text(unknownError.localizedDescription)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder private var buttonView: some View {
        if case .loading = state {
            ProgressView()
                .frame(width: 50, height: 50)
        } else {
            Button {
                state = .loading
                Task {
                    state = .result(Result {
                        try Process.executeAndWait("zsh", arguments: ["-c", stdIn], workingDir: workingPath)
                    })
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

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView(axis: .horizontal, workingPath: FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0], stdIn: .constant(""), state: .constant(.idle))
    }
}
