import SwiftUI

private let timeDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateFormat = .none
    return formatter
}()

@available(macOS 13.0, *)
struct SlideControlPanel: View {

    @EnvironmentObject var presentation: PresentationProperties
    @Environment(\.openWindow) private var openWindow
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var now: Date = Date()
    @State var stateTime: Date?
    
    @State var focusManualEntry: String = ""
    
    @State var screenXManualEntry: String = ""
    @State var screenYManualEntry: String = ""
    
    @State var slideXManualEntry: String = ""
    @State var slideYManualEntry: String = ""
    
    @State var focusesChangeContext: [[String]]
    @State var selectedFocus: Int? = nil

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    dateCounter
                    Spacer()
                    timeCounter
                    runButton
                }
                if presentation.mode != .editor {
                    Spacer()
                        .frame(maxHeight: .infinity)
                }
                Text("Klávesové zkratky").bold().frame(maxWidth: .infinity, alignment: .leading)
                Text(presentation.mode.hotkeyHint.joined(separator: "\n"))
                Text("Ovládání prezentace").bold().frame(maxWidth: .infinity, alignment: .leading)
                presentationControl
            }
            Divider()
            VStack(spacing: 16) {
                Text("Poznámky pro zaostřené").bold().frame(maxWidth: .infinity, alignment: .leading)
                if let hint = presentation.hint {
                    ScrollView { Text(LocalizedStringKey(hint)) }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                } else {
                    Spacer()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }.padding()
    }
    
    private var runButton: some View {
        Button {
            stateTime = Date()
            openWindow(id: "slides")
        } label: {
            Image(systemName: "play.circle.fill")
                .resizable()
                .foregroundStyle(.primary, .secondary, .green)
                .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
        .frame(width: 50, height: 50)
    }
    
    private var dateCounter: some View {
        Text(timeDateFormatter.string(from: now)).onReceive(timer) { _ in
            now = Date()
        }.font(.largeTitle)
    }
    
    @ViewBuilder private var timeCounter: some View {
        if let stateTime {
            Text(
                timeDateFormatter.string(
                    from: Date(timeIntervalSince1970: -stateTime.timeIntervalSinceNow - 3600)
                )
            ).font(.largeTitle)
        } else {
            Text("00:00:00").font(.largeTitle)
        }
    }
    
    @ViewBuilder private var presentationControl: some View {
        VStack {
            Grid {
                GridRow {
                    Text("Režim")
                    Picker(
                        "",
                        selection: .init(
                            get: {
                                presentation.mode.rawValue
                            },
                            set: {
                                presentation.mode = .init(rawValue: $0)!
                            }
                        )
                    ) {
                        Text("Inspekce").tag(0)
                        Text("Prezentace").tag(1)
                        Text("Editor").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .gridCellColumns(2)
                    Button("Reload placeholders") {
                        presentation.loadThumbnails.toggle()
                    }
                }
                if presentation.mode == .entry {
                    controlPanel
                }
                if presentation.mode == .editor {
                    editorCommands
                }
            }
        }
    }
    
    @ViewBuilder var controlPanel: some View {
        GridRow {
            Text("Zaměřený slide:")
            Button("Předchozí") {
                presentation.selectedFocus -= 1
            }
            Button("Následující") {
                presentation.selectedFocus += 1
            }
            HStack {
                TextField("Manuální", text: $focusManualEntry)
                Button("Přejít") {
                    Int(focusManualEntry).flatMap { presentation.selectedFocus = $0 }
                }
            }
        }
        GridRow {
            Text("Pozice kamery")
            Grid {
                GridRow {
                    Text("Scale: \(presentation.camera.scale)")
                    Slider(value: $presentation.camera.scale, in: ClosedRange<CGFloat>(0.1...2))
                }
                GridRow {
                    Text("X")
                    Text("\(presentation.camera.offset.dx)")
                }
                GridRow {
                    Text("Y")
                    Text("\(presentation.camera.offset.dy)")
                }
            }.gridCellColumns(3)
        }
        GridRow {
            Text("Velikost obrazovky")
            Toggle(isOn: $presentation.automaticScreenSize, label: { Text("Automaticky") })
            TextField("X", text: $screenXManualEntry)
                .disabled(presentation.automaticScreenSize)
                .onChange(of: presentation.screenSize) { screenXManualEntry = "\($0.width)" }
            TextField("Y", text: $screenYManualEntry)
                .disabled(presentation.automaticScreenSize)
                .onChange(of: presentation.screenSize) { screenYManualEntry = "\($0.height)" }
        }
        GridRow {
            Spacer()
            Spacer()
            Spacer()
            Button("Použít") {
                if let w = Double(screenXManualEntry), let h = Double(screenYManualEntry) {
                    presentation.screenSize = CGSize(width: CGFloat(w), height: CGFloat(h))
                }
            }
        }
        GridRow {
            Text("Velikost slidu")
            Toggle(isOn: $presentation.automaticFameSize, label: { Text("Automaticky") })
            TextField("X", text: $slideXManualEntry)
                .disabled(presentation.automaticFameSize)
                .onChange(of: presentation.frameSize) { slideXManualEntry = "\($0.width)" }
            TextField("Y", text: $slideYManualEntry)
                .disabled(presentation.automaticFameSize)
                .onChange(of: presentation.frameSize) { slideYManualEntry = "\($0.height)" }
        }
        GridRow {
            Spacer()
            Spacer()
            Spacer()
            Button("Použít") {
                if let w = Double(slideXManualEntry), let h = Double(slideYManualEntry) {
                    presentation.frameSize = CGSize(width: CGFloat(w), height: CGFloat(h))
                }
            }
        }
        GridRow {
            Text("Barevné schéma")
            Spacer()
            Spacer()
            Picker(
                "",
                selection: .init(
                    get: {
                        presentation.colorScheme == .dark ? 0 : 1
                    },
                    set: {
                        presentation.colorScheme = $0 == 0 ? .dark : .light
                    }
                )
            ) {
                Text("Dark").tag(0)
                Text("Light").tag(1)
            }
            .pickerStyle(.segmented)
        }
        GridRow {
            Text("Fonty")
            Grid(alignment: .trailing) {
                GridRow {
                    FontPicker("Titulek", selection: $presentation.title)
                    FontPicker("Napis", selection: $presentation.headline)
                    FontPicker("Tělo", selection: $presentation.body)
                }
                GridRow {
                    FontPicker("Podtitulek", selection: $presentation.subTitle)
                    FontPicker("Podnadpis", selection: $presentation.subHeadline)
                    FontPicker("Poznámka", selection: $presentation.note)
                }
            }.gridCellColumns(3)
        }
    }
    
    @ViewBuilder var editorCommands: some View {
        GridRow {
            Text("Save changes")
            Spacer()
            Button("Save offsets") {
                let editor = EditorCodeManipulator(slidesPath: presentation.slidesPath, knowSlides: presentation.slides)
                print(editor.saveUpdatesToSourceCode())
            }
        }
        GridRow {
            
        }
        GridRow {
            focusEditor
                .gridCellColumns(4)
                .frame(idealHeight: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder var focusEditor: some View {
        List(selection: $selectedFocus) {
            ForEach(presentation.focuses, id: \.hashValue) { focus in
                let index = presentation.focuses.firstIndex(of: focus)!
                HStack() {
                    switch focus {
                    case let .slides(slides):
                        Text(slides.map { $0.name }.joined(separator: " "))
                    case let .properties(properties):
                        Text("X")
                        TextEditor(text: .init(get: { focusesChangeContext[index][0] }, set: { focusesChangeContext[index][0] = $0 }))
                        Text("Y")
                        TextEditor(text: .init(get: { focusesChangeContext[index][1] }, set: { focusesChangeContext[index][1] = $0 }))
                        Text("Scale")
                        TextEditor(text: .init(get: { focusesChangeContext[index][2] }, set: { focusesChangeContext[index][2] = $0 }))
                        Button("Ulož") {
                            var copy = properties
                            let dx = Double(focusesChangeContext[index][0]).flatMap(CGFloat.init(_:))
                            let dy = Double(focusesChangeContext[index][1]).flatMap(CGFloat.init(_:))
                            let scale = Double(focusesChangeContext[index][2]).flatMap(CGFloat.init(_:))
                            copy.offset.dx = dx ?? copy.offset.dx
                            copy.offset.dy = dy ?? copy.offset.dy
                            copy.scale = scale ?? copy.scale
                            presentation.focuses[index] = .properties(copy)
                        }
                    }
                }
            }.onMove { source, destination in
                presentation.focuses.move(fromOffsets: source, toOffset: destination)
                focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: presentation.focuses)
            }.onDelete { toDelete in
                presentation.focuses.remove(atOffsets: toDelete)
                focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: presentation.focuses)
            }
        }
        .onChange(of: presentation.focuses) { newValue in
            focusesChangeContext = SlideControlPanel.makeFocusesChangeContext(with: newValue)
        }
    }
    
    static func makeFocusesChangeContext(with value: [Focus]) -> [[String]] {
        return value.map { item -> [String] in
            switch item {
            case let .properties(properties):
                return ["\(properties.offset.dx)", "\(properties.offset.dy)", "\(properties.scale)"]
            case let .slides(slides):
                return slides.map { $0.name }
            }
        }
    }

}

@available(macOS 13.0, *)
struct SlideControlPanel_Previews: PreviewProvider {
    static var previews: some View {
        SlideControlPanel(focusesChangeContext: [])
    }
}
