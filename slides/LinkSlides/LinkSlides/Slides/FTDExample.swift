import SwiftUI
import CodeEditor

struct FTDExample: View, Slide {    
    static let offset = CGVector(dx: 1, dy: 2)
    static let hint: String? =
    """
    Tady si vyzkoušíme něco nového:
    
     - Compile this
     - *get this*
     - **return this**
     - `typecheck this`
    """

    static let defaultCode =
    """
    public struct FTDExample: View {
      @State var isPushed: Bool = false

      public var body: some View {
        VStack(spacing: 8) {
          Text("Ahoj")
          Button(
            "Zmáčkni mě",
            action: { isPushed.toggle() }
          )
        }.background(
          isPushed ? .green : .red
        )
      }
    }
    """

    init() {}
    
    let workingPath: URL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    @State var stdIn: String = "ls"
    @State var terminalStatus: TerminalView.State = .idle

    @State var buildCommand: String = RuntimeViewProvider.defaultCommand
    @State var code: String = FTDExample.defaultCode
    @State var compilerState: CompilerView.State = .idle

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A teď něco pro zasmání :D")
                .font(.presentationHeadline)
            terminalView
            codeView
        }
        .padding()
    }
    
    @ViewBuilder private var codeView: some View {
        HStack {
            VStack {
                ToggleView {
                    CompilerView(
                        axis: .horizontal,
                        uniqueName: "FTDExample",
                        code: $code,
                        state: $compilerState,
                        buildCommand: $buildCommand
                    )
                }
            }.frame(idealWidth: .infinity)
            ZStack {
                Color.gray.opacity(0.1)
                switch compilerState {
                case .idle:
                    EmptyView()
                case .loading:
                    ProgressView("Kompilace")
                        .preferredColorScheme(.light)
                case let .view(view):
                    view
                case let .exception(ProcessError.endedWith(code: _, error: .some(message))):
                    Text(message)
                        .foregroundColor(.red)
                case let .exception(otherError):
                    Text(otherError.localizedDescription)
                        .foregroundColor(.red)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder private var terminalView: some View {
        ToggleView {
            TerminalView(
                axis: .horizontal,
                workingPath: workingPath,
                aspectRatio: 0.25,
                stdIn: $stdIn,
                state: $terminalStatus
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct FTDExample_Previews: PreviewProvider {
    static var previews: some View {
        FTDExample()
    }
}
