//
//  FTDExample.swift
//  LinkSlides
//
//  Created by Mikoláš Stuchlík on 20.08.2022.
//

import SwiftUI
import CodeEditor

private let defaultCode =
"""
public struct MyView: View {
  @State var isPushed: Bool = false

  public var body: some View {
    VStack(spacing: 8) {
      Text("Ahoj")
      Button("Zmáčkni mě", action: { isPushed.toggle() })
    }.background(
      isPushed ? .green : .red
    )
  }
}
"""

struct FTDExample: View, Slide {
    private final class Model {
        static let shared = Model()
        var runtimeProvider = RuntimeViewProvider(rootViewName: "MyView")
        var code = defaultCode
    }
    
    static let offset = CGVector(dx: 1, dy: 2)

    @Binding var currentLiveView: AnyView?
    @Binding var exception: String?
    @Binding var isLoading: Bool

    var body: some View {
        ZStack {
            Color.white
            VStack(alignment: .leading, spacing: 16) {
                Text("A teď něco pro zasmání :D")
                    .foregroundColor(.black)
                    .font(.system(size: 40))
                    .bold()
                HStack {
                    VStack {
                        CodeEditor(
                            source: Binding(
                                get: { Model.shared.code },
                                set: { Model.shared.code = $0 }
                            ),
                            language: .swift,
                            indentStyle: .softTab(width: 2)
                        )
                        Button("Zkompiluj a spusť!") {
                            isLoading = true
                            currentLiveView = nil
                            exception = nil
                            Task {
                                do {
                                    let newView = try Model.shared.runtimeProvider.compileAndLoad(code: Model.shared.code)
                                    currentLiveView = newView
                                } catch {
                                    exception = "\(error)"
                                }
                                isLoading = false
                            }
                        }
                        .foregroundColor(.black)
                        .background()
                    }.frame(idealWidth: .infinity)
                    ZStack {
                        Color.gray.opacity(0.1)
                        currentLiveView
                        if let exception = exception {
                            Text(exception)
                                .foregroundColor(.red)
                        }
                        if isLoading {
                            ProgressView("Kompilace")
                                .colorInvert()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
    }
}

struct FTDExample_Previews: PreviewProvider {
    static var previews: some View {
        FTDExample(currentLiveView: .constant(nil), exception: .constant(nil), isLoading: .constant(false))
    }
}
